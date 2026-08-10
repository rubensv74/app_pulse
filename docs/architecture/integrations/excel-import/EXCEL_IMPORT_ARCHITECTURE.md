# PULSE - Excel import architecture

## Scope

Sprint I01.1 provides the export-side foundation required for safe Punch Excel imports. `power-apps/screens/Punches/scr_Punches_1.pa.yaml` calls `Warroom_ExportPunchesToExcel_Codex` with twelve positional parameters. Staging, validation and commit remain later import-workstream responsibilities until reactivated and re-audited.

## Trust boundary and lifecycle

Excel protection is a usability control, never a trust boundary. SQL owns the export identity, project/template scope, row membership, original values, checksums and business-column allowlist.

```text
select → export/snapshot → upload → stage → validate → diff → preview → confirm → revalidate → apply → audit
```

Uploading a file never updates production Punch data by itself.

## Export contract v3

Every importable `INTERNAL` workbook contains hidden, locked columns:

- `ExportBatchId`
- `ProjectId`
- `TemplateId`
- `WorkItemId`
- `RowVersion` (reserved and currently blank)
- `ExportedAtUtc`
- `RowChecksum`

The Office Script derives canonical names from the existing physical `PunchExportLogId`, `PunchId` and `RowHash`. Runtime contract source is:

```text
power-apps/contracts/excel-import/export-columns.v3.json
```

Power Apps sends only selected business columns. Technical columns are created and protected by the Office Script.

## Data model

The import foundation uses:

| Object | Responsibility |
|---|---|
| `warroom.ExportBatch` | Extension keyed by existing BIGINT `PunchExportLogId`; scope and allowlist snapshot. |
| `warroom.ExportBatchRow` | Immutable original JSON and SHA-256 per exported Punch. |
| `warroom.ImportBatch` | Import lifecycle and counters. |
| `warroom.ImportBatchRow` | Staged row, diff, validation and apply state. |
| `warroom.ImportAudit` | Applied field-level audit. |
| `warroom.ImportColumnDefinition` | Backend technical/business allowlist. |

`usp_RegisterPunchExportSnapshot` receives exported rows, validates them and creates the batch plus rows transactionally. Repeating the same request is idempotent; different immutable data for the same ID is rejected.

## Concurrency and checksum

The Punch source does not expose physical SQL `rowversion`, so `RowVersion` remains nullable. Concurrency uses SHA-256 over canonical `OriginalValuesJson`, including exported standard fields and sorted dynamic custom-field values.

The immutable JSON/checksum is persisted before workbook creation. Later validation must recompute the current canonical checksum. A mismatch is a blocking `CONFLICT`; no forced overwrite exists.

## Column governance

Contract/mapping v3 is current. Business editability comes from `warroom.usp_GetPunchExportColumnMap` and `IsEditableInExcel`; the selected allowlist is also frozen in `ExportBatch.AllowedColumnsJson`.

A field is importable only if both the stored batch allowlist and active backend mapping authorize it. `CF__` fields remain deny-by-default unless explicitly enabled by the current contract.

## Performance

- export flow hard limit: 50,000 rows;
- one structured table, `tblPunches`;
- one SQL snapshot call for the complete dataset;
- no SQL call per row.

## Canonical source locations

```text
power-apps/contracts/excel-import/
power-apps/mappings/
sql/export/
sql/import/
office-scripts/
```

Historical sprint copies are not retained in the working tree; Git history provides recovery. Before reactivating unfinished import stages, perform a targeted audit against current contracts and SQL source under the incremental-development protocol.
