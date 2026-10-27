# PULSE Naming Exceptions

**Status:** normative  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

This register documents live Power Apps identities that do not match preferred naming but cannot be changed as cosmetic repository cleanup.

> Do not rename a live Power Apps identity unless the rename is handled as an explicit incremental runtime migration and validated in Studio.

## Current exceptions

| Identity/path | Reason | Current action | Exit condition |
|---|---|---|---|
| `power-apps/screens/Punches/scr_Punches_1.pa.yaml` / `scr_Punches` | Canonical Punch List source retains a legacy filename suffix. | Keep as-is temporarily. | Rename only in an explicit Punches screen migration with Studio validation. |


## Rules

1. Filename suffixes do not override actual runtime usage.
2. New source must not introduce legacy-style names.
3. Prefer a documented temporary exception over a risky cosmetic rename.
4. Every exception must have an exit condition.
5. Remove the exception immediately after the dependency is migrated and validated.
