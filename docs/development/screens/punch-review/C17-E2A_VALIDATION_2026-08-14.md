# C17-E2A — Responsive / visual validation status

**Date:** 2026-08-14  
**Screen:** `scr_PunchReview`  
**Status:** VISUAL PASS / NAVIGATION FIX PENDING

## Evidence reviewed

Power Apps Studio screenshots supplied after DF-07B-FIX1, DF-06E-FIX4 and Session Activity scope correction.

## Visual gate — PASS

The current workspace composition is visually stable at the minimum desktop target being validated:

- header remains fully visible;
- Review Queue remains usable with vertical scrolling;
- Punch Overview stays dominant in the center workspace;
- Comments and Custom Fields remain side-by-side;
- Comments composer remains visible;
- Custom Fields footer remains visible;
- Review Progress fits without clipping;
- Session Activity fits without clipping;
- no global horizontal clipping is visible;
- no right-rail truncation is visible;
- Custom Field value controls retain the compact density approved in C17-D-FIX2.

## Session Activity accumulation — PASS

The latest Studio evidence shows:

- badge = `2 events`;
- previously recorded events remain visible after the current Punch changes;
- Session Activity no longer collapses to the current Punch only.

This is sufficient to validate the session-wide retention behavior introduced by C17-E2A-FIX1.

## Contextual Back — FAIL / FIX REQUIRED

Real navigation evidence confirms that Punch Review still returns to Home when the user expected to return to Punch List.

The source explains why:

- Punch List correctly sets `varPunchReviewSource = "PUNCHES"` and `varPunchReviewReturnScreen = "PUNCHES"` before opening Punch Review;
- `btnPR_Back.OnSelect` ignores that explicit return contract and calls `Back()`;
- the Dirty Guard `BACK` continuation also calls `Back()`;
- the visible button label is still fixed as `Back to Punches`.

Therefore navigation depends on Power Apps navigation history rather than the explicit functional origin.

Correction: `C17-E2A-FIX2_explicit_return_navigation.property-guide.md`.

## Current C17-E2A status

```text
HEADER                         PASS
QUEUE                          PASS
PUNCH OVERVIEW                 PASS
COMMENTS                       PASS
CUSTOM FIELDS                  PASS
RIGHT RAIL                     PASS
REVIEW PROGRESS                PASS
SESSION ACTIVITY VISUAL        PASS
SESSION EVENT ACCUMULATION     PASS
GLOBAL CLIPPING                PASS
HORIZONTAL SCROLL              PASS
CONTEXTUAL BACK                FAIL / FIX2 PENDING
```

After C17-E2A-FIX2 is validated from both Home and Punch List, C17-E2A can be closed and validation can continue with the next desktop size.