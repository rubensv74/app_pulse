# Executive Dashboard Deployment Plan RC1

Status: **BLOCKED BY RC1-01 — DO NOT EXECUTE**

This is a controlled runbook only. It does not authorize deployment.

## Preconditions

- RC1-01 is remediated and the release audit is reissued as passed.
- Exact implementation commit is approved.
- SQL backup/current procedure definition is captured.
- Target environment, connection references and solution identity are confirmed.
- Product Owner schedules an integration window.
- No uncommitted changes exist.

## Required order

### 1. SQL Bundle v4

Source: `sql/dashboard/usp_GetPunchDashboardBundle_v4.sql`.

- verify target tables/views and column compatibility;
- capture current `warroom.usp_GetPunchDashboardBundle`;
- execute the approved v4 procedure script;
- call it with a controlled ProjectId/TemplateId;
- validate JSON, `contractVersion = 4.0`, five canonical sections, compatibility extensions, maximum 100 Punches and response duration;
- stop on any SQL or contract error.

### 2. Dashboard Bundle Flow

The Flow definition is unchanged. It remains a transparent carrier:

- inputs: ProjectId and TemplateId;
- SQL procedure: `[warroom].[usp_GetPunchDashboardBundle]`;
- output: first `Table1.result` as string.

Verify connection reference, ownership, enabled state and a successful controlled run. Do not redesign or add another SQL action.

### 3. Power Apps Home_1

Only after SQL and Flow validation:

- prepare the approved Canvas artifact from the exact audited commit;
- import/update through the controlled solution process;
- compile in Studio;
- confirm no unsupported properties or broken formulas;
- save without publishing until technical validation passes;
- publish only under separate authorization.

### 4. Integrated validation

Execute the RC1 checklist:

- Project and Template selectors;
- one Bundle request;
- five-section parsing;
- KPIs, Heatmap, Donut, Detail and Grid reconciliation;
- paging, sorting, CSV and Drawer;
- navigation to Punches_1 with filters;
- error/empty/loading states;
- performance and regression.

## Stop conditions

Stop immediately for schema mismatch, missing payload section, compilation error, duplicate backend call, broken navigation, connector failure, material count mismatch or unacceptable response time.

No deployment step may begin while this plan remains blocked.
