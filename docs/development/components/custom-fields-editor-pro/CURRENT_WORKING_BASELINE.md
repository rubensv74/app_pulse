# cmp_CustomFieldsEditorPro — Current Working Baseline

## Status

Current baseline validated visually and functionally by the user in Power Apps Studio through **DF-07B-FIX1** on 2026-08-14.

The component is insertable without Studio errors and its current three-column administration workflow is considered the authoritative implementation baseline for future fixes. Older DF replacement artifacts remain historical inputs only.

## Current validated state

- three-column architecture `Field catalog → Field configuration → Live preview`: **FROZEN**;
- Internal Key generated/locked model: **VALIDATED**;
- Save / Cancel footer: **VALIDATED**;
- compact Behavior / Filtering controls: **VALIDATED**;
- project context in modal header: **VALIDATED**;
- host-owned definition load/save contract: **FUNCTIONAL_FROZEN**;
- Active / Inactive persistence via host `DraftDefinition`: **VALIDATED**;
- false `definition not present in loaded catalog` regression: **CLOSED** by DF-06E-FIX4;
- readability floor: **VISUAL_APPROVED** by DF-07B-FIX1;
- no text below the approved dense-editor minimum readability floor;
- Live Preview balance and metadata readability: **PASS**;
- catalog row typography/readability: **PASS**;
- Filtering captions and actions: **PASS** in the validated Studio evidence.

## Source of truth

The authoritative source is the latest user-supplied full `ComponentDefinitions > cmp_CustomFieldsEditorPro` from Power Apps Studio, together with subsequent property-only fixes validated in Studio.

The component contract includes:

- project definition catalog;
- local definition draft state;
- Choice/MultiChoice option editing;
- dynamic Live Preview;
- Active / Inactive host event;
- host-owned backend persistence;
- stable `DraftDefinition` output used as authoritative mutation context.

## Active / Inactive lesson

The reliable host contract is:

```text
component draft → DraftDefinition → host mutation service
```

Do not reintroduce a dependency on transient `ActiveChangeFieldKey` / `ActiveChangeTarget` outputs for persistence when `DraftDefinition` already contains the visible and stable `FieldKey` / `IsActive` pair.

## Readability contract

Dense administration layout must not be achieved by microtypography.

Current visual contract:

- no routine text below 7 pt;
- 7 pt reserved for micro-status/meta only;
- normal captions, body and secondary metadata around 8 pt;
- panel titles around 10 pt;
- modal title around 15 pt;
- do not enlarge inputs/toggles solely to improve typography;
- if text growth creates clipping, fix spacing rather than shrinking text again.

## Frozen scope

Unless a later requirement explicitly reopens it, preserve:

- component custom-property contract;
- header geometry/actions;
- catalog geometry;
- center editor geometry;
- right preview geometry;
- host ownership of backend flows;
- Active / Inactive `DraftDefinition` host pattern;
- readability floor.

## Mandatory construction gates

Before generating any new `.pa.yaml` for this component or its host screens, re-read:

1. `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` in `rubensv74/app_pulse`;
2. `30-playbooks/power-platform/modular-power-apps-screen-construction.md` in `rubensv74/functional-engineering-knowledge-base`.

Power Apps Studio remains authoritative for implementation and validation.

## Next checkpoint

The editor no longer blocks Punch Review responsive validation.

Resume **C17-E2A — 1366×768 responsive / final visual QA** for `scr_PunchReview`. Any new defect found there must be handled as an isolated C17-E2A FIX without reopening this validated editor architecture.