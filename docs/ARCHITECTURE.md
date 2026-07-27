# PULSE — Application Architecture

## Platform

- Front end: Microsoft Power Apps Canvas.
- Orchestration: Power Automate.
- Data services: Azure SQL and project data sources.
- Source format: Power Apps Source Code YAML.

## Runtime layers

### Application shell

The shell controls global navigation, project context and cross-screen loading overlays.

Key global states include:

- `varProjectId`
- `varProjectSwitching`
- `varGlobalLoading`
- `varGlobalLoadAction`
- `varGlobalLoadPending`

### Home orchestration

Home uses a centralized dispatcher for dashboard requests. The dispatcher selects the appropriate existing loader and maintains a single executive runtime status:

- `IDLE`
- `LOADING`
- `READY`
- `ERROR`

### Dashboard data

Home separates data into purpose-specific collections. Relevant examples include:

- `colHomeHiveNodes`
- `colHomePendingSubsystems`
- `colPunchDashboardSummary`
- `colPunchDashboardMatrix`
- `colPunchDashboardTimeline`
- `colPunchDashboardInsights`
- `colPunchDashboardSubsystems`
- `colPunchDashboardSubcontractors`

## Component contract principles

- Inputs must be explicit and typed.
- Navigation and actions use Event properties.
- Components do not call Flows directly.
- Components do not own project context.
- Components receive theme colors as inputs.
- Components expose no global variables.
- Business rules stay in the screen or orchestration layer.

## Executive component library

| Component | Responsibility |
|---|---|
| `cmp_ExecutiveKpiCard` | Present one KPI, trend and status with a navigation event. |
| `cmp_ExecutiveInsightCard` | Present one rule-derived insight with drill-through. |
| `cmp_ExecutiveAlertBanner` | Present error, warning or information notices with retry and dismiss events. |
| `cmp_SkeletonLoader` | Provide a consistent loading placeholder. |
| `cmp_EmptyState` | Present empty, error, no-project and no-permission states. |
| `cmp_DashboardSectionHeader` | Standardize section title, context and optional action. |

## Integration rule

The screen maps existing variables and collections into component inputs. Components must not change current Flow signatures, SQL procedure contracts or collection schemas.
