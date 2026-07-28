# PULSE — Excel import architecture

## Scope and baseline

Sprint I01 defines the foundations for importing a PULSE-generated Punch Excel
export. The existing export is initiated by
`main/screens/Punches/scr_Punches_1.pa.yaml`, which calls
`Warroom_ExportPunchesToExcel` with twelve positional parameters. The twelfth,
`SelectedColumnsJson`, carries the requested columns.

No reproducible Power Automate definition, SQL source object, data contract or
backend mapping for that Flow existed in this repository at the start of I01.
Staging/validation procedures, import Flows and import UI are not part of I01.

## Trust boundary and lifecycle

Excel protection is a usability control, not a security boundary. SQL is the
authority for the export batch, project/template scope, work item membership,
original values, row versions, checksums and active editable-column allowlist.

The lifecycle is:

`select → analyse → create batch → stage → validate → diff → preview → confirm
→ revalidate → apply → audit`.

Uploading a file never updates a production Punch table.

## Export contract

Every exported row carries `ExportBatchId`, `ProjectId`, `TemplateId`,
`WorkItemId`, `RowVersion`, `ExportedAtUtc` and `RowChecksum`. Power Apps
appends these keys to `SelectedColumnsJson`; they are not user-selectable.

The Flow must persist the export batch and its rows, populate the metadata,
protect those columns, and return the file only after persistence succeeds.
The exact request contract is
`main/contracts/excel-import/export-columns.v1.json`.

## Data model

`main/sql/import/001_import_foundations.sql` creates:

| Object | Responsibility |
|---|---|
| `warroom.ExportBatch` | Export identity, scope and allowlist snapshot. |
| `warroom.ExportBatchRow` | Original state, row version and checksum. |
| `warroom.ImportBatch` | Import lifecycle and aggregate counters. |
| `warroom.ImportBatchRow` | Staged data, diff and validation/apply state. |
| `warroom.ImportAudit` | Per-field applied-change audit. |
| `warroom.ImportColumnDefinition` | Backend allowlist by project/template. |

The unique import-to-export relationship prevents reuse of an export batch.
Sprint I02 procedures must enforce lifecycle transitions and semantic
invariants transactionally.

## Concurrency and integrity

`RowVersion` travels as 16-character uppercase hexadecimal text and is stored
as `binary(8)`. A mismatch between export state and current state is a blocking
`CONFLICT`; I01 defines no forced overwrite.

`RowChecksum` is SHA-256 over a backend canonical row representation. The same
backend implementation must generate and verify it; Power Apps and Excel are
never checksum authorities.

## Column governance

`main/mappings/excel-import/punch-columns.v1.json` is the initial logical
allowlist. Deployment loads approved entries into
`warroom.ImportColumnDefinition`; runtime validation reads that table.
Dynamic `CF__` fields are denied by default and require an active scoped
backend definition.

## Performance baseline

- Maximum MVP file size: 5,000 data rows.
- One structured Excel table per file.
- Batch or bulk staging, never one SQL call per row.
- Set-based validation/diff and paged row-error retrieval.

## Deployment dependencies

1. Check logical field names and lengths against the production Punch schema,
   which is not versioned here.
2. Run the foundation script twice in non-production to verify idempotency.
3. Load the approved backend mapping.
4. Update and test `Warroom_ExportPunchesToExcel` against export contract v1.
5. Begin I02 only after those dependencies are accepted.

No credentials, connections or environment-specific secrets are included.
