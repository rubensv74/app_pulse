# PULSE — PR-IMP-C02B Preview validation

**Date:** 2026-08-17  
**Branch:** `feature/pr-exp-c03-exact-review-queue`  
**Result:** PASS

## Evidence

Validated in `db-homeoffice-dev` using the negative-checksum batch created by PR-IMP-C02A.

Observed:

- `warroom.usp_GetPunchCommentImportPreview` exists.
- `WritesPunchComment = 0`.
- Batch status = `BLOCKED`.
- `TotalRows = 3`.
- `ErrorRows = 1`.
- Result set 2 returns exactly 3 preview rows.
- Result set 3 with `@ValidationStatus = 'ERROR'` returns exactly 1 row.
- The underlying staged batch was previously validated with `CHECKSUM_MISMATCH` for that row.
- No production comment write occurs during preview.

## Gate conclusion

PR-IMP-C02B is accepted as the read-only paged preview slice. It is sufficient to prove that the future `scr_PunchImport` can retrieve all staged rows and isolate blocking rows before any commit.

## Next required capability

Before implementing Commit, concurrency/current-state validation must be added so that the backend can distinguish:

- workbook integrity errors;
- unchanged rows;
- rows ready to append a comment;
- rows whose underlying Punch changed after the export snapshot (`CONFLICT`).

The UI must not be allowed to present `Apply changes` until that conflict model is validated.
