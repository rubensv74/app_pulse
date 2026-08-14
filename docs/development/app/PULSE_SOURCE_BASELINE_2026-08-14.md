# PULSE — Source Baseline 2026-08-14

**Status:** USER-SUPPLIED CURRENT SOURCE / ARCHIVED  
**Captured:** 2026-08-14  
**Purpose:** preserve the complete Power Apps source context supplied in chat before continuing priority work.

## Why this is a baseline instead of an immediate canonical overwrite

The current incremental-architecture framework requires repository-first traceability **and** real-environment validation.

For that reason, the supplied sources are preserved intact as an immutable evidence baseline, while validated canonical source paths are promoted/updated during the priority-specific Studio/source-sync gates.

This avoids two bad outcomes:

1. losing the user's actual current source;
2. blindly replacing a previously validated canonical artifact with code that has not yet passed Power Apps Studio validation in this session.

## Included source

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `scr_Home.pa.yaml` | 671443 | `8a077e955f604d537fb6518f018df8c6b9a483c685749767aeae9d255b1b630f` |
| `scr_PunchReview.pa.yaml` | 456573 | `4389d3a44eaaec0237e93392539973acd24e07e8aed84703774a4d43b19e177c` |
| `scr_Punches.pa.yaml` | 258557 | `a4531fa71255c8f94a7c37ee58b60f1deb2a33b0aa00a98e4accf85e630115f1` |
| `scr_Overview.pa.yaml` | 155048 | `ff4463f7f0dbbe658fbebf57eb29b25b077deb464fd0ea3081d26204ffe2809e` |
| `scr_Tasks.pa.yaml` | 143946 | `93977f7724a3289132a974beabdc8cb65623e7bb7ebc9d10bb8a5ed2a51dad65` |
| `scr_Briefing.pa.yaml` | 65830 | `20dc620bc988cc36ed9171e894cefc603d6187ae284cfd1e6e8dbb0eaaac3b91` |
| `scr_SuperAdmin.pa.yaml` | 31925 | `efe573d7081f4c1b30a3a582c10654dfdff58e824a8b6cc96bb0f1437c4df09c` |
| `scr_Skyline.pa.yaml` | 118830 | `7e5f7841dbee72968586581c694a20526aa53f1d76e48cfa17736fa13a9b528c` |
| `scr_Config.pa.yaml` | 174523 | `e4901019f7baa9c368fa00b5d12d273f5ccf5c3e9288c14724775c10c3e171ba` |
| `App.OnStart.powerfx` | 25419 | `58dc66356bb82e8d17616926277a6a2aea0eaed2963aaf6050a43871414ef2fa` |

## App.OnStart transport normalization

The `App.OnStart` content arrived through a Markdown attachment and contained transport escaping such as:

- `*App*`
- `\_`
- `\*`

The archived `App.OnStart.powerfx` normalizes **only those transport artifacts** to their Power Fx form. No functional/semantic rewrite was performed.

## Home_PDS

The message also included the beginning of `scr_Home_PDS`.

That fragment is already represented by the existing incremental artifact:

`docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml`

It is intentionally **not** presented as a complete current screen because the supplied inline fragment was partial. The Home priority will decide its eventual role through a parity/cutover gate.

## Archive integrity

The complete source set is stored as an `xz`-compressed tar archive encoded as Base64 and split into repository-friendly text parts.

Concatenated Base64 SHA-256:

`f7ae116505ca63f9c98cf4787fb710f01cdec0ed96976809033578d32b6c0431`

Decoded `PULSE_SOURCE_BASELINE_2026-08-14.tar.xz` SHA-256:

`2064e9d7ad1f8af4804b429d4b2d3fd461d2b42a24076599b4e218011fce3cd9`

See:

`docs/development/source-baseline/2026-08-14/README.md`

## Findings that affect the active roadmap

### Punch Review

The supplied `scr_PunchReview` contains C17-E3A initial hydration. The pending C17-E3 dirty-protection/router changes are not yet incorporated, so C17-E3 remains the immediate action.

### Excel Export

The supplied `scr_Punches` already contains the export UI/runtime call to `Warroom_ExportPunchesToExcel_Codex` and launches the returned file URL. Export is therefore a closure/hardening priority, not greenfield implementation.

### Excel Import

No runtime import action was found in the supplied `scr_Punches` source. The repository import design remains a design/contract basis for P3 after export is frozen.

## Promotion rule

When a priority reaches its real-environment validation gate:

1. compare the working Studio/source artifact with this baseline;
2. update the canonical repository source;
3. record the validation evidence;
4. only then mark that source as the new current canonical baseline.

## Related files

- `docs/development/PULSE_EXECUTION_PRIORITIES.md`
- `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- `docs/development/screens/punch-review/blocks/C17-E3_runtime_completion.accelerated.instructions.md`
- `docs/development/CODEX_IMPORT_EXCEL_INSTRUCTIONS.md`
