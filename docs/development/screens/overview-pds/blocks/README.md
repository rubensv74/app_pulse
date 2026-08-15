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

Planned sequence:

```text
00 strategy and architecture
01 screen shell
02 page header integration
03 visual state surfaces with local test selector
04 data load, typed collections and real-outcome classification
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
