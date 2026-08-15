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

## Checks pending Studio

The following mandatory acceptance criteria remain `NOT_RUN` until Rubén completes
the single grouped Studio validation:

- Source Code accepted by Studio;
- Sidebar and Page Header public contracts exposed and rendered;
- App Checker free of new blocking errors;
- six surfaces visually correct and non-overlapping at 1600×900;
- actions behave as local visual demonstrations;
- save/reopen preserves the screen and component instances;
- `scr_Overview` remains unchanged in the actual app.

Because mandatory runtime evidence remains `NOT_RUN`, OPDS-C01 is not completely
accepted. Its current state is `CANDIDATE / VISUAL_PREPARED`, ready for one grouped
Studio validation.

