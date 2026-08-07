# HOME_PDS — Modular Construction Workspace

**Screen:** `scr_Home_PDS`  
**Target display title:** `Punch Control Tower`  
**Primary archetype:** Operational Control Tower  
**Secondary pattern:** Data Explorer  
**Construction mode:** parallel rebuild from blank screen  

---

## Normative references

```text
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/guides/GUIA_RECONSTRUCCION_PDS_EN_PANTALLA_PARALELA.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md
docs/specifications/home-pds/BLOCK_00_FOUNDATION_AUDIT.md
```

---

## Frozen source baselines

### Screens / Components

```text
3b71b860ed869a970a5a1b43cc137a580118b30c
```

### SQL warroom schema

```text
17bbe86e25bbb3962df237420136600b6aca12e2
```

If a later block depends on a contract changed after these commits, that block must perform and document a targeted re-audit.

---

## Block 00 validation decision

Block 00 was explicitly accepted on **2026-08-07**.

The following architectural decisions are therefore frozen for the first construction pass:

- build `scr_Home_PDS` from a blank screen in parallel with `scr_Home`;
- keep `scr_Home` as stable reference and rollback until final cutover;
- primary archetype: Operational Control Tower;
- secondary pattern: Data Explorer;
- reuse proven backend contracts rather than recreate them;
- reuse compatible premium components through PDS inputs;
- use `cmp_PieChartPro` as the primary discipline-composition chart;
- complement the pie with interactive horizontal discipline bars;
- synchronize pie and bars through one shared discipline-selection state;
- keep SQL/Flow snapshot and pagination authority server-side;
- do not change `StartScreen` during construction.

`cmp_DonutPro` remains a valid PDS component for progress/completion/capacity-style metrics, but it is **not** the selected chart for Home_PDS discipline distribution.

---

## Block status

| Block | Name | Status |
|---:|---|---|
| 00 | Foundation audit and reuse matrix | **validated** |
| 01 | Blank screen shell | **integrating — visual gate passed / App Checker pending** |
| 02 | PDS Page Header contract / implementation | planned |
| 03 | Home_PDS header integration | planned |
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

---

## Block 01 publication

Published construction artifact:

```text
docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml
```

Purpose:

- create `scr_Home_PDS` from Source Code;
- establish the root horizontal AutoLayout;
- reuse `cmp_SidebarNav` with `Home` as the active business key;
- create an empty PDS content shell;
- introduce no business collections, flows, charts, KPIs or production navigation changes.

### Visual validation received — 2026-08-07

The Studio screenshot confirms:

```text
PASS  scr_Home_PDS exists independently from scr_Home
PASS  conHPDS_ScreenRoot exists
PASS  cmpHPDS_Sidebar exists and renders at the left
PASS  conHPDS_ContentShell exists and occupies the remaining surface
PASS  Home is visually active in the sidebar
PASS  current project context is preserved and displayed (70200)
PASS  content shell is intentionally empty and uses the light PDS page surface
PASS  no Page Header, KPI, charts or Data Explorer were introduced prematurely
```

Still required before final `validated` state:

```text
[ ] Save accepted by Studio without formula errors attributable to Block 01
[ ] App Checker shows no new PA1001 / PA2108 attributable to Block 01
[ ] scr_Home remains operational after the new screen was added
```

Block 02 must not be published until these remaining checks are confirmed.

---

## Construction policy

The new screen must be created from a blank screen. Do not duplicate `scr_Home`.

During construction:

```text
scr_Home     = stable reference + rollback
scr_Home_PDS = isolated PDS implementation
```

Do not change `StartScreen` or the production Home navigation before final acceptance.

No dependent block advances while the current block is `failed`.

---

## Repository workspace

Expected structure as blocks are published:

```text
docs/development/screens/home-pds/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
│   ├── 01_screen_shell.pa.yaml
│   ├── 02_page_header.*
│   └── ...
└── user-guide/
    └── MANUAL_USUARIO_HOME_PDS.md
```

Blocks are construction artifacts and do not replace the canonical screen source until the consolidation gate.
