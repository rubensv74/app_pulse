# PULSE Repository — Power Automate Source Gap Decision

**Status:** architecture decision required  
**Date:** 2026-08-10

## Context

The repository structure has been migrated from the ambiguous `main/` source folder to explicit technology roots:

```text
power-apps/
sql/
office-scripts/
docs/
```

The active-source policy requires the repository to be the canonical technical source for project artifacts.

However, canonical Power Apps screens currently invoke multiple Power Automate flows, while the repository has no explicit top-level canonical Power Automate source area.

Examples include dashboard, Punch filter, comments, custom-fields and export/integration flow calls from the current screens.

This creates an architectural gap: Power Apps, SQL and Office Scripts have explicit canonical source locations, but Power Automate does not.

## Decision required

### Option A — version Power Automate as a first-class source layer — RECOMMENDED

Target repository:

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

Rules:

- store current deployable/exported flow definitions where technically available;
- one folder per active flow;
- keep flow-facing request/response contracts close to the flow source or in a clearly linked contract area;
- remove obsolete flow generations when superseded and no longer active;
- validate flow changes in Power Automate before declaring them complete;
- update Power Apps/SQL contract documentation when parameter order or payloads change.

Benefits:

- repository becomes materially closer to a complete source of truth;
- AI agents can inspect actual orchestration rather than infer it from Power Fx calls;
- flow contract drift becomes visible in Git;
- incremental architecture can be applied consistently across Canvas, Flow, SQL and Office Scripts.

### Option B — do not version flow definitions

Keep only flow names/contracts documented under `docs/` and treat the Power Automate environment as the implementation source of truth.

Trade-offs:

- simpler repository;
- incomplete technical source of truth;
- agents cannot reliably audit actual flow implementation;
- parameter/payload drift is easier to miss;
- rollback and code review are weaker.

## Recommendation

Choose **Option A**.

It best matches the active incremental-development protocol and the repository-as-source-of-truth principle already adopted for the other PULSE layers.

## Constraint

No placeholder flow implementation should be invented. If Option A is approved, active flow definitions are added incrementally from real environment/exported source. Missing flows are tracked explicitly until synchronized.
