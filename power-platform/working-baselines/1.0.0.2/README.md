# PULSE working baseline 1.0.0.2

Status: `WORKING BASELINE — APPROVED WITH KNOWN DEBT`.

| Field | Value |
|---|---|
| Original package | `baseline/exported/2026-07-31/baseline_pulse_1_0_0_2.zip` |
| ZIP size | 5,033,101 bytes |
| ZIP SHA-256 | `7E7646877DB8DF38CFCB5C2BF7896C598C4E772A1E2F667ACFDD9134C3959D77` |
| Solution | `baseline_pulse` / `BASELINE_PULSE` |
| Version / type | `1.0.0.2` / Unmanaged |
| Official solution destination | `power-platform/working-baselines/1.0.0.2/solution/` |
| Official tool | Microsoft SolutionPackager via `Microsoft.PowerApps.MSBuild.Solution` 1.52.1 and `dotnet msbuild` |
| Command | `SolutionPackagerTask Action=Extract PackageType=Unmanaged` |
| Result | Success; 144 files; 69 workflows; 1 Canvas App |
| Unpacked at | `2026-07-31T13:06:45+02:00` |
| Log | `SolutionPackager.log` |

`solution/` is the official SolutionPackager output. `canvas-source/new_pulse_9584c/` is a separate read-only extraction of the preserved MSAPP container made with .NET ZIP support for source inventory; it is not a PAC Canvas conversion. The MSAPP remains unchanged with SHA-256 `F77B0BEEBF102A5D848EAB43212E97A3047A29B1AA04689FF93481C2A99230FC`.

This baseline is recoverable working state, not a final release or cleaned Golden Baseline. Do not edit the preserved ZIP or delete legacy screens/components during the Home_1 / Punches_1 sprint.
