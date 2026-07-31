# Upgrade Definition

## Identity

| Field | Value |
|---|---|
| Upgrade ID | `I01.1-UPG-002` |
| Title | Deploy Export Punches Codex Flow |
| Project | PULSE |
| Solution unique name | `pulse_i011_upg002` |
| Package type | Unmanaged |
| Objective count | 1 |

## Objective

Deploy exclusively the Power Automate Flow
`Warroom_ExportPunchesToExcel_Codex` and the three Connection References that
its physical definition consumes.

## Business reason

Deploy the I01.1 Punch export orchestration without modifying or replacing the
PULSE Canvas App, the dashboard Flow, the legacy export Flow, or any unrelated
Power Platform component.

## Allowlist

| Type | Name/logical name | GUID |
|---|---|---|
| Modern Flow | `Warroom_ExportPunchesToExcel_Codex` | `{1d37f98f-2d8b-f111-ab10-000d3a21ce45}` |
| Connection Reference | `pls_sharedexcelonlinebusiness_1f1af` | Not declared in unpacked source |
| Connection Reference | `pls_sharedsharepointonline_facb1` | Not declared in unpacked source |
| Connection Reference | `pls_sharedsqldw_771b7` | Not declared in unpacked source |

No other component is authorized.

## Denylist

The following invalidate the package:

- Any Canvas App or `CanvasApps/` entry.
- `Warroom_ExportPunchesToExcel`.
- `warroom_GetPunchDashboardBundle`.
- Any Flow other than `Warroom_ExportPunchesToExcel_Codex`.
- Any Connection Reference other than the three allowlisted references.
- Any Environment Variable.
- Any table, column, relationship, option set or Dataverse entity component.
- Any security role or field security profile.
- Any Custom Control or PCF component.
- Any template, entity map, data provider or organization setting.
- Any component with unknown provenance.
- Any unexpected file or folder in the physical ZIP.

## Required dependencies

| Component | Dependency | Classification | Justification |
|---|---|---|---|
| Flow Codex | `pls_sharedexcelonlinebusiness_1f1af` | Required | Used by Excel Online actions |
| Flow Codex | `pls_sharedsharepointonline_facb1` | Required | Used by template, file and sharing actions |
| Flow Codex | `pls_sharedsqldw_771b7` | Required | Used by SQL stored-procedure actions |

There are no optional dependencies authorized for inclusion.

## Acceptance criteria

- Root components: exactly 1.
- Root component: exactly the allowlisted Flow GUID.
- Workflows: exactly 1.
- Connection References: exactly 3.
- Canvas Apps: 0.
- Environment Variables: 0.
- Unexpected components: 0.
- `solution.xml` and `customizations.xml`: present and valid XML.
- Flow JSON: present, valid UTF-8 and without BOM.
- Source provenance and SHA-256: recorded.
- Physical ZIP inventory and SHA-256: recorded.
- Unpack/repack verification: successful.
- Import Approval conclusion: exactly `PASS`.

Any failed criterion triggers Self-Rejection. A rejected ZIP must not be
delivered.

## Rollback requirements

### Preconditions

- Export or otherwise retain the current target Flow definition before import.
- Record its state and connection bindings.

### Procedure

- Reimport the retained previous Flow solution/definition.
- Restore the previous connection bindings.
- Turn off the upgraded Flow if restoration cannot be completed immediately.

### Validation

- Confirm the previous Flow definition and state.
- Execute its existing smoke test.
- Confirm no Canvas App or unrelated Flow changed during rollback.
