# PULSE Repository — Power Automate Source Gap Decision

**Status:** decided — Option A approved  
**Date:** 2026-08-10  
**Decision:** version Power Automate as a first-class source layer

## Context

The repository structure was migrated from the ambiguous `main/` source folder to explicit technology roots.

Canonical Power Apps screens invoke multiple Power Automate flows. Without an explicit Power Automate source area, the repository could not become a sufficiently complete technical source of truth.

## Approved architecture

```text
/
├── power-apps/
├── power-automate/
│   ├── flows/
│   ├── contracts/
│   └── README.md
├── sql/
├── office-scripts/
└── docs/
```

## Decision rules

- store current deployable/exported flow definitions when extracted from the real environment;
- keep active flow definitions under `power-automate/flows/`;
- keep stable flow-facing request/response contracts under `power-automate/contracts/` when useful;
- never invent missing flow internals from Power Apps `.Run(...)` calls;
- treat a missing definition as a repository coverage gap;
- validate flow changes in Power Automate before declaring them complete;
- update Power Apps/SQL contract documentation when parameter order or payloads change;
- remove superseded-only flow definitions from the working tree after migration; Git history preserves recovery.

## Progressive synchronization model

```text
identify active runtime caller
→ verify the real flow in Power Automate
→ export/read the real definition
→ save the definition under power-automate/flows/
→ document/update the interface contract when useful
→ validate caller/flow compatibility
→ mark repository coverage complete
```

Until a real definition is captured, the Power Automate environment remains the execution authority for that flow.

## Implementation result

The canonical source area now exists:

```text
power-automate/README.md
power-automate/flows/README.md
power-automate/contracts/README.md
```

An active-flow coverage register is maintained at:

```text
power-automate/FLOW_COVERAGE.md
```

This decision closes the repository-level architecture question. Capturing each real active flow definition is now ordinary incremental source synchronization, not a new architecture decision.
