# HOME_PDS — Block 00 Foundation Audit

**Status:** VALIDATED  
**Validation date:** 2026-08-07  
**Screen target:** `scr_Home_PDS`  
**Display title target:** `Punch Control Tower`  
**Primary archetype:** Operational Control Tower  
**Secondary pattern:** Data Explorer  
**Method:** PULSE UI Delivery Framework + Modular Power Apps Screen Construction Protocol  

---

# 1. Purpose

This document is the mandatory Phase 0 / Block 00 audit before producing the first YAML block for `scr_Home_PDS`.

The new screen will be built **from a blank screen in parallel with `scr_Home`**. The current Home remains the stable functional reference and rollback option. Block 00 establishes the real contracts, reusable assets, risks and target architecture from the current repository state.

No runtime code was modified by this audit.

Block 00 was explicitly accepted on **2026-08-07**. The architecture and build sequence defined here are therefore frozen for the first construction pass unless a later approved architecture change is documented.

---

# 2. Frozen source baselines

The audit is intentionally tied to immutable repository commits, not to mutable `main`.

## 2.1 Power Apps screens and components

```text
Repository: rubensv74/app_pulse
Commit:     3b71b860ed869a970a5a1b43cc137a580118b30c
Screens:    main/screens
Components: main/components
```

Canonical references inspected:

```text
main/screens/Home/scr_Home.pa.yaml
main/screens/PunchReview/scr_PunchReview.pa.yaml

main/components/cmp_SidebarNav.pa.yaml
main/components/cmp_KpiCardPro.pa.yaml
main/components/cmp_HeatMapPro.pa.yaml
main/components/cmp_PieChartPro.pa.yaml
main/components/cmp_DonutPro.pa.yaml
main/components/cmp_ActionToolbarPro.pa.yaml
main/components/cmp_DataTableProV2.pa.yaml
main/components/cmp_DashboardSectionHeader.pa.yaml
main/components/cmp_EmptyState.pa.yaml
main/components/cmp_SkeletonLoader.pa.yaml
```

## 2.2 SQL schema

```text
Repository: rubensv74/app_pulse
Commit:     17bbe86e25bbb3962df237420136600b6aca12e2
Path:       sql/schema_warroom
Primary machine-readable reference:
            sql/schema_warroom/schema_warroom.csv
```

The screens/components commit and SQL commit are different by design. This audit records both explicitly and must not silently replace either baseline with a later revision.

---

# 3. Confirmed current Home architecture

`scr_Home` is not a simple dashboard. It already contains a substantial operational punch workspace with:

- project and punch-template context;
- dashboard bundle loading;
- KPI presentation models;
- executive alert/insight treatment;
- open-punch heatmap;
- discipline distribution;
- contextual action toolbar;
- paged punch grid;
- selection state;
- detail-drawer support;
- loading state;
- task-oriented legacy/Home functionality that predates the current punch-control-tower direction.

The current screen is functionally valuable but structurally heterogeneous because it has evolved through several generations. `scr_Home_PDS` must therefore reuse **contracts and proven components**, not copy the complete control tree.

Current page identity observed in Home:

```text
Title:    Executive Dashboard
Subtitle: Punch analytics, hotspots and drill-through
```

For Home_PDS this becomes:

```text
Title:    Punch Control Tower
Subtitle: Open punch concentration, discipline distribution and operational drill-through
```

This is a semantic architecture change, not only a label change: Home_PDS is explicitly an **Operational Control Tower**.

---

# 4. Confirmed Punch Review reference architecture

`scr_PunchReview` is the current architectural reference screen for PULSE.

Confirmed patterns include:

- horizontal root shell;
- shared `cmp_SidebarNav`;
- vertical content shell;
- contextual header;
- modular body;
- typed runtime collections;
- master queue / current record / contextual inspector structure;
- local session state;
- search and quick filters;
- explicit loading / empty / error handling;
- hidden service controls where they isolate Power Fx responsibilities;
- comments as a separately loaded remote module;
- session activity as a distinct module;
- help and dirty-state infrastructure.

Home_PDS should inherit the **engineering discipline** of Punch Review, not its three-column layout. The two screens have different primary archetypes.

---

# 5. Confirmed visual foundations in current Home

The current Home already uses most of the future PDS foundation values:

```text
Navigation background  #07111F
Page background        #F6F8FB
Surface                #FFFFFF
Surface alternate      #F8FAFC
Border                 #E2E8F0
Primary text           #0F172A
Muted text             #64748B
Soft text              #94A3B8
Brand cyan             #00C8FF
Interaction blue       #1677FF
```

However, legacy values and hardcodes still coexist. Examples include additional blues such as `#0B5ED7`, plus multiple radii and component-level shadow decisions.

Therefore Home_PDS must consume PDS tokens from the beginning instead of reproducing current hardcodes.

---

# 6. Confirmed discipline visualization palette

The current Home discipline palette is considered valuable business/data-visualization semantics and can be preserved:

```text
Electrical       #F97316
Piping           #14B8A6
Mechanical       #2563EB
Instrumentation  #8B5CF6
Civil            #06B6D4
HVAC             #0EA5E9
Structural       #6366F1
Fireproofing     #EF4444
Telecom          #22C55E
Safety           #F59E0B
Other            #64748B
```

PDS rule for Home_PDS:

> Discipline colors encode discipline data. They do not replace the global interaction or selection language.

A selected discipline may retain its discipline-colored bar/slice while its **selected container** must use the common PDS selection treatment.

---

# 7. Reusable component assessment

## 7.1 `cmp_SidebarNav`

**Decision:** `REUSE_AS_IS` for initial shell, followed by PDS hardening only if required.

Why:

- it is already the navigation component used by both Home and Punch Review;
- its base navigation background matches PDS BrandDark;
- changing navigation during Home_PDS construction would unnecessarily expand scope.

Known debt:

- some internal active/hover colors remain hardcoded;
- those are component-system debt, not a reason to duplicate the sidebar in Home_PDS.

## 7.2 `cmp_KpiCardPro`

**Decision:** `REUSE_WITH_PDS_INPUTS`.

Strengths:

- explicit accent, surface, border and text inputs;
- loading/error states;
- information tooltip;
- click/selection contract;
- trend support;
- normalized trend series;
- stable `CardKey`.

PDS notes:

- pass canonical PDS interaction/semantic tokens from Home_PDS;
- do not use arbitrary KPI colors merely to make every card different;
- existing component shadow can be hardened separately; it is not a reason to rebuild KPI behavior inside the screen.

## 7.3 `cmp_HeatMapPro`

**Decision:** `REUSE_WITH_PDS_INPUTS` — high-confidence reuse.

Strengths:

- external rows, columns and cells;
- selection contract and selected outputs;
- ready/loading/empty/error state contract;
- compact mode;
- totals, legend and summary controls;
- explicit accent/surface/border/text inputs.

This component should remain the main **Open Punch Concentration** visualization unless Block-level validation discovers a real limitation.

## 7.4 `cmp_PieChartPro` / `cmp_DonutPro`

**Validated decision:** use `cmp_PieChartPro` as the primary Home_PDS discipline-composition visualization and complement it with interactive horizontal discipline bars.

Rationale:

- the core question is part-to-whole distribution across disciplines;
- a full pie provides more visible sector area than a thin ring and therefore makes the share distribution easier to perceive;
- the horizontal bars provide the precision view for ranking and relative magnitude;
- the two visualizations answer complementary questions and must share one selected-discipline state;
- current Home already proves `cmp_PieChartPro` consumption;
- `cmp_PieChartPro` exposes normalized segment inputs, selection outputs/events, percentages, values, legend behavior and ready/loading/empty/error states.

Shared selection rule:

```text
Pie segment ─────┐
                 ├──> selected discipline ──> Active Context ──> Data Explorer
Discipline bar ──┘
```

`cmp_DonutPro` remains a reusable PDS component for cases such as completion, readiness, utilization or capacity, where a central KPI plus circular progress is the dominant reading. It is **not** the selected chart for Home_PDS discipline distribution.

## 7.5 `cmp_ActionToolbarPro`

**Decision:** `REUSE_WITH_PDS_INPUTS`, with a new Home_PDS action definition table.

Current component contract is suitable: contextual text, secondary text, ordered actions, tone, enabled/visible state and a single `OnAction` event.

Current Home behavior that must **not** be copied literally:

```text
CLEAR_FILTERS → Tone = danger
```

In Home_PDS, clearing filters is neutral because it is reversible.

Recommended Home_PDS action hierarchy:

```text
Primary:    REVIEW
Secondary:  OPEN_PUNCHES
Utility:    REFRESH, EXPORT, COMMENT
View:       COLUMNS, DENSITY
Selection:  SELECT_VISIBLE / selection actions
Neutral:    CLEAR_FILTERS
Overflow:   MORE
```

## 7.6 `cmp_DataTableProV2`

**Decision:** `REUSE_WITH_PDS_INPUTS` — high-confidence reuse.

Strengths:

- normalized external rows;
- configurable columns;
- sorting;
- page change contract;
- page size contract;
- local/multi-page selection contract;
- bulk actions;
- contextual row actions;
- column visibility;
- Compact / Comfortable / Spacious density;
- loading and empty states.

Home_PDS must preserve SQL/flow authority for real pagination rather than treating the component as the data source.

## 7.7 `cmp_DashboardSectionHeader`

**Decision:** `REIMPLEMENT` as the future PDS panel-header pattern rather than making it the canonical new standard.

Reason:

- the existing component is useful but its current typography/geometry predates the final PDS specification;
- Home_PDS is the correct place to introduce a canonical `cmp_PanelHeaderPro` contract if required.

Do not delete or mutate the existing component as part of Home_PDS Block 01.

## 7.8 `cmp_EmptyState`

**Decision:** `REUSE_WITH_PDS_INPUTS`, subject to local visual hardening.

The component already supports state, title, message, action, PDS-like surface/border/text/accent inputs and no shadow. Its current radius/button geometry can be normalized later without changing the screen contract.

## 7.9 `cmp_SkeletonLoader`

**Decision:** `REUSE_WITH_PDS_INPUTS`, subject to geometry hardening.

It already provides a localized loading skeleton with external background, skeleton and border colors. Home_PDS should prefer localized loading over blocking the whole page when only one module refreshes.

---

# 8. Current Home business/data contracts

The following Power Apps calls are confirmed in the current Home and are therefore sources of truth for Home_PDS. Parameter order must not be reconstructed from memory.

## 8.1 Punch template catalog

```powerfx
Warroom_GetProjectPunchTemplates.Run(
    Value(varProjectId)
)
```

SQL reference available in the schema baseline:

```text
warroom.usp_GetProjectPunchTemplates(@ProjectId)
```

The SQL contract exposes project/template identity, active flags, category count/summary, inclusion and display order.

## 8.2 Dashboard bundle

Power Apps currently calls:

```powerfx
warroom_GetPunchDashboardBundle.Run(
    Value(varProjectId),
    Value(varPunchDashboardTemplateId),
    <force-refresh integer>
)
```

Relevant SQL contracts confirmed in the schema baseline:

```text
warroom.usp_GetOrRefreshPunchDashboardBundle
warroom.usp_GeneratePunchDashboardSnapshot
warroom.usp_GetPunchDashboardBundle
warroom.usp_GetPunchDashboardSnapshotStatus
warroom.usp_GetLatestPunchDashboardSnapshot
```

`usp_GetPunchDashboardBundle` currently declares contract version `3.0` and returns JSON sections for:

```text
success
hasSnapshot
message
snapshotInfo
summary
matrix
timeline
insights
subsystems
subcontractors
contractVersion
```

The current screen parser should be reused as a **logic reference**, not pasted wholesale into the new `OnVisible`.

## 8.3 Selected heatmap-cell details

Power Apps currently calls:

```powerfx
warroom_GetPunchDashboardCellDetails.Run(
    ProjectId,
    TemplateId,
    SubcontractorId,
    CategoryCode,
    PageNumber,
    PageSize,
    ...
)
```

The exact Power Apps call must be copied from the current screen when its integration block is implemented.

Relevant SQL contract confirmed:

```text
warroom.usp_GetPunchDashboardCellDetailsPaged
```

The SQL procedure is authoritative for paging and returns a JSON contract with real page metadata and punch rows.

## 8.4 Snapshot storage

Confirmed snapshot model:

```text
warroom.PunchDashboardSnapshotRun
warroom.PunchDashboardSnapshotCategoryStatus
warroom.PunchDashboardSnapshotSubsystem
warroom.PunchDashboardSnapshotSubcontractor
warroom.PunchDashboardSnapshotPunch
```

Indexes exist specifically for project/template context, dashboard-cell access and snapshot browsing. Home_PDS must not replace this server-side model with client-side aggregation of the entire punch population.

---

# 9. Architectural rule for Home_PDS data loading

The current Home contains a very large `OnVisible` that mixes theme initialization, typed collections, page state, project state, legacy task state, punch-dashboard state and data loading support.

Home_PDS must not reproduce that pattern.

Target responsibility split:

```text
App / central bootstrap
    → PDS tokens and true application-global state

scr_Home_PDS.OnVisible
    → page identity + minimum typed screen state only

Hidden service controls / timers
    → explicit local operations such as load templates, request dashboard bundle,
      parse presentation model, load selected cell details, rebuild grid view

Reusable components
    → presentation + local UI events

Flows / SQL
    → remote data authority
```

This is one of the main architectural improvements of the parallel rebuild.

---

# 10. Navigation contracts

## 10.1 Sidebar

Home_PDS must use the shared `cmp_SidebarNav` and the existing navigation collection contract. It must not create a second navigation model.

Recommended active key during development:

```text
Home
```

The new screen is a new implementation of Home, not a new top-level business module.

## 10.2 Cutover

During construction:

```text
scr_Home     → active production/reference Home
scr_Home_PDS → reachable only by explicit development navigation/test path
```

Do not change `StartScreen` or production navigation in early blocks.

## 10.3 Punch Review

Current Home has a `REVIEW` toolbar action but its current implementation is still scaffolding/notification rather than final navigation.

Home_PDS must implement the real contract only in the dedicated integration block:

- build a contextual review queue from the authoritative current grid context;
- set explicit review source/context variables;
- navigate to `scr_PunchReview`;
- preserve enough return context to recover the Home_PDS selection/filter state.

Do not invent this contract in Block 01.

---

# 11. Target Home_PDS control tree

The following architecture is frozen for the first construction pass.

```text
scr_Home_PDS
└── conHPDS_ScreenRoot
    ├── cmpHPDS_Sidebar
    └── conHPDS_ContentShell
        ├── conHPDS_PageHeaderHost
        │   └── cmpHPDS_PageHeader
        │
        ├── conHPDS_Body
        │   ├── conHPDS_KpiStrip
        │   │   ├── cmpHPDS_KpiTotal
        │   │   ├── cmpHPDS_KpiOpen
        │   │   ├── cmpHPDS_KpiClosed
        │   │   └── cmpHPDS_KpiCompletion
        │   │
        │   ├── conHPDS_AnalyticsGrid
        │   │   ├── conHPDS_HeatmapPanel
        │   │   │   └── cmpHPDS_Heatmap
        │   │   └── conHPDS_DisciplinePanel
        │   │       ├── cmpHPDS_DisciplinePie
        │   │       └── conHPDS_DisciplineBarsHost
        │   │
        │   ├── conHPDS_ActiveContext
        │   │   └── cmpHPDS_ActionToolbar
        │   │
        │   └── conHPDS_DataExplorer
        │       └── cmpHPDS_DataTable
        │
        └── conHPDS_OverlayLayer
            ├── conHPDS_HelpModal
            └── conHPDS_FutureDrawerHost
```

Architecture rules:

- AutoLayout controls major page geometry.
- ManualLayout is allowed inside bounded modules/components.
- The analytics grid is not allowed to own business state.
- Pie and discipline bars share one selected-discipline state.
- The Data Explorer must preserve server paging authority.
- The overlay layer must not alter body layout when hidden.

---

# 12. Validated build sequence

```text
00  Foundation audit and reuse matrix                         VALIDATED
01  Blank screen shell + shared sidebar + content shell      NEXT
02  PDS Page Header component contract / implementation
03  Home_PDS header integration
04  Workspace/body structural layout + placeholders
05  Minimum typed runtime state
06  KPI strip with static/test presentation model
07  Real punch-template context selector
08  Dashboard bundle remote read service
09  Dashboard bundle parser / presentation model
10  KPI real-data integration
11  Heatmap panel integration
12  Heatmap selection and active context
13  Discipline pie integration
14  Discipline bars + shared discipline selection
15  Action toolbar integration
16  Cell-details remote read service
17  DataTableProV2 integration + SQL-authoritative paging
18  Search/sort/column/density/selection behavior
19  Home → Punch Review contextual navigation
20  Loading / empty / error hardening
21  Help + accessibility + responsive pass
22  Remove test scaffolding / final visual QA
23  Canonical consolidation + user guide + cutover decision
```

No functional block is advanced while the previous required block remains failed.

---

# 13. Known incompatibilities / design debt

Confirmed issues to prevent from propagating into Home_PDS:

```text
- Multiple historical primary-blue hardcodes coexist in current Home.
- Legacy geometry uses several radii outside the final PDS scale.
- Some reusable components still use Semilight shadows on normal cards.
- Existing ActionToolbar default marks CLEAR_FILTERS as danger.
- Existing DashboardSectionHeader predates final PDS typography/geometry.
- Existing SkeletonLoader/EmptyState geometry predates RadiusPanel=12.
- Current Home OnVisible owns too many unrelated responsibilities.
- Current Home contains legacy/parallel implementation history; it must not be cloned wholesale.
- Current Home REVIEW action is not yet the final Punch Review navigation contract.
```

These are migration inputs, not reasons to modify `scr_Home`.

---

# 14. Do-not-invent list

Agents working on Home_PDS must not invent:

```text
- flow parameter order;
- JSON property names;
- dashboard contract versions;
- SQL paging metadata;
- status codes or category semantics;
- Punch Review queue fields;
- sidebar navigation keys;
- Power Apps control properties not demonstrated in the current Source Code schema;
- component custom properties that do not exist in the inspected component version;
- data-source fields inferred only from display labels;
- new theme colors outside PDS without a documented PDS change.
```

If a required contract is missing from the audited source, the block must stop and document the gap.

---

# 15. Open risks

## R1 — Component visual debt versus reuse

Some premium components are functionally mature but predate the final PDS geometry/shadow rules.

**Mitigation:** reuse behavior through explicit PDS inputs, then harden component visuals in isolated component blocks. Do not fork screen-local copies.

## R2 — Home contains both punch and older task-oriented responsibilities

Home_PDS v1 is specified as **Punch Control Tower**. Importing the entire old Home state would reintroduce mixed responsibilities.

**Mitigation:** keep task/Hive functionality out of the initial Home_PDS scope unless a separate explicit requirement reintroduces it.

## R3 — Review navigation is incomplete in current Home

Current toolbar scaffolds the Review action but does not yet prove the final Home → Punch Review handoff.

**Mitigation:** defer to dedicated Block 19 and use `scr_PunchReview` plus the actual Punches integration as contract references before writing code.

## R4 — Multiple source layers

Power Apps flows and SQL procedures are related but not identical abstractions.

**Mitigation:** treat the current Power Apps `.Run(...)` call as authority for the Power Apps contract and the SQL export as authority for server procedure structure. Do not assume a one-to-one wrapper mapping without evidence.

## R5 — Baseline drift during construction

The repository will continue evolving.

**Mitigation:** every Home_PDS block header must state the relevant source baseline and dependencies. If the production Home contracts change materially, perform a targeted re-audit before the affected integration block.

## R6 — Discipline cardinality

A pie chart loses usefulness when too many small disciplines are simultaneously visible.

**Mitigation:** keep horizontal bars as the precision surface and preserve a shared selection model. Any future grouping/Other rule must be implemented as an explicit approved visualization rule, not silently invented inside the chart.

---

# 16. Definition of Done for Block 00

The following conditions are accepted:

```text
[x] immutable screens/components baseline recorded
[x] immutable SQL baseline recorded
[x] current Home and Punch Review roles understood
[x] target archetype confirmed
[x] reuse decisions recorded
[x] discipline Pie + Bars decision recorded
[x] remote contracts identified
[x] navigation constraints recorded
[x] target control tree frozen
[x] block plan frozen
[x] open risks documented
[x] do-not-invent list documented
[x] no runtime code modified
```

**Block 00 status: VALIDATED.**

---

# 17. Next allowed action

Block 00 validation authorizes:

```text
BLOCK 01 — BLANK SCREEN SHELL
Operation: CREATE
Target: scr_Home_PDS
Scope:
  - blank screen
  - root AutoLayout
  - existing shared sidebar
  - empty PDS content shell
Out of scope:
  - header
  - KPI
  - flows
  - business collections
  - heatmap
  - pie chart
  - discipline bars
  - grid
  - Punch Review navigation
```

The objective of Block 01 is to prove the new screen can exist safely beside `scr_Home` before any business logic is introduced.
