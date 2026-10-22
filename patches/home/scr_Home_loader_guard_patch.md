# Patch candidate — scr_Home loader guards

Source: Studio export `upload/Pasted text(20261022-124452).txt` (2026-10-22).

## Apply in Power Apps Studio

For each control below, replace only its `OnSelect` formula with the matching `.fx.txt` contents (including the leading `=`). Existing successful-load logic, flow calls, parameter order, parsing, error handling, and final loading-state cleanup are retained.

- `btnHome_LoadPunchDashboard_1.OnSelect.fx.txt`
- `btnHome_LoadPendingSubsystems_2.OnSelect.fx.txt`
- `btnHome_LoadHive_2.OnSelect.fx.txt`

## Changes

- Removes active `Exit()` calls from load guards.
- Places request bodies under valid-context and idle-state branches.
- Moves Punch refresh-request consumption and Hive global loading setup inside the branch that starts a request.
- Ensures the Hive flow cannot run with a blank project ID.

## Validation

Static check: the three formulas have balanced parentheses and no remaining `Exit()` calls. Power Fx compilation and Studio/runtime behavior have not been run. This is a targeted safety patch, not the broader screen efficiency refactor. That refactor follows after the table/flow pagination, sorting and action contracts are reconciled.
