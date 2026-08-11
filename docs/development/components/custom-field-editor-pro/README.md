# cmp_CustomFieldEditorPro — DEPRECATED PROTOTYPE

**Status:** frozen / superseded  
**Do not continue CF-04 or later work from this prototype.**

## Why this prototype is frozen

The CF-01/CF-02/CF-03 line was created under an incorrect responsibility model: `cmp_CustomFieldEditorPro` was being developed as the Punch Review record-value editor.

The corrected architecture separates two different concerns:

1. `cmp_CustomFieldValuesPro` — shows and edits the current Custom Field values for one selected Punch.
2. `cmp_CustomFieldsEditorPro` — project-level editor for defining which Custom Fields exist and how they behave.

The previous prototype is retained only as implementation history and as a source of Power Apps compatibility lessons. It must not become a production component.

## Current architecture

See:

`docs/development/custom-fields/CUSTOM_FIELDS_ARCHITECTURE_REFACTOR_PLAN.md`

## Existing prototype artifacts

The following files remain archived for traceability:

- `blocks/01_component_shell.pa.yaml`
- `blocks/02_working_buffer.pa.yaml`
- `blocks/03_field_renderers.pa.yaml`
- `blocks/03A_field_renderers_test_seed.optional.powerfx`

They are not the basis for the new components.

## Permanent lessons preserved

Any Source Code compatibility incidents discovered while building this prototype remain valid and are recorded in:

`docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

That file remains a mandatory PRE-YAML gate for all subsequent Power Apps YAML work.
