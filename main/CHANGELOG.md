# CHANGELOG

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

## EPIC-01 — Home1 instance stabilization

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
