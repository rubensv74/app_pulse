# P4+ Overview PDS — premium reconstruction strategy

## 1. Decision

PULSE will not redesign `scr_Overview` in place.

The current screen remains the functional reference and fallback. A new independent
screen named `scr_Overview_PDS` will be built from an empty screen through cumulative
Source Code blocks.

```text
scr_Overview       = current functional reference; frozen
scr_Overview_PDS   = premium candidate; isolated construction
```

No block may replace, rename, or modify `scr_Overview`. Navigation will continue to
use the current screen until the premium candidate passes its final comparison and
an explicit promotion decision is made.

## 2. Product purpose that must be preserved

Overview is the Project Handover Report workspace. It must let a user:

1. work inside the active project;
2. read the published report structure by subsystem and report hierarchy;
3. understand task and Punch metrics in that structure;
4. filter and page subsystem results;
5. refresh and read the latest snapshot;
6. open Tasks or Punch List in the selected subsystem/report context;
7. return to Overview without losing the relevant context.

It is not a generic executive dashboard. Premium design must improve comprehension,
hierarchy, density, feedback and actionability without changing this purpose.

## 3. Experience direction

The premium screen follows the same design quality target as Punch Review:

- clear page identity and project context;
- one dominant workspace rather than a collection of unrelated cards;
- visible loading, empty, no-configuration and error states;
- compact but legible operational density;
- actions adjacent to the context they affect;
- restrained PULSE blue palette, neutral surfaces and no violet;
- no decorative charts without a business question;
- responsive behavior designed structurally, not by shrinking everything.

### Proposed page hierarchy

```text
Application shell
  Page identity + project/report context + Refresh
  Report context strip
  Report-family tabs + subsystem filter
  Dominant handover matrix
  Pagination / horizontal navigation / freshness
  Loading, empty, error and help overlays
```

The matrix remains visually dominant. The context strip may show only facts already
available from the current snapshot contract, such as project, selected report
family, subsystem count and last refresh. New KPIs must not be invented before their
source and meaning are proven.

## 4. Frozen first-pass control tree

```text
scr_Overview_PDS
└── conOPDS_ScreenRoot
    ├── cmpOPDS_Sidebar
    └── conOPDS_ContentShell
        ├── conOPDS_PageHeaderHost
        │   └── cmpOPDS_PageHeader
        ├── conOPDS_ReportContext
        ├── conOPDS_CommandBar
        │   ├── conOPDS_ReportTabs
        │   ├── cmbOPDS_Subsystem
        │   └── cmpOPDS_Actions
        ├── conOPDS_MatrixCard
        │   ├── conOPDS_MatrixHeader
        │   ├── galOPDS_SubsystemRows
        │   └── conOPDS_MatrixFooter
        └── conOPDS_OverlayLayer
            ├── cmpOPDS_Skeleton
            ├── cmpOPDS_EmptyState
            ├── conOPDS_ErrorState
            └── conOPDS_HelpModal
```

Names become frozen after Block 01 is accepted unless Studio proves an incompatibility.

## 5. Component strategy

### Reuse now

| Component | Decision | Reason |
|---|---|---|
| `cmp_SidebarNav` | Reuse | Existing application shell and navigation language. |
| `cmp_PageHeaderPro` | Reuse through manual Studio insertion | `INSTANCE_SAFE` evidence exists; host-side public bindings require the proven manual insertion route. |
| `cmp_EmptyState` | Reuse if its current public contract fits | Avoid duplicating standard state presentation. |
| `cmp_SkeletonLoader` | Reuse if instance-safe in this host | Provides premium loading feedback without business logic. |
| `cmp_ActionToolbarPro` | Evaluate for Refresh, Clear and Help | Reuse only if its action-table contract remains clear at Overview density. |

### Do not componentize yet

The first functional matrix remains screen-native. It owns:

- report hierarchy and active L1 tab;
- subsystem rows;
- metric cells;
- fixed columns and horizontal offset;
- paging;
- Tasks/Punches drill-through;
- screen loading and selection state.

Premature extraction would hide dependencies and make Source Code failures harder to
diagnose.

### Component candidate after stabilization

`cmp_ReportMatrixPro` may be proposed only after the screen-native matrix passes the
functional and visual gates and a second credible consumer exists. Before extraction
it needs an explicit contract for headers, rows, cells, selection, paging, actions,
loading, empty/error states and maximum supported volume.

Small screen-local visual groups must not be turned into components merely to increase
the number of reusable artifacts.

## 6. State and data ownership

The premium screen will use an `OPDS` namespace for local variables and collections
during construction. This prevents collisions with the current screen and allows both
screens to coexist.

Examples:

```text
varOPDS_IsLoading
varOPDS_IsRendering
varOPDS_Loaded
varOPDS_Error
varOPDS_Page
varOPDS_PageSize
varOPDS_SelectedL1NodeId
varOPDS_SelectedSubsystemCode

colOPDS_Subsystems
colOPDS_Headers
colOPDS_Metrics
colOPDS_RowCells
```

Global project identity remains shared:

```text
varProjectId
varSelectedProject
```

The first data pass must consume the existing flow contracts without changing them:

```text
warroom_GenerateOverviewSnapshot(ProjectId)
Warroom_GetOverviewSnapshot(ProjectId, SubsystemCode, Page, PageSize)
```

SQL and Power Automate changes are outside the first reconstruction pass. If a premium
capability later needs a new field, that becomes a separate contract decision, not a
silent screen assumption.

## 7. Incremental capability sequence

Blocks are construction units inside capabilities. Each accepted block updates the
complete cumulative `scr_Overview_PDS` snapshot.

### Capability OPDS-C01 — premium shell and visual state surfaces

**User result:** The user can open a clearly branded Overview candidate and review
the intended visual treatment for loading, no-project, no-configuration, no-data,
error and ready states using controlled test-state selection.

**Risk:** B.

**Acceptance:**

1. `scr_Overview_PDS` exists independently and `scr_Overview` remains unchanged.
2. The application shell, sidebar and premium header render at the target viewport.
3. Each planned state surface can be displayed deliberately through a local
   `varOPDS_VisualTestState` selector or equivalent temporary test mechanism.
4. Only one state surface is visible at a time and no surface obscures the shell when
   its test state is inactive.
5. Text hierarchy, spacing, actions and visual language are suitable for later data
   binding.
6. No C01 result is described as evidence that a real project has no configuration,
   no data or a flow error.

**Validation:** One grouped Studio visual validation using synthetic/local test
states only. Confirm Source Code acceptance, component instantiation, layout and
state exclusivity. Do not invoke or assess the Overview flows in C01.

| Block | Content | Validation |
|---|---|---|
| 00 | Architecture, geometry and dependency contract | Repository review only. |
| 01 | Empty `scr_Overview_PDS`, application shell and sidebar | Studio accepts complete screen; original screen unchanged. |
| 02 | `cmp_PageHeaderPro` manual instance and Overview bindings | Header renders with project identity and Refresh/Help actions. |
| 03 | Visual loading, no-project, no-configuration, no-data, error and ready surfaces | Each synthetic test state is visually distinct and does not overlap; no data classification is claimed. |

### Capability OPDS-C02 — report snapshot workspace

**User result:** The user can load/refresh the Project Handover Report and see its
report families and subsystem scope.

**Risk:** B.

**Acceptance:**

1. The existing Generate and Get Overview flow contracts are connected without
   changing their parameters.
2. Flow responses populate typed `OPDS` collections without mutating the current
   `scr_Overview` state.
3. Classification rules map real outcomes to exactly one screen state: loaded,
   no-configuration, no-data or error.
4. “No configuration” is demonstrated only from a stable structured discriminator
   in the real producer contract, such as an explicit result code/field or a distinct
   documented response shape, for a project without a published configuration.
   `FirstError.Message`, substring searches, translated connector text and any other
   free-text interpretation are forbidden as classification logic.
5. “No data” is demonstrated only from a successful real response whose published
   configuration produces no subsystem/report rows.
6. “Error” is demonstrated only from a genuine failed call or returned error outcome;
   it is not simulated and is not created deliberately in a shared environment.
7. When a real case is unavailable, its classification remains `NOT_RUN`; static
   inspection or C01 visual-state switching cannot promote it to demonstrated.
8. If the current producer contract does not expose a stable discriminator for
   no-configuration, that case remains `NOT_RUN` and the missing contract is recorded;
   C02 must not compensate by parsing error prose.
9. Refresh, freshness, tabs, filter and page reset use the connected response and
   leave the screen in a consistent state.

**Validation:** One grouped data/runtime validation. Record the project used, stable
structured discriminator or response shape, raw classification evidence safe to
retain, resulting OPDS state and visible surface for each executed case. Cases
unavailable in the environment, or unsupported by a stable producer discriminator,
must be listed explicitly as `NOT_RUN`.

| Block | Content | Validation |
|---|---|---|
| 04 | Existing flow calls, typed OPDS collections and structured real-outcome classification | At least one real project loads; every demonstrable outcome maps through a stable discriminator to one state without changing `scr_Overview`; unavailable/ambiguous cases remain `NOT_RUN`. |
| 05 | Report context strip and freshness | Project, selected family, subsystem count and refresh time agree with response. |
| 06 | L1 tabs, subsystem filter, clear and page reset | Controls rebuild the same loaded context predictably. |

### Capability OPDS-C03 — premium handover matrix

**User result:** The user can read the report matrix efficiently across subsystems,
metrics and report hierarchy.

**Risk:** B.

| Block | Content | Validation |
|---|---|---|
| 07 | Matrix skeleton, fixed context columns and responsive width budget | Geometry works at 1600×900 before real cells. |
| 08 | Hierarchical header and metric cells | Values match the current Overview for the same project/page. |
| 09 | Selection language, status treatment and horizontal navigation | Selected row/tab remains obvious and scroll remains aligned. |
| 10 | Paging and filtered-result feedback | Counts and navigation agree with the flow response. |

### Capability OPDS-C04 — contextual action flow

**User result:** The user can move from a subsystem row to Tasks or Punch List and
return to the premium Overview context.

**Risk:** B.

| Block | Content | Validation |
|---|---|---|
| 11 | Tasks drill-through contract | Correct subsystem/report scope and return target. |
| 12 | Punch List drill-through contract | Correct subsystem/template scope and return target. |
| 13 | Dirty/loading guard and re-entry restoration | No accidental navigation during load; context restored. |

### Capability OPDS-C05 — visual QA and promotion decision

**User result:** A premium candidate can be compared objectively with the current
Overview and either promoted or rejected without losing the original.

**Risk:** B.

| Block | Content | Validation |
|---|---|---|
| 14 | Responsive, accessibility, overflow and performance hardening | Desktop and compact evidence; App Checker. |
| 15 | Help content and final visual polish | One complete user journey and screenshot set. |
| 16 | Side-by-side parity and premium-value review | Explicit promote / continue / reject decision. |

## 8. Validation cadence

Do not validate every visual property independently.

```text
OPDS-C01 -> one Studio visual validation with synthetic/local states; no real-state proof
OPDS-C02 -> one data/runtime validation with real classification evidence
OPDS-C03 -> one matrix parity + visual validation
OPDS-C04 -> one end-to-end navigation validation
OPDS-C05 -> one final QA and promotion review
```

A consolidated FIX is prepared after each capability only if real defects appear.
The target is one manual Studio round-trip per capability and no more than two when a
FIX batch is necessary.

## 9. Promotion rules

`scr_Overview_PDS` must not replace the current route until all are true:

1. Source Code accepted by Studio;
2. App Checker has no new blocking errors;
3. the same project/page produces materially equivalent report values;
4. Refresh, filter, tabs, paging and horizontal alignment work;
5. Tasks and Punch List drill-through and return work;
6. loading, empty, no-configuration and error states are proven;
7. 1600×900 visual QA is approved;
8. cumulative source is synchronized to the repository;
9. Rubén explicitly chooses promotion.

Until then, `scr_Overview` remains the operational route and rollback is simply to
keep using it.

## 10. First implementation package

The next delivery should implement **OPDS-C01 as one coherent package**, containing
Blocks 01–03. Block 00 is this approved strategy.

It must provide:

- complete `scr_Overview_PDS.pa.yaml` candidate;
- manual Studio insertion instructions for `cmp_PageHeaderPro` if required;
- exact navigation entry used only for test access;
- temporary local visual-state selector for the six planned surfaces;
- one grouped Studio visual validation without flow execution;
- updated cumulative source after validation;
- no changes to `scr_Overview`, SQL or Power Automate.

The first package must label no-configuration, no-data and error as **visual
candidates**, not demonstrated operational states. Their real classification and
evidence belong exclusively to OPDS-C02.
