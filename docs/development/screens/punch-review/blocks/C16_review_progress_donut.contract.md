# BLOCK C16 — Review Progress donut card

**Type:** `C — Component`  
**Status:** published, pending Power Apps Studio validation.

## Target

`conPR_RightColumn`

## Operation

Add one new child at the bottom of the existing right column.

## Purpose

Introduce the compact **Review Progress** card requested for Punch Review, using the already installed `cmp_DonutPro` and the current session queue state.

The card represents session progress only:

- **Reviewed in Session** = queue rows with `IsReviewedInSession=true`;
- **Remaining** = queue rows not reviewed in the current session;
- **Total** = `CountRows(colPunchReviewQueue)`;
- **Current Position** = `varPunchReviewCurrentIndex` within the full loaded queue.

It does **not** represent Punch operational status, project completion, SQL history or server-side review state.

## Dependencies

- `cmp_DonutPro` installed in the active app;
- `colPunchReviewQueue`;
- `varPunchReviewCurrentIndex`;
- current PULSE theme variables.

## Touches

Only the addition of `conPR_ReviewProgressCard` as a child of `conPR_RightColumn`.

## Do not modify

- Comments;
- Custom Fields;
- right-column width/height/layout geometry;
- queue;
- Punch Overview;
- Session Activity;
- Related in Queue;
- header/navigation;
- Custom Fields contracts;
- backend flows.

## Visual model

The reference supplied by the user is interpreted as:

1. card title `Review Progress`;
2. donut with total in the center;
3. `Reviewed in Session` and `Remaining` as the donut legend with values and percentages;
4. `Current Position` as a separate compact footer row.

The existing `cmp_DonutPro` is reused rather than recreating a chart in screen YAML.

## Geometry

- card height: 184 px;
- width: current right-column width;
- `FillPortions=0` so the card does not compete for flexible space;
- no change to the parent column geometry.

At narrower widths, `cmp_DonutPro` already degrades by hiding its internal legend below its own responsive threshold. The footer position remains visible.

## Color status

Structure and behavior are the scope of C16. The donut component currently requires segment colors as text/HEX, so the current PULSE blue and neutral values are used for its two segments.

Color remains independently governable and may stay `PENDING` after functional validation, consistent with the modular construction playbook.

## Validation in Studio

1. Insert `C16_review_progress_donut.add-child.pa.yaml` as a new child of `conPR_RightColumn`, after Custom Fields.
2. Confirm no Source Code or formula errors.
3. Confirm center total equals the full loaded queue count.
4. Mark a Punch reviewed and confirm Reviewed/Remaining update immediately.
5. Confirm Reviewed + Remaining = Total.
6. Navigate Previous/Next or select another queue row and confirm Current Position updates.
7. Confirm Comments and Custom Fields are unchanged.
8. Confirm no Flow or SQL call is produced by the card.

## Expected status after validation

```text
STRUCTURE       FROZEN
BEHAVIOR        FROZEN
DATA CONTRACT   FROZEN
COLOR           PENDING

=> FUNCTIONAL_FROZEN
```

## Next block gate

DF-05 is an `I — Integration` block. Per the active construction playbook, its implementation YAML must not be generated/applied until C16 has been validated in Power Apps Studio or any C16 issue has been repaired with a dedicated `C16-FIX`.
