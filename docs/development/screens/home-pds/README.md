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
| 02 | PDS Page Header contract / implementation | **INSTANCE_SAFE PASS — final combined contract/visual smoke pending** |
| 03 | Home_PDS header integration | **blocked only by final Block 02 smoke** |
| 04 | Workspace/body structural layout | planned |
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

Validation report:

```text
docs/development/screens/home-pds/CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md
```

Known history:

```text
02   initial reusable Page Header
02A  ModernText overflow/AutoHeight correction
     + PaYaml Patch: root incident corrected
     + later FAIL_INSTANCE observed
```

### Reference-first correction

Primary stable reference:

```text
cmp_HeatMapPro
```

Secondary stable reference:

```text
cmp_SidebarNav
```

The original header was compared structurally against both. The principal objective delta was that header Inputs used a reduced metadata shape while stable PULSE references normally use:

```text
PropertyKind
DisplayName
Description
DataType
Default
```

The complete `cmp_PageHeaderPro` contract was rebuilt using the proven PULSE pattern; Events use the complete event metadata form demonstrated by stable components.

Correction commit:

```text
ccaccacd2de75263edc20751eed0efec3c78da83
```

### Instance-safety result

On 2026-08-10 the user created a new instance of the corrected complete component in Power Apps Studio and reported that the instance was created successfully and Studio remained stable.

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
```

No further reduction is justified unless a later regression reproduces the issue.

### Final Block 02 smoke

Before Block 03, perform one combined check rather than separate microtests:

```text
1. change one representative Text input
2. toggle one representative Boolean visibility input
3. execute one Event with a trivial Notify() binding
4. visually confirm no clipping, unintended scrollbar or overlap
```

If the combined test passes:

```text
PUBLIC_CONTRACT_VALIDATED = PASS
VISUAL_QA_VALIDATED       = PASS
Block 02                  = VALIDATED
Block 03                  = UNBLOCKED
```

## Diagnostic efficiency rule

For Power Apps components in this workspace:

```text
problem component
→ positive instance-safe PULSE reference
→ full contract/body diff
→ corrected complete component
→ one smoke test
→ reduction only if still failing
```

Do not request property-by-property microtests while repository comparison can produce a concrete complete correction.

## Construction policy

No dependent block advances while its dependency has a failed or unvalidated runtime gate.

A reusable component may be consumed by a screen only after:

```text
SOURCE_VALID
→ DEFINITION_ACCEPTED
→ INSTANCE_SAFE
→ PUBLIC_CONTRACT_VALIDATED
→ VISUAL_QA_VALIDATED
```

Power Apps Studio + App Checker remain the acceptance authority.
