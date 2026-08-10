# PULSE — Excel Import Architecture

**Status:** active architecture reference  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

## Scope

Sprint I01.1 provides the export-side foundation required for safe Punch Excel imports. The canonical Punches screen is:

```text
main/screens/Punches/scr_Punches_1.pa.yaml
```

It calls `Warroom_ExportPunchesToExcel_Codex` with twelve positional parameters. Staging, validation and commit remain later import work.

## Trust boundary and lifecycle

Excel protection is a usability control, never a trust boundary. SQL owns the export identity, project/template scope, row membership, original values, checksums and business-column allowlist.

```text
select → export/snapshot → upload → stage → validate → diff → preview → confirm → revalidate → apply → audit
```

Uploading a file never updates production Punch data.

## Export contract v3

Every importable `INTERNAL` workbook contains hidden, locked columns:

- `ExportBatchId`
- `ProjectId`
- `TemplateId`
- `WorkItemId`
- `RowVersion` (reserved and currently blank)
- `ExportedAtUtc`
- `RowChecksum`

The Office Script derives canonical names from the existing physical `PunchExportLogId`, `PunchId` and `RowHash`. Contracts v1/v2 remain history; runtime uses:

```text
main/contracts/excel-import/export-columns.v3.json
```

Power Apps sends only selected business columns. Technical columns are created and protected by the Office Script.

## Canonical implementation locations

```text
Power Apps screen
main/screens/Punches/scr_Punches_1.pa.yaml

Contracts
main/contracts/excel-import/

Mappings
main/mappings/excel-import/

SQL import
sql/import/

SQL export
sql/export/

Office Script
office-scripts/BuildPunchExport.ts
```

## Data model

`sql/import/001_import_foundations.sql` creates:

| Object | Responsibility |
|---|---|
| `warroom.ExportBatch` | Extension keyed by existing BIGINT `PunchExportLogId`; scope and allowlist snapshot. |
| `warroom.ExportBatchRow` | Immutable original JSON and SHA-256 per exported Punch. |
| `warroom.ImportBatch` | Import lifecycle and counters. |
| `warroom.ImportBatchRow` | Staged row, diff, validation and apply state. |
| `warroom.ImportAudit` | Applied field-level audit. |
| `warroom.ImportColumnDefinition` | Backend technical/business allowlist. |

`usp_RegisterPunchExportSnapshot` receives all exported rows once, validates them and creates the batch plus rows in one transaction. Repeating the same request is idempotent; different immutable data for the same ID is rejected.

## Concurrency and checksum

The Punch source does not expose physical SQL `rowversion`, so `RowVersion` remains nullable. Concurrency uses SHA-256 over canonical `OriginalValuesJson`, which includes all exported standard fields and sorted dynamic custom-field values.

The immutable JSON/checksum is persisted before the workbook is created. Later validation must recompute the current canonical checksum. A mismatch is a blocking `CONFLICT`; no forced overwrite exists.

## Column governance

Contract/mapping v3 is current. `sql/import/003_seed_import_columns_v3.sql` loads the technical mappings. Business editability comes from `warroom.usp_GetPunchExportColumnMap` and `IsEditableInExcel`; the selected allowlist is also frozen in `ExportBatch.AllowedColumnsJson`.

A field is importable only if both the stored batch allowlist and active backend mapping authorize it. `CF__` fields remain deny-by-default.

## Performance

- Export Flow hard limit: 50,000 rows.
- One structured table, `tblPunches`.
- One SQL snapshot call for the complete dataset.
- No SQL call per row.
- Import limit must be established by the corresponding import validation/performance phase.

## Historical deployment evidence

The original I01.1 environment deployment/E2E checklist has been archived at:

```text
docs/archive/sprints/excel-import-i01/I01_1_E2E_VALIDATION.md
```

That checklist is retained as historical delivery evidence and may contain paths from the repository layout that existed at the time. It is not the current repository navigation authority.
