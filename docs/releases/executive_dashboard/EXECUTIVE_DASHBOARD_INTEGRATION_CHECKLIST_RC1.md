# Executive Dashboard Integration Checklist RC1

Status: **BLOCKED — RC1-01 OPEN**

## Release identity

- [ ] Approved commit recorded.
- [ ] Working tree clean.
- [ ] Audit status is PASSED.
- [ ] SQL and application rollback artifacts captured.
- [ ] No package generated from an unaudited commit.

## SQL Bundle v4

- [ ] Procedure compiles.
- [ ] `contractVersion` is `4.0`.
- [ ] `kpis` is present and valid.
- [ ] `matrix` is present and valid.
- [ ] `distribution` is present and valid.
- [ ] `detail` is present and valid.
- [ ] `punches` is present and contains at most 100 rows.
- [ ] Punch rows match Project and Template.
- [ ] PunchId rows are unique.
- [ ] Legacy compatibility properties remain valid.
- [ ] Response timing is acceptable.

## Dashboard Bundle Flow

- [ ] Connection reference resolves.
- [ ] Flow is enabled and owned correctly.
- [ ] ProjectId and TemplateId inputs are unchanged.
- [ ] Flow calls only the Bundle procedure.
- [ ] Flow returns the SQL `result` string unchanged.
- [ ] Controlled run succeeds.

## Power Apps compilation

- [ ] Home_1 source is from the approved commit.
- [ ] No Studio compilation errors.
- [ ] No unsupported properties.
- [ ] No broken `Select` or `Navigate` references.
- [ ] Exactly one Dashboard Bundle call.
- [ ] No direct `Warroom_Punches_Filtered_Paged` call in Home_1.
- [ ] All five canonical sections are parsed. **BLOCKED in audited endpoint.**

## Functional integration

- [ ] Application opens.
- [ ] Home_1 renders without grey screen.
- [ ] Project selector works.
- [ ] Template selector works.
- [ ] Refresh performs one Bundle load.
- [ ] Five KPI cards reconcile.
- [ ] Heatmap totals reconcile.
- [ ] Donut distribution reconciles.
- [ ] Detail follows Heatmap selection.
- [ ] Grid follows Heatmap selection.
- [ ] Grid sorting cycles ascending/descending/default.
- [ ] Page sizes 25/50/100 work.
- [ ] CSV contains current filtered subset.
- [ ] Single row selection works.
- [ ] Double-click opens Premium Drawer.
- [ ] View/Go navigation preserves filters in Punches_1.
- [ ] Zero, loading and error states remain isolated.

## Regression and performance

- [ ] 11 screens preserved.
- [ ] 27 components preserved.
- [ ] Legacy hidden sections remain recoverable.
- [ ] Punches_1 complete paging remains authoritative.
- [ ] No duplicate backend request on Heatmap interaction.
- [ ] Studio Monitor shows acceptable recalculation and response time.
- [ ] Authentication and connector permissions pass.
- [ ] Product Owner completes UAT.

## Gate decision

- [ ] Product Owner signs controlled integration authorization.
- [ ] Package generation is separately authorized.
- [ ] Deployment is separately authorized.

Current decision: **RELEASE AUDIT FAILED — NOT READY FOR INTEGRATION**.
