# HOME_PDS — Modular Construction Workspace

**Screen:** `scr_Home_PDS`  
**Target display title:** `Punch Control Tower`  
**Primary archetype:** Operational Control Tower  
**Secondary pattern:** Data Explorer  
**Construction mode:** parallel rebuild from blank screen  
**Current Studio baseline:** restart in progress as of 2026-08-11

## Current restart authority

Implementation has been reset from an empty `scr_Home_PDS` without discarding prior architectural or diagnostic knowledge.

Start here:

```text
docs/development/screens/home-pds/RESTART_BASELINE_2026-08-11.md
```

Current corrective artifact:

```text
docs/development/screens/home-pds/blocks/01A_sidebar_manual_instance.md
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
| 01 | Blank screen shell | **visual shell PASS / project binding unresolved** |
| 01A | Sidebar instance hydration | **NEXT — manual Studio insertion** |
| 02 | PDS Page Header contract / implementation | **retained component evidence; `INSTANCE_SAFE = PASS`** |
| 03 | Home_PDS header integration | **pending after Block 01A; use manual Studio insertion path** |
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

## Restart Block 01 result — 2026-08-11

The restarted screen successfully rendered the major shell:

```text
cmpHPDS_Sidebar visible
Home visually active
conHPDS_ContentShell fills remaining area
content surface intentionally empty
```

However, the screenshot showed the sidebar footer as:

```text
CURRENT PROJECT
Text
Text
```

Those values match the component defaults rather than the expected screen bindings to `varSelectedProject`.

Therefore Block 01 is not closed yet. Geometry/rendering passed, but the source-created sidebar instance did not apply the required custom Input values reliably.

Corrective path:

```text
docs/development/screens/home-pds/blocks/01A_sidebar_manual_instance.md
```

## Historical Page Header evidence retained

Before the 2026-08-11 reset, `cmp_PageHeaderPro` had demonstrated:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

Block 03 then showed that a PageHeader instance created from screen Source Code did not hydrate the same usable public contract/body as the manually inserted instance. Host-side custom-property assignments produced `PA2108`, and a later generic Source Code-created instance rendered blank and lacked expected public Inputs.

Retained evidence:

```text
docs/development/screens/home-pds/CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md
docs/development/screens/home-pds/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
docs/development/screens/home-pds/blocks/03C_header_integration_manual_instance.md
```

After Block 01A passes, PageHeader integration must use the proven manual Studio route.

## Construction policy

```text
repository artifact
→ implement in Studio
→ one meaningful validation
→ record result
→ advance only if dependency gate passes
```

Power Apps Studio + App Checker remain the acceptance authority.
