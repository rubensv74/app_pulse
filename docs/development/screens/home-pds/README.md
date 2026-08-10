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
| 03 | Home_PDS header integration | **03B source-created instance not hydrated / 03C manual insertion pending** |
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

The corrected complete component was instantiated successfully in Power Apps Studio:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

Target-screen binding remains a separate validation surface.

## Block 03 — Header integration evidence

### 03 — partial child Source Code

Studio accepted the generic `CanvasComponent` structure but returned `PA2108 Unknown property` for every `cmp_PageHeaderPro` custom property assigned by the screen.

### 03A — complete `Screens:` Source Code

The same PA2108 pattern was reproduced in a complete screen source. Therefore the partial edit-surface hypothesis was refuted.

### 03B — generic Source Code instance

A complete screen was then created with the header instance using only:

```yaml
Control: CanvasComponent
ComponentName: cmp_PageHeaderPro
Properties:
  Height: =Parent.Height
  Width: =Parent.Width
```

Studio accepted the screen. However, visual evidence showed that the selected `cmpHPDS_PageHeader` instance:

```text
- rendered as a blank header surface;
- exposed generic properties such as Fill, Height, Visible, Width, X and Y;
- exposed OnUtility;
- did NOT expose expected public Inputs such as Context1Value, Title, Subtitle, ShowHelp, etc.
```

This means the Source Code-created instance has not hydrated the same usable contract/body demonstrated by the prior manual instance insertion.

## Block 03C — manual instance hydration

Artifact:

```text
docs/development/screens/home-pds/blocks/03C_header_integration_manual_instance.md
```

Strategy:

```text
keep conHPDS_PageHeaderHost
→ delete only source-created cmpHPDS_PageHeader
→ insert cmp_PageHeaderPro manually from Studio Custom components
→ move it into conHPDS_PageHeaderHost
→ rename to cmpHPDS_PageHeader
→ set Width/Height = Parent
→ configure Block 03 public inputs in one pass
```

This is not a new component diagnostic. It deliberately uses the same manual insertion path that already demonstrated `INSTANCE_SAFE = PASS`.

If the manually inserted instance exposes the expected public contract and renders normally, close Block 03 after binding/visual validation. If it does not, reopen the component public-contract definition itself; no further screen-YAML variants are justified.

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
