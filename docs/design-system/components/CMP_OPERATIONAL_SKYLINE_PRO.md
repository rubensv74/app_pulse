# cmp_OperationalSkylinePro

**Lifecycle:** `REVIEW_REQUIRED`  
**PDS status:** candidate reusable visualization  
**Canonical source:** `power-apps/components/cmp_OperationalSkylinePro.pa.yaml`  
**Validation gate:** `docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md`  
**Compatibility register:** `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

## Purpose

`cmp_OperationalSkylinePro` is a reusable premium timeline visualization for PULSE. It represents operational load, readiness, risk or milestone concentration over an ordered sequence of time slots without depending on Punches, Tasks, Milestones or any other domain object.

The component is deliberately domain-agnostic:

> the host screen transforms its data into the Skyline slot contract; the component only renders and selects slots.

The component does **not** query SQL, call flows, filter data sources, navigate or persist state.

## Primary scenarios

### 1. Punch Skyline

One slot per day/week/month.

Suggested mapping:

| Skyline field | Punch mapping |
|---|---|
| `SlotKey` | date bucket key |
| `SlotLabel` | formatted planned date/week |
| `SlotCaption` | day/week caption |
| `Value` | OPEN punches in bucket |
| `Segment1Value..4Value` | configurable category/status/risk buckets |
| `MarkerText` | optional milestone affecting the bucket |
| `StatusText` | optional readiness label |
| `TooltipText` | contextual summary |

Recommended first experiment: OPEN Punches by `PLANNED_DATE`, aggregated by week when daily density is high.

### 2. Task Skyline

`Value` represents planned/active tasks per time bucket. The four segments can represent, for example, Ready / In Progress / At Risk / Blocked.

### 3. Milestone / Readiness Skyline

One slot represents a milestone date or planning bucket. `MarkerText` contains `WD`, `MCC`, `RFC`, `RFSU` or another milestone code. `Value` represents the number of blockers or the calculated readiness burden.

### 4. Generic operational capacity

Any ordered time bucket can be rendered when the host supplies the required slot contract.

## Visual model

The component contains:

1. title and subtitle;
2. three summary chips: slots, total and peak;
3. optional four-segment legend;
4. horizontal time axis;
5. horizontally scrollable skyline;
6. variable-height bars scaled against the peak or a fixed maximum;
7. optional four-part stacked composition;
8. optional marker pill above a slot;
9. date/period label, caption and status;
10. loading, empty and error states;
11. selection language aligned with PULSE Design System.

No SVG is used.

## Slot contract

`Slots` is a table with this schema:

| Field | Type | Required | Meaning |
|---|---|---:|---|
| `SlotKey` | Text | yes | Stable unique key |
| `SlotLabel` | Text | yes | Main axis label |
| `SlotCaption` | Text | recommended | Secondary axis text |
| `Value` | Number | yes | Total height metric |
| `Segment1Value` | Number | no | First stacked segment |
| `Segment2Value` | Number | no | Second stacked segment |
| `Segment3Value` | Number | no | Third stacked segment |
| `Segment4Value` | Number | no | Fourth stacked segment |
| `MarkerText` | Text | no | Milestone/event code |
| `MarkerColorHex` | Text | no | Marker color as valid hex |
| `StatusText` | Text | no | Slot status |
| `StatusColorHex` | Text | no | Status text color as valid hex |
| `BarColorHex` | Text | no | Fallback single-bar color |
| `TooltipText` | Text | recommended | Hover context |
| `IsEnabled` | Boolean | recommended | Enables/disables selection |
| `IsToday` | Boolean | recommended | Adds current-slot accent |
| `SortOrder` | Number | yes | Explicit timeline order |

### Segment behavior

When the sum of `Segment1Value..Segment4Value` is greater than zero, the bar is rendered as a normalized four-segment stack.

When all four segment values are zero, the bar is rendered as a single color using:

1. `BarColorHex`, when supplied;
2. otherwise `AccentColor`.

`Value` controls the overall bar height. The segment sum controls only the internal composition. For semantically exact charts, the host should normally make the segment sum equal `Value`.

## Public inputs

### Content and state

- `Title`
- `Subtitle`
- `AxisLabel`
- `Slots`
- `State`
- `LoadingText`
- `EmptyText`
- `ErrorText`

### Behavior

- `EnableSelection`
- `DefaultSelectedSlotKey`
- `MaxValue`
- `SlotWidth`
- `CompactMode`
- `ShowLegend`
- `ShowMarkers`
- `ShowStatus`
- `ShowSummary`
- `ShowValues`

### Formatting

- `ValueFormat`
- `ValueSuffix`
- `Legend1Text..Legend4Text`

### PDS / theme

- `BackgroundColor`
- `SurfaceAltColor`
- `BorderColor`
- `TextColor`
- `MutedTextColor`
- `AccentColor`
- `SelectedBackgroundColor`
- `SelectedBorderColor`
- `Segment1Color..Segment4Color`

## Public outputs

- `SlotCount`
- `TotalValue`
- `PeakValue`
- `PeakSlotKey`
- `PeakSlotLabel`
- `ScaleMaximum`
- `SelectedSlot`
- `SelectedSlotKey`
- `SelectedSlotLabel`
- `SelectedSlotValue`
- `SelectedStatusText`
- `HasSelection`
- `IsLoading`
- `IsEmpty`
- `IsError`

## Event

### `OnSlotSelect`

Raised when a selectable slot is clicked.

The host screen owns the resulting action. Typical examples:

- filter a Punch grid to the selected date bucket;
- open a contextual drawer;
- select a milestone;
- update a secondary chart;
- navigate to a review workspace.

No internal `Set()` variable is used for selection. Selection is derived from `galOSP_Slots.Selected`, so component instances do not share hidden selection state.

## PDS alignment

The default component uses the PULSE design system values:

- surface `#FFFFFF`;
- border `#E2E8F0`;
- text `#0F172A`;
- muted text `#64748B`;
- interaction blue `#1677FF`;
- selected background `#EFF6FF`;
- selected border `#91CAFF`;
- segment defaults green / blue / amber / red;
- radius panel `12`;
- radius controls `8`;
- Segoe UI;
- minimum reusable text size `8`;
- border-first / no standard panel shadow.

## Architecture constraints

The component intentionally avoids:

- domain-specific field names such as PunchId or TaskId;
- data-source calls;
- Power Automate calls;
- SQL calls;
- navigation;
- persistence;
- SVG;
- nested galleries;
- hidden global selection variables;
- screen-level dependencies.

The host is responsible for aggregation and shaping of `Slots`.

## Performance model

The component uses one horizontal gallery and no nested gallery. For dense horizons, the host should aggregate by week or month rather than passing hundreds of daily slots.

Recommended working target:

- day view: approximately 7–31 slots;
- week view: approximately 8–26 slots;
- month view: approximately 6–24 slots.

These are product guidelines, not hard technical limits.

## Lifecycle and validation

Current status:

```text
SOURCE_VALID: STATICALLY REVIEWED
COMPONENT_DEFINITION_ACCEPTED: PENDING
INSTANCE_SAFE: PENDING
PUBLIC_CONTRACT_VALIDATED: PENDING
VISUAL_QA_VALIDATED: PENDING
READY_FOR_INTEGRATION: NO
```

The component must remain `REVIEW_REQUIRED` until the isolated Studio validation described in `docs/development/components/operational-skyline-pro/VALIDATION.md` is completed.

## First PULSE integration candidate

After the reusable component passes the validation gate, the first recommended integration is a diagnostic `scr_SkylineLab` or equivalent sandbox screen using aggregated OPEN Punches by planned date.

Target-screen integration must not begin before the reusable component reaches `INSTANCE_SAFE`.
