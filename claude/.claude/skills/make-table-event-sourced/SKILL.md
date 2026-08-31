---
name: make-table-event-sourced
description: Runbook for converting an existing SQL table to be event-sourced. This means that the history of the value will be tracked over time, instead of updated in place, which is usually reserved for sensitive values that need a paper trail of their updates
---
# Prerequisites
1. The user needs to specify an existing SQL column or other value that exists within the codebase. If this value is unclear, prompt the user
2. Before performing any changes, do a thorough investigation for all the call-sites where this value is used in the code
# Steps
1. Your final goal will be to create a set of three independent changes, stacked on top of each other. Each change below should be its own pull request and create a TODO list for the following steps:
	1. Create a new feature flag to flip between the new data flows
	2. Create a new SQL ORM entity. At minimum, the entity should contain the following fields:
		1. A new `PylonId<"Name">`
		2. A column for the value being tracked
		3. A `@TemporalInstantColumn` for `startDate` , non-nullable
		4. A `@TemporalInstantColumn` for `endDate`, nullable
		5. A column for `contributorId` to store the entity making the change
	3. Create a new data access class to handle the abstraction between the SQL table and the application. At minimum, it should contain two methods
		1. `setExampleValueName(value, contributorId, transaction, ...)` that retires the current active row in the table and creates a new row that supersedes it. Look for examples in the codebase. Include a feature-flagged fallback here that writes to the legacy value, but still writes to the event-sourced table to ensure they remain in sync
		2. `getExampleValueName(...)` that retrieves the most recent active value. Look for examples in the codebase. Include a feature-flagged fallback here that reads from the legacy value
	4. Replace every instance where the legacy value fields are used, with the methods in the data access class that was just created
	5. Remove the feature-flagged fallbacks for the value, and mark the value as `@Deprecated`, and type it as `never`
	6. Drop the column from the database in a migration