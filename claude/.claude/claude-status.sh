#!/usr/bin/env bash
# claude-status — the Claude Code status line for fusion Coder boxes (AGT-1322).
# Reads the statusLine JSON on stdin, emits one ANSI line. Malformed input emits
# nothing and exits 0. Graded by :claude-status-rate-limits.
set -euo pipefail

# `read -d ""` slurps stdin in the shell; no cat. It returns nonzero at EOF
# having set the variable, which is the normal path here.
IFS= read -rd '' input || true

# Month spend is not in the payload; Claude Code caches the server figures here.
usage_config="${CLAUDE_CONFIG_DIR:-${HOME:-}}/.claude.json"
usage_cache='null'
if [ -f "$usage_config" ] && [ "$(wc -c <"$usage_config" 2>/dev/null || echo 0)" -le 4194304 ]; then
  # `input` takes ONE document; a torn config holding two would break --argjson.
  # Two lines from one parse: whether this config carries an OAuth (i.e.
  # subscription) account, and the cache itself.
  # NOT -r: with raw output a string-valued cache prints unquoted, which then
  # fails --argjson and blanks the whole line. -c keeps it valid JSON, and a
  # JSON boolean already prints bare.
  if cfg="$(jq -cn 'input as $c | ($c.oauthAccount != null), ($c.cachedUsageUtilization // null)' "$usage_config" 2>/dev/null)"; then
    { read -r has_oauth; read -r usage_cache; } <<<"$cfg"
  fi
fi
case "$usage_cache" in
'' | *'
'*) usage_cache='null' ;;
esac

# Nothing refreshes that cache on its own, so a month figure only ever appears
# for someone who runs /usage by hand. `claude -p /usage` fetches it with zero
# turns and zero cost (measured), so nudge one when the cache is missing or
# past Claude Code-s own 1h validity -- but only while someone is working, and
# at most once an hour per machine.
#
# The hour-bucketed mkdir IS the whole lock: every concurrent session on the
# box races for the same name, exactly one wins, and a new bucket each hour
# means there is nothing to expire or clean up.
usage_age=-1
transcript=
if probe="$(printf '%s' "$input" | jq -r --argjson u "$usage_cache" '
      [ (if ($u | type) == "object" and ($u.fetchedAtMs | type) == "number"
         then (((now * 1000) - $u.fetchedAtMs) / 1000 | floor) else -1 end),
        (.transcript_path // "") ] | @tsv' 2>/dev/null)"; then
  usage_age="${probe%%	*}"
  transcript="${probe#*	}"
fi
case "$usage_age" in '' | *[!0-9-]*) usage_age=-1 ;; esac

lock_dir="${TMPDIR:-/tmp}"
lock_dir="${lock_dir%/}" # macOS TMPDIR ends in /, which would break the sweep

# No record at all: fetch once regardless of activity. A fresh session has not
# written its transcript yet and a resumed one wrote it long ago, so an activity
# gate here would leave month permanently absent for the sessions that need the
# first fetch most. Staleness still requires activity, so an idle session never
# re-fetches data it already has.
# Only subscription auth has usage to fetch. Everything else (Bedrock, Vertex,
# an API key, a bearer token, an apiKeyHelper, a settings-file env block) never
# populates the cache, so absence would be PERMANENT and the nudge would spawn
# hourly forever -- on a `claude -p /usage` whose zero-turn/zero-cost behaviour
# was only measured under subscription auth. The two tests fail in opposite
# directions and the asymmetry matters: too wide costs one status segment, too
# narrow costs an unmeasured spawn every hour on every box. So require a
# POSITIVE signal -- an oauthAccount in the config -- rather than enumerating
# the modes to exclude, and keep the env checks as a second, cheaper veto for a
# stale oauthAccount left behind on a cloud-provider box.
if [ "${has_oauth:-false}" = true ] \
  && [ -z "${CLAUDE_CODE_USE_BEDROCK:-}" ] \
  && [ -z "${CLAUDE_CODE_USE_VERTEX:-}" ] \
  && [ -z "${ANTHROPIC_API_KEY:-}" ] \
  && [ -z "${ANTHROPIC_AUTH_TOKEN:-}" ] \
  && { [ "$usage_age" -lt 0 ] \
     || { [ "$usage_age" -ge 3600 ] \
          && [ -n "$transcript" ] \
          && [ -n "$(find "$transcript" -mmin -10 2>/dev/null)" ]; }; } \
  && command -v claude >/dev/null 2>&1
then
  # The bucket boundary sits at :37, not :00 -- the hour mark is when every
  # other timer on the box, and most of the internet, already fires. A constant
  # is enough; it must simply not be zero.
  now_s="${EPOCHSECONDS:-$(date +%s)}" # builtin on bash 5+; date only as fallback
  lock="$lock_dir/claude-status-usage.${UID:-0}.$(( (now_s - 37 * 60) / 3600 ))"

  if mkdir "$lock" 2>/dev/null; then
    # Sweep spent buckets on this once-an-hour winning path, not every render.
    # They are empty by construction, so rmdir can take nothing else. Without it
    # a box accrues a directory an hour on the HOME VOLUME -- the templates
    # mount /tmp as a subPath of the home PVC.
    for spent in "$lock_dir"/claude-status-usage."${UID:-0}".*; do
      [ -d "$spent" ] && [ "$spent" != "$lock" ] && rmdir "$spent" 2>/dev/null || true
    done
    # Bounded and stdin-detached: a wedged mint would otherwise leave a stuck
    # process per hour on a long-lived box, and `claude -p` reads non-TTY stdin.
    # timeout is coreutils on the box but absent from a stock macOS, so it is
    # used when present rather than assumed -- assuming it disables the nudge.
    nudge_cmd=(claude -p "/usage" --no-session-persistence)
    command -v timeout >/dev/null 2>&1 && nudge_cmd=(timeout 120 "${nudge_cmd[@]}")
    ( "${nudge_cmd[@]}" </dev/null >/dev/null 2>&1 & )
  fi
fi

# NOTE: this jq program is one single-quoted string — no apostrophes below.
printf '%s' "$input" | jq -j -r --argjson usage "$usage_cache" '
  # Haskell `round` is half-to-even; jq round is not.
  def bankers:
    . as $x
    | ($x | floor) as $f
    | ($x - $f) as $frac
    | if $frac < 0.5 then $f
      elif $frac > 0.5 then $f + 1
      else (if ($f % 2) == 0 then $f else $f + 1 end)
      end;

  def fg($n; $t): "\u001b[38;5;" + ($n|tostring) + "m" + $t + "\u001b[0m";
  def dimt($t): "\u001b[2m" + $t + "\u001b[0m";

  def contextSeg($pct):
    (if $pct >= 75 then 196 elif $pct >= 50 then 220 else 114 end) as $color
    | dimt("context") + " " + fg($color; (($pct | bankers) | tostring) + "%");

  def formatModel($name):
    if   ($name | contains("Opus"))   then fg(141; "Opus")
    elif ($name | contains("Sonnet")) then fg(75;  "Sonnet")
    elif ($name | contains("Haiku"))  then fg(216; "Haiku")
    else fg(255; $name)
    end;

  # Unit from the RAW span, rounded within it: choosing by the rounded value
  # renders 12h01m as "in 1d".
  def resetIn($epoch):
    (($epoch - now) | floor) as $s
    | if   $s <= 0      then "now"
      elif $s >= 86400  then "in " + ((($s / 86400) | bankers) | tostring) + "d"
      elif $s >= 3600
      then (($s / 3600) | bankers) as $h
        | if $h >= 24 then "in 1d" else "in " + ($h | tostring) + "h" end
      else (($s / 60) | bankers) as $m
        | if   $m >= 60 then "in 1h"
          else "in " + (([$m, 1] | max) | tostring) + "m"
          end
      end;

  def rateSeg($label; $w):
    ($w.used_percentage) as $pct
    | (if $pct >= 75 then 196 elif $pct >= 50 then 220 else 114 end) as $color
    | (if $pct >= 90 and ($w.resets_at != null)
       then " " + dimt("(reset " + resetIn($w.resets_at) + ")")
       else "" end) as $reset
    | dimt($label) + " " + fg($color; (($pct | bankers) | tostring) + "%") + $reset;

  def money($d):
    if $d >= 1000
    then (($d / 100) | bankers) as $hundreds
      | ($hundreds / 10) as $k
      | ($k | floor) as $whole
      | ((($k - $whole) * 10) | bankers) as $tenth
      | "$" + ($whole | tostring)
        + (if $tenth == 0 then "" else "." + ($tenth | tostring) end) + "k"
    else "$" + (($d | bankers) | tostring)
    end;

  # A limit is an object or a bare number; only null was observable.
  def monthSeg($s):
    ($s.used.amount_minor / pow(10; ($s.used.exponent // 2))) as $used
    | ($s.limit) as $lim
    | (if   ($lim | type) == "object"
       then ($lim.amount_minor / pow(10; ($lim.exponent // 2)))
       elif ($lim | type) == "number" then $lim
       else null end) as $limit
    | (if $limit != null and $limit > 0 then ($used / $limit) * 100 else null end) as $pct
    | (if   $pct == null then 249
       elif $pct >= 75   then 196
       elif $pct >= 50   then 220
       else                   114 end) as $color
    | dimt("month") + " "
      + fg($color; money($used) + (if $limit != null then "/" + money($limit) else "" end));

  # Joined over the PRESENT windows, so a lone window leaves no dangling sep.
  def usedSeg($rl):
    [ ($rl.five_hour | select(.used_percentage != null) | rateSeg("5h"; .)),
      ($rl.seven_day | select(.used_percentage != null) | rateSeg("7d"; .)) ]
    | select(length > 0)
    | dimt("used") + " " + join(dimt(" · "));

  # The Haskell original emits "$1.0e" in [0.01, 0.10).
  def formatCost($usd):
    if $usd < 0.01 then "0.00"
    else (($usd * 100) | bankers) as $cents
      | ($cents / 100) as $v
      | ($v | floor) as $whole
      | ((($v - $whole) * 100) | bankers) as $fr
      | ($whole | tostring) + "." + (if $fr < 10 then "0" else "" end) + ($fr | tostring)
    end;

  dimt(" │ ") as $sep

  # `try` per segment: jq is one expression, so a reshaped field would abort it
  # and the `|| true` below would blank the WHOLE line.
  | [
      ( .model.display_name             | select(. != null) | formatModel(.) ),
      ( .context_window.used_percentage | select(. != null) | contextSeg(.) ),
      ( try (.rate_limits | select(. != null) | usedSeg(.)) ),
      # The cache must be under a day old, not from the future (this machine
      # writes it, so a future stamp is a clock jump that passes a one-sided
      # check), and from the CURRENT calendar month -- age alone is a proxy: a
      # cache written at 23:50 on the last of the month is under 24h old at
      # 00:10 on the 1st and would show last month as this one. Both zones must
      # agree, since the billing month-s zone is not knowable here and dropping
      # the segment is the safe direction.
      ( try ($usage
        | select(. != null and (.fetchedAtMs | type) == "number"
                 and ((now * 1000) - .fetchedAtMs) >= 0
                 and ((now * 1000) - .fetchedAtMs) < 86400000
                 and (((.fetchedAtMs / 1000) | gmtime)[0:2]) == ((now | gmtime)[0:2])
                 and (((.fetchedAtMs / 1000) | localtime)[0:2]) == ((now | localtime)[0:2]))
        | .utilization.spend
        | select(. != null and .enabled != false
                 and (.used.amount_minor | type) == "number")
        | monthSeg(.)) ),
      ( .cost.total_cost_usd | select(. != null)
        | dimt("session") + " " + fg(249; "$" + formatCost(.)) ),
      ( (.cost.total_lines_added // 0) as $added
        | (.cost.total_lines_removed // 0) as $removed
        | select($added > 0 or $removed > 0)
        | fg(114; "+" + ($added|tostring)) + " " + fg(204; "-" + ($removed|tostring)) )
    ]
  | join($sep)
' 2>/dev/null || true
