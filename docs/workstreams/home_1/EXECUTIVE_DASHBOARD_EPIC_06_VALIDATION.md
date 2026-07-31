# EPIC 06 — Analytical Navigation

Status: **IMPLEMENTED — PENDING INTEGRATION VALIDATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Delivered

- Enabled Detail Panel `View Punches`.
- Enabled Executive Grid `Go to Punches`.
- Centralized both actions on one navigation formula.
- Navigates to `scr_Punches_1` with no transition or intermediate screen.
- Preserves Project, Template, Category, Subsystem, Status, Discipline and Subcontractor context.
- Sets `varPunches_FilterSource = "Dashboard"` and `varPunches_AutoLoad = true`.
- Resets destination paging to page 1 and preserves the existing Punches_1 authoritative loader.
- Disables navigation when the active analytical result contains no Punches.

## Navigation contract

| Home_1 state | Punches_1 filter |
|---|---|
| `varProjectId` | Existing global Project |
| `varPunchDashboardTemplateId` | `varFilter_PunchTemplateId` |
| `varPunchDrillSubsystemCode` | `varFilter_SubsystemsCsv` and `varFilter_Subsystem` |
| `varPunchDrillCategoryCode` | `varFilter_PunchCategoryCode` |
| `varPunchDrillStatusCode` | `varFilter_PunchStatusCode` |
| `varPunchDrillDisciplineCode` | `varFilter_PunchDiscipline` |
| `varPunchDrillSubcontractorId` | `varFilter_Subcontractor` |

Blank analytical dimensions are transferred as blank destination filters, representing the complete dimension within the current Project and Template.

## Architectural validation

- Home_1 navigation performs no SQL or Flow execution.
- `scr_Punches_1.OnVisible` already recognizes `varPunches_FilterSource = "Dashboard"`, preserves transferred filters, enables automatic loading and invokes its existing authoritative loader.
- `Warroom_Punches_Filtered_Paged` remains owned by Punches_1.
- The two Home_1 actions do not duplicate filter-mapping business logic.

## Product Owner integration validation

- confirm both buttons navigate to Punches_1;
- confirm Project and Template remain selected;
- confirm Category and Subsystem match the Heatmap selection;
- confirm overall context produces unfiltered Category/Subsystem dimensions;
- confirm destination autoload occurs once;
- confirm zero-result actions remain disabled;
- confirm no Studio compilation errors.

These checks do not block repository progression.

## Risks

- Runtime control reset order and catalog loading require periodic Studio validation.
- Destination server results can exceed the bounded Home_1 subset by design; Punches_1 is the complete authoritative dataset.

## Next EPIC

EPIC 07 — repository validation, visual/functional comparison evidence, regression analysis and performance-risk review.
