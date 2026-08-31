---
name: send-mct-export
description: Run an MCT export against the current state of the production pipeline and send it to someone on Slack
---
# Prerequisites
1. Slack MCP access
2. A user-provided Slack channel name or description of a Slack channel to send a message to
	1. Before the rest of the workflow begins, confirm this fact with the user and decide on a channel identifier
# Steps
1. If the user has not already told you what environment they want to run the export in, such as `local`, `dev`, or `prod`, assume `prod`. This is completely safe to do because it doesn't actually touch any of the loans
2. Run the MCT export workflow `nx run mct-export:pull-latest <environment:prod>`
3. Re-confirm the Slack destination channel to send it in
4. Send the generated CSV file to the channel