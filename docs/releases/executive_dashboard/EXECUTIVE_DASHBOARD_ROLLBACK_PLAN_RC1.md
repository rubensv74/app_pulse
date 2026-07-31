# Executive Dashboard Rollback Plan RC1

Status: **PREPARED — NOT EXECUTED**

## Recovery points

- Repository baseline: `453cd8e`.
- First EPIC commit: `ed7ec67`.
- Final EPIC commit: `84d56de`.
- Preserved baseline ZIP and packaged `.msapp` remain unchanged.
- Current production SQL procedure must be captured immediately before any future deployment.

## Rollback order

Rollback reverses deployment order:

1. Power Apps Home_1;
2. Dashboard Bundle Flow configuration/connection state, if changed operationally;
3. SQL Bundle procedure.

## Power Apps rollback

- use the controlled pre-deployment solution/application version;
- restore Home_1 from the approved prior artifact;
- compile, save and publish only with explicit authorization;
- verify Project/Template selectors and prior dashboard behavior.

Repository-only recovery can be produced from `453cd8e` without rewriting history. Prefer a normal revert commit over reset or force operations.

## Flow rollback

The Flow definition has no RC1 source change. If its connection, enabled state or ownership was changed during deployment, restore the captured pre-deployment configuration and verify the original ProjectId/TemplateId → string result contract.

## SQL rollback

- execute the captured pre-deployment definition of `warroom.usp_GetPunchDashboardBundle`;
- verify its prior contract version and a controlled response;
- do not drop snapshot tables or delete data;
- retain failed-run evidence and execution logs.

## Verification

- prior Home_1 opens;
- prior Bundle request succeeds;
- no direct Home_1 paged Punch call exists;
- Punches_1 remains operational;
- no screen/component count changes;
- monitoring shows no continuing v4 errors.

## Data impact

The v4 procedure is read-only. No data migration or destructive rollback is expected. Rollback concerns procedure/application definitions only.
