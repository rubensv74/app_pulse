# PR-IMP-C02A — Negative checksum validation — PASS

Date: 2026-08-17

## Result

The checksum-negative test passed.

Observed result:
- Import batch status: `BLOCKED`
- TotalRows: `3`
- ChangedRows: `0`
- UnchangedRows: `2`
- ValidRows: `2`
- ErrorRows: `1`
- ConflictRows: `0`
- canCommit: `0`
- ProductionCommentDelta: `0`
- Failing row: Excel row `2`, WorkItemId `1292427`
- Error code: `CHECKSUM_MISMATCH`

## Gate conclusion

PR-IMP-C02A Stage + Validate is closed with PASS.

The validator blocks a workbook whose immutable row checksum no longer matches the export snapshot and does not write to `warroom.PunchComment`.

Next capability: PR-IMP-C02B Preview SQL.
