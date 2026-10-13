---
name: babysit-pr-stack
description: Skill that defines how to babysit, watch, monitor, or otherwise ensure a set of pull requests get merged. Call this whenever the user requests any of these things
---
## Prerequisites
1. Find all the PRs included in the "current stack". If Graphite is available, you can find this with `gt ls --stack`
2. Make sure all the PRs in the stack are out of the "Draft" status, or get approval using the "Question" tool, asking "This stack contains PRs that are still in the draft status, do you want to move them out?" (yes/no)
3. Make sure the changes have been submitted to GitHub and aren't sitting unmerged in the local tree

# Steps
On a 10 minute loop:
1. Check for CI failures, and make any changes necessary to resolve those CI failures
2. Watch the comments on the PR, and if anyone makes them, make any changes necessary to resolve their concerns and resolve their comments
3. If any user requests changes, once you're done addressing their changes, re-request them for review
4. Make sure Greptile gets a 5/5, otherwise it will require a manual review from the queue. NEVER assume this requires manual review, and ALWAYS go for a 5/5