# OPDS-C01 — static validation record

## Scope

This record covers repository inspection of the OPDS-C01 candidate. It does not claim
Power Apps Studio acceptance, runtime rendering or real functional-state evidence.

## Checks executed

| Check | Obligation | Result | Evidence |
|---|---|---|---|
| Valid PaYaml root and unique control names | Required | `PASS` | `audit_payaml.py` completed without errors or warnings. |
| Complete screen snapshot is present | Required | `PASS` | Root is `Screens:` and contains `scr_Overview_PDS`. |
| Six synthetic state values are selectable | Required | `PASS` | Buttons set `LOADING`, `NO_PROJECT`, `NO_CONFIGURATION`, `NO_DATA`, `ERROR` and `READY`. |
| Six state surfaces are mutually exclusive by source formula | Required | `PASS` | Every surface uses equality against the same local `varOPDS_VisualTestState`. |
| Overview flow calls absent | Required | `PASS` | Static search found neither existing Overview flow name nor any `.Run(` expression. |
| Operational navigation absent | Required | `PASS` | Static search found no `Navigate(` expression. |
| Existing `scr_Overview` not modified | Required | `PASS` | Repository diff contains no change under `power-apps/screens/Overview/`. |
| SQL and Power Automate not modified | Required | `PASS` | Repository diff contains no file under `sql/` or `power-automate/`. |
| Component hydration risk handled before Studio | Required | `PASS` | Source contains empty hosts; the one-pass guide uses the demonstrated manual insertion route. |
| Static ModernText guardrail | Required | `PASS` | Every new `ModernText@1.0.0` control declares `AutoHeight: =true`. |

## First Studio validation — 2026-08-15

Evidence received:

- [Loading surface](evidence/2026-08-15/OPDS-C01-loading.png);
- [Ready surface](evidence/2026-08-15/OPDS-C01-ready.png);
- [Formula/App Checker list](evidence/2026-08-15/OPDS-C01-formula-errors.png)
  showing 18 existing errors outside `scr_Overview_PDS`;
- [complete current `scr_Overview_PDS` Source Code](evidence/2026-08-15/scr_Overview_PDS.after-first-studio.pa.yaml)
  after manual component insertion.

| Criterion | Obligation | Result | Evidence / consequence |
|---|---|---|---|
| Complete screen Source Code accepted | Required | `PASS` | Screen rendered in Studio. |
| Loading surface renders alone | Required | `PASS` | Loading screenshot. |
| Ready surface renders alone | Required | `PASS` | Ready screenshot. |
| No-project, no-configuration, no-data and error surfaces | Required | `NOT_RUN` | No direct screenshot or result was supplied for these four selector states. |
| `cmp_SidebarNav` public bindings | Required | `FAIL` | Sidebar rendered Home-only defaults and `Text` / `Text`. |
| `cmp_PageHeaderPro` host rendering | Required | `FAIL` | Header area remained blank; captured instance exposed only `Height` and `OnUtility`. |
| No new blocking Formula error attributable to OPDS | Required | `PASS` | Error list contains other screens/components and no `scr_Overview_PDS` entry. |
| Save/reopen persistence | Required | `NOT_RUN` | No explicit save/reopen result supplied. |
| Runtime exclusivity across all six states | Required | `NOT_RUN` | Two states were observed individually; the full six-state walkthrough was not evidenced. |

The component failures are localized. They do not invalidate the native state
surfaces, but they prevent complete C01 acceptance. A single consolidated FIX replaces
the failed Page Header reuse with a native premium header and reapplies the Sidebar
bindings through its visible public contract.

## Checks pending after the consolidated FIX

The following mandatory acceptance criteria remain pending until Rubén completes the
second and final grouped Studio validation:

- updated Source Code accepted by Studio;
- native premium header rendered;
- Sidebar public bindings rendered without literal defaults;
- App Checker free of new blocking errors;
- six surfaces visually correct and non-overlapping at 1600×900;
- actions behave as local visual demonstrations;
- save/reopen preserves the screen and component instances;
- `scr_Overview` remains unchanged in the actual app.

Because mandatory criteria remain `FAIL` or `NOT_RUN`, OPDS-C01 is not completely
accepted. Its current state is `PARTIALLY_VALIDATED`, ready for one consolidated FIX
validation.
