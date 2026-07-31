# ZIP validation report

## Package identity and integrity

- Source/preserved ZIP: 4,924,908 bytes; identical SHA-256 `C80249D24ECAA1BDF646595B00C2B8E951C4C8AB9825CA7DE5D7233B9D48B375`.
- `solution.xml`, `customizations.xml`, and `[Content_Types].xml`: present, non-empty and valid XML.
- Solution: `baseline_pulse` / `BASELINE_PULSE`, version `1.0.0.1`, publisher `pulse` / `PULSE`, Unmanaged (`Managed=0`).
- Root components: 1 Canvas App and 2 workflows. Manifest reports no missing dependencies.
- Extraction completed with exit code 0 in an ignored, unique audit workspace.

## Gate failures

1. The Canvas App has 73 flow data sources but the ZIP packages only 2 workflows. The other 71 runtime dependencies are not traceable from this package.
2. Expected `Warroom_ExportPunchesToExcel` is absent; only `Warroom_ExportPunchesToExcel_Codex` is included.
3. Four Azure SQL connection-reference logical names are referenced but none is a packaged root component.
4. Currentness is unresolved: ZIP `.msapp` SHA-256 `F77B…30FC` differs from repository `.msapp` SHA-256 `6A2E…69B`.
5. `Screen1`, `Component ------------`, and `cmp_DetailDrawer_old` are unexpected/residual-looking and lack an approved explanation.
6. PAC CLI is unavailable, so toolchain readiness for the next official phase is blocked (although PAC was not needed for this physical audit).

There is no evidence of ZIP corruption or a Managed package. The failure is completeness, dependency traceability, currentness, and unexplained content.
