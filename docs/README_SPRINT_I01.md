# Sprint I01 — Excel import foundations

## Objective

Create governed data, contract and export-request foundations for importing a
modified Punch export without applying production changes.

## Implemented scope

- Inspected the actual Punch export call and its column selection.
- Added five target batch/audit tables and a backend allowlist table.
- Added versioned export metadata, summary and column mapping contracts.
- Added mandatory metadata to the existing export request while preserving its
  twelve-parameter Flow signature.
- Documented trust, lifecycle, concurrency, performance and deployment.

I02 procedures, import Flows and import UI are out of scope.

## Files created

- `main/sql/import/001_import_foundations.sql`
- `main/contracts/excel-import/export-columns.v1.json`
- `main/contracts/excel-import/import-batch-summary.v1.json`
- `main/mappings/excel-import/punch-columns.v1.json`
- `docs/EXCEL_IMPORT_ARCHITECTURE.md`
- `docs/README_SPRINT_I01.md`

## Files modified

- `main/screens/Punches/scr_Punches_1.pa.yaml`
- `main/CHANGELOG.md`

## Dependencies

- Production Punch/catalog schemas for mapping approval.
- External `Warroom_ExportPunchesToExcel` Flow implementation.
- Non-production Azure SQL for execution tests.
- Power Apps Studio for authoritative Source Code compilation.

## Installation

1. Review mappings with the Punch data owner.
2. Execute `main/sql/import/001_import_foundations.sql` in non-production.
3. Re-run it to verify idempotency.
4. Load approved mappings into `warroom.ImportColumnDefinition`.
5. Update the Flow to persist batches and emit/protect all metadata columns.
6. Import the updated screen YAML in Power Apps Studio.

## Test instructions

1. Strict-parse every JSON file.
2. Parse every `.pa.yaml` and check duplicate mapping keys.
3. Search YAML for incompatible properties and broken/empty formulas.
4. Execute the SQL script twice in a disposable Azure SQL database.
5. Compile the screen in Power Apps Studio.
6. Generate an export and verify metadata, batch rows and protection.

## Validation results

Local static validation results are reported in the Sprint handoff.

## Known limitations

- The Flow, Office Script, SQL export and fixture are now versioned by I01.1.
- SQL execution requires an unconfigured non-production target.
- The current checksum does not cover every editable standard field.
- Immutable export-row snapshots are not yet persisted by the supplied Flow.

## Next step

Complete the I01.1 checksum and immutable export-row snapshot integration.
Only then begin I02 set-based batch creation, staging, validation, diff and
conflict detection.
