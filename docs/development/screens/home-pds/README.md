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
| 02 | PDS Page Header contract / implementation | **validated for progression** |
| 03 | Home_PDS header integration | **published — pending Studio validation** |
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

The original instance-safety failure was corrected by comparing the complete component against `cmp_HeatMapPro` and `cmp_SidebarNav`, then rebuilding the full public contract using the proven PULSE metadata patterns.

The corrected full component was instantiated successfully in Power Apps Studio. The user subsequently instructed progression to the next block. Block 02 is therefore accepted for progression; if Block 03 exposes a header-attributable contract or visual regression, Block 02 must be reopened.

## Block 03 — Header integration

Published artifact:

```text
docs/development/screens/home-pds/blocks/03_header_integration.children.pa.yaml
```

Commit:

```text
76b5ab999437d97bd6307eb713429617781e2213
```

Responsibilities:

```text
conHPDS_PageHeaderHost
└── cmpHPDS_PageHeader (cmp_PageHeaderPro)
```

Current bindings:

```text
Title / Subtitle       → varPageTitle / varPageSubtitle
Project                → current varSelectedProject context
Template               → temporary presentation value `Master Punch List`
Last refresh            → `Not loaded` until remote read exists
Project interaction     → disabled in this block
Template interaction    → disabled until Block 07
Refresh                 → visible but disabled until Block 08
Help                    → hidden until Block 21
```

This prevents the header from presenting interactions or timestamps that are not implemented yet.

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

Power Apps Studio + App Checker remain the acceptance authority.
