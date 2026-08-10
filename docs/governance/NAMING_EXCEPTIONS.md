# PULSE Naming Exceptions

**Status:** normative  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

This register documents names that do not match the preferred repository naming style but must remain unchanged because they are live Power Apps identities or active runtime dependencies.

The governing rule is:

> Do not perform cosmetic renames when the name itself may be part of a Power Apps Source Code or screen/component contract.

## Current exceptions

| Identity/path | Reason | Current action | Exit condition |
|---|---|---|---|
| `main/screens/Punches/scr_Punches_1.pa.yaml` / `scr_Punches` | Canonical Punch List source retains a legacy filename suffix. Renaming the source/identity is not required for repository clarity and may create unnecessary Power Apps migration risk. | Keep as-is; document as canonical in repository indexes. | Rename only as part of an explicit Punches screen migration with Studio validation. |
| `main/components/cmp_DetailDrawer_old.pa.yaml` / `cmp_DetailDrawer_old` | Despite `_old`, this Canvas component is still instantiated by canonical `scr_Punches` as `comp_DetailDrawer_6`. | Keep in `main/components/` as `LEGACY_SUPPORTED`; never select by default for new work. | Replace the drawer in Punches, validate the replacement in Studio, then archive/remove the old component. |

## Rules for future exceptions

1. A filename suffix does not override actual runtime usage.
2. Add an exception here when a safer repository name would require changing a live Power Apps identity or contract.
3. Prefer documenting the exception over a cosmetic runtime rename.
4. Remove an exception only after the dependency has been migrated and validated.
5. New components and screens should follow current naming rules so this register does not grow through new debt.
