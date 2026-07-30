# Sprint I01.1 - Real export integration

## Objective

Deliver a repository-complete, import-ready export implementation for one
round of non-production E2E deployment and validation.

## Implemented scope

- Final Flow name: `Warroom_ExportPunchesToExcel_Codex`.
- Corrected Power Apps trigger-key expressions.
- Deployable Flow ZIP and reproducible definition.
- Canonical checksum covering standard and sorted custom values.
- Atomic, idempotent persistence of `ExportBatch` and `ExportBatchRow`.
- Canonical contract-v3 metadata emitted/locked by Office Script.
- Technical mapping seed and backend allowlist snapshot.
- Power Apps call updated to the Codex Flow.
- Structured failure response and snapshot-before-file dependency.
- Repeatable XLSX structural inspector.
- One consolidated E2E checklist.

No I02 validation procedures or import UI were implemented.

## Files created

- `main/sql/export/002_register_punch_export_snapshot.sql`
- `main/sql/import/003_seed_import_columns_v3.sql`
- `main/contracts/excel-import/export-columns.v3.json`
- `main/mappings/excel-import/punch-columns.v3.json`
- `main/power-automate/Warroom_ExportPunchesToExcel_Codex/definition.deploy.json`
- `main/power-automate/Warroom_ExportPunchesToExcel_Codex/Warroom_ExportPunchesToExcel_Codex.zip`
- `docs/I01_1_E2E_VALIDATION.md`
- `power-platform/solutions/PULSE/dist/PULSE_I01_1_unmanaged.zip`

## Files modified

- `main/sql/import/001_import_foundations.sql`
- `main/sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
- `main/office-scripts/BuildPunchExport.ts`
- `main/screens/Punches/scr_Punches_1.pa.yaml`
- `main/tests/excel-export/Inspect-PunchExport.ps1`
- `main/power-automate/Warroom_ExportPunchesToExcel_Codex/README.md`
- `power-platform/solutions/PULSE/pulse/src/Workflows/Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json`
- `docs/EXCEL_IMPORT_ARCHITECTURE.md`
- `docs/README_SPRINT_I01_1.md`
- `main/CHANGELOG.md`

## Deployment order

The only environment work is the single ordered checklist in
`docs/I01_1_E2E_VALIDATION.md`.

## Local validation

- Strict JSON parsing.
- Flow action/dependency and trigger-key assertions.
- Flow ZIP integrity and display-name inspection.
- SQL static safety/idempotency checks.
- Office Script structural/contract checks.
- Power Apps Flow-reference and changed-formula checks.
- Contract/mapping consistency.
- `git diff --check`.

## Limitations

- Azure SQL execution requires the target non-production database.
- Office Script and Power Apps compilation require Microsoft editors.
- Flow connections and SharePoint/script identifiers are environment-specific.
- `RowVersion` is intentionally blank until the Punch source exposes one;
  checksum concurrency is authoritative.

## Next step

Execute the single E2E checklist. If every check passes, close I01.1 and begin
I02 backend validation.

## Block A stabilization

The SQL snapshot model is now GUID/BIGINT canonical, includes an idempotent migration, nullable RowVersion, failure compensation and SQL tests. Non-production execution evidence is required before Block A is closed.
