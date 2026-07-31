# EPIC 01 — Home_1 Punch Dashboard

Status: **IMPLEMENTED — VALIDATION PENDING**

## Scope delivered

- Added explicit category (Y) and status (X) labels to the Punch Heat Map.
- Added persistent visual feedback for the selected category/status cell.
- Replaced the cell's immediate legacy-screen navigation with an in-place drilldown.
- Added a matching punch-detail list sourced from `Warroom_Punches_Filtered_Paged`.
- Added loading, empty, and error states.
- Added controlled server paging with a fixed limit of 25 rows and Previous/Next controls.
- Preserved all screens, components, flows, SQL objects, and existing navigation contracts.

## Confirmed data contract

The dashboard bundle supplies `CategoryCode`, `CategoryName`, `CategoryOrder`, `StatusCode`, `StatusName`, `StatusOrder`, `PunchCount`, `Intensity`, and `IntensityBand`. The detail loader uses the existing paged-flow signature: ProjectId, Subsystem, Discipline, Subcontractor, PageNumber, PageSize, TemplateId, CategoryCode, StatusCode, CustomFiltersJson. No columns or parameters were guessed.

## Static validation

- `git diff --check`: pass.
- Control-name uniqueness for new controls: pass.
- Drilldown filter mapping and fixed page-size inspection: pass.
- No deletion or rename of screens, components, flows, or SQL: pass.
- No changes to `scr_Punches_1` or global navigation: pass.

## Runtime validation still required

Power Apps Studio / maker runtime is not available in this workspace. Before EPIC 01 can be marked technically closed, open the app in Studio and verify: formula compilation, responsive heat-map headers, selected-cell highlight, matching detail counts, Previous/Next boundaries, empty response, and simulated flow error. EPIC 02 must not start until these checks pass.

## Changed files and rollback

- `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml`
- `docs/workstreams/home_1/EPIC_01_VALIDATION_REPORT.md`

Rollback is limited to reverting the EPIC 01 commit (or these two files) before any later phase begins.
