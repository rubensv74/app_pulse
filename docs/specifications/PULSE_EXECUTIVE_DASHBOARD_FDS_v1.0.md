PULSE EXECUTIVE DASHBOARD
Functional Design Specification (FDS)
Version 1.0
BLOQUE 01
Vision, Scope and Design Principles
1. Document Purpose
1.1 Objective

This document defines the complete functional specification of the Executive Punch Dashboard implemented in the Home_1 screen of the PULSE application.

Its purpose is to provide a definitive implementation guide for the development team and for AI-assisted development tools such as Codex.

Once approved, this specification becomes the single source of truth for the Executive Dashboard.

No design decisions shall be taken outside this document.

1.2 Audience

This document is intended for:

Power Apps Developers
Power Platform Architects
Azure SQL Developers
Power Automate Developers
Technical Product Owners
Functional Analysts
Codex
1.3 Relationship with Existing Documentation

This document complements—but does not replace—the following project documentation:

PULSE Development Framework
SQL Specifications
Flow Specifications
Navigation Specifications
Data Contracts
Component Library

Whenever contradictions exist, this document has priority regarding the Executive Dashboard.

2. Product Vision

The Executive Dashboard is not another Power Apps screen.

It is the primary decision-making interface for Construction Management and Commissioning teams.

The dashboard must allow a Project Manager to understand the status of thousands of Punches in less than thirty seconds.

The entire design is therefore driven by information hierarchy rather than by visual decoration.

Every pixel must contribute to faster decision making.

No visual element may exist purely for aesthetic purposes.

3. Design Philosophy

The current implementation evolved incrementally over multiple iterations.

Although functionally valuable, it no longer reflects the intended user experience.

Rather than continuing to evolve the existing layout, the dashboard will be rebuilt around a single approved design.

The approved design is represented by the reference image accepted by the Product Owner.

That image is not inspiration.

It is the specification.

4. Fundamental Rule

The approved dashboard image is considered the canonical implementation.

Whenever the existing Home_1 implementation differs from the approved image:

The approved image always prevails.

Existing controls may be reused.

Existing components may be reused.

Existing SQL procedures shall be reused whenever technically feasible.

Existing collections shall be reused whenever technically feasible.

However:

The visual behaviour shall always match the approved dashboard.

5. Product Goals

The Executive Dashboard has five business objectives.

Goal 1

Allow executive users to immediately identify where Punches are concentrated.

Goal 2

Allow instant drill-down without navigating away from the screen.

Goal 3

Provide a visual representation requiring minimal explanation.

A new project member should understand the dashboard within minutes.

Goal 4

Reduce navigation between Home and Punch List.

The majority of investigations should begin directly from the Executive Dashboard.

Goal 5

Provide a premium user experience representative of the PULSE platform.

6. Scope

This specification applies exclusively to:

Home_1

specifically to the Executive Punch Dashboard section.

It does not define:

Task Dashboard
Premium Drawer implementation
Export Flow implementation
Configuration screens
Administration screens

These modules have independent specifications.

7. Out of Scope

The following activities are explicitly excluded:

SQL redesign
Database normalization
Flow refactoring
Navigation redesign
Authentication changes
Performance optimization unrelated to the dashboard
Repository cleanup
Legacy screen deletion
8. Repository Policy

This specification adopts the following repository principles.

Legacy objects

Legacy screens are intentionally preserved.

Deletion is prohibited.

When required they may be renamed using the suffix:

_legacy

Example:

scr_Home_legacy

This allows safe rollback during development.

Experimental components

Experimental components may coexist with production components.

Only the Product Owner may authorize their removal.

Repository cleanliness

Repository cleanliness is not considered an implementation objective.

Functional completeness always has priority.

9. Design Priorities

When conflicts occur, priorities shall be resolved using the following order.

Priority 1

Functional correctness.

Priority 2

Visual fidelity.

Priority 3

User experience.

Priority 4

Performance.

Priority 5

Code elegance.

This ordering shall never be inverted.

10. Constraints

The implementation shall preserve whenever technically possible:

Existing SQL Stored Procedures.
Existing Power Automate Flows.
Existing collections.
Existing Power Fx formulas.
Existing global variables.
Existing navigation contracts.

Visual redesign shall never imply unnecessary architectural redesign.

11. Codex Responsibilities

Codex acts exclusively as an implementation agent.

Codex shall not redesign the product.

Codex shall not reinterpret the dashboard.

Codex shall not simplify the interface.

Codex shall not introduce alternative layouts.

Codex shall not replace the approved visual hierarchy with its own interpretation.

Whenever ambiguity exists, Codex shall preserve the approved design rather than making assumptions.

12. Definition of Success

The implementation will be considered successful only when:

A side-by-side comparison between the implemented dashboard and the approved reference image shows no meaningful visual differences.
Existing business logic continues to operate correctly.
Navigation remains compatible with the current PULSE application.
Existing SQL procedures remain reusable.
Existing collections remain reusable.
Executive users can perform the same analysis shown in the approved design without additional navigation.


13. Purpose of this Assessment

The purpose of this chapter is to analyse the existing implementation of Home_1 from a functional and architectural perspective.

This assessment is not a code review.

It is an engineering exercise intended to determine:

what must remain,
what must be replaced,
what must be reorganised,
what technical assets can be reused during implementation.

The current screen represents several months of development effort and contains valuable business logic.

However, it no longer represents the desired user experience.

Therefore, the implementation strategy is evolutionary reuse with complete visual replacement.

14. Guiding Principle

The current screen is considered an implementation platform.

It is not considered the visual baseline.

The approved dashboard image replaces the current visual hierarchy.

Consequently:

Business logic is preserved.

Presentation layer is redesigned.

15. Assets to Preserve

The following elements constitute project knowledge accumulated during previous iterations.

They shall be preserved whenever technically possible.

15.1 SQL Layer

The Executive Dashboard shall continue using the existing SQL architecture.

Existing Stored Procedures already encapsulate the business rules required by the dashboard.

Unless a defect is identified, SQL shall not be rewritten.

The dashboard redesign is a presentation project rather than a database project.

15.2 Collections

Existing Power Apps collections represent an important architectural investment.

Collections currently used for dashboard generation shall remain the primary data source.

Typical examples include:

Dashboard Matrix collections.
KPI collections.
Dashboard detail collections.
Summary collections.
Supporting lookup collections.

New collections shall only be introduced when absolutely necessary.

15.3 Variables

Existing global variables shall be preserved.

Examples include:

Current Project
Current Template
Current Filters
Loading States
Dashboard Selection
Navigation Context

Variable renaming is discouraged.

15.4 Navigation

Navigation between screens has already been standardised.

The redesign shall preserve:

navigation routes,
parameter passing,
context variables,
return behaviour.

The Executive Dashboard must remain compatible with the remainder of the PULSE application.

16. Components Requiring Replacement

The following sections are considered obsolete from a UX perspective.

They shall be removed from the visual hierarchy.

Executive Insights

The current Executive Insights cards occupy valuable screen real estate without providing immediate operational value.

They are replaced by the new dashboard layout.

Snapshot Timeline

The timeline introduces unnecessary visual complexity.

Its information value is significantly lower than the heatmap.

The timeline is removed.

TOP Summary

The TOP Summary duplicates information that will be available through the heatmap drill-down.

It shall be removed.

Subcontractor Summary

The current subcontractor panel is replaced by interactive filtering inside the Punch Grid.

No dedicated panel shall remain.

17. Components to Reuse

Several existing elements already satisfy functional requirements.

These shall be retained and visually adapted where necessary.

Project Selector

The current project selector already fulfils its purpose.

Only cosmetic improvements are allowed.

Its behaviour shall remain unchanged.

Template Selector

The existing template selector shall be preserved.

The redesign shall not modify its functional behaviour.

Refresh Action

The refresh mechanism shall remain identical.

Only its visual appearance may change.

KPI Data Sources

The existing KPI calculations shall remain valid.

Only the presentation layer shall change.

18. Current UX Weaknesses

The current implementation presents several usability issues.

These observations define the motivation for the redesign.

18.1 Information Density

The dashboard distributes information across numerous independent blocks.

Users must visually scan the entire screen before understanding project status.

The redesign concentrates the most important information into a single visual focal point.

18.2 Visual Hierarchy

Current widgets compete equally for user attention.

No clear hierarchy exists.

The redesign introduces three hierarchical levels:

Level 1

Heatmap

Level 2

KPI Cards

Donut

Detail Panel

Level 3

Punch Grid

18.3 Navigation Cost

Several investigations currently require leaving the Home screen.

The redesign minimises navigation by providing immediate drill-down capabilities.

18.4 Screen Utilisation

Large portions of the current screen remain underutilised.

The approved design increases information density without sacrificing readability.

19. Technical Debt

The redesign acknowledges the existence of technical debt.

However, technical debt shall not delay functional improvements unless it introduces one of the following:

compilation failures,
execution failures,
data inconsistency,
navigation failures,
visual corruption.

All other debt shall be documented for future remediation.

20. Legacy Objects

Legacy screens, controls and components may coexist with the redesigned implementation.

Examples include:

previous Home screens,
experimental controls,
archived components,
temporary galleries.

Deletion is prohibited during this implementation phase.

When differentiation is required, the suffix _legacy shall be applied.

This policy guarantees safe rollback.

21. Expected Mapping

The redesign follows the mapping below.

Existing Element	Future State
Project Selector	Reused
Template Selector	Reused
Refresh	Reused
KPI Calculations	Reused
KPI Cards	Restyled
Executive Insights	Removed
Timeline	Removed
TOP Summary	Removed
Subcontractor Summary	Removed
Dashboard Matrix	Expanded into Executive Heatmap
Existing Filters	Reused
Existing Navigation	Reused
Existing SQL	Reused
Existing Collections	Reused
22. Risks

The redesign must avoid introducing regressions in the following areas:

project switching,
template switching,
loading indicators,
dashboard refresh,
SQL execution,
navigation to Punches_1,
global application state.

Each implementation phase shall include regression validation.

23. Success Criteria for the Migration

The migration from the current dashboard to the new Executive Dashboard will be considered complete only when:

all obsolete panels have been removed,
the new layout occupies the entire available workspace,
existing business logic remains operational,
no SQL redesign has been required,
no navigation regression has been introduced,
the dashboard behaves as a single integrated analytical workspace.
24. Deliverables Produced by This Phase

At the conclusion of the assessment phase, the development team shall possess:

a complete inventory of reusable assets,
a complete inventory of obsolete visual components,
a migration map between the existing implementation and the target dashboard,
a clear separation between business logic and presentation logic,
an agreed baseline for implementation.

No coding activities shall begin until this assessment has been accepted by the Product Owner.

25. Purpose of this Chapter

This chapter defines the visual architecture of the Executive Dashboard.

Unlike the previous chapter, this section does not analyse the existing implementation.

Instead, it establishes the design rules that the new dashboard shall follow.

The approved reference image is considered the canonical design.

Every layout decision described in this chapter originates from that image.

No alternative interpretation is permitted.

26. Design Philosophy

The Executive Dashboard has been designed as an executive analytical workspace rather than as a conventional Power Apps screen.

Traditional Power Apps applications frequently present information as independent controls distributed vertically.

The Executive Dashboard intentionally rejects this approach.

Instead, it adopts the principles commonly found in Business Intelligence platforms.

The screen behaves as a single analytical canvas.

Each visual block contributes to one continuous decision-making process.

Users should perceive one dashboard—not multiple independent widgets.

27. Visual Hierarchy

The dashboard establishes four levels of visual importance.

Level 1 — Executive Focus

The Heatmap.

This is the centre of the application.

Everything else exists to support it.

The Heatmap occupies the greatest amount of space because it answers the most important executive question:

"Where are the Punches concentrated?"

Every other control derives its context from the current Heatmap selection.

Level 2 — Executive Summary

The KPI cards.

These cards answer:

How many Punches exist?
How many are Open?
How many are Overdue?
How many are Completed?
What is the overall trend?

The KPI cards provide context before analysis begins.

Level 3 — Contextual Analysis

The Donut Chart.

The Detail Panel.

These controls explain the current Heatmap selection.

They never become the primary visual focus.

Level 4 — Operational Detail

The Punch Grid.

The grid represents the deepest level of information.

Users arrive here only after narrowing the analysis.

28. Reading Flow

The dashboard shall guide the user's eyes naturally.

The expected reading sequence is:

Header

↓

KPI Cards

↓

Heatmap

↓

Donut

↓

Selected Cell Panel

↓

Punch Grid

Any implementation that causes users to read the interface in a different order shall be considered incorrect.

29. Dashboard Grid System

The Executive Dashboard follows a structured grid.

No control may be positioned arbitrarily.

The layout is divided into three horizontal bands.

Band 1

Application Header.

Full width.

Contains:

Project selector.
Template selector.
Refresh.
Action buttons.

Height remains constant.

Band 2

Executive Analytics Area.

Contains:

KPI Cards.
Heatmap.
Donut.
Detail Panel.

This band occupies approximately seventy percent of the screen height.

It represents the analytical workspace.

Band 3

Operational Detail Area.

Contains:

Punch Grid.

Occupies the remaining vertical space.

The grid expands as required.

30. White Space Strategy

White space is intentional.

It exists only to improve readability.

Large unused areas are prohibited.

Every empty area must satisfy one of the following purposes:

visual separation,
breathing room,
hierarchy reinforcement.

Whitespace shall never reduce the information density of the dashboard.

31. Symmetry

The dashboard is strongly symmetrical.

The following elements shall align perfectly:

KPI cards.
Header controls.
Heatmap.
Donut.
Detail panel.
Punch grid.

Visible misalignment shall be treated as a defect.

32. Horizontal Balance

The Heatmap dominates the left side.

The Donut occupies the upper-right area.

The Detail Panel occupies the lower-right area.

Together, these three blocks form one balanced analytical region.

None of these blocks may be resized independently without Product Owner approval.

33. Vertical Rhythm

The dashboard follows a consistent rhythm.

Each section begins with:

title,
content,
spacing,
next section.

Margins remain consistent throughout the screen.

Spacing must appear intentional rather than automatic.

34. Typography Hierarchy

The interface contains four typography levels.

Executive KPI

Largest typography.

Reserved exclusively for KPI values.

Never reused elsewhere.

Section Titles

Used for:

Heatmap
Punch Distribution
Selected Details
Punch List

All titles share identical style.

Operational Labels

Used inside charts.

Must remain readable at executive viewing distance.

Supporting Information

Used for:

descriptions,
legends,
secondary values,
helper text.

Supporting text shall never compete visually with KPIs.

35. Colour Strategy

Colour communicates information.

It is not decoration.

The dashboard shall maintain a restrained colour palette.

Primary colours identify interaction.

Neutral colours organise structure.

Semantic colours communicate status.

The Heatmap alone is authorised to display a full intensity colour scale.

36. Contrast

Important information must attract attention without excessive saturation.

Contrast shall be achieved primarily through:

size,
spacing,
typography,
positioning.

Colour shall reinforce—not replace—hierarchy.

37. Card Design

Every dashboard card follows identical principles.

Each card contains:

background,
border,
padding,
icon,
title,
value,
optional description.

Cards must appear as belonging to the same design system.

No individual styling is permitted.

38. Heatmap Position

The Heatmap occupies the dominant position.

Approximate proportions:

Width: 70% of analytical area.
Height: 100% of analytical area.

It is visually impossible to mistake another component for the dashboard's primary element.

39. Donut Position

The Donut occupies the upper-right quadrant.

It shall never extend below the Detail Panel.

The Donut is secondary to the Heatmap but more prominent than the Punch Grid.

40. Detail Panel Position

The Detail Panel occupies the remaining right-hand space beneath the Donut.

It behaves as contextual information.

It never competes visually with the Heatmap.

41. Punch Grid Position

The Punch Grid spans the full dashboard width.

It acts as the natural continuation of the analytical workflow.

Its visual boundaries align perfectly with the dashboard margins.

42. Visual Consistency

Every component shall appear to belong to the same product.

Consistency applies to:

shadows,
corner radius,
borders,
spacing,
typography,
colours,
icons,
interaction feedback.

Introducing alternative visual styles within the dashboard is prohibited.

43. Visual Anti-Patterns

The following design decisions are expressly forbidden:

Oversized cards that reduce analytical space.
Multiple competing focal points.
Large decorative empty areas.
Independent widgets disconnected from the analytical flow.
Random spacing.
Inconsistent margins.
Different border radii between panels.
Different shadow styles.
Different typography scales.
Multiple accent colours without semantic meaning.

Any of these conditions shall be treated as implementation defects.

44. Pixel Fidelity Requirement

The Executive Dashboard is subject to Pixel Fidelity Validation.

This means that implementation success is evaluated through a side-by-side comparison between:

The approved design reference.
The implemented Power Apps screen.

Differences in hierarchy, proportions, spacing or visual balance shall be corrected before acceptance.

Minor implementation differences required by Power Apps limitations may be accepted only if they do not alter the perceived layout.

45. Outcome of this Chapter

At the completion of this chapter, the development team shall clearly understand:

how the dashboard is visually organised,
where each analytical block belongs,
why each block occupies its position,
how users read the dashboard,
which visual principles cannot be modified.

This chapter defines the visual language of the Executive Dashboard.

Subsequent chapters will describe the functional behaviour of each individual component.

46. Purpose

This chapter defines the physical architecture of the Executive Dashboard.

While the previous chapter described the visual philosophy, this chapter specifies how the dashboard shall be physically constructed inside Power Apps.

It establishes:

layout zones,
containers,
alignment rules,
responsive behaviour,
component hierarchy,
implementation constraints.

Once approved, this chapter becomes the construction blueprint for the Executive Dashboard.

47. Architectural Principle

The Executive Dashboard shall be implemented as one continuous analytical workspace.

The user must never perceive independent dashboards stacked vertically.

Instead, every section shall appear as part of one integrated executive workspace.

The implementation shall therefore prioritise:

continuity,
alignment,
information flow,
spatial consistency.
48. Root Layout

The Home_1 screen shall be divided into five major zones.

+--------------------------------------------------------------+
|                     EXECUTIVE HEADER                          |
+--------------------------------------------------------------+
|                        KPI STRIP                             |
+--------------------------------------------------------------+
|                     ANALYTICAL WORKSPACE                      |
|                                                              |
|  HEATMAP                         DONUT                       |
|                                  DETAIL                      |
+--------------------------------------------------------------+
|                     OPERATIONAL GRID                          |
+--------------------------------------------------------------+
|                       STATUS BAR                             |
+--------------------------------------------------------------+

No additional major zones are permitted.

49. Zone Responsibilities
Zone 1 — Executive Header

Purpose:

Application context.

Contains:

Project selector
Template selector
Refresh
Global actions

This zone never displays analytical information.

Zone 2 — KPI Strip

Purpose:

Immediate executive summary.

Contains exactly five KPI cards.

No charts.

No filters.

No secondary widgets.

Zone 3 — Analytical Workspace

Purpose:

Interactive analysis.

Contains only:

Heatmap
Donut
Detail Panel

This area occupies the largest portion of the screen.

Zone 4 — Operational Workspace

Purpose:

Detailed records.

Contains:

Punch Grid.

No charts.

Zone 5 — Status Layer

Purpose:

Transient information.

Examples:

Loading

Refreshing

Errors

Synchronization

This layer shall remain hidden during normal operation.

50. Container Hierarchy

The layout shall be constructed using nested containers.

Recommended hierarchy:

Home_1

 ├── RootContainer

      ├── HeaderContainer

      ├── KPIContainer

      ├── AnalyticsContainer

            ├── HeatmapContainer

            ├── RightContainer

                  ├── DonutContainer

                  ├── DetailContainer

      ├── GridContainer

      ├── OverlayContainer

This hierarchy shall remain stable throughout the project.

51. Layout Philosophy

The dashboard uses proportional rather than absolute sizing.

Widths shall adapt to available resolution.

Relative positioning shall always be preferred over fixed coordinates.

Only minimum dimensions may be fixed.

52. Header Layout

The Header is divided into three regions.

+------------------------------------------------------------+

 Project        Template

                        Refresh

                                Actions

+------------------------------------------------------------+

Objects shall remain horizontally aligned.

Vertical alignment shall always be centred.

53. KPI Layout

Exactly five KPI cards.

□□□□□□□□□□□□□□□□□
□□□□□□□□□□□□□□□□□
□□□□□□□□□□□□□□□□□
□□□□□□□□□□□□□□□□□
□□□□□□□□□□□□□□□□□

Rules:

Equal width.

Equal spacing.

Equal height.

Equal alignment.

Equal margins.

Cards shall resize proportionally.

54. Analytical Workspace

The analytical workspace is divided into two columns.

□□□□□□□□□□□□□□□□□□□□□□□□□□  □□□□□□□□□□□

□□□□□□□□□□□□□□□□□□□□□□□□□□  □□□□□□□□□□□

□□□□□□□□□□□□□□□□□□□□□□□□□□  □□□□□□□□□□□

□□□□□□□□□□□□□□□□□□□□□□□□□□  □□□□□□□□□□□

Left Column

Heatmap

Right Column

Donut

Detail Panel

55. Heatmap Area

The Heatmap receives approximately seventy percent of the analytical width.

Reasons:

primary interaction
largest information density
executive focus

No other control may reduce its usable size.

56. Right Analytical Column

The right column contains two vertically stacked elements.

Donut

-----------------

Selected Details

Both panels have identical width.

The Detail Panel expands vertically when required.

57. Punch Grid

The Punch Grid occupies the full dashboard width.

The grid begins immediately below the analytical workspace.

No independent margins shall exist.

The grid visually belongs to the dashboard rather than behaving as another page.

58. Margins

Outer margins remain constant.

Inner spacing remains constant.

Nested controls shall never invent additional spacing.

The dashboard must appear mathematically organised.

59. Alignment Rules

The following edges shall align perfectly.

Left edges:

Header
KPI strip
Heatmap
Grid

Right edges:

Header
Donut
Detail Panel
Grid

Top edges:

Heatmap
Donut

Bottom edges:

Heatmap
Detail Panel
60. Responsive Behaviour

The Executive Dashboard supports desktop-first operation.

Target resolution:

1920 × 1080

Secondary resolutions:

1600 × 900

1440 × 900

1366 × 768

Behaviour:

The dashboard scales proportionally.

Columns reduce width before reducing height.

Heatmap always remains the dominant visual element.

61. Scroll Behaviour

The preferred implementation contains a single vertical scroll.

Horizontal scrolling is prohibited.

Charts shall never introduce their own scrollbars.

Only the Punch Grid may scroll internally when required.

62. Layering

The interface contains three logical layers.

Layer 1

Dashboard

Layer 2

Dialogs

Layer 3

Loading overlays

Controls shall never overlap across layers unexpectedly.

63. Loading Strategy

During refresh:

Header remains visible.

KPI cards remain visible.

Analytical area displays loading state.

Punch Grid displays loading state.

No white flashes shall appear.

64. Empty States

Each analytical component defines its own empty state.

Heatmap

"No data available."

Donut

"No distribution available."

Detail Panel

"No selection."

Grid

"No Punches found."

The dashboard itself never becomes empty.

65. Error States

Errors shall remain local.

A Heatmap failure shall not hide:

Header

KPIs

Grid

Similarly:

Grid failures shall not remove Heatmap.

Component isolation is mandatory.

66. Power Apps Constraints

The implementation shall respect Power Apps limitations.

Specifically:

Avoid unnecessary nesting.

Avoid deep control hierarchies.

Avoid duplicated galleries.

Avoid expensive recalculations.

Reuse existing collections.

Avoid additional SQL calls.

67. Component Independence

Every major dashboard component shall expose a well-defined responsibility.

Heatmap

Selection.

Donut

Distribution.

Detail Panel

Context.

Grid

Records.

No component shall assume another component's responsibility.

68. Performance Objectives

The redesigned layout shall not increase loading time.

Preferred strategy:

Single SQL refresh.

Collections updated once.

Components refreshed through binding.

Avoid cascading recalculation chains.

69. Visual Integrity Rules

The following shall never occur:

Components touching each other.
Unequal spacing.
Misaligned borders.
Different padding values.
Floating controls.
Orphan labels.
Misaligned titles.

The dashboard must appear intentionally engineered.

70. Definition of Completion

The Layout Architecture shall be considered complete when:

every zone has been implemented,
every container exists,
every alignment rule is respected,
responsive behaviour has been validated,
spacing remains consistent,
visual balance matches the approved design.

No business logic is evaluated during this phase.

Only layout quality.

Executive Heatmap Functional Specification
71. Purpose

The Executive Heatmap is the central analytical component of the Executive Dashboard.

It is not a chart.

It is not a report.

It is not a summary.

It is the primary decision-making interface of the PULSE application.

Every analytical action performed by the user begins here.

The remaining dashboard components exist exclusively to provide additional context to the Heatmap selection.

If the Heatmap is removed, the dashboard loses its analytical identity.

72. Business Objective

The Executive Heatmap answers one executive question:

Where should management focus its attention right now?

Instead of forcing users to analyse long tables containing hundreds or thousands of Punches, the Heatmap compresses operational status into a single visual matrix.

The user should identify abnormal situations in less than five seconds.

73. Functional Responsibilities

The Heatmap has six responsibilities.

Responsibility 1

Display Punch distribution.

Responsibility 2

Display concentration.

Responsibility 3

Identify hotspots.

Responsibility 4

Drive dashboard navigation.

Responsibility 5

Synchronise every analytical widget.

Responsibility 6

Provide drill-down without leaving Home_1.

No additional responsibilities shall be assigned.

74. Data Source

The Heatmap shall not query SQL directly.

Its source shall be the existing dashboard collections already populated during the Home refresh process.

The refresh pipeline remains:

SQL Stored Procedure
        │
        ▼
Power Automate Flow
        │
        ▼
Power Apps Collections
        │
        ▼
Heatmap

The Heatmap is a presentation component only.

75. Matrix Structure

The Heatmap represents a two-dimensional matrix.

Rows and columns are defined by configurable business dimensions.

The implementation shall not hard-code the matrix structure.

The dashboard must support future changes to the underlying business dimensions without requiring a redesign.

76. Matrix Headers

Both axes are mandatory.

Horizontal Header

Displays the first business dimension.

Examples:

Status
Priority
Category

depending on the configured dashboard model.

Vertical Header

Displays the second business dimension.

Examples:

Subsystem
Discipline
Area

depending on configuration.

No axis may remain unlabeled.

77. Cell Definition

Every Heatmap cell represents one aggregated business state.

Each cell corresponds to exactly one combination of:

Row Dimension
        +

Column Dimension

The displayed value is the number of Punches belonging to that intersection.

No duplicated aggregation is permitted.

78. Cell Layout

Every cell shall contain:

numeric value
background colour
hover behaviour
selection behaviour

Optional icons are prohibited.

Progress bars are prohibited.

Decorative graphics are prohibited.

The Heatmap is intentionally minimalist.

79. Colour Scale

Colour communicates intensity.

It never communicates category.

The scale shall progress continuously from:

Low concentration

↓

Medium concentration

↓

High concentration

↓

Critical concentration

Only one colour scale shall exist.

Multiple competing palettes are prohibited.

80. Colour Calculation

The colour intensity shall be calculated from the visible dataset.

The calculation must adapt automatically after filtering.

Hard-coded thresholds are discouraged unless explicitly required by the Product Owner.

81. Zero Values

Cells containing zero Punches shall remain visible.

Reasons:

preserve matrix structure,
avoid shifting columns,
preserve user orientation.

Zero-value cells shall use the lightest colour in the palette.

82. Missing Values

Missing data differs from zero.

Zero means:

No Punches.

Missing means:

Unknown information.

Missing cells shall display a dedicated visual state.

83. Totals

The Heatmap shall display:

Horizontal totals.

Vertical totals.

Grand total.

Totals are part of the analytical model.

They are not optional.

84. Hover Behaviour

Moving the pointer over a cell shall provide immediate visual feedback.

Hover behaviour shall include:

border emphasis,
subtle background enhancement,
pointer cursor.

Hover shall never trigger SQL execution.

85. Selection Behaviour

Clicking a cell creates the current analytical context.

Only one active selection may exist.

Selecting another cell immediately replaces the previous selection.

86. Persistent Selection

The selected cell remains highlighted until:

another cell is selected,
filters change,
dashboard refreshes,
project changes.

Hover effects shall never replace selection feedback.

87. Double Click

Double-click behaviour is intentionally undefined.

The dashboard shall not require double-click interactions.

Single click is the standard interaction model.

88. Keyboard Accessibility

Future implementations shall support keyboard navigation.

Selection shall eventually be possible using:

Arrow Keys

Enter

Escape

Although not mandatory in Version 1.0, the architecture shall not prevent this capability.

89. Drill-Down Contract

Selecting a Heatmap cell performs the following sequence:

User Click

↓

Store Selection

↓

Update Context Variables

↓

Refresh Donut

↓

Refresh Detail Panel

↓

Refresh Punch Grid

No additional navigation occurs.

The user remains on Home_1.

90. Dashboard Synchronisation

The Heatmap acts as the dashboard controller.

The following components subscribe to its current selection:

Donut
Detail Panel
Punch Grid

The Heatmap itself never depends on those components.

Dependency is unidirectional.

91. Performance Rules

The Heatmap shall never execute SQL directly.

The Heatmap shall never call a Flow.

The Heatmap shall never rebuild collections.

Its responsibility ends at updating the current analytical selection.

92. Refresh Behaviour

When the dashboard refreshes:

Previous selection is cleared.

Matrix recalculates.

Totals recalculate.

Colour scale recalculates.

Subscribed widgets refresh automatically.

93. Loading State

While data is loading:

The Heatmap container remains visible.

A skeleton loading state shall replace matrix values.

The layout shall never collapse.

94. Empty State

When no dashboard data exists:

Headers remain visible.

Matrix remains visible.

A centred message displays:

"No Punch data available."

The Heatmap structure never disappears.

95. Error State

If Heatmap generation fails:

The remaining dashboard continues functioning.

The user receives a non-blocking error notification.

Dashboard recovery shall be possible without restarting the application.

96. Power Apps Implementation Guidelines

Preferred implementation:

Nested galleries only when required.
Reuse existing collections.
Minimise recalculation.
Avoid duplicated formulas.
Keep Power Fx readable.
Separate presentation from business logic.

The Heatmap shall remain a reusable analytical component.

97. Anti-Patterns

The following implementations are prohibited:

Hard-coded colours per category.
Hard-coded matrix dimensions.
Independent SQL queries.
Embedded business logic.
Manual totals.
Multiple selected cells.
Hidden zero-value rows.
Dynamic resizing that changes the matrix layout.
98. Acceptance Criteria

The Heatmap implementation shall satisfy all of the following:

Displays both axes.
Displays every business intersection.
Displays totals.
Displays grand total.
Colours represent concentration.
Zero values remain visible.
Selection is persistent.
Hover is responsive.
Drill-down updates the remaining dashboard.
Refresh clears obsolete selections.
No SQL execution occurs from the Heatmap.
Layout matches the approved reference image.

Failure of any criterion constitutes a functional defect.

99. Definition of Done

The Executive Heatmap is considered complete only when:

it is visually indistinguishable from the approved design,
it drives the analytical workflow of the dashboard,
all dependent components synchronise correctly,
performance remains equivalent to the current implementation,
no regressions are introduced into the Home_1 screen.

Donut Chart & Selected Cell Detail Panel
100. Purpose

The right-hand analytical column complements the Executive Heatmap.

Unlike the Heatmap, these components do not initiate analysis.

Their purpose is to explain the meaning of the current Heatmap selection.

The right column transforms a numerical hotspot into operational information that can be immediately understood by executive users.

101. Architectural Principle

The right analytical column is composed of two independent components:

Executive Donut Chart
Selected Cell Detail Panel

Although visually grouped together, they have different responsibilities.

The Donut explains distribution.

The Detail Panel explains context.

Neither component may assume the responsibilities of the other.

102. Dependency Model

The analytical dependency is strictly hierarchical.

Executive Heatmap
        │
        ▼
Current Selection
        │
        ├────────► Donut Chart
        │
        ├────────► Detail Panel
        │
        └────────► Punch Grid

The Heatmap is the only controller.

The Donut never modifies the Heatmap.

The Detail Panel never modifies the Heatmap.

The Punch Grid never modifies the Heatmap.

103. Executive Donut Purpose

The Donut provides an executive visual explanation of the selected Heatmap cell.

It answers the question:

How is this hotspot composed?

It is intentionally simple.

The objective is rapid understanding.

It is not intended to replace the Punch Grid.

104. Business Responsibilities

The Donut has four responsibilities.

Responsibility 1

Display proportional distribution.

Responsibility 2

Provide immediate executive insight.

Responsibility 3

Remain synchronized with the Heatmap.

Responsibility 4

Remain visually lightweight.

No additional responsibilities are allowed.

105. Information Source

The Donut shall consume existing dashboard collections.

It shall never execute SQL.

It shall never call Power Automate.

It shall never create temporary collections.

Its data shall already exist in memory.

106. Refresh Contract

Whenever the Heatmap selection changes:

The Donut refreshes automatically.

No manual refresh button exists.

The user must perceive the Donut as a live analytical view.

107. Initial State

Before any Heatmap selection:

The Donut displays the overall dashboard distribution.

This allows the dashboard to remain informative immediately after loading.

The Product Owner may redefine this behaviour in future releases.

108. Empty Selection

If no records exist for the selected cell:

The Donut remains visible.

Instead of disappearing, it displays:

"No distribution available."

The dashboard layout never changes.

109. Donut Composition

The Donut contains:

Title
Circular chart
Total value
Legend
Percentage labels (optional)

The chart shall remain visually clean.

Three-dimensional effects are prohibited.

Exploded slices are prohibited.

Animations are discouraged.

110. Colour Rules

The Donut uses semantic colours.

Colour meanings shall remain consistent throughout PULSE.

Example:

Green

Completed

Yellow

In Progress

Orange

Pending

Red

Critical

Grey

Unknown

The exact palette shall follow the global design system.

111. Slice Behaviour

Each slice represents one business category.

Slice sizes shall always sum to 100%.

The chart shall never contain overlapping categories.

112. Slice Ordering

Slices shall follow a predictable order.

Random ordering between refreshes is prohibited.

Executive users must develop visual memory.

113. Hover Behaviour

Hovering a slice displays:

Category
Count
Percentage

Tooltips shall appear instantly.

Hover shall never trigger data refresh.

114. Click Behaviour

Version 1.0

Clicking the Donut performs no navigation.

Future versions may support drill-down.

The architecture shall not prevent this extension.

115. Animation Policy

Animations must remain subtle.

Allowed:

Fade

Opacity

Minor transitions

Prohibited:

Rotation

Bounce

Elastic

Continuous animation

The dashboard is an analytical workspace—not a presentation.

116. Detail Panel Purpose

The Detail Panel explains the selected Heatmap cell.

Where the Donut answers:

"How is it distributed?"

The Detail Panel answers:

"What exactly have I selected?"

117. Information Displayed

The Detail Panel shall display:

Selected Row

Selected Column

Punch Count

Percentage

Business Context

Additional descriptive information when available.

The panel is informational.

It contains no editable fields.

118. Action Area

The Detail Panel contains executive actions.

Initially:

View Punches

Future releases may include:

Export Selection

Create Report

Share

The panel architecture shall support extension.

119. View Punches

The View Punches action represents the primary transition between analytical and operational workflows.

Pressing the button navigates to:

Punches_1

The navigation shall preserve:

Current Project

Current Template

Current Heatmap Selection

Applied Filters

No information shall be lost.

120. Navigation Contract

Navigation follows this sequence.

Heatmap Selection

↓

Current Context Variables

↓

View Punches

↓

Punches_1

↓

Filtered Grid

Users must never repeat filtering manually.

121. Detail Refresh

Whenever the Heatmap selection changes:

The Detail Panel refreshes automatically.

No loading spinner shall appear unless the entire dashboard is refreshing.

122. Initial Detail State

Immediately after dashboard loading:

The Detail Panel displays:

Overall dashboard context.

It shall never appear empty.

123. Empty State

If the current Heatmap selection returns zero records:

The panel displays:

"No Punches found."

Buttons become disabled.

Layout remains unchanged.

124. Error State

Component failures shall remain isolated.

If the Detail Panel cannot display information:

The Heatmap continues functioning.

The Punch Grid continues functioning.

The Donut continues functioning.

Component isolation is mandatory.

125. Responsive Behaviour

The right analytical column preserves its proportions.

Donut remains above.

Detail Panel remains below.

Vertical stacking shall never change.

126. Power Apps Guidelines

Preferred implementation:

Single container.

Independent child components.

Bindings through existing collections.

Minimal recalculation.

No duplicated formulas.

Avoid unnecessary variables.

127. Anti-Patterns

The following are prohibited.

Interactive Donut filtering.

Independent SQL queries.

Manual data refresh.

Charts larger than the Heatmap.

Multiple action buttons without business value.

Large descriptive paragraphs.

Decorative icons.

Duplicated business information already shown elsewhere.

128. Acceptance Criteria

The right analytical column shall satisfy:

✓ Donut always synchronized.

✓ Detail always synchronized.

✓ View Punches preserves filters.

✓ No SQL execution.

✓ No Flow execution.

✓ No layout changes.

✓ No visual flicker.

✓ Correct empty state.

✓ Correct loading state.

✓ Correct navigation.

Failure of any criterion constitutes a functional defect.

129. Definition of Done

The Donut and Detail Panel are complete only when:

they update instantly after Heatmap selection,
they visually match the approved dashboard,
navigation to Punches_1 requires no additional filtering,
they remain independent from SQL execution,
they preserve dashboard responsiveness,
they function as contextual analytical components rather than primary controls.
130. Future Evolution

The architecture shall permit future enhancements without redesign.

Potential extensions include:

multi-level drill-down,
historical trend comparison,
export of selected analytical context,
AI-generated insights,
predictive distribution,
comparison between snapshots.

These features are outside the scope of Version 1.0 but shall be considered during implementation to avoid architectural limitations.

Executive Punch Grid Functional Specification
131. Purpose

The Executive Punch Grid represents the operational layer of the Executive Dashboard.

Where the Heatmap identifies where management attention is required, the Punch Grid identifies which Punches require action.

The Grid is not an independent screen.

It is the final step of the analytical workflow initiated by the Executive Heatmap.

The user must perceive the Grid as a continuation of the Heatmap rather than as a traditional table.

132. Business Objective

The Executive Punch Grid answers one operational question:

Which specific Punches are responsible for the selected analytical result?

The Grid bridges executive analysis and operational execution.

It enables supervisors, coordinators and project managers to transition from aggregated information to individual Punch records without changing context.

133. Functional Responsibilities

The Punch Grid has seven responsibilities.

Responsibility 1

Display the Punches corresponding to the current Heatmap selection.

Responsibility 2

Provide rapid access to operational information.

Responsibility 3

Support sorting.

Responsibility 4

Support pagination.

Responsibility 5

Support export.

Responsibility 6

Preserve analytical context.

Responsibility 7

Provide navigation to the complete Punch List.

134. Data Source

The Punch Grid shall consume the dashboard dataset already loaded into Power Apps.

It shall not execute SQL independently.

It shall not invoke Power Automate.

Filtering shall occur over the existing dashboard collections whenever technically feasible.

If server-side paging is required due to dataset size, the architecture shall preserve the same functional behaviour while delegating pagination to the existing backend services.

135. Relationship with Punches_1

The Executive Punch Grid is not intended to replace the Punches screen.

The relationship is complementary.

Home_1 Executive Grid	Punches_1
Executive analysis	Operational management
Limited dataset	Complete dataset
Read-oriented	Full interaction
Dashboard context	Full workflow
136. Initial State

Immediately after the dashboard loads:

The Grid shall display the dataset corresponding to the default analytical context.

If no Heatmap selection exists, the Grid shall display the default executive dataset defined by the Product Owner.

The Grid shall never appear empty after a successful dashboard refresh unless no Punches exist.

137. Synchronization Contract

The Grid is fully synchronized with the Heatmap.

Whenever the user selects another Heatmap cell:

The Grid refreshes automatically.

No refresh button is required.

No confirmation dialog is displayed.

The transition shall appear instantaneous.

138. Column Philosophy

Every visible column must support decision-making.

Columns that do not contribute to operational analysis shall not be displayed.

The objective is clarity rather than exhaustiveness.

Additional information belongs in the Premium Drawer, not in the Grid.

139. Default Columns

The initial implementation shall display, at a minimum:

Punch Code
Description
Status
Category
Subsystem
Discipline
Responsible Company
Responsible Person
Due Date
Priority

Future releases may introduce additional columns through configuration.

140. Column Order

Columns shall follow a logical reading sequence.

Recommended order:

Punch Code
Description
Status
Category
Subsystem
Discipline
Responsible
Due Date
Priority

The order shall remain stable across sessions.

Random column ordering is prohibited.

141. Column Width

Column widths shall be proportional to their content.

Examples:

Punch Code

Narrow.

Description

Wide.

Status

Medium.

Priority

Narrow.

No horizontal scrolling shall be required under normal operating conditions.

142. Sorting

The Grid shall support sorting by every visible column.

Rules:

Single-column sorting only.

Click once:

Ascending.

Click again:

Descending.

Click a third time:

Default order restored.

Sorting shall never modify the analytical context.

143. Filtering

The Grid inherits its primary filter from the Heatmap.

Additional local filters may be supported in future versions.

However:

Local filtering shall never modify the Heatmap.

The dependency remains unidirectional.

144. Pagination

The Grid shall support server-compatible pagination.

Preferred page size:

25 rows.

Configurable alternatives:

50

100

The selected page size shall persist during the session.

145. Record Selection

Selecting a row highlights it.

Only one active row may exist.

Selection shall never modify the Heatmap.

Selection only affects row-specific actions.

146. Double Click Behaviour

Double-clicking a Punch opens the Premium Drawer.

This interaction replaces traditional navigation to a secondary screen.

The objective is to minimise context switching.

147. Premium Drawer Integration

The Punch Grid is the primary entry point to the Premium Drawer.

Selecting a record shall populate:

Overview

Comments

History

Custom Fields

Attachments

Workflow information

The Drawer architecture is specified independently.

The Grid simply provides the current record context.

148. Toolbar

The Grid toolbar contains operational actions.

Minimum actions:

Refresh
Export
Column Selector
Go to Punches
Page Size

Future actions may include:

Bulk Selection

Saved Views

Bookmarks

AI Summary

149. Export

The Export action exports the currently filtered dataset, not the entire project.

The exported dataset shall preserve:

Current Project

Current Template

Current Heatmap Selection

Current Sort Order

Current Filters

This behaviour guarantees consistency between dashboard analysis and exported information.

150. Column Selector

Users may temporarily hide non-essential columns.

Rules:

Mandatory columns cannot be hidden.

Selections persist during the current session.

The selector affects presentation only.

No data is removed from memory.

151. Go to Punches

The Go to Punches action transfers the user to the full operational module.

Navigation shall preserve:

Project

Template

Heatmap Selection

Status Filters

Category Filters

Subsystem Filters

Discipline Filters

Company Filters

The destination screen must display the same logical dataset visible in the Executive Grid.

152. Navigation Contract

The transition sequence shall be:

Heatmap Selection
        │
        ▼
Executive Grid
        │
        ▼
Go to Punches
        │
        ▼
Punches_1
        │
        ▼
Filtered Dataset

The user shall never repeat filtering manually.

153. Empty State

When no Punches satisfy the current selection:

The Grid remains visible.

Headers remain visible.

Toolbar remains visible.

Message displayed:

"No Punches match the current analytical selection."

154. Loading State

During refresh:

Headers remain visible.

Toolbar remains visible.

Skeleton rows replace data.

The Grid height shall not change.

155. Error State

Grid failures shall remain isolated.

Failure to display records shall not affect:

Heatmap

Donut

Detail Panel

KPIs

Dashboard stability is prioritised over complete refresh failure.

156. Performance Requirements

The Grid shall remain responsive.

Preferred implementation:

Reuse existing collections.

Avoid duplicated filtering logic.

Avoid repeated calculations inside galleries.

Use delegation-compatible expressions whenever possible.

The Grid shall not introduce additional SQL requests unless explicitly required by server-side pagination.

157. Power Apps Guidelines

Preferred implementation:

Gallery-based layout.
Existing collections.
Existing navigation contracts.
Existing global variables.
Reusable formatting components.
Minimal recalculation.

Business logic shall remain outside presentation controls.

158. Anti-Patterns

The following are prohibited:

Independent SQL execution.
Independent Flow execution.
Rebuilding collections inside the Grid.
Manual synchronization with the Heatmap.
Hidden mandatory columns.
Automatic navigation after row selection.
Multiple active rows.
Horizontal scrolling caused by poor layout decisions.
Reordering columns on every refresh.
159. Acceptance Criteria

The Executive Punch Grid shall satisfy all of the following:

Displays the dataset corresponding to the current Heatmap selection.
Updates immediately after Heatmap changes.
Supports sorting.
Supports pagination.
Supports export.
Supports column visibility.
Supports Premium Drawer.
Preserves analytical context.
Navigates correctly to Punches_1.
Never executes SQL directly.
Never invokes Power Automate.
Maintains visual consistency with the Executive Dashboard.

Failure of any criterion constitutes a functional defect.

160. Definition of Done

The Executive Punch Grid is considered complete only when:

it behaves as the operational continuation of the Executive Heatmap,
analytical context is preserved throughout the workflow,
navigation to Punches_1 is seamless,
all toolbar functions operate correctly,
performance remains equivalent to or better than the existing implementation,
no regression is introduced into the current Home_1 architecture.

Data Contracts & Application State
161. Purpose

This chapter defines the complete data architecture supporting the Executive Dashboard.

Unlike previous chapters, which focused on user interface and behaviour, this chapter defines how information flows through the application.

The objective is to ensure that every component consumes a single, consistent analytical model while avoiding duplicated logic and unnecessary recalculations.

This chapter is mandatory for all Power Apps, SQL and Power Automate developers working on the Executive Dashboard.

162. Architectural Principle

The Executive Dashboard follows a Single Source of Truth architecture.

Business data shall be retrieved only once.

From that moment onward, every dashboard component shall consume the same in-memory model.

The dashboard shall never execute independent queries for individual widgets.

The Heatmap, KPI Cards, Donut Chart, Detail Panel and Executive Grid must always represent different views of the same analytical dataset.

163. Data Flow

The complete execution pipeline is defined below.

Azure SQL Stored Procedures
            │
            ▼
Power Automate
Dashboard Flow
            │
            ▼
Power Apps
Collections
            │
            ▼
Dashboard Components

The pipeline shall remain linear.

Feedback loops are prohibited.

164. Dashboard Loading Sequence

The dashboard shall always execute the following sequence:

Step 1

User selects Project.

↓

Step 2

Template is determined.

↓

Step 3

Dashboard Flow executes.

↓

Step 4

Stored Procedures retrieve analytical data.

↓

Step 5

Power Automate returns a complete dashboard payload.

↓

Step 6

Collections are populated.

↓

Step 7

Dashboard components render.

Only after Step 7 may user interaction begin.

165. Single Payload Principle

The dashboard shall receive one consolidated payload.

The payload shall contain all information required to populate:

KPI Cards
Heatmap
Donut
Detail Panel
Punch Grid

The objective is to eliminate multiple Flow executions.

166. Collection Responsibilities

Collections shall have clearly defined ownership.

A collection must never serve unrelated business purposes.

Recommended categories:

Analytical Collections

Executive dashboard data.

Lookup Collections

Reference information.

Configuration Collections

Application settings.

Session Collections

Temporary user state.

Collections shall never mix responsibilities.

167. Heatmap Collection

The Heatmap consumes a dedicated analytical collection.

Each record represents one matrix intersection.

Minimum information:

Row Dimension
Column Dimension
Punch Count
Percentage
Total Row
Total Column

The Heatmap shall never calculate totals independently.

168. KPI Collection

The KPI Cards consume a dedicated KPI collection.

Each record represents one executive indicator.

Typical fields:

KPI Identifier
Title
Value
Trend
Variation
Display Order

Presentation properties shall remain outside SQL whenever possible.

169. Donut Collection

The Donut shall consume an already aggregated collection.

Each record shall contain:

Category
Count
Percentage
Colour Key

No runtime aggregation shall occur inside the chart.

170. Detail Collection

The Detail Panel consumes the selected analytical context.

Fields include:

Selected Row
Selected Column
Punch Count
Percentage
Description

The collection represents the current analytical selection only.

171. Executive Grid Collection

The Grid consumes the filtered dashboard dataset.

The Grid collection shall preserve:

current sorting,
current page,
current selection.

The Grid shall never rebuild the dashboard dataset.

172. Global Variables

Global variables represent application state.

Typical examples include:

Current Project

Current Template

Current Dashboard Selection

Dashboard Loading

Dashboard Error

Navigation Context

Variables shall describe application state rather than UI state.

173. Local Variables

Local variables shall be used only for presentation behaviour.

Examples:

Popup visibility

Temporary animations

Hover state

Temporary selections

Business logic shall never depend on local variables.

174. Selection Contract

Only one dashboard selection may exist.

The current selection shall contain:

Selected Row

Selected Column

Associated Filters

Timestamp

Origin Component

The selection becomes the analytical context shared by the dashboard.

175. Synchronization Model

Whenever the analytical context changes:

The following components refresh:

Donut
Detail Panel
Executive Grid

The following components do not refresh:

Header
KPI Cards
Navigation

This selective refresh minimizes recalculation.

176. Dashboard Refresh

A dashboard refresh replaces all analytical collections.

The following sequence shall occur:

Clear previous collections

↓

Load new payload

↓

Populate collections

↓

Reset selection

↓

Render dashboard

Partial collection refreshes are discouraged.

177. State Management

The dashboard defines four application states.

Idle

Dashboard ready.

Loading

Collections updating.

Error

Dashboard unavailable.

Interactive

User exploring data.

Every component shall respect these global states.

178. Navigation Contract

When navigating from Home_1 to Punches_1, the following information shall always be transferred:

Project

Template

Current Heatmap Selection

Category

Subsystem

Discipline

Status

Company

Current Sorting

Current Filters

The receiving screen shall reproduce the same logical dataset.

179. Flow Contract

Power Automate has one responsibility:

Populate dashboard data.

It shall not:

calculate UI behaviour,
determine layout,
perform visual formatting,
define colours.

Presentation remains entirely within Power Apps.

180. SQL Contract

Stored Procedures are responsible for:

Business rules.

Aggregation.

Filtering.

Performance.

They shall not contain:

Presentation logic.

Display text.

Colour definitions.

Layout information.

The separation between business and presentation shall remain strict.

181. Error Propagation

Errors propagate upward.

SQL

↓

Flow

↓

Power Apps

↓

Notification

The dashboard shall never silently ignore backend failures.

182. Logging

Dashboard loading events should be logged.

Recommended events:

Dashboard Loaded

Dashboard Refreshed

Navigation to Punches

Dashboard Error

Performance Metrics

Logging shall never affect user experience.

183. Performance Principles

The Executive Dashboard shall minimise:

SQL executions.

Flow executions.

Collection rebuilding.

Repeated filtering.

Nested calculations.

The preferred architecture is:

Load Once

Use Many Times.

184. Data Ownership

Every dataset has one owner.

SQL owns:

Business information.

Power Automate owns:

Transport.

Power Apps owns:

Presentation.

Components own:

Rendering.

Ownership overlap is prohibited.

185. Anti-Patterns

The following practices are forbidden:

Multiple Flows for dashboard widgets.

Duplicated SQL calls.

Duplicated collections.

Component-specific SQL.

Hidden business logic inside controls.

Independent data refreshes.

Circular dependencies.

Component-to-component communication bypassing application state.

186. Acceptance Criteria

The data architecture shall satisfy all of the following:

✓ Single dashboard payload.

✓ One analytical model.

✓ Reusable collections.

✓ No duplicated SQL.

✓ No duplicated Flow execution.

✓ Shared dashboard selection.

✓ Predictable refresh sequence.

✓ Preserved navigation context.

✓ Stable application state.

Failure of any criterion shall be considered an architectural defect.

187. Definition of Done

The Data Contract is considered complete only when:

every dashboard component consumes the same analytical model,
all navigation preserves context,
collections have clearly defined ownership,
application state remains predictable,
SQL, Flow and Power Apps responsibilities are completely separated,
no duplicated business logic exists within the dashboard.
188. Traceability Matrix
Layer	Responsibility	Owner
Azure SQL	Business rules, aggregation, filtering	Database
Power Automate	Data transport and orchestration	Integration
Power Apps Collections	Analytical model in memory	Canvas App
Global Variables	Session and navigation state	Canvas App
Heatmap	Analytical controller	Presentation
Donut	Distribution visualization	Presentation
Detail Panel	Context visualization	Presentation
Executive Grid	Operational visualization	Presentation
Punches_1	Operational management	Presentation

This matrix is normative and shall be respected throughout the implementation.

Power Apps Implementation Architecture
189. Purpose

This chapter defines the implementation architecture of the Executive Dashboard inside Microsoft Power Apps.

Unlike previous chapters, which define functional behaviour, this chapter establishes how the solution shall be physically constructed inside the Canvas App.

The objective is to guarantee:

maintainability,
scalability,
readability,
performance,
compatibility with the existing PULSE architecture.

This chapter is mandatory for every developer modifying Home_1.

190. Implementation Philosophy

The Executive Dashboard shall reuse the existing application architecture.

The redesign is not a rewrite.

Business logic already implemented inside PULSE shall remain valid.

Only the presentation layer shall evolve.

The implementation strategy is therefore:

Reuse Architecture — Replace Presentation

191. Screen Ownership

The Executive Dashboard belongs exclusively to:

Home_1

No additional dashboard screen shall be created.

Alternative implementations such as:

Home2

DashboardHome

ExecutiveDashboard

DashboardV2

are prohibited.

The existing Home_1 screen shall evolve.

192. Root Structure

The recommended structure is:

Home_1

│

├── Header

├── KPI Strip

├── Executive Analytics

│      ├── Heatmap

│      ├── Donut

│      └── Detail

├── Punch Grid

├── Loading Layer

├── Error Layer

└── Hidden Commands

Every control shall belong to one of these areas.

193. Control Hierarchy

The implementation shall minimise nesting.

Maximum recommended hierarchy:

Container

↓

Container

↓

Gallery

↓

Control

Additional hierarchy levels require explicit technical justification.

194. Container Strategy

Containers define layout.

They do not contain business logic.

Responsibilities:

Alignment

Spacing

Sizing

Responsiveness

Containers shall never calculate dashboard information.

195. Component Strategy

Reusable components are encouraged.

Recommended candidates:

KPI Card

Dashboard Header

Loading Skeleton

Empty State

Section Header

Status Badge

The following shall not become reusable components:

Heatmap

Executive Grid

These represent screen-specific analytical behaviour.

196. Gallery Usage

Galleries represent datasets.

Every Gallery shall have one responsibility.

Example:

Heatmap Gallery

↓

Display matrix

Grid Gallery

↓

Display Punches

No Gallery shall display unrelated datasets.

197. Formula Placement

Business formulas shall remain outside visual properties whenever possible.

Example:

Avoid:

Label.Text =
VeryLargeCalculation(...)

Prefer:

Variable

↓

Collection

↓

Simple binding

This improves readability and performance.

198. Variable Strategy

Variables describe application state.

Never presentation.

Examples:

Correct

varSelectedHeatmapCell

Incorrect

varBlueRectangle

Names shall express business meaning.

199. Collection Strategy

Collections represent datasets.

Variables represent state.

Controls represent presentation.

These responsibilities shall never overlap.

200. Naming Convention

Recommended prefixes:

scr_

cmp_

gal_

grp_

lbl_

ico_

btn_

txt_

rec_

cnt_

var

loc

col

The convention already adopted by PULSE shall remain unchanged.

201. Visibility Rules

Visibility shall be driven by state.

Never by duplicated calculations.

Example:

Preferred

Visible =
varDashboardLoaded

Avoid

Visible =
CountRows(...)
>
0

repeated throughout the screen.

202. Responsive Design

Containers shall resize.

Controls shall align.

Charts shall scale proportionally.

The Heatmap shall always remain the dominant component.

The dashboard shall never collapse into an unusable layout.

203. Power Fx Principles

Power Fx shall follow five principles.

Readable.

Predictable.

Delegation-friendly.

Reusable.

Business-oriented.

Complex nested expressions shall be avoided.

204. Event Ownership

Every user action has one owner.

Examples:

Project Selector

↓

Dashboard Refresh

Heatmap

↓

Dashboard Selection

Grid

↓

Drawer Context

Buttons shall never duplicate event logic.

205. Dashboard State Machine

The Executive Dashboard follows this lifecycle.

Initialize

↓

Loading

↓

Ready

↓

Interactive

↓

Refreshing

↓

Ready

No intermediate undocumented states shall exist.

206. Loading Layer

The Loading Layer shall be implemented once.

Every component subscribes to it.

Multiple independent loading indicators are prohibited.

207. Error Layer

Errors shall appear through one centralized mechanism.

Individual components may expose local error messages.

However:

Global dashboard failures shall always use the shared Error Layer.

208. Dashboard Refresh

Refreshing the dashboard performs:

Clear state

↓

Load data

↓

Populate collections

↓

Reset selection

↓

Render

↓

Enable interaction

Components shall never refresh independently.

209. Navigation Rules

Only designated controls may navigate.

Examples:

View Punches

Project Selector

Global Menu

Charts shall not perform unexpected navigation.

210. Component Communication

Components communicate only through:

Collections

Variables

Context

Never directly.

Example:

Incorrect

Heatmap

↓

Calls

↓

Donut

Correct

Heatmap

↓

Updates Selection

↓

Donut observes Selection

This architecture guarantees loose coupling.

211. Hidden Controls

Hidden controls shall exist only for technical purposes.

Examples:

Initialization

Flow execution

State synchronization

Hidden controls shall never contain business rules.

212. Performance Guidelines

Avoid:

Repeated LookUps

Repeated Filter()

Repeated AddColumns()

Repeated GroupBy()

inside visual controls.

Prefer:

Pre-computed collections.

213. Delegation Guidelines

Every delegated query shall remain server-compatible whenever possible.

Large datasets shall never depend on non-delegable formulas.

If delegation limits exist:

SQL shall solve the problem.

Not Power Apps.

214. Comments

Complex Power Fx shall contain comments.

Example:

Initialize dashboard context

Load analytical payload

Apply default selection

Future maintainability has priority over compact code.

215. Premium Drawer Integration

The Premium Drawer shall receive:

Punch Identifier

Current Project

Current Template

Current Filters

Drawer shall never reload dashboard data.

Its responsibility begins after record selection.

216. Existing Assets

The implementation shall preserve:

Existing SQL

Existing Flow

Existing Variables

Existing Collections

Existing Navigation

Existing Components

Only obsolete presentation elements shall disappear.

217. Migration Strategy

Migration shall occur incrementally.

Recommended sequence:

Remove obsolete widgets.

Create new layout.

Reconnect existing collections.

Reconnect navigation.

Reconnect actions.

Validate.

Deploy.

This sequence minimizes regressions.

218. Anti-Patterns

The following are prohibited.

Creating duplicate screens.

Creating duplicate collections.

Duplicating SQL calls.

Duplicating Flows.

Embedding business logic inside Labels.

Embedding SQL assumptions inside controls.

Using invisible controls as business engines.

Rewriting working architecture to satisfy presentation requirements.

219. Acceptance Criteria

The implementation architecture shall satisfy:

✓ Existing architecture preserved.

✓ Presentation redesigned.

✓ Components loosely coupled.

✓ Collections reused.

✓ Variables reused.

✓ Navigation preserved.

✓ Business logic preserved.

✓ YAML remains maintainable.

✓ Dashboard remains performant.

Failure of any criterion represents an architectural defect.

220. Definition of Done

The Power Apps implementation architecture shall be considered complete only when:

Home_1 remains the single implementation of the Executive Dashboard.
Existing business logic has been preserved.
The presentation layer matches the approved specification.
Components communicate only through application state.
No duplicated architecture has been introduced.
The YAML structure remains understandable by developers unfamiliar with the project.
221. Codex Implementation Rules (Mandatory)

This section is normative. Codex shall comply with every rule below when editing the repository.

Rule 1 — Minimal Surface Area

Modify only the controls required to implement the specification.

Do not regenerate the entire screen unless explicitly instructed.

Rule 2 — Preserve Object Identity

Whenever possible, existing controls shall be modified in place.

Deleting and recreating controls is discouraged because it breaks references, formulas and review history.

Rule 3 — Preserve Stable Names

Existing names for collections, variables, components and controls shall remain unchanged unless the Product Owner explicitly requests a rename.

Rule 4 — No Functional Regression

A visual improvement shall never introduce regressions in:

project selection,
template selection,
navigation,
loading,
dashboard refresh,
existing SQL integration.
Rule 5 — Atomic Commits

Every implementation phase shall be independently deployable.

One commit shall correspond to one functional objective.

Examples:

Layout refactor.
Heatmap implementation.
Donut integration.
Executive Grid.
Navigation fixes.

Never mix unrelated changes in the same commit.

Rule 6 — Validation Before Completion

Before considering a phase complete, Codex shall verify:

YAML compiles successfully.
No broken references exist.
Existing components still render.
Existing flows remain connected.
Dashboard matches the approved design.


Implementation & Migration Plan
222. Purpose

This chapter defines the official implementation strategy for the Executive Dashboard.

Unlike previous chapters, which describe architecture and functionality, this chapter defines how the implementation shall be executed.

Its objective is to minimise regressions while allowing continuous progress.

The migration strategy is based on incremental implementation.

Large refactoring activities are explicitly prohibited.

223. Migration Philosophy

The Executive Dashboard shall evolve through controlled iterations.

The application must remain deployable after every completed phase.

At no point shall the dashboard exist in an unusable intermediate state.

Every phase shall end with:

successful compilation,
successful deployment,
successful functional validation.
224. General Principles

Implementation follows five mandatory principles.

Principle 1

Small changes.

Principle 2

Independent validation.

Principle 3

Minimal regression risk.

Principle 4

Business continuity.

Principle 5

Functional delivery before technical perfection.

225. Migration Strategy

The implementation shall never begin with cosmetic improvements.

The sequence shall always be:

Architecture

↓

Layout

↓

Components

↓

Interactions

↓

Validation

↓

Optimization

Changing this order significantly increases implementation risk.

226. Phase Zero

Before modifying any control, Codex shall perform the following verification.

Checklist:

Home_1 compiles.
Existing Flow connections exist.
Existing SQL references exist.
Dashboard opens successfully.
No broken YAML.

If any of these checks fail, implementation shall stop.

227. EPIC 01 — Executive Dashboard Foundation

Objective:

Prepare the dashboard for redesign.

Tasks:

Remove obsolete panels.
Preserve architecture.
Preserve navigation.
Preserve SQL.
Preserve collections.

Deliverable:

Clean implementation platform.

228. EPIC 02 — Executive Layout

Objective:

Construct the new visual structure.

Tasks:

Root containers.
KPI strip.
Analytical workspace.
Grid workspace.

Deliverable:

Pixel-correct layout without business logic.

229. EPIC 03 — Heatmap

Objective:

Implement the Executive Heatmap.

Tasks:

Matrix.

Headers.

Totals.

Selection.

Hover.

Colour scale.

Synchronization.

Deliverable:

Fully functional Heatmap.

230. EPIC 04 — Right Analytical Column

Objective:

Implement:

Donut.

Detail Panel.

Tasks:

Bindings.

Synchronization.

Navigation button.

Empty states.

Deliverable:

Complete analytical context.

231. EPIC 05 — Executive Grid

Objective:

Implement the operational grid.

Tasks:

Toolbar.

Columns.

Sorting.

Pagination.

Drawer integration.

Export.

Deliverable:

Executive operational layer.

232. EPIC 06 — Navigation

Objective:

Reconnect analytical navigation.

Tasks:

Home

↓

Punches

↓

Premium Drawer

Deliverable:

End-to-end workflow.

233. EPIC 07 — Validation

Objective:

Verify implementation.

Tasks:

Visual comparison.

Functional comparison.

Regression testing.

Performance testing.

Deliverable:

Approved dashboard.

234. Work Unit

One work unit equals one functional objective.

Examples:

Implement Heatmap.

Reconnect Grid.

Repair Navigation.

Never mix unrelated objectives.

235. Commit Policy

One functional objective.

↓

One commit.

Examples.

Good:

Implement Executive Heatmap Selection

Bad:

Heatmap
+
Drawer
+
Navigation
+
Export
236. Pull Request Policy

Each Pull Request shall contain:

Objective.

Files modified.

Risk assessment.

Rollback strategy.

Validation evidence.

No implementation shall be merged without these sections.

237. Rollback Strategy

Every implementation phase must be reversible.

Rollback shall never require manual reconstruction.

The preferred rollback mechanism is Git.

Deleting objects as a rollback strategy is prohibited.

238. Testing Strategy

Each EPIC concludes with four validations.

Compilation.

↓

Visual.

↓

Functional.

↓

Regression.

Failure of any validation blocks completion.

239. Compilation Validation

Mandatory checks:

YAML imports successfully.

No missing controls.

No missing components.

No broken references.

No unsupported properties.

Compilation is mandatory before visual validation begins.

240. Visual Validation

The implemented dashboard shall be compared side-by-side with the approved reference.

Validation criteria include:

Overall layout.

Spacing.

Alignment.

Typography.

Visual hierarchy.

Heatmap size.

Donut position.

Grid alignment.

This review is manual.

241. Functional Validation

Every interaction defined in this specification shall be executed.

Examples:

Project selection.

Template selection.

Dashboard refresh.

Heatmap selection.

Grid refresh.

Go to Punches.

Drawer opening.

Export.

Each interaction shall produce the expected result.

242. Regression Validation

Existing functionality shall remain operational.

Examples:

Project switching.

Flow execution.

SQL execution.

Navigation.

Collections.

Variables.

Dashboard refresh.

Regression testing is mandatory.

243. Performance Validation

The redesign shall not introduce noticeable performance degradation.

Preferred targets:

Dashboard load time equivalent to current implementation.

Heatmap response perceived as immediate.

Grid refresh under one second for cached data.

No unnecessary SQL calls.

244. Definition of Ready

An EPIC may begin only if:

Requirements approved.

Dependencies satisfied.

Previous EPIC completed.

Repository synchronized.

No unresolved blocking defects.

245. Definition of Done

An EPIC is complete only when:

Implementation finished.

Compilation successful.

Validation successful.

Regression successful.

Documentation updated.

Git committed.

Product Owner approval obtained.

246. Defect Classification

Every detected issue shall be classified.

Critical

Application unusable.

Implementation stops.

Major

Business functionality incorrect.

Must be corrected before merge.

Minor

Visual inconsistency.

May be corrected before release.

Cosmetic

No functional impact.

May be scheduled later.

247. Technical Debt Policy

Technical debt shall be documented.

It shall not automatically block implementation.

Debt categories:

Architecture.

Performance.

Naming.

Formatting.

Documentation.

Only defects affecting business behaviour are blockers.

248. Codex Working Rules

Codex shall work incrementally.

For every implementation:

Read specification.
Analyse YAML.
Modify minimum required controls.
Validate.
Stop.

Automatic continuation to the next EPIC is prohibited.

249. Deliverables per EPIC

Every completed EPIC shall produce:

Updated YAML.

Technical notes.

Validation checklist.

List of modified controls.

Rollback instructions.

Git commit.

No EPIC is considered complete without these deliverables.

250. Final Acceptance

The Executive Dashboard implementation will be accepted only when all of the following conditions are simultaneously true:

✓ Layout matches the approved design.

✓ Heatmap functions correctly.

✓ Donut synchronizes correctly.

✓ Detail Panel synchronizes correctly.

✓ Executive Grid operates correctly.

✓ Navigation to Punches_1 preserves analytical context.

✓ Premium Drawer opens correctly.

✓ Existing architecture remains intact.

✓ No critical regressions exist.

✓ Product Owner formally approves the implementation.

Until all ten conditions are satisfied, the Executive Dashboard shall remain in implementation status.

251. Codex Execution Protocol (Mandatory)

Before starting any coding activity, Codex shall execute the following protocol:

Step 1 — Read

Read the complete FDS before modifying any file.

Step 2 — Analyse

Identify all controls, collections and formulas affected by the current EPIC.

Step 3 — Plan

Produce a short implementation plan listing:

files to modify,
controls to modify,
expected impact,
validation steps.
Step 4 — Implement

Modify only the minimum required artifacts.

Step 5 — Validate

Confirm:

successful compilation,
expected behaviour,
no regressions.
Step 6 — Deliver

Produce:

updated YAML,
summary of changes,
validation results.

No further implementation shall begin until the current EPIC has been accepted.

Acceptance Criteria & Validation Protocol
252. Purpose

This chapter defines the formal acceptance criteria for the Executive Dashboard.

Unlike previous chapters, which describe implementation, this chapter defines how implementation quality shall be evaluated.

The objective is to eliminate subjective acceptance.

The dashboard shall either satisfy the criteria defined below or remain in implementation status.

There shall be no intermediate interpretation.

253. Validation Philosophy

Validation shall be based upon measurable evidence.

Statements such as:

"looks good"
"seems correct"
"close enough"

are not valid acceptance criteria.

Every requirement shall be demonstrable.

254. Acceptance Levels

Validation is divided into six categories.

Level 1

Compilation

Level 2

Visual

Level 3

Functional

Level 4

Integration

Level 5

Regression

Level 6

Performance

Every level must pass.

255. Compilation Validation

The implementation shall compile without errors.

Mandatory checks:

YAML imports successfully.
No invalid controls.
No missing components.
No unsupported Power Apps properties.
No broken formulas.
No unresolved references.

Compilation warnings shall be reviewed individually.

256. Visual Validation

The implemented dashboard shall be compared directly with the approved reference image.

The comparison shall verify:

overall proportions,
spacing,
margins,
alignment,
typography,
colour hierarchy,
information density.

The objective is visual equivalence, not approximate similarity.

257. Pixel Fidelity Validation

The following elements shall be visually identical to the approved design:

Header layout.
KPI strip.
Heatmap size.
Heatmap position.
Donut position.
Detail Panel position.
Executive Grid width.
Section titles.
Overall visual balance.

Minor deviations imposed by Power Apps limitations may be accepted only if they do not alter the perceived design.

258. Heatmap Validation

The Heatmap shall satisfy every requirement defined in Block 05.

Checklist:

✓ Row headers.

✓ Column headers.

✓ Totals.

✓ Grand Total.

✓ Colour scale.

✓ Hover.

✓ Selection.

✓ Persistent selection.

✓ Synchronization.

✓ Correct drill-down.

259. KPI Validation

Each KPI card shall be validated.

Checks:

Correct value.

Correct title.

Correct formatting.

Correct spacing.

Correct alignment.

Correct icon.

Correct responsiveness.

260. Donut Validation

Checks:

Correct distribution.

Correct percentages.

Correct colours.

Correct legend.

Correct refresh after Heatmap selection.

Correct empty state.

Correct loading state.

261. Detail Panel Validation

Checks:

Displays current analytical context.

Updates after every Heatmap selection.

Correct navigation button.

Correct empty state.

Correct disabled state.

Correct formatting.

262. Executive Grid Validation

Checklist:

Correct dataset.

Correct sorting.

Correct pagination.

Correct toolbar.

Correct export.

Correct navigation.

Correct Drawer integration.

Correct row selection.

Correct empty state.

263. Navigation Validation

Every navigation path shall be tested.

Examples:

Home

↓

Punches

Home

↓

Drawer

Project change

↓

Dashboard refresh

Template change

↓

Dashboard refresh

Every path must preserve analytical context.

264. Data Validation

Every analytical widget shall display identical business information.

Validation includes:

Heatmap totals.

Grid totals.

Donut totals.

KPI totals.

Any inconsistency shall be treated as a Critical Defect.

265. Collection Validation

Checks:

Collections populated once.

Collections reused.

Collections not duplicated.

No unnecessary recalculation.

No redundant filtering.

266. SQL Validation

Checks:

Existing Stored Procedures reused.

No duplicated SQL.

No unexpected SQL execution.

Expected execution order preserved.

267. Flow Validation

Checks:

Existing Flow reused.

Correct payload.

Correct execution.

Correct response.

No duplicated dashboard Flow.

268. Performance Validation

The implementation shall satisfy the following objectives:

Dashboard refresh time comparable to the existing implementation.

Heatmap interaction perceived as immediate.

No visible UI freezing.

No repeated Flow execution.

No repeated SQL execution.

269. Regression Validation

The following existing features shall continue functioning exactly as before:

Project Selector.

Template Selector.

Refresh.

Global navigation.

Dashboard loading.

Existing SQL.

Existing Flow.

Existing authentication.

No accepted regression exists.

270. Responsive Validation

Supported resolutions:

1920×1080

1600×900

1440×900

1366×768

Validation shall confirm:

No overlapping controls.

No clipped controls.

No horizontal scrolling.

Heatmap remains dominant.

271. Accessibility Validation

Checks:

Readable typography.

Sufficient contrast.

Consistent focus order.

Keyboard navigation compatibility.

Meaningful labels.

Although accessibility improvements may evolve in future versions, the redesign shall not reduce current accessibility.

272. Error Validation

Every component shall be tested under failure conditions.

Examples:

SQL unavailable.

Flow timeout.

Empty dataset.

Incorrect project.

Disconnected network.

The dashboard shall fail gracefully.

273. Loading Validation

Checks:

Loading overlay.

Skeleton components.

No layout jumping.

No white flashes.

No disappearing dashboard.

Loading shall appear intentional.

274. User Acceptance Testing (UAT)

The Product Owner shall execute the following scenarios.

Scenario 1

Select Project.

Scenario 2

Select Template.

Scenario 3

Review KPIs.

Scenario 4

Select Heatmap cell.

Scenario 5

Review Donut.

Scenario 6

Review Detail Panel.

Scenario 7

Review Grid.

Scenario 8

Open Premium Drawer.

Scenario 9

Navigate to Punches.

Scenario 10

Return Home.

Every scenario must succeed.

275. Defect Classification

Every issue discovered during validation shall be classified.

Critical

Application unusable.

Major

Business functionality incorrect.

Minor

Visual inconsistency.

Cosmetic

Presentation only.

Acceptance is blocked by:

Critical

Major

276. Acceptance Checklist

The following checklist shall be completed before release.

✓ YAML compiles.

✓ Layout matches specification.

✓ Heatmap approved.

✓ Donut approved.

✓ Detail Panel approved.

✓ Grid approved.

✓ Navigation approved.

✓ SQL approved.

✓ Flow approved.

✓ Performance approved.

✓ Regression approved.

✓ Product Owner approval.

Every item is mandatory.

277. Product Owner Approval

Formal approval shall occur only after successful completion of all validation stages.

Approval shall confirm:

The implemented dashboard faithfully reproduces the approved design.

No outstanding Critical or Major defects remain.

The implementation complies with this Functional Design Specification.

278. Release Readiness Criteria

The Executive Dashboard is considered ready for release only if all the following conditions are met:

Functional Specification implemented.
Compilation successful.
Validation successful.
Regression testing successful.
Performance acceptable.
Documentation updated.
Repository synchronized.
Product Owner approval recorded.

Failure of any condition postpones release.

279. Definition of Acceptance

The Executive Dashboard shall be considered Accepted only when:

Every mandatory acceptance criterion has passed.
The Product Owner signs off the implementation.
The dashboard is visually equivalent to the approved design.
The implementation preserves the existing PULSE architecture.
No unresolved Critical or Major defects remain.

Acceptance is binary.

The dashboard is either Accepted or Not Accepted.

280. Certification Statement

Upon successful completion of this validation protocol, the Executive Dashboard shall become the official implementation of the Executive analytical experience within the PULSE application.

Any future modifications shall maintain compatibility with this Functional Design Specification unless superseded by a formally approved revision.

Technical Appendices
281. Purpose

This chapter consolidates the technical reference material required to implement, maintain and evolve the Executive Dashboard.

Unlike previous chapters, which define behaviour and implementation, these appendices provide traceability between the visual specification, the Power Apps implementation and the backend architecture.

These appendices are normative.

Future modifications shall preserve their integrity.

APPENDIX A
Dashboard Traceability Matrix

The following matrix defines the relationship between the approved dashboard design and the implementation artifacts.

Visual Element	Power Apps Control	Collection	SQL	Flow	Destination
Project Selector	Existing ComboBox	Existing Project Collection	Existing SP	Existing Flow	Dashboard Refresh
Template Selector	Existing ComboBox	Existing Template Collection	Existing SP	Existing Flow	Dashboard Refresh
KPI Cards	KPI Components	KPI Collection	Existing Bundle SP	Dashboard Bundle Flow	Home_1
Heatmap	Heatmap Gallery	Matrix Collection	Existing Bundle SP	Dashboard Bundle Flow	Home_1
Donut	Donut Component	Distribution Collection	Existing Bundle SP	Dashboard Bundle Flow	Home_1
Detail Panel	Detail Container	Selection Collection	Existing Bundle SP	Dashboard Bundle Flow	Home_1
Executive Grid	Gallery	Grid Collection	Existing Bundle SP	Dashboard Bundle Flow	Home_1
View Punches	Button	Current Selection	—	—	Punches_1
Premium Drawer	Drawer Component	Selected Punch	Existing Detail SP	Existing Flow	Drawer

This table shall remain synchronized with future architectural changes.

APPENDIX B
Component Inventory

The Executive Dashboard shall contain only the following major functional areas.

Home_1

Header

KPI Strip

Executive Analytics

    Heatmap

    Donut

    Detail Panel

Executive Grid

Loading Layer

Error Layer

No additional executive analytical panels shall be introduced without Product Owner approval.

APPENDIX C
Components Removed During Migration

The following visual elements are officially deprecated.

Executive Insights

Snapshot Timeline

TOP Summary

Subcontractor Summary

These components shall not reappear in future dashboard versions unless a new Functional Design Specification explicitly authorizes their return.

APPENDIX D
Collections Inventory

The following logical collections are required.

Dashboard Collections

Executive KPI Collection

Executive Heatmap Collection

Executive Distribution Collection

Executive Detail Collection

Executive Grid Collection

Configuration Collections

Projects

Templates

Status Definitions

Category Definitions

Subsystem Definitions

Discipline Definitions

Session Collections

Current Dashboard Selection

Current Navigation Context

Temporary User State

Collections shall not duplicate information already available elsewhere.

APPENDIX E
Global Variables

The following logical application state shall exist.

Current Project

Current Template

Dashboard Loaded

Dashboard Loading

Dashboard Error

Current Heatmap Selection

Current Grid Selection

Current Navigation Context

Current Drawer Context

Variable names shall follow the existing PULSE naming convention.

APPENDIX F
Dashboard Events

The Executive Dashboard recognises the following business events.

Project Changed

Template Changed

Dashboard Loaded

Dashboard Refreshed

Heatmap Selected

Heatmap Cleared

Donut Updated

Detail Updated

Grid Updated

Drawer Opened

Navigation to Punches

Dashboard Error

These events define the observable behaviour of the dashboard.

APPENDIX G
Migration Checklist

Before implementation begins:

✓ Repository synchronized.

✓ Baseline imported successfully.

✓ Existing Home_1 validated.

✓ Existing Flow operational.

✓ Existing SQL operational.

✓ Existing navigation operational.

During implementation:

✓ Minimal controls modified.

✓ Existing collections reused.

✓ Existing variables reused.

✓ Existing architecture preserved.

✓ YAML validated after every phase.

After implementation:

✓ Visual comparison completed.

✓ Functional comparison completed.

✓ Regression completed.

✓ Documentation updated.

✓ Git committed.

APPENDIX H
Repository Structure

Recommended structure.

docs/

    specifications/

        PULSE_EXECUTIVE_DASHBOARD_FDS_v1.md

    proposals/

    analysis/

power-platform/

sql/

flows/

screens/

components/

Documentation shall remain version-controlled together with the application.

APPENDIX I
Naming Conventions

Power Apps prefixes.

scr_

cmp_

cnt_

gal_

grp_

lbl_

ico_

btn_

txt_

rec_

var

loc

col

SQL

usp_

vw_

tbl_

Flows

FLOW_

warroom_

PULSE_

These conventions shall remain consistent across the repository.

APPENDIX J
Documentation Standards

Every future modification shall update:

Functional Specification.

Technical Proposal.

Implementation Notes.

Validation Report.

Git Commit Description.

The Functional Design Specification shall always reflect the implemented product.

APPENDIX K
Future Evolution

The following enhancements are anticipated.

Heatmap customization.

Executive bookmarks.

Saved dashboard layouts.

AI-generated executive insights.

Historical comparison.

Predictive hotspot detection.

Trend overlays.

Executive reporting.

These capabilities are intentionally excluded from Version 1.0 but shall be considered during architectural evolution.

APPENDIX L
Golden Rules

The following rules are immutable.

The approved reference image is the visual specification.
Business logic shall be reused whenever technically possible.
Presentation may evolve.
Architecture shall remain stable.
Dashboard components communicate only through application state.
SQL owns business logic.
Power Automate owns orchestration.
Power Apps owns presentation.
One analytical model.
One dashboard.
One implementation.
No duplicate screens.
No duplicate SQL.
No duplicate Flows.
No regressions accepted.
Pixel fidelity has priority over subjective interpretation.
Functional correctness has priority over aesthetic experimentation.
Every implementation phase shall be independently deployable.
Every implementation phase shall be independently reversible.
The Product Owner has final authority over dashboard design.
APPENDIX M
Codex Operating Instructions (Normative)

When implementing this specification, Codex shall:

Read the complete Functional Design Specification before modifying any file.
Identify only the controls affected by the current implementation phase.
Preserve all existing SQL Stored Procedures unless a defect requires modification.
Preserve existing Power Automate Flows unless a defect requires modification.
Preserve existing collections and variables whenever possible.
Modify the minimum number of YAML objects required to achieve the objective.
Validate compilation after every implementation phase.
Produce a list of modified controls.
Produce rollback instructions.
Stop after completing the current implementation phase.

Codex shall never continue automatically to the next phase without explicit Product Owner approval.

282. Final Statement

This document constitutes the official Functional Design Specification for the Executive Dashboard of the PULSE application.

It defines:

functional behaviour,
visual architecture,
implementation architecture,
data contracts,
validation procedures,
migration strategy,
repository standards.

Any future implementation shall conform to this specification unless superseded by a formally approved revision.

Document Status

Document: PULSE Executive Dashboard Functional Design Specification

Version: 1.0

Status: Approved for Implementation

Primary Audience: Power Apps Developers, Power Platform Architects, SQL Developers, Power Automate Developers and Codex

Approval Authority: Product Owner

Implementation Mode: Incremental, EPIC-based, regression-safe

APPENDIX N — Current Home_1 Technical Mapping
N.1 Objetivo

Análisis técnico completo del archivo Home_1.pa.yaml.

Su finalidad es eliminar cualquier ambigüedad durante la implementación del Executive Dashboard.

N.2 Inventario completo de controles

Tabla del estilo:

Control	Tipo	Contenedor	Estado	Acción
cmpExecutiveHeader	Component	Root	Reutilizar	Mantener
galPunchMatrix	Gallery	Analytics	Reutilizar	Transformar en Heatmap
cmpExecutiveInsight	Component	Analytics	Obsoleto	Eliminar
galTopSubsystems	Gallery	Analytics	Obsoleto	Eliminar
cmpExecutiveKpiCard	Component	KPI	Reutilizar	Restyling
btnViewPunches	Button	Grid	Reutilizar	Actualizar navegación
N.3 Jerarquía de contenedores

Árbol completo.

Home_1

RootContainer

HeaderContainer

FiltersContainer

AnalyticsContainer

LeftPanel

RightPanel

GridContainer

LoadingOverlay

ErrorOverlay
N.4 Variables actuales

Tabla.

Variable	Uso actual	Mantener	Observaciones
varProjectId	Proyecto	Sí	Sin cambios
varSelectedTemplate	Template	Sí	Sin cambios
varDashboardLoading	Loading	Sí	Reutilizar
varSelectedHeatmap	Selección	Adaptar	Cambiar contrato
N.5 Colecciones actuales

Tabla.

Colección	Procedencia	Consumidor	Acción
colDashboardMatrix	SQL	Heatmap	Reutilizar
colDashboardKPI	SQL	KPI	Reutilizar
colPunchGrid	SQL	Grid	Reutilizar
colExecutiveSummary	SQL	Obsoleto	Eliminar
N.6 Componentes reutilizables

Lista completa.

Por ejemplo:

cmpExecutiveKpiCard
cmpDashboardSectionHeader
cmpSkeletonLoader
cmpEmptyState
cmpDrawer

Indicando cuáles pueden mantenerse sin modificaciones y cuáles necesitan adaptación.

N.7 Componentes obsoletos

Listado completo.

Por ejemplo:

Executive Insights
Timeline
Top Subsystems
Top Companies

Todos marcados para retirada.

N.8 SQL Mapping

Tabla.

SP	Uso	Nuevo consumidor
usp_GetDashboardBundle	Dashboard	Dashboard completo
usp_GetPunches	Punch Grid	Grid
usp_GetPunchDetail	Drawer	Premium Drawer
N.9 Flow Mapping

Tabla.

Flow	Estado	Acción
warroom_GetDashboardBundle	Reutilizar	Sin cambios
ExportPunches	Reutilizar	Sin cambios
N.10 Navegación

Mapa completo.

Home_1

↓

Heatmap

↓

Grid

↓

Punches_1

↓

Premium Drawer
N.11 Riesgos

Tabla de riesgos.

Riesgo	Impacto	Mitigación
Borrar galerías equivocadas	Alto	Modificar in-place
Cambiar nombres de variables	Alto	Mantener nomenclatura
Duplicar colecciones	Medio	Reutilizar existentes
Crear nuevos Flows	Alto	Prohibido
N.12 Plan de edición del YAML

Listado exacto.

Modificar

Eliminar

Crear

Mover

Sin tocar

Cada control quedaría clasificado.
