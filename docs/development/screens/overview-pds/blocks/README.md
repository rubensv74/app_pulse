# Overview PDS construction blocks

This directory will contain the implementation artifacts for `scr_Overview_PDS`.

Rules:

1. `scr_Overview` is never a block target.
2. Every accepted capability updates the complete cumulative screen snapshot under
   `power-apps/screens/OverviewPDS/`.
3. Blocks are internal construction units, not independent product deliveries.
4. A block states target, operation, dependencies, exclusions, expected result and
   validation.
5. Components are reused or created only through the PULSE component validation gate.
6. Runtime evidence and repository state are recorded separately.

Capability boundary:

- Block 03 belongs to OPDS-C01 and constructs visual surfaces only. Its local test
  selector is synthetic evidence of layout and exclusivity, never evidence of a real
  project outcome.
- Blocks 04–06 belong to OPDS-C02 and own flow connection, typed OPDS state and
  classification from real responses.
- The authorized producer contract returns `NO_CONFIGURATION`, `SNAPSHOT_REQUIRED`,
  `NO_DATA` or `READY`; genuine failed calls map to `ERROR` in Canvas.
- Parsing `FirstError.Message`, substring searches, translated messages or any
  free-text error is prohibited.
- A `READY` project with zero matches for the active filter is `NO_RESULTS`; it must
  not be reclassified as global `NO_DATA`.
- If a stable outcome exists but no suitable real project is available, the scenario
  is `NOT_RUN` and remains pending evidence when mandatory.
- A gate limited to one data scenario stops only that scenario and its dependants.

Validation result semantics:

| Result | Use |
|---|---|
| `PASS` | Executed; expected result observed and evidenced. |
| `FAIL` | Executed; observed result does not meet the expectation. |
| `NOT_RUN` | Safely testable, but not executed or no suitable real case available. A mandatory criterion remains pending unless predeclared conditional on case availability. |
| `GATED` | Missing material contract, permission, environment or dependency prevents safe implementation or validation. |
| `NOT_APPLICABLE` | Genuinely outside approved scope, with an explicit justification. |

The following are classification examples, not executed test results:

| Situation | Expected result |
|---|---|
| Stable code returned and correct surface shown | `PASS` |
| Stable code returned and wrong surface shown | `FAIL` |
| Contract recognizes the case but no suitable project is available | `NOT_RUN` |
| Contract cannot distinguish the case reliably | `GATED` |
| Scenario genuinely outside approved scope | `NOT_APPLICABLE`, with justification |

Capability results are recorded per criterion. Partial validation may continue, but
complete acceptance requires every mandatory criterion to be `PASS` or justified
`NOT_APPLICABLE`. A mandatory `FAIL` or `GATED` prevents complete acceptance. A
mandatory `NOT_RUN` remains pending evidence unless the criterion was explicitly
conditional on case availability before validation. A whole capability stops only
when the gate affects a shared mandatory dependency or safe cumulative construction.

Planned sequence:

```text
00 strategy and architecture
01 screen shell
02 page header integration
03 visual state surfaces with local test selector
04 SQL/Flow contract v2, data load, typed collections and real-outcome classification
05 report context
06 tabs and filters
07 matrix geometry
08 hierarchy and cells
09 selection and horizontal navigation
10 paging
11 Tasks drill-through
12 Punch drill-through
13 re-entry protection
14 hardening
15 help and polish
16 promotion review
```
