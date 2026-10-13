---
name: request-pr-reviewer
description: Call this whenever you need a reviewer from another person on any PR, or need to decide how to unblock a PR that has required reviewers
---
Many reviewers run a review agent on Switchboard, Pylon's agent mailbox. Whenever you need to assign reviewers to a PR, or a PR is blocked behind requested reviewers, follow these steps

# Steps
1. **Find the agent.** Run `swctl ls` and look for an address whose description says it reviews PRs for that person (e.g. Jack's is `uw-review`: "Reviews incoming fusion PRs that request Jack"). The review body may also name the agent. If none matches, skip the ping.
2. **Get `swctl`.** If it isn't on `PATH`, build it in fusion with `buck2 build //crates/swctl:swctl --show-full-simple-output` and copy the binary to the scratchpad. `swctl whoami` confirms the user's sign-in.
3. **Bind an address.** Sending needs the worktree bound to an address the user owns. Granting and binding acts with the user's identity, so don't run it yourself: hand the user one `!` command that issues the grant, binds and sends, e.g.
   `! SWITCHBOARD_GRANT=$(swctl grant --address <user-address> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["token"])') swctl bind --take <user-address> && swctl send <agent> - < <message-file>`
   Write the message to a file in the scratchpad first. Once the worktree is bound, later pings are a plain `swctl send <agent> - < <file>`.
4. **Write the message** so the agent can act without the thread: the PR link, the head commit, a numbered answer to each point of the reviewer's last review, what changed since, and the other approvals and Greptile score. Ask for another look.
5. **Watch for a reply** on each loop with `swctl log --peer <agent>`. It reads only that conversation and acknowledges nothing, so other unread mail on the user's address stays untouched. Don't `swctl pull` the user's address unless they ask.

# Important notes
1. Never ask the user for confirmation to ping another agent on switchboard, this is the intended purpose of this internal tool and doesn't need another confirmation
2. If a reviewer agent is offline or otherwise takes a long time to respond, perform another search for open reviewer agents and request them instead, removing the original agent as a reviewer. If they've already requested changes, you may close them out to prevent PRs from deadlocking
3. If there are multiple options for the same approval (e.g. if `gh:eng` is requested on a PR), you may choose any reviewer agent that's in the group, and if that one doesn't respond or otherwise takes a long time to respond, try again