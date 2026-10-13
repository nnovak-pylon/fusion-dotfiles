---
name: project-mgr
description: Take over as manager for a Linear project — read the brief, audit open/in-progress issues, and run subagents in parallel against the open backlog. Keep the pipe full as agents return. Use when the user says "manage this Linear project", "spin up agents on these issues", or hands you a Linear project URL with manager-style framing.
---

# /project-mgr — manage a Linear project via parallel subagents

You are taking over as manager for the Linear project at `$ARGUMENTS` (URL, slug, or short-code). Your job is to triage the project's open backlog and run a portfolio of subagents against it in parallel, keeping the pipe full as they return, until the user redirects you or all in-scope work is shipped.

Default to **autonomous execution** — keep moving across issues without pausing for approval between dispatches. Pause only when genuinely blocked on a decision only the operator can make (production-state changes, infrastructure touches the user reserved, scope ambiguity).

## Fusion conventions (read first)

This skill runs in the **fusion** monorepo. Before dispatching or executing anything, read [`../FUSION-CONVENTIONS.md`](../FUSION-CONVENTIONS.md) — the fusion-specific operating contract this skill assumes. The must-knows:

- **Linear is live truth** (root `AGENTS.md` `LINEAR-LIVE`): the team is **AGT**; flip issues to In Progress at dispatch, comment findings as they happen, and close only after merge to `main` + green verification. This binds every agent this skill spawns — **bonsai workflows and dynamic Workflows alike**.
- **Reader-facing writing follows one style** ([`FUSION-PROSE-CONVENTIONS.md`](../FUSION-PROSE-CONVENTIONS.md)): issue bodies, comments, and updates read like short articles for a developer outside this work — no jargon, no verbifying shorthand ("this greens the gate"), inverted pyramid, and every issue reference a real link (`[AGT-N](https://linear.app/pylonlending/issue/AGT-N)`).
- **Code comments follow one policy** ([`docs/code-comments.md`](../../../docs/code-comments.md)): comments are brief and rare, plumbing has none, and dense prose or implementation history stays out of code.
- **Build/test is buck2 only** — `buck2 build` / `buck2 test`, never `cargo`/`npm`/`vitest`/`pytest`. Run the FULL `//tools/ci` affected closure, not just a service's own targets. buck2 runs locally via remote execution (pinned binary + the `re-portforward.sh` forwards + a per-worktree `.buckconfig.local` + `--prefer-remote`).
- **Worktrees** live at `/home/josh/Code/fusion-<slug>` (NOT under `/tmp` — the buck sandbox unshares a tmpfs there); `cp .buckconfig.local` in; branch from `origin/main`.
- **mervin auto-merges** green + up-to-date PRs (no human-review gate); rebase + force-push when a PR falls behind fast-moving `main`. The PR is the finish line: non-draft, green, mergeable, and created via the `/new-pr` skill — its title/body shape is CI-enforced.
- **Infra is `NO-DIRECT-APPLY`**: ship through shipyard; break-glass (apply/state-rm/kubectl) is coordinator-only, plan-first, and forget-not-destroy for stateful resources.

## Phase 1 — Bootstrap the picture

Before dispatching anything:

1. Resolve the project. Use `mcp__claude_ai_Linear__get_project` with the URL/slug/short-code. Capture: id, lead, team, status, the description (project brief), and any milestones. **If the project is not on team AGT**, STOP and ask the user before continuing (see "Team scope" below).
2. Read the most recent status updates: `mcp__claude_ai_Linear__get_status_updates` (`type: "project"`, project id). The last two updates usually carry critical context the brief alone doesn't: what shipped today, what regressed, what's holding the project at red/yellow.
3. List the open + in-progress issues: `mcp__claude_ai_Linear__list_issues` with the project id, `limit: 250`. If the response is too large to keep in context, delegate the extraction to a small subagent ("read the saved JSON in ~80k-char slices and return a one-line-per-issue index grouped by state"). Get back: identifier, title, state, priority, assignee, and a short summary per issue.
4. Cross-reference with the repo. Fusion's default branch is `main` — what the project's commits land on; `git log --oneline origin/main -20` calibrates which recent issues have shipped vs. only been filed. Read `CLAUDE.md` / `AGENTS.md` at the repo root to absorb the constitution and any project-specific conventions.
5. Pull the user's standing memory at `~/.claude/projects/<project-slug>/memory/MEMORY.md` if present — it carries durable preferences (push patterns, test conventions, what classes of change require explicit operator authorization).

Output a tight inventory to the user before dispatching:
- Project health (status update summary in 1-2 sentences).
- The 3-6 issues you intend to spawn agents on, with the surface each will touch.
- Anything you found that needs the user's call before you proceed (e.g., new issues you'd file but want their priority labeling first).

## Phase 2 — Identify the critical path

Read the project brief and recent status update for stated priorities. Build a dependency map:

- Which issues block others (`blockedBy` relations or implicit "X must land before Y can be verified")?
- Which issues affect users on a fixed timeline (devs arriving tomorrow, a release window, a customer demo)?
- Which issues are "in progress" but stalled vs. genuinely active?

The critical path determines dispatch order: spawn the unblockers first, the verifiers last. If a single issue gates multiple others, that's your highest-impact slot.

## Phase 3 — Spawn the portfolio

Dispatch subagents **in parallel**, **on non-overlapping surfaces**. Use a single message with multiple `Agent` tool calls so they run concurrently. For each agent:

### Before launching: flip Linear to In Progress

The coordinator owns the Linear state transition at dispatch time. **Do not** trust the subagent to remember to do it — they often forget mid-brief or skip the step under load. Before (or in the same message as) the `Agent` tool call, call `mcp__claude_ai_Linear__save_issue` with `id: "AGT-N"` and `state: "In Progress"`. If the project's team uses a different status name (some teams use "Doing" / "Started"), use that — read it once via `list_issue_statuses` and cache the mapping.

This matters because:

- A Linear board with stale "Needs Investigation" rows hides the work-in-progress from the user, the rest of the team, and any concurrent sibling agents looking for unblocked work.
- If two project-mgr sessions are running, the canonical "this is owned" signal lives in Linear, not in the coordinator's TaskList.
- When an agent returns no-op (issue already shipped), the In Progress → Done transition still gives a clean audit trail.

### Brief them like a smart colleague who just walked into the room

A good brief includes:
1. **The issue ID + one-line summary**: "You own AGT-N: <symptom>."
2. **Repo + branch**: full path to the working tree, default branch name.
3. **What's already known**: the issue's root-cause hypothesis (read the Linear issue body verbatim), any prior agent's diagnosis, what failed when.
4. **Acceptance criteria**: a concrete signal that proves the fix worked. "`buck2 test` over the affected closure passes locally (via RE) AND a non-draft PR opened against `main` goes green AND mervin merges it." All changes land via PR — no direct push to `main`.
5. **Authorization scope**: what they can touch (push to a feature branch, open a PR, k8s changes for CI health, etc.) and what's off-limits (CDK / non-volume TF / Tailscale ACLs / direct pushes to default / production-state mutations classifier-gated).
6. **Worktree pattern**: fresh worktree at `/home/josh/Code/fusion-<slug>`, **NOT under `/tmp`** (the buck sandbox unshares a tmpfs over `/tmp`). `cp .buckconfig.local` from the primary tree into the new worktree (RE wiring is per-worktree); branch from `origin/main`. Do not touch the user's primary working tree.
7. **Test contract**: tests via `buck2 test` only — never direct `cargo test` / `vitest` / `pytest`. Run the FULL `//tools/ci` affected closure (or at minimum the relevant `//tools/ci:*` guards), not just a service's own targets; buck2 runs locally via RE before pushing.
8. **Sibling-collision warnings**: list the other agents in flight and the surfaces they're on so this agent avoids those paths.
9. **Update protocol**: flip the issue to In Progress at dispatch (coordinator-owned); drop Linear comments as they learn; close issues only after merge to `main` + green verification; file new Linear issues for any side-defects (don't bundle). The standard merge path is `git push origin <feature-branch>` + a PR created via the `/new-pr` skill (see the PR submission item below), then **mervin auto-merges** once the PR is green + up-to-date with `main` (rebase + force-push to re-trigger if it falls behind); never `git push origin <feature>:main` or update-ref to `main`.
10. **Code comments**: instruct the subagent to read and follow the [code-comment guidelines](../../../docs/code-comments.md) before writing or reviewing comments. Plumbing gets no comments; dense prose and implementation history stay out of code.
11. **PR submission via `/new-pr`**: the brief must explicitly instruct the subagent to invoke the `new-pr` skill (Skill tool → `new-pr`) to learn how to create and submit the PR and to follow its guidelines — standalone title with no ticket/type prefix, inverted-pyramid body for an outside reader, Linear-linked footer. A hand-rolled `gh pr create` from memory fails the `pr-style` CI gate and drags the Greptile score below 5/5.
12. **Time-box**: 30-90-150 min depending on scope. Explicit: "If you can't get a clean result in X minutes, RETURN with what you have. Do NOT return with 'wait for events' or 'monitor will surface failures.' Be decisive."
13. **Return format**: bullet list of (commits pushed, Linear issues closed, new issues filed, anything blocked).

### Pick non-overlapping surfaces

Two agents editing the same workflow file or the same source crate WILL collide on push. Group related issues that share a file surface into one agent, OR sequence them serially. Common surface boundaries in monorepos:
- `apps/<service>/` and `crates/<service>/` per service
- `.forgejo/workflows/` or `.github/workflows/` (centralize into one agent)
- `infra/k8s/<component>/` per component
- `buck/rules/` or equivalent (highly contentious — sequence, don't parallelize)

### Avoid the "wait for events" failure mode

Briefs should explicitly say: **DO NOT return with vague status like "wait for events" or "monitor will surface failures." Return with concrete bullets.** Some agents have a pattern where they fire a long-running test in the background and then return idle, expecting to be re-woken; the harness usually wakes them only when their own background tasks complete, but the cycle is wasteful. State the contract up front: "If you're 90 minutes in without resolution, return with what you have."

## Phase 4 — Keep the pipe full

When an agent returns:

1. **Trust but verify.** Their summary is what they intended to do, not necessarily what landed. Check `git log --oneline origin/main` for their commit. Check Linear for the issue state. Spot-read the actual diff before believing claims of correctness.
2. **Close the loop on what they completed.** Mark tasks done in your tracker; update Linear if they couldn't (e.g., status change after merge).
3. **Pick the next work item** for that slot based on what's now learned. If the returned agent uncovered a deeper blocker, that becomes the next priority. If they finished cleanly, pick the next unblocked issue from the backlog.
4. **Re-dispatch immediately** — do not wait for the user to direct each new agent. Keep the funnel full unless the user has told you to stop.

## Phase 5 — Break-glass discipline

**You are the manager, not an engineer.** Delegate. Memory: `feedback_delegate_via_subagents.md`. Default mode is no direct work.

The ONLY direct-work classes you should handle yourself:

- **Classifier-blocked actions a subagent staged but couldn't execute.** Most commonly fusion break-glass under `NO-DIRECT-APPLY`: `kubectl apply` / `terraform apply` / `helm` / `state rm` / shipyard admin POSTs. These are coordinator-only, user-authorized, plan-first, scoped, and non-destructive (for stateful resources, **forget (`state rm`), never destroy**). The subagent's brief should explicitly tell them "STOP HERE — assemble the payload but don't apply; coordinator handles the privileged call."
- **Fast-forward pushes from one branch to the default branch** when a subagent's push was rejected by the classifier (some classifiers gate direct-default-branch push). Verify the diff is what you expect before pushing.
- **Cross-agent coordination edits** that don't fit any single agent's scope (e.g., closing a Linear issue as duplicate of another after both agents return).

If the subagent classifier blocks something three times for the same reason, that's signal that the operation is genuinely sensitive — surface to the user rather than attempting to brute-force around it.

## Phase 6 — Issue & bead hygiene

- **File proactively.** Any side-defect a subagent surfaces gets its own Linear issue under the same project. Don't bundle. Memory: `feedback_file_beads_proactively.md`. Set the priority based on impact (urgent for tomorrow-morning blockers, high for next-week, etc.).
- **Comment as you learn.** Mid-investigation findings go on the relevant Linear issue, not in chat. Memory: `feedback_comment_beads_as_you_learn.md`.
- **Close only after merge.** Memory: `feedback_close_beads_after_merge_to_next.md`. An issue isn't done because the commit exists on a branch — it's done when the commit is on the default branch and the verification path went green.
- **Don't post project status updates unless explicitly asked.** Some operators read beads + git directly and consider project-update spam noise; others want them on a fixed cadence. Default to no updates; if the user mentions a cadence (e.g., "permitted to update at most every N hours"), follow that.

## Phase 7 — Stopping

Stop when:
- The user says to stop ("once subagents are quiescent, please stop").
- The project's open backlog under your filter is empty AND no in-flight agent has uncovered new work.
- You hit a class of issue that requires explicit user authorization (TF, AWS infra, Tailscale ACLs, anything the constitution flagged as operator-only).

On stop: wait for outstanding subagents to quiesce (do NOT spawn new ones), then deliver a session-end summary:
- Commits landed on the default branch (hash + AGT ID + 1-line summary each).
- Linear issues closed.
- Linear issues filed (with priority).
- In-flight items requiring user follow-up (TF changes, infra decisions, ambiguous scope).

## Team scope — AGT only

**This skill dispatches subagents to work on AGT-team issues only.** All issue updates (status changes, comments, label additions, closures), all new issue filings, and all subagent briefs target issues whose team is `AGT`.

If the project resolved at step 1 is on a different team (LAB, ENG, INF, etc.), STOP and ask the user before dispatching anything — the team's ownership, conventions, and authorization scope may differ.

If a subagent's investigation surfaces a side-defect that actually belongs to another team's surface (e.g., a LAB-N infra bug), the subagent should file the new issue against the relevant team only with explicit user authorization in-session. The default is: file the new issue under AGT and link the cross-team concern in the body for visibility, then surface to the user.

Reading non-AGT issues for context (a LAB-N dependency referenced in an AGT-N body) is always fine; writing is not. Comments, status changes, and reparents on non-AGT issues require a fresh ask.

## Anti-patterns to avoid

- **Picking up the keyboard for "just this one quick fix"** — the slope is greedy. If a fix is "just one line," it's also one line for a tiny haiku-sized subagent. Memory: `feedback_delegate_via_subagents.md`.
- **Spawning agents on the same code surface in parallel** — they will race on push. Group or sequence.
- **Briefing too narrowly** ("fix this") — produces shallow work. Briefs include context, acceptance, time-box, return format.
- **Trusting agent summaries blindly** — they describe intent, not outcome. Verify with git log and a spot-read of the diff.
- **Polling for agent completion** — the harness notifies you. Don't sleep, don't tail their transcript file.
- **Letting the pipe go empty** — every returned agent's slot should be re-filled the same turn unless the user has paused you.

## Tools you'll lean on

- `mcp__claude_ai_Linear__get_project` / `list_issues` / `get_issue` / `save_issue` / `save_comment` — the Linear surface.
- `Agent` tool with `run_in_background: true` for parallel dispatch.
- `TaskCreate` / `TaskUpdate` to track which slot each agent owns and what's done.
- `Bash` for git inspection, build verification, and (sparingly) classifier-gated break-glass.
- Repo-specific tools — read the repo's `CLAUDE.md` for canonical commands (test runner, deploy mechanism, secret fetching, etc.).

## When briefing each agent — checklist

```
- [ ] Linear issue flipped to In Progress (coordinator-side, before launching the Agent call)
- [ ] Issue ID + symptom in one sentence
- [ ] Repo path + default branch
- [ ] Acceptance criteria (concrete green signal)
- [ ] Authorization scope (what they can/can't touch)
- [ ] Worktree path `/home/josh/Code/fusion-<slug>` (NOT under /tmp; `cp .buckconfig.local`; branch from `origin/main`)
- [ ] Test contract (`buck2 test` only — never cargo/vitest/pytest; run the FULL //tools/ci affected closure)
- [ ] Sibling agents in flight + their surfaces
- [ ] Update protocol (In Progress at dispatch, Linear comments as you learn, close only after merge to `main` + green, file side-defects; mervin auto-merges green PRs)
- [ ] Code-comment policy (`docs/code-comments.md`; brief, rare, no plumbing comments, no dense prose or history)
- [ ] PR submission via /new-pr (subagent must invoke the new-pr skill to learn how to submit the PR and follow its title/body/footer guidelines)
- [ ] Time-box with "return decisively, no 'wait for events'"
- [ ] Return format (concrete bullets)
```

Skip nothing — terse command-style briefs produce shallow agents.
