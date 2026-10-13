---
name: ui-craft
description: Build high-craft, polished CC2 screens — the layout/typography/state/status/motion/a11y and real-browser-verification discipline distilled from the read-only Order Outs rebuild. Use when building or polishing a view/card/panel, when a screen "looks bland," when covering all of a screen's states, or before calling any UI change done.
---

# High-craft UI

The bar is a screen that reads as **data, not a form** — figure-on-ground
regions, one hero fact per unit, honest states, and geometry verified in a real
browser. This skill is the distilled playbook from the Order Outs rebuild
(`src/views/products-pricing/order-outs/`).

**North stars — study these first, don't re-derive them:**

- **Amit's evidence viewer** — the "list → focused detail" viewer host:
  `src/views/evidence/EvidenceView.tsx` (collapses nav to maximize reading
  space; drives detail from a focused-record store),
  `src/views/evidence/evidence-bridge.ts` (viewer↔right-sidebar wiring).
- **Amit's underwriting tab** — one unified table of a loan's tasks +
  requirements, row → modal/viewer, quiet accessible table chrome:
  `src/views/readiness/ReadinessView.tsx`,
  `src/views/readiness/ReadinessDataTable.tsx` (the shadcn data-table layout as
  lightweight plain React; status-tone dots),
  `src/views/readiness/FiledTasksPanel.tsx`.
- **shadcn v3** — the design language. The repo points to it by role, not by
  name (`src/pages/docs-page.tsx` links the official docs): data-table = the
  *tasks* example (`ReadinessDataTable`, `ApplicationDataTable`), shell =
  the *dashboard* example (`docs/pylon-design-system.html`), and
  `src/components/button-group-demo.tsx` shows the clone-into-owned-source
  idiom. Compose these primitives; never re-skin `src/components/ui`.

## When to use

Building or polishing any view, card, panel, tray, or table under `src/`; the
human says a screen is "bland" or "so-so"; you need to cover every state of a
screen; or you are about to call a layout/spacing/wrapping change done. For the
correct *composition* of primitives (Card shapes, pinned Table, `as` rules) read
`src/components/AGENTS.md`; for the non-negotiable semantic-HTML/DOM rules read
`src/AGENTS.md`. This skill is the craft layer on top of those.

## Before you build — ground the work, don't jump to code

- **Study the best in-repo exemplar first, then write a short playbook.** The
  strongest results came from reading Amit's evidence viewer + underwriting tab
  and distilling their moves before touching the new screen — not from coding
  straight away. Reuse `docs/screen-redesign-process.md` for the port workflow.
- **"It looks bland" is latitude to redesign, not a pixel tweak.** The Order
  Outs "it looks so so bland… it doesn't need to be what I told you" triggered a
  full rethink into rich dossier rows — treat that feedback as permission to
  change structure.
- **Run a quick adversarial design panel before building.** Sketch 2–3 layouts
  and judge them on craft / data-parity / a11y / buildability. Order Outs
  rejected two-side-by-side-rails and a full-width single-column stack before
  choosing list→right-tray; the ground-up experiment chose an inline dossier.
- **Pick master-detail vs. persistent-inline by item count + interactivity.** A
  right-side **Sheet tray** scales to N rows and 10–30 scrolling docs and keeps
  the list compact; a **persistent inline stack** wins for very few, read-only
  units where hiding one behind a click is pure friction. Order Outs (~2
  read-only items) went inline; the disclosures/Mail/CC1 pattern uses the tray.
- **Make every state viewable before you polish it — you can't craft what you
  can't see.** Gate rich fixtures behind a URL param, live-fetch when absent
  (`?orderOutsStub=1|waived|inprogress|cancelled|notordered`, one-line hook
  override). Add a distinct stub per state and verify EACH — the dev-API loan
  lacked rich data, so this is the only way the full craft is visible.

## Layout, hierarchy & density

- **Figure-on-ground beats hairlines.** Articulate regions with one canvas color
  a step off card + elevation + spacing, not dividing borders ("paper on a grey
  well"). Order Outs cards sit on `bg-muted/20` with `border-border/60` +
  hover-lift, not boxed dividers; the evidence viewer shares one `--bg-canvas`
  and lets only chips/shadows carry contrast.
- **One focal fact per unit — the "hero fact."** Each row/card earns a single
  high-weight number the eye lands on; everything else is muted support.
  Appraisal card → appraised value `text-2xl tabular-nums` right-aligned, `h2`
  name kept clean.
- **"Not bland with few items": pack each row with at-a-glance signal.** A
  2-item screen still reads as intentional when each row carries icon + name +
  status + hero fact + a momentum cue + quiet counts —
  `8 milestones · latest May 16, 2026 · 2 contacts · 2 docs` + a milestone strip
  — a scannable dossier, not a thin line.
- **Don't inflate dead space for symmetry; anchor actions to their content.**
  Equal-height columns top-anchor their content (never stretch); an action lives
  in the header `CardAction` or `CardFooter`, never orphaned mid-card
  (identity → facts → action).
- **Push long/secondary detail behind an affordance.** Filenames, notes, vendor
  refs wrap and wreck a row — move them into a dialog/icon. The underwriting tab
  pulled filenames into a paperclip dialog; Order Outs docs open the shared
  `DocumentPreviewDialog`.
- **Columns are data — drop one that would be all-noise, keyed to the full
  dataset.** A column that's all-empty/all-dash/all-same is removed, memoized
  over ALL rows so layout never shifts as you filter. "A table where every row
  is a dash is noise."

## Typography & numbers

- **Muted-first, 3-step ink scale.** Everything supporting is
  `text-muted-foreground`; reserve `font-semibold`/`text-foreground` for the one
  emphasis per unit. Meta lines, eyebrow headings
  (`text-xs uppercase tracking-wide text-muted-foreground`), and
  `CardDescription` are all muted.
- **`tabular-nums` on every number that aligns or updates — non-negotiable.**
  Money, dates, counts, percentages, zoom%. The underwriting playbook flags this
  as the one thing to always ADD to a money/date tracker.
- **Variable text clamps with a `title` fallback and never resizes layout.**
  Two-line clamp + `overflow-wrap: anywhere`, full text on hover; long values
  truncate beside a fixed control, never shove it (see the copy-button fix under
  Verify).

## Content honesty & states

- **Blank ≠ dash ≠ value.** Not-applicable renders empty; a real-but-unscored
  value renders the value (`100%`), never a placeholder dash. An in-progress
  appraisal shows *no* appraised value at all (the `Fact` component returns
  `null` when absent) — this single discipline is why a screen reads as data.
- **Empty ≠ error; failure is honest and distinct.** Never show a "no data"
  empty state for a load failure (it reads "nothing here" and invites redundant
  re-entry). Partial vs. total failure read differently ("Couldn't load 10" vs.
  "8 of 10 loaded"). Order Outs uses an inline `Alert` + Retry, separate from the
  `EmptyState`.
- **Never fake a number or a progress script.** Narrate real observed backend
  state; fall back to a value you actually have rather than a dash (on a vendor
  detail failure, fall back to the summary's direct-order value so a real value
  never reads as "—").
- **Model mutually-exclusive states as first-class either/or.** An appraisal is
  EITHER ordered OR waived — the waived case is a resolved positive hero (green
  seal, "Appraisal waived — no order needed"), never a sad empty state leaking
  `Program: PROPERTY_INSPECTION_WAIVER` and never a "Place order" affordance.
- **Humanize enums at the boundary; never leak wire values to the UI.**
  `TITLE_COMPANY` → "Title company"; the waiver program mapped via an inline
  Title-Case map in the model — not the copy catalog, and never a vendor name
  (see the MEMORY note on vendor names).
- **Cover the whole state space and make each state demoable.** Audit every
  status (ordered / in-progress / terminal-negative / not-ordered / waived +
  title equivalents + empty contacts/docs); a terminal-negative reads "stopped,"
  not "broken." Gate each behind a stub mode with a spec.

## Status signaling

- **Status = shape + word + color, never color alone.** Back every tone with a
  distinct glyph + a text label from one central resolver + one label catalog.
  "open/not-yet" is a dashed empty outline dot (`border-dashed bg-transparent`),
  not a hue; a distinct failed glyph serves color-blind users; every dot is
  `role="img"` + `aria-label` + `title`; `StatusDot` + `Badge` always paired.

## Motion

- **Microanimations are functional and lawful, each with a reduced-motion
  off-switch.** Two easings, a 100/200/300ms duration law (longer = an
  explicitly-flagged brand exemption); nothing pops (width/opacity ease in AND
  out). Order Outs — tray slide, staggered milestone reveal, row hover-lift,
  chevron rotate on select, copy-button icon swap, section fade-in — all wrapped
  in `motion-safe:` / `motion-reduce:transition-none`; the repo lint enforces the
  fallback.
- **Cap staggered entrances so long lists stay calm.** Cap the per-item delay
  (e.g. at the 10th child) so a 50-row list doesn't cascade for seconds; key the
  container on the active view to replay the entrance on switch.

## Structure, semantics & a11y — the HTML is a deliverable

- **Reconstruct the rendered DOM and justify every surviving `<div>`.** Semantic
  elements over roles: `<ul>/<li>` for lists, `<dl>/<dt>/<dd>` for labeled
  readouts (`<dd>` bold via a font class, never `<strong>`),
  `<article>`/`<section>`/`<header>` for the tray, `Card as="section"`,
  `CardTitle as="h2"`. A single-column list is a `<ul>`, never a single-column
  `<table>`. Enforced by `src/AGENTS.md` + local ESLint rules
  (`card-title-requires-as`, `no-single-column-table`, the `role="button"` ban).
- **The shell owns the single `<h1>`; a section view is a headless fragment.** It
  mints no page heading and no `banner`/`contentinfo` landmark. A `<header>`
  becomes a `banner` unless scoped by a sectioning tag, so a dialog/tray uses
  `<section role="dialog">`, not `<div role="dialog">`.
- **Live regions announce settled values only, mounted-empty, split by
  liveness.** A polite sr-only `role="status"` speaks the settled summary once
  (`<p className="sr-only" role="status">{settledSummary}</p>`); transient
  "Loading…" never enters it (that doubles every utterance); errors are
  `role="alert"`; the skeleton is `aria-hidden` (loading is visual-only). Don't
  add an empty region as box-check theater.
- **Each surface owns its own load/error feedback — no competing panel banner.**
  Contacts and Documents each render their own skeleton/error; the tray doesn't
  stack a second one.
- **Compose primitives; add no frame the design doesn't show.** Use
  `Card`/`Badge`/`Sheet`/`Alert`/`Empty`/`Skeleton` as-is; collapse wrappers
  with `as`; a flush table takes no extra `Card`. Per-type variance goes through
  a strategy registry, not inline ternaries. Hand-build a small list when
  `Item`/`ItemGroup` don't exist rather than inventing chrome; drop redundant
  roles the repo bans (`role="list"` on a `<ul>`).
- **A clickable row's real control is a `<button>`; the row `onClick` is a
  pointer-only widener** that stands down on descendant `a`/`button` clicks and
  on ⌘/Ctrl/Shift/Alt (new-tab / extend-selection stay native). Icon-button row
  actions `stopPropagation`.
- **Charts carry their data for AT and aren't keyboard traps.** `aria-hidden`
  when adjacent text already states the figures, else `role="img"` with the real
  numbers; recharts `accessibilityLayer={false}` unless a real
  keyboard-exploration UX is built.

## Skeletons & scrolling

- **The skeleton is a photograph of the settled layout** — same
  dot/title/value/badge rhythm and the same responsive hiding, so nothing jumps
  when the query lands. A mismatched skeleton is worse than none; delete any
  stand-in that maps to no real element (the underwriting commit deleted a
  9-tile metrics skeleton that matched no section); hold ambiguous summary text
  until its query settles.
- **Scroll, don't paginate**, via a `min-h-0 flex-1 overflow-auto` chain — every
  flex ancestor sets `min-h-0`, the inner panel is the scroller. Order Outs tray
  detail is `min-h-0 flex-1 overflow-y-auto overscroll-contain` so a 10–30 doc
  list scrolls while the close button stays put.

## Verify in a real browser — jsdom can't judge layout

The authoritative procedure is `AGENTS.md` §"UI verification in a real browser
(Playwright)"; the checked-in sweeps are
`scripts/playwright/responsive-sweep.js` and
`.../error-state-sweep.js`. The hard-won craft on top of it:

- **Any change to layout/spacing/wrapping/breakpoints/containers is not done
  until measured in a real browser.** Green typecheck/lint/tests/build are
  necessary but not sufficient — jsdom passes overflowing dialogs and wrapping
  controls.
- **Measure geometry from bounding boxes; don't eyeball "looks fine."** The
  `dana.whitfield@example.com` copy-button-wrap defect was invisible to tests: a
  long email pushed its copy button to the next line. Fix = group each
  value+button, `min-w-0 truncate` on the link + `shrink-0` on the button;
  confirmed by `btnTop≈emailTop` and `btnLeft≥emailRight` at desktop AND 390px,
  not by looking.
- **Stress the width that breaks, not the one that fits.** Desktop hid that bug
  (the email fit); the defect only appears where the value must truncate. Sweep
  just above/below each breakpoint + container flip you introduced, plus the
  side-panel-narrowed desktop column (an open right panel squeezes
  `@container/main` at full viewport — no phone preset catches it).
- **Sweep the error/empty/waived states too, at every breakpoint.** Error-state
  geometry (a control dropping when the alert mounts) is invisible to jsdom; your
  stub modes make each state reachable for the sweep.
- **Emulate sizes with CDP device-metrics, never `browser_resize`.** A
  `browser_resize` pin survives a plain emulation-clear, letterboxes the
  developer's own window, and blocks resizing ("why can't I resize the screen?").
  Clear with `Emulation.clearDeviceMetricsOverride`, and if you ever resized,
  close + reopen the page. (See the MEMORY note on CDP emulation.)
- **Re-verify a blocker before repeating it.** `FORBIDDEN` / `/login` /
  "Application unavailable" are usually org-context flux or an expired session,
  not your code — ask the human to re-auth rather than ship blind or blame the
  change.

## Not covered here — pointers, don't duplicate

- **Demo videos** for the UI-facing PR → the `record-demo` skill.
- **Guardrails / shrink-only baselines / mutation-form wiring** → `CLAUDE.md`
  "Guardrails" + your MEMORY notes; a red guard means fix the root cause, never
  weaken it.
- **Graphite stacking, CI engine rotation, DIRTY-PR-runs-zero-CI, ticketing,
  Greptile-to-5/5** → `CLAUDE.md` + MEMORY. Craft rule that belongs here: run a
  Greptile-grade self-review of the diff *before* the PR is open so it lands at
  5/5, and when a screen goes read-only, remove the dead machinery end-to-end
  (mutation, hooks, flags, specs, guard-baseline entry) rather than leaving it
  to rot.
