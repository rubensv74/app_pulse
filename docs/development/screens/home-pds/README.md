# HOME_PDS — Modular Construction Workspace

**Screen:** `scr_Home_PDS`  
**Target display title:** `Punch Control Tower`  
**Primary archetype:** Operational Control Tower  
**Secondary pattern:** Data Explorer  
**Construction mode:** parallel rebuild from blank screen  
**Current Studio baseline:** `scr_Home_PDS` intentionally empty as of 2026-08-11

## Current restart authority

Implementation has been reset from an empty `scr_Home_PDS` without discarding prior architectural or diagnostic knowledge.

Start here:

```text
docs/development/screens/home-pds/RESTART_BASELINE_2026-08-11.md
```

Immediate executable artifact:

```text
docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml
```

## Normative references

```text
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md
docs/design-system/components/CMP_PAGE_HEADER_PRO.md
docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md
```

## Frozen architecture

```text
scr_Home_PDS
└── conHPDS_ScreenRoot
    ├── cmpHPDS_Sidebar
    └── conHPDS_ContentShell
        ├── conHPDS_PageHeaderHost
        │   └── cmpHPDS_PageHeader
        ├── conHPDS_Body
        │   ├── conHPDS_KpiStrip
        │   ├── conHPDS_AnalyticsGrid
        │   │   ├── conHPDS_HeatmapPanel
        │   │   └── conHPDS_DisciplinePanel
        │   ├── conHPDS_ActiveContext
        │   └── conHPDS_DataExplorer
        └── conHPDS_OverlayLayer
```

`scr_Home` remains the stable reference/rollback screen until final cutover. `StartScreen` is not changed during construction.

## Current block status after restart

| Block | Name | Current status |
|---:|---|---|
| 00 | Foundation audit and reuse matrix | **retained / validated architecture** |
| 01 | Blank screen shell | **NEXT — reapply to empty screen** |
| 02 | PDS Page Header contract / implementation | **retained component evidence; `INSTANCE_SAFE = PASS`** |
| 03 | Home_PDS header integration | **pending after Block 01; use manual Studio insertion path** |
| 04 | Workspace/body structural layout | **blocked by Block 03** |
| 05 | Minimum typed runtime state | planned |
| 06 | KPI strip with local presentation model | planned |
| 07 | Punch-template context selector | planned |
| 08 | Dashboard bundle remote read | planned |
| 09 | Bundle parser / presentation model | planned |
| 10 | KPI real-data integration | planned |
| 11 | Heatmap integration | planned |
| 12 | Heatmap selection + active context | planned |
| 13 | Discipline pie integration | planned |
| 14 | Discipline bars + shared selection | planned |
| 15 | Action toolbar | planned |
| 16 | Cell-details remote read | planned |
| 17 | DataTableProV2 + SQL-authoritative paging | planned |
| 18 | Search/sort/columns/density/selection | planned |
| 19 | Home → Punch Review contextual navigation | planned |
| 20 | Loading/empty/error hardening | planned |
| 21 | Help/accessibility/responsive | planned |
| 22 | Remove scaffolding + visual QA | planned |
| 23 | Consolidation + user guide + cutover decision | planned |

## Historical evidence retained

Before the 2026-08-11 reset, implementation had reached Block 03.

`cmp_PageHeaderPro` had already demonstrated:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

However, Block 03 showed that a PageHeader instance created from screen Source Code did not hydrate the same usable public contract/body as the manually inserted instance. Host-side custom-property assignments produced `PA2108`, and a later generic Source Code-created instance rendered blank and lacked expected public Inputs.

Retained evidence:

```text
docs/development/screens/home-pds/CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md
docs/development/screens/home-pds/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
docs/development/screens/home-pds/blocks/03C_header_integration_manual_instance.md
```

Therefore, after Block 01 is revalidated, PageHeader integration must use the proven route:

```text
create host
→ insert cmp_PageHeaderPro manually in Studio
→ configure public inputs in Studio
→ integration smoke test
```

Do not generate further equivalent screen-YAML variants for the header unless new evidence requires it.

## Immediate Block 01 acceptance

```text
scr_Home_PDS opens normally
cmpHPDS_Sidebar renders at left
Home is active
current project is preserved
conHPDS_ContentShell fills remaining area
content shell intentionally empty
scr_Home remains unchanged
no new PA1001 / PA2108 attributable to Block 01
```

## Construction policy

```text
repository artifact
→ implement in Studio
→ one meaningful validation
→ record result
→ advance only if dependency gate passes
```

Power Apps Studio + App Checker remain the acceptance authority.
