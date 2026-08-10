# HOME_PDS — Modular Construction Workspace

**Screen:** `scr_Home_PDS`  
**Target display title:** `Punch Control Tower`  
**Primary archetype:** Operational Control Tower  
**Secondary pattern:** Data Explorer  
**Construction mode:** parallel rebuild from blank screen

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

## Block status

| Block | Name | Status |
|---:|---|---|
| 00 | Foundation audit and reuse matrix | **validated** |
| 01 | Blank screen shell | **validated** |
| 02 | PDS Page Header contract / implementation | **validated for progression / isolated instance-safe** |
| 03 | Home_PDS header integration | **FAILED for host-side custom-property assignment in Source Code / 03B pending** |
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

## Block 01

Validated shell:

```text
scr_Home_PDS exists independently from scr_Home
conHPDS_ScreenRoot exists
cmpHPDS_Sidebar renders at the left
conHPDS_ContentShell occupies remaining surface
Home is active in sidebar
current project context is preserved
no later modules introduced prematurely
```

## Block 02 — Page Header

Canonical source:

```text
power-apps/components/cmp_PageHeaderPro.pa.yaml
```

The original instance-safety failure was corrected by comparing the complete component against `cmp_HeatMapPro` and `cmp_SidebarNav`, then rebuilding the full public contract using the proven PULSE metadata patterns.

The corrected complete component was instantiated successfully in Power Apps Studio:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

Target-screen binding remains a separate validation surface.

## Block 03 — Header integration incident

### 03 — partial child Source Code

Artifact:

```text
docs/development/screens/home-pds/blocks/03_header_integration.children.pa.yaml
```

Studio accepted the generic `CanvasComponent` structure but returned `PA2108 Unknown property` for every `cmp_PageHeaderPro` custom property assigned by the screen.

### 03A — complete `Screens:` Source Code

Artifact:

```text
docs/development/screens/home-pds/blocks/03A_header_integration.full-screen.pa.yaml
```

The same PA2108 pattern was reproduced in a complete screen source. Therefore the previous edit-surface hypothesis is refuted for this incident.

Confirmed differential:

```text
Height / Width and generic CanvasComponent structure → recognized
cmp_PageHeaderPro-specific custom properties         → not recognized by screen Source Code parser
```

PULSE provides a positive counterexample: `scr_PunchReview` binds `cmp_SidebarNav` custom properties in screen Source Code successfully. Therefore generic `CanvasComponent + ComponentName + Properties` syntax is valid when Studio resolves the component public contract.

Current interpretation is deliberately limited:

> In the current app state, host-side Source Code does not resolve the `cmp_PageHeaderPro` public properties. The internal metadata reason is not claimed.

## Block 03B — Studio-resolved contract integration

Artifact:

```text
docs/development/screens/home-pds/blocks/03B_header_integration_studio_contract.md
```

Strategy:

```text
create host + component instance with only standard CanvasComponent properties
→ save
→ select cmpHPDS_PageHeader in Studio
→ configure its public inputs through Studio property selector/formula bar
→ save and let Studio own host-side binding representation
```

Required Block 03 overrides:

```text
Context1Interactive = false
Context1Value       = current selected project
Context2Interactive = false
Context3Interactive = false
Context3Value       = "Not loaded"
ShowHelp            = false
UtilityEnabled      = false
```

If those properties are visible on the selected instance, configure all seven in one pass and validate the header.

If `Context1Value` and the other public properties are absent from Studio's property selector, stop. That result is a direct gate for **public-contract re-registration in Studio**; no further screen-YAML variants are justified.

## Diagnostic efficiency rule

```text
problem component
→ positive instance-safe PULSE reference
→ full contract/body diff
→ corrected complete candidate
→ one consequential Studio test
→ reduction only if still necessary
```

A failed hypothesis must be retired immediately rather than spawning equivalent YAML variants.

## Construction policy

No dependent block advances while its dependency has a failed or unvalidated runtime gate.

Power Apps Studio + App Checker remain the acceptance authority.
