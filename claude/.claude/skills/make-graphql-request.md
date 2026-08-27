We expose our public API to our customers through GraphQL, so it's extremely valuable to verify features by making a request directly. When the user asks to make an "API request", "real API request", "GQL request", handle them with this skill

We use the `bru` command line tool to make GQL requests, and you'll be able to find a pre-existing set of tracked queries in `./tools/bruno` that can be re-used or modified to make specific requests. If the user asks to make a different kind of API request, create a new `.bru` file in that repository similar to the other requests
# Prerequisites

1. The local API server (`braid-api`) must be running
	1. Verify this by calling the health checks with `curl -s http://localhost:8080/health`
	2. If this doesn't exist, prompt the user if they want to:
		1. Start if themselves with `process-compose up -D`
		2. Want the agent to start it for them
# Steps
1. Look at the other `.bru` files in `./tools/bruno/pylon-api` for requests that are doing something similar, or create a new `.bru` file conforming to the patterns with the existing requests
	1. If the request being made is unclear or there is some ambiguity over what fields to request, prompt the user. Don't assume the request being made as that could give the user a false sense of verification
2. Fill in the request that you created with any sample inputs that the request needs, such as the loan ID, loan amount, property value, etc...
	1. If these values are unclear from the context of the response, never assume them and prompt the user instead
3. Tell the user the full `bru` command you're running and make the request with the `bru` command-line tool. Don't ask for confirmation on whether to run the command