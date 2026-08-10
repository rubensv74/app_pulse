# PULSE Power Automate

**Status:** active source area  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

This directory is the canonical repository home for Power Automate assets used by PULSE.

## Structure

```text
power-automate/
├── README.md
├── flows/
└── contracts/
```

## `flows/`

Contains exported/deployable definitions of **currently active** PULSE flows when those definitions have been extracted from the real environment and verified.

Rules:

- never invent a flow definition from a Power Apps `.Run(...)` call;
- use the real exported definition as source;
- one flow, one clearly named folder or file set;
- record the source environment/export date when a definition is imported;
- when a flow changes, update the canonical definition in the same development cycle;
- remove superseded-only definitions from the working tree after migration; Git preserves history.

## `contracts/`

Contains stable interface contracts for active flows when a contract must be documented independently from the exported definition.

A contract may include:

```text
flow name
purpose
Power Apps caller(s)
input names and order
input types
optional/default semantics
response payload
error semantics
permissions/connections
related SQL procedures
```

A contract is not a substitute for the real flow definition when that definition is available.

## Progressive capture rule

PULSE currently contains Power Apps screens that call real Power Automate flows, while not all flow definitions are yet versioned in GitHub.

Therefore the migration strategy is incremental:

```text
identify active runtime call
→ verify the real flow in Power Automate
→ export/read the real definition
→ save canonical definition under power-automate/flows/
→ document/update contract when useful
→ validate caller/flow compatibility
→ mark coverage complete
```

Until a flow definition has been captured, the Power Automate environment remains the execution authority for that flow. The repository must not fabricate missing internals.

## Incremental protocol

All Power Automate changes follow:

`docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`

A flow change is not complete merely because a JSON definition was edited: the real Power Automate environment must validate/import/run the change as applicable.
