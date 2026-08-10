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
| 03 | Home_PDS header integration | **FAILED on partial child edit surface / 03A full-screen correction pending Studio validation** |
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

The corrected complete component was instantiated successfully in Power Apps Studio. Therefore:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

Target-screen binding remains a separate validation surface.

## Block 03 — Header integration incident

Original artifact:

```text
docs/development/screens/home-pds/blocks/03_header_integration.children.pa.yaml
```

Studio rejected every `cmp_PageHeaderPro` custom property on the nested CanvasComponent instance with `PA2108 Unknown property`, including Text, Boolean and utility properties. Standard CanvasComponent properties such as `Height` and `Width` were not part of the reported failures.

The error was produced while integrating the component through the **partial child/control Source Code edit surface**.

This does not prove that the `cmp_PageHeaderPro` contract is invalid. PULSE contains a positive full-screen reference in `scr_PunchReview`, where `cmp_SidebarNav` is represented as:

```yaml
Control: CanvasComponent
ComponentName: cmp_SidebarNav
Properties:
  ActiveKey: =...
  ProjectCode: =...
  ProjectName: =...
```

Therefore the instance-property syntax itself is already proven in a full `Screens:` source.

### Block 03A corrective candidate

Artifact:

```text
docs/development/screens/home-pds/blocks/03A_header_integration.full-screen.pa.yaml
```

Commit:

```text
e932d9e3af233cd5bea23c6b532e9c29d5ed974f
```

Corrective strategy:

```text
failed partial ADD CHILD source
→ preserve cmp_PageHeaderPro contract
→ rebuild Block 01 + Block 03 as one complete Screens: source
→ validate once
```

If 03A passes, the incident is classified as an edit-surface/source-context compatibility issue and Block 03 can close.

If 03A returns the same PA2108 errors, the next investigation is **host-visible public-contract registration for cmp_PageHeaderPro**, not another property-by-property test.

## Diagnostic efficiency rule

For Power Apps components in this workspace:

```text
problem component
→ positive instance-safe PULSE reference
→ full contract/body diff
→ corrected complete candidate
→ one consequential Studio test
→ reduction only if still necessary
```

Do not request property-by-property microtests while repository comparison can produce a concrete correction.

## Construction policy

No dependent block advances while its dependency has a failed or unvalidated runtime gate.

Power Apps Studio + App Checker remain the acceptance authority.
