---
name: babysit-pr-stack
description: Skill that defines how to babysit, watch, monitor, or otherwise ensure a set of pull requests get merged. Call this whenever the user requests a set of changes to be merged
---
## Prerequisites
1. Make sure all the requested changes have been turned into a pull request on GitHub (check with the `gh` tool), and no local changes are setting untracked in the local tree
2. Use the TODO-list skill to create a list of PRs to be merged. Refer to this set of PRs as the "stack" to be merged
3. Make sure every PR in the stack is in the "Draft" status. If there are any PRs not in the draft status, move them back to drafts and notify the user. You should never require approval for this step

# Steps
On a 10 minute loop:
1. Check for CI failures, and make any changes necessary to resolve those CI failures
2. Watch the comments on the PR, and if anyone makes them, make any changes necessary to resolve their concerns and resolve their comments
3. If any user requests changes, once you're done addressing their changes, re-request them for review
4. Make sure Greptile gets a 5/5, otherwise it will require a manual review from the queue. NEVER assume this requires manual review, and ALWAYS go for a 5/52. Watch the Greptile status on the PR and make any changes necessary to get it to a 5/5, otherwise it will require a manual review. NEVER assume a PR on its own requires manual review, and ALWAYS go for a 5/5
3. Watch the comments and reviewers on the PR, and if anyone makes a suggestion or otherwise has a blocking comment, make any changes necessary to resolve their concerns and resolve their comments
	1. Once you're done addressing their changes, re-request them for review, and ping their review agent on Switchboard (below)

## Finishing the Change
Once a PR has passed all of its checks (CI passes, Mervin shows approvals from all parties, and Greptile shows a 5/5), the PR is ready to merge. Move all the PRs in the stack off out of the draft status and set a 10 minute loop to wait for the PRs to merge. You should NEVER require approval for this step because it's the intended behavior of this skill

Once a PR has been merged to main, remove it from the TODO list and continue with the rest of the stack. A failure at this step should move the PR back to the set of steps in the "steps" section

# Pinging reviewers on Switchboard
Many reviewers run a review agent on Switchboard, Pylon's agent mailbox. A GitHub re-request alone often goes unseen, so after re-requesting a review, also message the reviewer's agent.

1. **Find the agent.** Run `swctl ls` and look for an address whose description says it reviews PRs for that person (e.g. Jack's is `uw-review`: "Reviews incoming fusion PRs that request Jack"). The review body may also name the agent. If none matches, skip the ping.
2. **Get `swctl`.** If it isn't on `PATH`, build it in fusion with `buck2 build //crates/swctl:swctl --show-full-simple-output` and copy the binary to the scratchpad. `swctl whoami` confirms the user's sign-in.
3. **Bind an address.** Sending needs the worktree bound to an address the user owns. Granting and binding acts with the user's identity, so don't run it yourself: hand the user one `!` command that issues the grant, binds and sends, e.g.
   `! SWITCHBOARD_GRANT=$(swctl grant --address <user-address> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["token"])') swctl bind --take <user-address> && swctl send <agent> - < <message-file>`
   Write the message to a file in the scratchpad first. Once the worktree is bound, later pings are a plain `swctl send <agent> - < <file>`.
4. **Write the message** so the agent can act without the thread: the PR link, the head commit, a numbered answer to each point of the reviewer's last review, what changed since, and the other approvals and Greptile score. Ask for another look.
5. **Watch for a reply** on each loop with `swctl log --peer <agent>`. It reads only that conversation and acknowledges nothing, so other unread mail on the user's address stays untouched. Don't `swctl pull` the user's address unless they ask.

Ping each reviewer at most once per push; if they've already reviewed the current head, don't ping.