# CHANGELOG

## Sprint I01.1 - E2E-ready export foundation

### Added

- Deployable `Warroom_ExportPunchesToExcel_Codex` Flow package and definition.
- Atomic `warroom.usp_RegisterPunchExportSnapshot` procedure.
- Contract/mapping v3 and idempotent technical mapping seed.
- Consolidated Microsoft-environment E2E checklist.
- Successfully packed unmanaged Power Platform solution artifact.

### Changed

- Export checksum now covers canonical standard values and sorted custom values.
- Office Script emits, hides and locks all seven canonical import metadata
  fields and excludes `OriginalValuesJson` from the workbook.
- Power Apps calls `Warroom_ExportPunchesToExcel_Codex`.
- `ExportBatchRow.RowVersion` is nullable while checksum concurrency is active.

### Fixed

- Flow trigger expressions now use the real Power Apps V2 internal keys.
- Export snapshot persistence must succeed before SharePoint file creation.
- Flow now returns a structured failure response when the success path cannot
  complete.

### Removed

- None.

### Known Issues

- Environment deployment, connector rebinding and Microsoft-editor compilation
  remain pending as one consolidated E2E validation round.
- Physical `RowVersion` remains unavailable from the Punch source; SHA-256 is
  the authoritative concurrency mechanism.

## Sprint I01.1 - Office Script compatibility fix

### Added

- None.

### Changed

- The generic JSON-object parser now crosses the `unknown` boundary explicitly,
  as required by the Office Scripts TypeScript compiler.

### Fixed

- Office Scripts compiler error TS2352 in `parseJsonObject<T>`.

### Removed

- None.

### Known Issues

- Office Scripts compilation must be confirmed again in the Microsoft editor.

## Sprint I01.1 - Real export integration

### Added

- Supplied Power Automate package and source definition for
  `Warroom_ExportPunchesToExcel`.
- Real Office Script, export dataset procedure and representative XLSX fixture.
- Repeatable structural workbook inspection.
- Version 2 export and mapping contracts aligned with physical fields.
- Corrected Flow definition using the real Power Apps trigger keys for selected
  columns and filter logging.

### Changed

- Power Apps no longer appends logical technical fields to
  `SelectedColumnsJson`; the real Office Script owns technical columns.
- I01 architecture now records the real checksum mechanism and 50,000-row Flow
  limit.

### Fixed

- Corrected assumed IDs to `PunchExportLogId` and `PunchId`.
- Corrected the assumption that a physical `RowVersion` is available.

### Removed

- None.

### Known Issues

- Current `RowHash` does not cover every editable standard field.
- Export rows are not persisted as immutable backend snapshots.
- The Flow lacks a complete error/cleanup scope.
- The corrected Flow definition is versioned but not deployed.

## Sprint I01 - Excel import foundations

### Added

- Azure SQL foundation tables, versioned contracts, backend column mapping and
  implementation documentation.

### Changed

- The Punch export request includes the seven mandatory import metadata fields.

### Fixed

- Column editability is now governed by a backend mapping contract.

### Removed

- None.

### Known Issues

- The external export Flow must implement and protect the requested metadata.
- SQL deployment and Power Apps Studio compilation require connected test
  environments and have not been executed locally.
- Logical target fields require verification against the production Punch schema.

## EPIC-01 â€” Home1 instance stabilization

### Modified

- `screens/Home/scr_Home_1.pa.yaml`

### Corrections

- Assigned valid theme colors to all four `cmp_ExecutiveKpiCard` instances.
- Assigned a non-empty `ActionText` to `cmpHomeKpiSectionHeader`.
- Replaced empty component events with valid Power Fx expressions.
- Removed empty `OnSelect: =` properties from non-interactive controls.
- Replaced empty transparent-button text properties with `Text: =""`.
- Replaced the empty `BorderColor` formula in `btnSelectNode_1`.
- Removed the invalid empty `Y` formula from the AutoLayout child `cntHome_PendingSubsystems_1`.
- Changed the drawer layer visibility to depend directly on `varShowDetailDrawer`.
- Connected sidebar collapse state to `varNavCollapsed`.
- Removed every remaining property whose value was only `=`.

### Scope

This delivery changes only component instances and invalid empty properties in Home1. It does not redesign the screen, change Flow contracts, alter SQL procedures, or modify dashboard data mappings.

### Validation performed

- YAML parsed successfully.
- Duplicate YAML mapping keys were checked.
- No property remains with an empty formula in the form `Property: =`.
- ZIP integrity was verified.

### Pending validation

- Import and compilation in Power Apps Studio.
- Interactive verification that selecting components no longer leaves the editor grey.
