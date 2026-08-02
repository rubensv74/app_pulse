# Punch Review Workspace — Decision Brief

Audit basis: repository commit `c6fcb68b5196f639a1c16bb426b5e6e0d6729d01`; evidence labels are defined in `CURRENT_STATE_ASSESSMENT.md`.

## 1. Scope evaluated

The candidate is a lateral meeting workspace over a frozen, filtered punch subset with list/previous/next navigation, explicit Save and Save-and-next, dirty-change warning, incremental saved-row refresh, temporary visited/modified/pending state, and reuse of current drawer behavior. It is not a new standalone screen and must not load the global population locally.

Explicitly excluded: persisted/restartable meeting sessions, corporate reviewed status, minutes/notes, treated-only export, bulk editing, simultaneous session collaboration, implementation, or generation of new YAML/flows/SQL.

## 2. What exists and what is missing

Reusable evidence exists for paged list/filter orchestration, selection normalization, a drawer shell, comments UI, typed custom-field UI, explicit custom save, loading/error conventions, theme variables and generic presentational components. `VERIFIED_IN_REPOSITORY`.

Missing or unproven: canonical active `_1` route, complete flow/SP source, versioned contracts, stable ordering, frozen-set identity, previous/next logic, dirty navigation guard, Save-and-next orchestration, Punch property update, History implementation, incremental list-row refresh contract, backend authorization, idempotency and concurrency. `MISSING` / `ENVIRONMENT_VALIDATION_PENDING`.

## 3. Reuse matrix

| Element | Classification | Evidence/dependencies | Risk and minimum change | Current drawer impact / regression |
|---|---|---|---|---|
| Current `_old` drawer shell | `REUSE_WITH_REFACTOR` | Consumed by Punches_1; owns tabs and business flow calls | Split shell/presentation from Punch domain orchestration; remove global-state coupling | High; retain single-punch adapter and test all tabs/close |
| Punch list navigation/selection | `REUSE_WITH_REFACTOR` | Paged gallery and normalized selection | Introduce stable set key/index and one selected-state owner | Medium; test filters, page changes and drawer opening |
| Detail load | `INSUFFICIENT_EVIDENCE` | List row supplies Overview; backend detail flow absent | Define authoritative detail response and refresh semantics | Medium; compare every displayed field |
| Comments read/write | `REUSE_WITH_REFACTOR` | UI and descriptors exist; paging argument defect; backend absent | Centralize adapter, fix only after signature confirmation, add idempotency/error contract | High; regression add/read/page/delete and permissions |
| Custom fields | `REUSE_WITH_REFACTOR` | Typed merged/base/dirty collections and bulk save | Extract editor/domain adapter; version schema and conflict behavior | High; test every type, required/choice validation and save |
| History | `NEW_CAPABILITY_REQUIRED` | Empty tab only | Define source, paging, event schema and presentation | Low until added; then all entity types |
| General Punch save | `NEW_CAPABILITY_REQUIRED` | No Punch property update operation found | Specify editable fields and atomic save contract | New behavior; ensure current read-only Overview unchanged |
| Save-and-next | `NEW_CAPABILITY_REQUIRED` | No orchestration | Save, reconcile one row, mark state, then advance only on success | Test failure preserves position/dirty state |
| Concurrency | `NEW_CAPABILITY_REQUIRED` | No runtime token | Add optimistic token from read through write/conflict response | Affects every editing route; conflict regressions mandatory |
| Permissions | `INSUFFICIENT_EVIDENCE` | Manager visibility only | Establish capability claims plus backend enforcement | Test reader/manager/denied and direct-call attempts |
| `gblPDS` tokens | `INSUFFICIENT_EVIDENCE` | Symbol absent | Confirm intended design-system source; otherwise map existing theme variables | Visual regression across drawer/workspace |
| `cmp_UI_*` | `NEW_CAPABILITY_REQUIRED` | Prefix absent | Use for domain-neutral shell/list/nav/dirty-dialog/status primitives | Component contract and responsiveness tests |
| `cmp_PULSE_*` | `NEW_CAPABILITY_REQUIRED` | Prefix absent | Use for Punch detail adapter, field mapping and domain actions | Domain contract and permission tests |
| Existing generic components | `REUSE_WITH_REFACTOR` | `cmp_EmptyState`, skeleton, cards, filters, layout exist | Normalize contracts and canonicalize copies | Visual/accessibility regressions |
| Existing Punch flows | `INSUFFICIENT_EVIDENCE` | Bindings/WADLs, sources absent | Recover sources, version contracts and prove auth/order/idempotency | Full connector regression |
| Existing Punch SPs | `INSUFFICIENT_EVIDENCE` | Runtime SQL absent | Export/source-control procedures and schemas | SQL contract/performance/security tests |
| Entry from Punches_1 | `REUSE_WITH_REFACTOR` | Filter state and paged collection exist | Open from explicit current query descriptor/snapshot, not only loaded page | Test across pages and mutable filters |
| Entry from Home_1 | `REUSE_WITH_REFACTOR` | Context variables exist, but routes target `scr_Punches` | Resolve canonical route; pass an explicit filter/query descriptor | Test each KPI/insight source and empty bundle |

The recommendation is to share domain adapters for comments/custom/save between the individual drawer and workspace, not duplicate their logic. Presentation-only `cmp_UI_*` components should remain flow-agnostic; `cmp_PULSE_*` should translate Punch contracts and expose events/state without owning global project context.

No evaluated element qualifies as `REUSE_AS_IS`: every candidate depends on an unverified backend contract, canonical-screen decision or state-isolation change. No evaluated element is classified `REPLACE` at this stage either; the evidence supports refactoring proven client behavior and adding missing capabilities, not discarding it before the authoritative baseline is recovered.

## 4. Review-subset alternatives

| Alternative | Advantages | Risks | Supported volume | Required changes | Recommendation |
|---|---|---|---|---|---|
| Current Punches_1 loaded collection | Immediate and simple | Only one page; cannot represent large filtered set; mutable refresh | At most current page (~50 evidenced) | Stable key/index plus page fetch | Use only as a seed/cache, not authority |
| Frozen local key list from filtered query | Stable during meeting; cheap per-row updates | Delegation/memory limits; expensive for thousands | Small bounded subsets only; threshold must be measured | Server endpoint returning ordered keys/token | Viable for explicitly bounded sets |
| Server-paged immutable snapshot/query token | Stable order/position, scalable, survives row leaving filter | New server state/expiry/cleanup; not session persistence across app restarts unless chosen | Hundreds of thousands globally, bounded pages client-side | Snapshot/query-token contracts and page/detail endpoints | Preferred architecture candidate; requires PO/architecture approval |
| Re-run paged filter on navigation | Reuses existing conceptual flow | Rows can move/disappear; page drift; order unproven | Potentially large but semantically unsafe | Stable ordering/cursor and frozen-as-of semantics | Do not use alone |
| Home dashboard bundle | Existing contextual subset and fast entry | Bundle is summarized/limited and not proven complete | Small dashboard slice only | Resolve bundle semantics then hand off filter/query descriptor | Entry context only, never canonical set |

No architecture is silently selected here. The server-paged snapshot/query-token option best satisfies scale and freeze semantics, while a bounded ordered key list may be simpler if Product confirms a strict maximum. This decision requires real volume and session-duration evidence.

## 5. Product Owner decision register

| Decision | Real options | Evidence/impact/risk | Recommendation | Confidence | Human confirmation |
|---|---|---|---|---|---|
| Baseline | Use current snapshot / obtain current unmanaged export | Current snapshot misses most flow/SP source and active route proof | Obtain new unmanaged export and rebuild baseline | High | Environment owner |
| Start functional/contracts work now | Start final contracts / only discovery draft / wait | Client behavior is visible; backend truth is not | Permit discovery outline only; defer approved contracts | High | PO + technical owner |
| Drawer reuse | Embed as-is / extract domain content / replace | `_old` is feature-rich but tightly coupled | Extract shared domain adapters/content behind compatibility layer | High | UX/technical owner |
| UI/domain component split | No split / `cmp_UI_*` + `cmp_PULSE_*` | Existing principles say components do not call flows | UI owns generic shell/navigation; PULSE owns mappings/events; screen/service adapter calls flows | Medium | Architecture owner |
| Subset state | Local page / bounded key list / server snapshot token | Scale and frozen semantics conflict with live re-filtering | Decide after maximum set size; favor server snapshot token | Medium | PO + data owner |
| Home entry | Bundle rows / filter descriptor / no direct entry | Bundle completeness unproven | Pass explicit project + filter/query descriptor to canonical Punch route | High | PO confirms expected context |
| Punches entry | Current collection / active query descriptor / selected rows | Current collection is only a page | Open from active query descriptor; optionally explicit selected subset | High | PO confirms selection behavior |
| Comments/custom contracts | Reuse implicit / version and wrap / replace | Existing UI useful, backend missing and comment paging inconsistent | Version and wrap after source recovery | High | Integration owner |
| Concurrency | Last-write-wins / optimistic token / lock | No existing strategy evidenced | Optimistic concurrency with conflict UX | High | PO + data owner |
| Pre-workspace debt | None / controlled remediation / baseline recovery first | Critical evidence gaps precede code defects | Baseline recovery first; then scoped remediation | High | Sponsor/environment owner |
| Exact next deliverable | FDS/contracts / remediation / new baseline / collect decisions | Repository cannot establish implementation truth | New unmanaged baseline audit package | High | Environment owner |

## 6. Safe entry points

From `Punches_1`, the technically safe conceptual entry is “open review from the current filter/query descriptor plus stable ordering and a server-issued snapshot/key identity,” not “copy `colPunches`,” because only one page is loaded. `INFERRED` pending backend capability.

From `Home_1`, the safe conceptual entry is “navigate to the canonical Punch route with explicit project and filter/query context, then create the review set through the same service.” Passing dashboard bundle rows as the complete review set is unsafe because completeness is not evidenced. `INFERRED`.

Neither entry is implementable safely until `scr_Home` versus `scr_Home_1` and `scr_Punches` versus `scr_Punches_1` are resolved in an authoritative Studio export. `ENVIRONMENT_VALIDATION_PENDING`.

## 7. Questions the repository cannot answer

1. Which screen generations are current in Studio and published?
2. What are the exact flow trigger orders, response schemas and failure codes?
3. Which SQL procedures/tables/views back Punch list, detail, comments and custom fields?
4. What are the actual SQL types and maximum values of all IDs?
5. Is authorization enforced in SQL/flows, and what capabilities are role-based?
6. What maximum review-set size and meeting duration must be supported?
7. Does “frozen” require point-in-time field values or only frozen membership/order?
8. What must happen when another user edits the current punch?
9. Is History an audit log, status history, comments history or combined timeline?
10. Which fields beyond custom fields/comments are editable in the workspace?

## 8. Recommended sequencing after this audit

After recovering an authoritative unmanaged baseline, rerun the static trace, confirm environment signatures, then prepare the Functional Design and versioned contracts. Any remediation should be separately approved and regression-protected; this audit does not approve it.

## 9. Executive verdict

| Dimension | Verdict | Confidence | Reason |
|---|---|---|---|
| Baseline reliability | Low | High | Current Studio correspondence and canonical copies are unproven. |
| Repository integrity | Partial | High | Rich Canvas source; dependent flow/SQL implementation incomplete. |
| Current drawer reusable | Partial | High | Useful comments/custom/detail UI, but tightly coupled and internally inconsistent. |
| Data contracts usable | Partial | High | Shapes can be inferred, but are not authoritative or versioned. |
| Ready to design workspace | Blocked | High | Baseline, backend contracts, security, ordering and concurrency must first be established. |

**Single recommended next step: Obtain a new unmanaged solution and reconstruct the baseline.**
