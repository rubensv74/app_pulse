# VF-05A — Visual validation matrix

Use this matrix after applying `05_visual_polish.incremental-patch.pa.yaml`.

## Purpose

Validate the full Punch Review right column after the Custom Field Values refactor without changing business logic.

## Required test state

- VF-03 + VF-03A applied to `cmp_CustomFieldValuesPro`.
- VF-04 + VF-04A applied to `scr_PunchReview`.
- A real Punch selected with Custom Fields loaded.
- Preferably test both a manager and a read-only role.

## Matrix

| Viewport | Expected layout | Validation |
|---|---|---|
| 1366×768 | Queue left, center workspace, right column remains three stacked regions; workspace can scroll vertically | No clipping or overlap; Comments composer, Custom Fields footer and Review Progress reachable |
| 1600×900 | Same desktop structure with less vertical scrolling | All three regions usable; Custom Fields list scrolls internally when needed |
| 1920×1080 | Full desktop layout with enough height for the three right-column regions | No excessive whitespace; no clipped cards |
| Width ~360–380 px for `cmp_CustomFieldValuesPro` | Two-row component header | Title/status do not overlap; Record/Manage/Refresh do not overlap |
| Width ~420–500 px for `cmp_CustomFieldValuesPro` | Two-row component header with more breathing room | Controls align cleanly and remain readable |

## Functional regression checks

1. Select Punch A and confirm Comments + Custom Field Values correspond to A.
2. Edit one Custom Field and confirm Unsaved state.
3. Cancel and confirm baseline restoration.
4. Edit and Save; confirm server-authoritative Saved state.
5. Edit and navigate to Punch B; confirm Dirty Guard opens.
6. Test Save and continue, Discard and continue, and Cancel.
7. Confirm Review Progress still reacts only to Mark Reviewed / Undo Review.
8. Confirm `Manage` remains the temporary DF-phase information action.
9. Confirm a non-manager sees values in read-only mode.

## Acceptance

VF-05 is accepted only when no Source Code/App Checker error appears and the visual/functional checks above pass. Any new incompatibility must be added first to `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` before subsequent YAML work.
