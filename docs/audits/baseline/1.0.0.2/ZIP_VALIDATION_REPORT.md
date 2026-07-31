# ZIP validation report — 1.0.0.2

## Passed controls

- Candidate readable, non-empty and immutable during audit.
- Preserved copy exactly matches source: 5,033,101 bytes and SHA-256 `7E7646877DB8DF38CFCB5C2BF7896C598C4E772A1E2F667ACFDD9134C3959D77`.
- Valid Power Platform Unmanaged solution `baseline_pulse` / `BASELINE_PULSE`, version 1.0.0.2, publisher PULSE.
- All three critical XML files are present, non-empty and valid.
- One Canvas App, 12 screens, 27 components and 69 workflows inventoried.
- All workflow roots have physical definitions; no manifest missing dependencies.
- `Warroom_ExportPunchesToExcel`, `_Codex`, and dashboard bundle are included.
- 63 app flow references are exact included matches; seven unused duplicates are classified historical.

## Failing controls

1. Three actively used app flow references remain UNRESOLVED; their FlowNameIds do not appear in the package.
2. Four required Azure SQL connection-reference logical names remain absent as root components and lack an external contract.
3. `Screen1` and `Component ------------` remain empty residual artifacts without justification.
4. `cmp_DetailDrawer_old` remains actively used but its legacy naming/status is unexplained.
5. The Canvas App is unchanged from rejected 1.0.0.1 and still differs from the repository copy.
6. Canonical migration from `_Codex` to unsuffixed export is not evidenced; the app still calls `_Codex`.

PAC CLI absence is a future operational blocker, not a content-rejection reason. No official unpack was executed.
