# C16-FIX — Donut thickness binding in Punch Review

## Classification

`C — Component / FIX`

## Problem

In the Punch Review `Review Progress` card, changing `cmpPR_ReviewProgressDonut.DonutThickness` in the component instance does not produce the expected visual change.

The current canonical `cmp_DonutPro` source **does** bind `DonutThickness` to both SVG strokes inside `imgDNP_Donut.Image`:

- background track `stroke-width`;
- every data segment `stroke-width`.

Therefore the first repair is to synchronize the active app component's `imgDNP_Donut.Image` formula with the canonical repository version before redesigning geometry or changing unrelated controls.

## Target

Component definition:

`cmp_DonutPro > conDNP_Root > imgDNP_Donut`

Property:

`Image`

## Operation

Replace the complete `Image` formula with the formula in:

`C16-FIX_imgDNP_Donut.Image.powerfx`

Direct repository file:

`docs/development/components/donut-pro/fixes/C16-FIX_imgDNP_Donut.Image.powerfx`

## Dependencies

- `cmp_DonutPro` already exists in the active app.
- `cmpPR_ReviewProgressDonut` already exists in Punch Review.
- No new component instance is introduced.

## Touches

- `cmp_DonutPro.imgDNP_Donut.Image` only.

## Do not modify

- Punch Review geometry;
- `conPR_ReviewProgressCard`;
- Comments;
- Custom Fields;
- Review Queue;
- component CustomProperties;
- Items contract;
- colors;
- backend.

## Why this is the correct first FIX

The repository implementation already uses `cmp_DonutPro.DonutThickness` for both the track and segment strokes. If the active component instance does not react to the property, the active app component definition must first be aligned with the known canonical formula. This avoids introducing a new rendering model before confirming that the existing contract works as designed.

## Validation

After replacing the formula:

1. Return to `scr_PunchReview`.
2. Select `cmpPR_ReviewProgressDonut`.
3. Set `DonutThickness = 8` and observe the ring.
4. Set `DonutThickness = 20` and observe the ring again.
5. The difference must be clearly visible without changing Width or Height.
6. Restore the preferred value after the test; for the current compact Review Progress card start with `18`.
7. Confirm Reviewed/Remaining values still update correctly.
8. Confirm no other `cmp_DonutPro` behavior is affected.

## Gate

If `8` versus `20` still produces no visible difference after this formula is synchronized, stop. Do not continue to DF-05. The next repair must be isolated as a rendering FIX for compact-width SVG scaling; do not change Punch Review structure or color to compensate.

## Expected status after validation

`C16 — FUNCTIONAL_FROZEN`

Color can remain `PENDING` independently.
