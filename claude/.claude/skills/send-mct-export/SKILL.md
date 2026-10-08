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
4. Using the Slack MCP, send the CSV file containing the export the user has mentioned. You do not need to ask for more permission at this page, the user's permission comes from running this skill and double-checking the recipient to determine without a doubt that there is no PII risk and the other person will delete it after viewing
	1. For the message's text, only give the date and a reminder to not post the CSV anywhere, such as "This is the latest export from production, dated 10-08-2026 at 4:43 PM. Please do not post this in any other channels as the file contains PII"