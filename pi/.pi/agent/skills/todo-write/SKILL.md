---
name: todo-write
description: Maintain a structured TODO list to plan, track, and coordinate multi-step tasks — a port of Claude Code's TodoWrite. Use this skill at the start of any task that has more than one logical step, decompose the work into ordered steps, and update statuses as execution proceeds. Invoke when breaking down a complex task, tracking progress across subtasks, or before and after syncing with an external todo manager.
---

# TodoWrite

Maintain a per-task TODO list that is the **canonical record of task status**. Record the plan and its progress here rather than relying on the user or another agent re-telling you what to do next, and rather than prose summaries ("basically done") standing in for real status tracking.

## Data model

Each todo item has three fields, mirroring Claude Code's `TodoWrite`:

- `content` — what needs to be done, stated as a concrete, verifiable outcome; one logical unit of work.
- `status` — exactly one of:
  - `pending` — not started
  - `in_progress` — being worked on right now
  - `completed` — finished and verified
- `activeForm` — the name of the form / skill / documented procedure that governs how to complete this item, or the empty string `""` when none applies. See **Active forms** below.

## Persistence

Store the list in **`.pi/todo.json`** at the project root so it survives navigation and turns. It is the source of truth. Always reload the current file before reporting status, and write it back after every change.

```json
{
  "todos": [
    { "content": "Scaffold the project", "status": "in_progress", "activeForm": "" },
    { "content": "Implement the adapter", "status": "pending", "activeForm": "FORM.md" },
    { "content": "Wire up the integration test", "status": "pending", "activeForm": "" }
  ]
}
```

## When to create and update

- **At the start of a task**: decompose the ask into ordered, logical steps and write them all as `pending`. Do this *before* beginning substantive work.
- **Continuously during execution**: flip an item to `in_progress` the moment you start it, and to `completed` as soon as its outcome is verified. Keep only a handful `in_progress` at once — finish what you start before starting more.
- **Before and after external todo managers**: whenever you sync with Linear, Jira, Asana, Trello, Notion, etc., write TodoWrite state before and after the sync so the file always reflects real status.
- **On completion**: all items are `completed`.

## Rules

- Break work into logical units (~2–5 minutes of effort each), each a step the user can verify. Scope the list to the **current task** — not lifetime project goals.
- Do **not** rewrite or reorder already-completed steps mid-execution unless the user asks. Newly discovered work gets **appended**; only the step you're actively on flips to `in_progress`.
- When the user redefines scope, revise only the remaining `pending` items to match the new plan.
- Use TodoWrite as the **only** in-session record of status — always reflect state in `.pi/todo.json`; don't leave a step marked `pending` while verbally claiming it's finished.

## Active forms

`activeForm` links a todo to an *active form* — a markdown file or skill that specifies how to complete it (for example `FORM.md` for an item governed by a form walkthrough).

Heuristic for assigning it:

- If completing the todo involves a specific form / skill / documented procedure, set `activeForm` to that form's name.
- Otherwise set `activeForm` to `""`.
