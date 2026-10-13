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

# Requesting and unblocking PRs that require reviewers
* See the `reqest-pr-reviewer` skill for instructions and norms to follow