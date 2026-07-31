# Known technical debt — working baseline 1.0.0.2

This debt is accepted for sprint startup and is not a Golden Baseline approval.

| Debt | Classification | Known impact | Impact not demonstrated | Home_1 / Punches_1 relationship | Sprint treatment | Recommended resolution |
|---|---|---|---|---|---|---|
| Active bindings `Warroom_AddTaskComment`, `Warroom_GetTaskCommentsPaged`, generic delete flow | MONITOR | Names/FlowNameIds do not map physically to packaged names | No failed local unpack; runtime failure not tested | First two used by Home_1; comments flow used by Punches_1 | Do not rename globally; validate only when drawer/comments are tested | Rebind in DEV and export after sprint functionality stabilizes |
| Four connection references are not root components | MONITOR | Import requires environment bindings | No import was attempted; no proven import failure | SQL flows across both screens | Record required bindings; do not modify environment | Add solution-aware references or deployment contract before import gate |
| `Screen1` | OUT_OF_SCOPE | Empty/default screen in app | No runtime/navigation impact shown | None direct | Preserve | Remove in a later cleanup release after app-owner approval |
| `Component ------------` | OUT_OF_SCOPE | Empty component definition | No runtime use shown | None direct | Preserve | Remove during dedicated cleanup |
| `cmp_DetailDrawer_old` | MONITOR | Legacy name, but actively instantiated | No malfunction shown | Direct Punches_1 dependency; not direct Home_1 dependency | Preserve and test; edits only for Punches_1 needs | Rename/migrate in later compatibility work |
| Historical/duplicate flows and `_1`/`_2` references | OUT_OF_SCOPE | Registry/solution noise | No core screen failure shown | Some adjacent admin/queue features | No consolidation | Cleanup after usage telemetry and owner review |
| Both export flows included; app calls `_Codex` | MONITOR | Canonical ownership unclear | No export failure shown | Direct Punches_1 dependency | Keep `_Codex` binding unless sprint acceptance requires change | Decide canonical flow after parity testing |
| MSAPP differs from prior repository solution path | MONITOR | Multiple lineages exist | Working ZIP unpacked successfully | Both target screens sourced from accepted MSAPP | Treat working-baseline source as sprint reference | Reconcile lineage before final release |
| Legacy/new navigation crosses (`Home_1`→`Punches`, `Punches_1`→`Home`) | MONITOR | May route users to legacy screens | Intended behavior not yet validated | Direct to both | Add navigation tests; no broad rename | Resolve through explicit sprint stories |

No item is classified `BLOCKS_IMPORT` or `BLOCKS_RUNTIME` because this task produced no concrete import/runtime failure. Those classifications must be applied if validation later supplies direct evidence.
