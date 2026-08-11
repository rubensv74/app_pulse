# cmp_CustomFieldsEditorPro — Current Working Baseline

## Status

Baseline supplied and visually validated by the user in Power Apps Studio on 2026-08-11.

The component can be inserted as instances without Studio errors. From this point forward this current full component is the implementation baseline for all remaining corrections and DF work. Older incremental DF replacement artifacts are historical inputs only and must not be used as the starting source for new fixes.

## Source of truth

User-supplied full `ComponentDefinitions > cmp_CustomFieldsEditorPro` source from the 2026-08-11 working Studio instance.

The current contract includes the established inputs/outputs/events, the project definition catalog, local definition draft state, Choice/MultiChoice line-based option editing, and the dynamic preview.

## Important structural finding

The current working source also exposes the visual defect visible in the supplied screenshot: the refined editor introduced during DF-04B exists as `conCFDEPro_Editor_1` nested inside the previous `conCFDEPro_Editor > conCFDEPro_Form`, while the older editor controls remain present. This produces the second editor panel rendered on top of/inside the original center editor.

The same duplication pattern exists for the corresponding editor-empty state.

This is not an architecture change and does not require changing the component contract. The next cleanup must consolidate the center workspace so there is exactly one `conCFDEPro_Editor` and one `conCFDEPro_EditorEmpty`, preserving the refined DF-04B controls and the currently working component contract.

## Working rule from now on

1. Start every remaining change from this current full working component, not from DF-01/02/03/04 fragments.
2. Preserve all control types and component custom properties that already work in Studio unless a specific issue requires changing them.
3. Prefer a complete consolidated component source when structural cleanup is required.
4. Use `.property-guide.md` only for property-only adjustments.
5. Power Apps Studio remains authoritative for validation.
6. Do not start backend wiring from a structurally duplicated center editor; consolidate the working UI first.

## Next technical checkpoint

Consolidate the center editor without changing behavior, then continue with DF-05 host-owned backend integration.
