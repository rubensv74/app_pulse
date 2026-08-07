# HOME_PDS — Screen Architecture

**Status:** Frozen for first construction pass / Block 00 validated  
**Screen:** `scr_Home_PDS`  
**Validation date:** 2026-08-07  

---

## 1. Architecture objective

Home_PDS is an **Operational Control Tower** with a **Data Explorer** as a subordinate pattern.

The architecture must preserve this hierarchy:

```text
Executive awareness
        ↓
Operational concentration / hotspot discovery
        ↓
Active context
        ↓
Action
        ↓
Record-level investigation
```

The Data Explorer does not become the page. The charts do not become decorative dashboards. Every major visualization must be able to create or refine an actionable context.

---

## 2. Frozen control tree

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

---

## 3. Layout responsibilities

### `conHPDS_ScreenRoot`

- full-screen horizontal AutoLayout;
- owns only sidebar + content relationship;
- must not contain business logic.

### `cmpHPDS_Sidebar`

- shared `cmp_SidebarNav` instance;
- active business key remains `Home`;
- Home_PDS is not a new top-level module.

### `conHPDS_ContentShell`

- vertical AutoLayout;
- consumes PDS PageBg;
- owns screen-level padding/gaps;
- must not own data transformations.

### `conHPDS_PageHeaderHost`

- contextual page identity and selectors;
- no normal-card shadow;
- future canonical PDS Page Header host.

### `conHPDS_KpiStrip`

- executive-density row;
- four KPIs only in v1;
- responsive stacking handled structurally, not by shrinking text below PDS scale.

### `conHPDS_AnalyticsGrid`

- primary analytical workspace;
- heatmap is the dominant visual area;
- discipline panel is the secondary analysis/control area;
- both create shared active context.

### `conHPDS_DisciplinePanel`

The discipline panel uses two complementary visual encodings of the **same distribution and the same selection state**:

```text
cmpHPDS_DisciplinePie
    → part-to-whole perception

conHPDS_DisciplineBarsHost
    → ranking + precise relative comparison
```

The pie is the primary composition visualization because the business question is the distribution of a meaningful total across disciplines. The bars are not a second independent chart state; they are a complementary analytical control.

Selection contract:

```text
Pie segment ─────┐
                 ├──> shared selected discipline ──> Active Context ──> Data Explorer
Discipline bar ──┘
```

Rules:

- `cmp_PieChartPro` is the selected component for `cmpHPDS_DisciplinePie`;
- pie slices and bars use the stable discipline palette;
- selecting either representation selects the same discipline;
- selected state also uses the common PDS selection language;
- the pie must not create private chart-only business state;
- when discipline cardinality makes a pie unreadable, bars remain the precision surface and a later approved block may adapt the pie presentation without changing the shared selection contract.

### `conHPDS_ActiveContext`

- compact bridge between analytics and record exploration;
- displays current operational context and available actions;
- prevents action ambiguity.

### `conHPDS_DataExplorer`

- dense record-level workspace;
- consumes authoritative paged results;
- does not load the entire punch population client-side.

### `conHPDS_OverlayLayer`

- help, future drawer and modal surfaces;
- does not change document flow when hidden;
- overlay controls must not become a dumping ground for unrelated runtime logic.

---

## 4. Component strategy

```text
cmp_SidebarNav       → reuse
cmp_KpiCardPro       → reuse with PDS inputs
cmp_HeatMapPro       → reuse with PDS inputs
cmp_PieChartPro      → preferred discipline composition chart
cmp_DonutPro         → not used for Home_PDS discipline distribution
cmp_ActionToolbarPro → reuse with Home_PDS action table
cmp_DataTableProV2   → reuse with PDS inputs
cmp_EmptyState       → reuse/harden
cmp_SkeletonLoader   → reuse/harden
```

`cmp_DonutPro` remains available in the broader PDS/component catalog for use cases where a central KPI plus ring progression is the correct encoding, such as completion, utilization, capacity or readiness. It is not the selected encoding for discipline share in Home_PDS.

New shared components should only be introduced when they solve a repeated PDS contract rather than a one-off Home layout problem.

Primary likely new shared component:

```text
cmp_PageHeaderPro
```

Potential later shared component:

```text
cmp_PanelHeaderPro
```

Do not create screen-local copies of existing Pro components.

---

## 5. Responsive strategy

Target bands inherit the current PULSE desktop-first behavior unless later visual validation proves a better threshold:

```text
Desktop: >= 1400
Tablet:  900–1399
Compact: < 900
```

Rules:

- desktop: KPI strip horizontal; analytics two-column;
- tablet: header context may wrap; analytics may stack when needed;
- compact: central analytical content takes priority; avoid horizontal page overflow;
- table-specific horizontal scrolling is acceptable when necessary;
- minimum readable PDS type sizes are preserved.

Exact breakpoints remain implementation details until the relevant layout block is validated in Studio.

---

## 6. State ownership

State should be split by responsibility.

### App/global state

Use existing truly global project/user/navigation state and PDS tokens.

### Home_PDS UI state

New screen-local/global variables use `varHPDS_` only when isolation is useful, for example:

```text
varHPDS_IsLoading
varHPDS_Error
varHPDS_SelectedDisciplineCode
varHPDS_SelectedSubcontractorId
varHPDS_SelectedCategoryCode
varHPDS_GridPage
varHPDS_GridPageSize
varHPDS_GridSortKey
varHPDS_GridSortDirection
```

Exact variables are not created until Block 05. Names above are architectural candidates, not runtime commitments.

### Presentation collections

Normalize remote contracts into screen-facing presentation collections. Do not make components parse large backend JSON contracts directly.

---

## 7. Data authority

```text
Power Apps component → presentation only
Home_PDS screen      → orchestration/presentation model
Power Automate       → connector/orchestration boundary
SQL warroom          → remote business/data authority
```

Paging metadata returned by the backend is authoritative.

Snapshot generation and aggregation remain server-side.

---

## 8. Selection contract

All analytical selection must converge into one active context.

Conceptually:

```text
Heatmap selection
      ┐
      │
Pie selection ────────┐
                      ├──> Active Context ──> Cell details / Data Explorer
Discipline bar ───────┘
```

Pie and bars represent the same discipline dimension and therefore must share one selected-discipline state.

PDS selection language:

```text
SelectedBg     #EFF6FF
SelectedBorder #91CAFF
SelectedAccent #1677FF
```

Discipline colors remain data colors inside the selected object.

---

## 9. Actions contract

Only one local primary action should dominate the Active Context:

```text
Review → primary
```

Other actions are subordinate:

```text
Open Punch List → secondary
Refresh         → utility
Export          → utility
Comment         → utility
Columns         → view
Density         → view
Clear context   → neutral
More            → overflow
```

The Home_PDS screen must not infer destructive semantics from the word `Clear`.

---

## 10. Architectural exclusions for v1

The following are outside the first Home_PDS implementation unless explicitly reintroduced by a later approved requirement:

```text
- cloning the legacy Home control tree;
- legacy Task/Hive dashboard responsibilities;
- replacing existing SQL snapshot architecture;
- loading all punches client-side;
- redesigning global navigation as part of Home_PDS;
- changing StartScreen before final cutover;
- embedding components inside galleries where the existing PULSE compatibility rules prohibit it;
- new arbitrary visual tokens outside PDS.
```

---

## 11. Architecture change policy

Block 00 is validated. Any change that alters a major branch of this frozen tree must now be documented before implementation.

A change such as replacing the discipline panel with a drawer, adding a permanent fourth page column, or moving the Data Explorer above analytics is an **architecture change**, not a cosmetic patch.

Minor internal component structure may evolve inside its own block without reopening the complete architecture.
