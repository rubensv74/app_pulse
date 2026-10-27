# cmp_DetailDrawer_1

**Lifecycle:** ACTIVE  
**Canonical source:** `power-apps/components/cmp_DetailDrawer_1.pa.yaml`  
**Primary consumer:** `scr_Punches`

## Responsibility

Display a selected punch record with its overview, comments, custom fields and history, including the custom-field management actions available to managers.

## Public contract

The component exposes the current Punches host contract for project and record context, loading state, user context, color tokens and callbacks for closing, managing fields, saving a field and toggling field activity. The screen keeps ownership of the selected record and supplies the callbacks.

## Runtime behavior

The component loads and saves comments and custom-field values through the existing PULSE flows. This is retained from the validated runtime implementation to preserve the current behavior during the component migration.

## Validation evidence

- PaYaml source and component property contract: statically checked.
- Studio compilation and target-screen behavior: confirmed by the user on 2026-10-27.
- The previous drawer identity is absent from the screen and replacement component source.

## Scope

This component is validated for the current PULSE Punches integration. Its flow bindings and app-scope behavior make it unsuitable for reuse in a different app without a separate contract review.
