# Dependency report — 1.0.0.2

| Dependency | Classification | Evidence |
|---|---|---|
| 63 app-referenced packaged flows | REQUIRED / INCLUDED | Exact names in app and solution |
| 3 active unmatched flow bindings | UNKNOWN / CRITICAL | Source uses and absent FlowNameIds |
| 7 unused duplicate flow references | HISTORICAL | Zero source use; suffixed duplicates |
| Four Azure SQL connection references | REQUIRED / UNKNOWN | Referenced but not packaged/contracted |
| Azure SQL DW | REQUIRED | Most flows and Canvas App |
| Excel Online Business + SharePoint | REQUIRED | Both export flows |
| Office 365 / Office 365 Users | REQUIRED / EXTERNAL | Canvas/flow connector APIs |
| `DIM_MASTER_COMPANIES_LH` | UNKNOWN | Included workflow not referenced by app; purpose not documented |

There are no forbidden dependencies evidenced. Critical UNKNOWN flow and connection bindings force FAIL.
