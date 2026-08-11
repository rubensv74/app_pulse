# cmp_CustomFieldsEditorPro — Current Working Baseline

## Status

Baseline supplied and visually validated by the user in Power Apps Studio on 2026-08-11.

The component can be inserted as instances without Studio errors. From this point forward this current full component is the implementation baseline for all remaining corrections and DF work. Older incremental DF replacement artifacts are historical inputs only and must not be used as the starting source for new fixes.

## Mandatory construction playbook

Before generating any new `.pa.yaml` for this component or its host screens, consult the current version of:

`30-playbooks/power-platform/modular-power-apps-screen-construction.md`

in `rubensv74/functional-engineering-knowledge-base`.

Its rules are mandatory for remaining work:

- Power Apps Studio is the primary implementation and validation environment;
- use skeleton/placeholders before filling new structural zones;
- freeze approved geometry and avoid incidental layout changes;
- classify every new block as `S — Structural`, `C — Component` or `I — Integration`;
- one dominant purpose per block;
- declare target, operation, dependencies, scope, out-of-scope controls and validation before YAML;
- repair a delivered increment with an isolated `FIX` block instead of silently modifying later blocks;
- treat approved parts as frozen;
- separate structure, behavior and color;
- use shared semantic color roles/tokens and validate uncertain color/rendering in an isolated Design System Lab before propagation.

This playbook is used together with the current PULSE Source Code compatibility register. Both gates must be consulted immediately before any new YAML delivery.

## Source of truth

User-supplied full `ComponentDefinitions > cmp_CustomFieldsEditorPro` source from the 2026-08-11 working Studio instance.

The current contract includes the established inputs/outputs/events, the project definition catalog, local definition draft state, Choice/MultiChoice line-based option editing, and the dynamic preview.

## Important structural finding

The current working source also exposes the visual defect visible in the supplied screenshot: the refined editor introduced during DF-04B exists as `conCFDEPro_Editor_1` nested inside the previous `conCFDEPro_Editor > conCFDEPro_Form`, while the older editor controls remain present. This produces the second editor panel rendered on top of/inside the original center editor.

The same duplication pattern exists for the corresponding editor-empty state.

This is not an architecture change and does not require changing the component contract. The next cleanup must consolidate the center workspace so there is exactly one `conCFDEPro_Editor` and one `conCFDEPro_EditorEmpty`, preserving the refined DF-04B controls and the currently working component contract.

## Frozen scope

Until explicitly reopened by a later requirement, the following are treated as approved/frozen for the structural cleanup:

- component custom-property contract;
- header geometry and actions;
- catalog geometry and behavior;
- right preview slot geometry;
- overall three-column workspace geometry;
- host ownership of backend flows.

The cleanup may touch only the duplicated center-editor subtree required to remove the regression.

## Working rule from now on

1. Start every remaining change from this current full working component, not from DF-01/02/03/04 fragments.
2. Preserve all control types and component custom properties that already work in Studio unless a specific issue requires changing them.
3. Prefer a complete consolidated component/control source when structural cleanup is required.
4. Use `.property-guide.md` only for property-only adjustments.
5. Power Apps Studio remains authoritative for validation.
6. Do not start backend wiring from a structurally duplicated center editor; consolidate the working UI first.
7. Do not use color-only concerns to reopen frozen structure or behavior.

## Next technical checkpoint

### `DF-04D-FIX` — Type `C — Component`

**Purpose:** remove the duplicated center editor introduced by the previous replacement while preserving the working component contract and approved surrounding geometry.

**Touches:** duplicated `conCFDEPro_Editor` / `conCFDEPro_Editor_1` subtree and duplicated editor-empty state only.

**Does not modify:** header, catalog, preview slot geometry, component custom properties, backend contracts or host integration.

**Expected status after validation:** center editor `FUNCTIONAL_FROZEN`; color may remain independently pending.

After Studio validates this FIX, continue with DF-05 as `I — Integration` for host-owned backend wiring.
