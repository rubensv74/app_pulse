# PULSE — Execution Priorities

**Status:** ACTIVE  
**Operating model:** Incremental Architecture v2.0 / capability-sized delivery  
**Last updated:** 2026-08-14  
**Source baseline:** `PULSE_SOURCE_BASELINE_2026-08-14`

## Purpose

Maintain one explicit execution order for PULSE so development does not fragment across too many simultaneous fronts.

The governing rule is:

> Finish a verifiable functional capability before opening another business front, except when a genuine blocker creates usable idle capacity.

## WIP limit

At any moment:

- **1 primary functional front** may be ACTIVE.
- **1 secondary non-blocking support/audit front** may be active only when it does not interrupt the primary gate.
- New business fronts remain PARKED until a priority closes or a blocking dependency justifies temporarily using the second slot.
- Minor defects discovered inside a priority are consolidated into the same capability unless they are blocking, high-risk, or independently reversible.

## Priority queue

| Priority | Capability | State | Risk mode | Dependency |
|---|---|---|---|---|
| P0 | Punch Review Workspace completion | **ACTIVE** | B / functional integration | None |
| P1 | Home functional closure + PDS migration path | QUEUED | B, with C gates for contracts | P0 entry/return contract stable |
| P2 | Excel Export end-to-end closure | QUEUED | B/C | Punch List/export contract |
| P3 | Excel Import end-to-end implementation | BLOCKED / QUEUED | C backend + B UI | P2 export contract frozen |
| P4+ | Next manageable fronts | PARKED | To audit | Open only as P0-P3 close |

---

## P0 — Punch Review Workspace completion

### Immediate capability

**C17-E3 — Runtime Completion**

Apply the accelerated package as one functional capability:

- initial Punch hydration;
- `Open Punch List`;
- preservation of current Punch focus;
- dirty-state protection;
- Save / Discard / Cancel continuation;
- return to the same Review session;
- regression check for Next / Previous / Mark Reviewed / Undo Review.

### Execution rule

Do **not** validate E3A/E3B/E3C separately. Apply the two pending E3 changes and execute the single A-F gate.

### After C17-E3 PASS

Close the remaining C17 work as one consolidated **Visual + Hardening capability**, not as a chain of micro-FIXes:

- responsive geometry;
- width budget;
- clipping;
- empty/long queue states;
- long comments / multiple custom fields;
- 0% / partial / 100% progress;
- final regression.

### Exit criterion

Punch Review is considered priority-complete when:

- Home and Punch List can enter it reliably;
- session position survives expected navigation;
- dirty Custom Fields cannot be lost silently;
- comments and Custom Fields hydrate on the correct Punch;
- core review actions work;
- responsive/hardening gate passes;
- no new known formula errors remain.

Direct execution package:
`docs/development/screens/punch-review/blocks/C17-E3_runtime_completion.accelerated.instructions.md`

---

## P1 — Home functional closure + PDS migration path

### Context

The current `scr_Home` is a mature business screen with project switching, Punch dashboard, drill-through, Review entry and additional project/report behaviors.

`Home_PDS` is currently a staged PDS-safe shell. It must not silently replace the mature Home until functional parity is demonstrated.

### Capability sequence

1. **Freeze Home contracts**
   - project context;
   - Punch dashboard load;
   - Punch Review entry contract;
   - Punch List drill-through;
   - project switching/runtime ownership.

2. **Define Home_PDS parity matrix**
   - what the current Home owns;
   - what Home_PDS already implements;
   - what must be migrated or intentionally retired.

3. **Functional parity pass**
   - move complete capabilities, not visual fragments;
   - keep current Home as safe reference until parity gate passes.

4. **PDS Visual/UX pass**
   - only after business behavior is stable.

5. **Home hardening + cutover gate**
   - responsive;
   - error/loading states;
   - navigation;
   - project change;
   - PunchReview/Punches integration;
   - regression.

### Exit criterion

One canonical Home path exists, with no ambiguous ownership between `scr_Home` and `scr_Home_PDS`, and all critical business navigation/data contracts are preserved.

---

## P2 — Excel Export end-to-end closure

### Context

Export is **not a greenfield feature**. `scr_Punches` already calls `Warroom_ExportPunchesToExcel_Codex` and launches the returned file URL.

Therefore the priority is to close and harden the capability end to end rather than rebuild it.

### Capability sequence

1. Audit the current UI -> Flow -> SQL/batch -> generated workbook chain.
2. Freeze the export request contract:
   - project;
   - template;
   - active filters;
   - selected/allowed columns;
   - export mode;
   - requester identity.
3. Confirm workbook content and error handling.
4. Confirm batch traceability and technical metadata required for safe re-import.
5. Persist missing Flow/contract documentation in the repository.
6. Execute one export acceptance gate.

### Import-enabling metadata gate

Before P2 can close, the exported workbook/associated batch must provide or preserve the technical identifiers required by the import design, including as applicable:

- `ExportBatchId`;
- `ProjectId`;
- `TemplateId`;
- work item / Punch identifier;
- row-version or equivalent concurrency token;
- export timestamp;
- checksum or equivalent integrity evidence.

If the existing export does not provide the agreed import-safe contract, that is a **P2 blocker**, not a P3 workaround.

### Exit criterion

A user can export the intended Punch subset, receive a valid workbook, understand failures, and the workbook/batch contract is frozen as the source format for import.

---

## P3 — Excel Import end-to-end implementation

### Dependency

Do not begin implementation until the P2 export contract is frozen.

### Existing design position

The repository already contains an import design based on staged validation/commit, auditability and optimistic-concurrency protection. Runtime import is not yet present in the supplied `scr_Punches` source.

### Accelerated capability sequence

1. **Contract + staging**
   - workbook metadata;
   - allowed editable columns;
   - batch registration;
   - row staging.

2. **Validate + preview**
   - file/batch ownership;
   - schema;
   - row identity;
   - allowed changes;
   - data types;
   - concurrency;
   - row-level errors/warnings.

3. **Commit + audit**
   - apply only validated rows;
   - preserve audit trail;
   - partial/atomic policy explicitly defined;
   - idempotency/retry behavior.

4. **UI integration**
   - upload/select file;
   - validation summary;
   - row issues;
   - confirm commit;
   - result summary.

5. **Hardening gate**
   - stale workbook;
   - modified identifiers;
   - unauthorized columns;
   - malformed file;
   - duplicate/replayed batch;
   - backend failure.

### Exit criterion

Excel round-trip is controlled, auditable and concurrency-safe; import cannot silently overwrite changes made after export.

---

## P4+ — Fronts that remain parked

The supplied source baseline also covers:

- Overview;
- Tasks;
- Config;
- Briefing;
- Skyline;
- SuperAdmin.

These are **source-baselined, not current priorities**.

When one of P0-P3 closes, choose the next front using:

1. dependency reduction;
2. user/business value;
3. production risk;
4. amount of unfinished work;
5. whether it can fit within the WIP limit.

Do not pre-open all of them.

## Governing references

- Universal framework: `functional-engineering-knowledge-base/30-playbooks/ai-assisted-engineering/incremental-ai-assisted-implementation.md`
- PULSE implementation protocol: `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- Current source baseline manifest: `docs/development/app/PULSE_SOURCE_BASELINE_2026-08-14.md`
- C17-E3 package: `docs/development/screens/punch-review/blocks/C17-E3_runtime_completion.accelerated.instructions.md`
- Excel import design: `docs/development/CODEX_IMPORT_EXCEL_INSTRUCTIONS.md`

## Current next action

**P0 / C17-E3 — Runtime Completion.**

No other functional front should displace it until its A-F gate has been executed or a genuine blocker is identified.
