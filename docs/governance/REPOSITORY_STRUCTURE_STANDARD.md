# PULSE Repository Structure Standard

**Status:** Normative  
**Version:** 1.1  
**Scope:** `rubensv74/app_pulse`  
**Last reviewed:** 2026-08-10

---

## 1. Purpose

This standard defines where each type of PULSE artifact belongs so that humans and AI agents can locate the authoritative source without guessing.

The governing rule is simple:

> **One content type, one canonical home.**

A second copy may exist only as an explicitly marked archive, generated projection or compatibility redirect.

---

## 2. Canonical top-level areas

```text
/
├── README.md
├── main/
├── sql/
├── office-scripts/
└── docs/
```

The repository root must remain minimal. Historical delivery reports, temporary exports and sprint-specific evidence do not belong at root.

---

## 3. `main/` — Canonical application source

Purpose: Power Apps and application-level source artifacts.

```text
main/
├── screens/
├── components/
├── contracts/
├── mappings/
├── tests/
└── CHANGELOG.md
```

Rules:

- full canonical screen source belongs in `main/screens/<Screen>/`;
- reusable Canvas component source that is currently required or actively planned belongs in `main/components/`;
- contracts and mappings belong under their dedicated folders;
- modular construction blocks, design notes and user guides do **not** belong in `main/`;
- source filenames ending in `_old`, `_backup`, `_copy`, `_final2`, etc. are prohibited in the active source area unless temporarily required by a documented live dependency/migration.

### Active component policy — Option A

`main/components/` is an **active source pool**, not a historical component library.

It contains only:

```text
1. components used by current canonical runtime screens;
2. components actively planned for approved current work;
3. components newly created/evolved for current PDS or product development.
```

Inactive historical components that no longer have a current runtime or approved planned use are moved out of the active pool after a dependency audit and may be retained under:

```text
docs/archive/components/
```

### New component creation rule

When a new reusable component is required by current work:

1. create its canonical Source Code file under `main/components/`;
2. update `docs/design-system/COMPONENT_CATALOG.md` in the same development cycle;
3. if it is a reusable PDS component, create/update its specification under `docs/design-system/components/`;
4. validate its Source Code in Power Apps Studio before treating it as installed/usable in the active app;
5. do not leave the only copy of a required component in chat, a modular screen block, a temporary folder or an archive.

The repository definition and the Studio installation state are separate facts: existence under `main/components/` does not prove the Canvas component has already been added to the active Power Apps application.

---

## 4. `sql/` — Executable SQL and database technical assets

Canonical model:

```text
sql/
├── export/
├── import/
├── schema/
│   └── warroom/
└── tools/
    └── warroom-schema/
```

Rules:

- executable SQL belongs here;
- schema snapshots belong under `sql/schema/<schema>/`;
- extraction/generation SQL tooling belongs under `sql/tools/`;
- explanatory documentation belongs in `docs/reference/sql/`, not mixed with executable SQL unless the README is local and operationally necessary;
- do not maintain both `database/` and `sql/` as competing database roots.

---

## 5. `office-scripts/`

Purpose: canonical Office Scripts source used by flows or export/import automation.

This area stays separate because TypeScript Office Scripts have a distinct runtime and lifecycle from Canvas Power Apps and SQL.

---

## 6. `docs/` — Product and engineering knowledge

Canonical model:

```text
docs/
├── README.md
├── governance/
├── architecture/
├── design-system/
├── specifications/
├── development/
├── reference/
├── analysis/
├── guides/
└── archive/
```

### `docs/governance/`
Repository standards, lifecycle rules, contribution conventions and documentation authority.

### `docs/architecture/`
Current application/system architecture. Historical architecture assessments belong in analysis or archive.

### `docs/design-system/`
The only normative location for PULSE UI/UX standards, SaaS archetypes, component specifications, component lifecycle catalog and visual QA guardrails.

### `docs/specifications/`
Functional/design specifications that define what a product area or screen must do.

### `docs/development/`
Implementation method, protocols, templates and active construction workspaces.

Target pattern for screen construction:

```text
docs/development/screens/<screen-key>/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
└── user-guide/
```

### `docs/reference/`
Stable technical reference documentation, including SQL object documentation.

### `docs/analysis/`
Audits, assessments and decision briefs that describe an observed state at a point in time.

### `docs/guides/`
Only reusable step-by-step operational/developer guides. A roadmap, architecture spec, design standard or sprint report is not a guide merely because it is Markdown.

### `docs/archive/`
Historical/superseded material retained for traceability but not to be used as a current source of truth.

Archived component source may be retained under `docs/archive/components/`, but it is never a normal reuse candidate.

---

## 7. Document lifecycle metadata

Every normative or potentially overlapping document should declare at least:

```text
Status: normative | active | draft | superseded | archived
Canonical: yes | no
Last reviewed: YYYY-MM-DD
```

When applicable:

```text
Supersedes: <path>
Superseded by: <path>
```

An AI agent must prefer `normative` and `active` documents over `superseded` or `archived` documents regardless of file modification date.

---

## 8. Naming rules

Directories:

```text
lowercase
kebab-case preferred
no spaces
```

Documentation filenames:

```text
UPPER_SNAKE_CASE.md for major normative project documents
or
lower-kebab-case.md for domain/reference notes
```

Do not mix case conventions for equivalent folders (`SQL` vs `sql`).

Runtime screen/component identities are exempt when Power Apps compatibility requires preserving their names. A misleading legacy runtime name must not be renamed while a canonical screen still depends on it unless the rename is handled as an explicit runtime migration.

---

## 9. Component lifecycle

Every reusable component should be catalogued as one of:

```text
ACTIVE
PDS_CANDIDATE
LEGACY_SUPPORTED
DEPRECATED
REVIEW_REQUIRED
ARCHIVED
```

Rules:

- only `ACTIVE`, `PDS_CANDIDATE` and intentionally supported legacy components remain in the normal active reuse pool;
- `LEGACY_SUPPORTED` may remain in `main/components/` while it is a current runtime dependency;
- inactive historical components leave `main/components/` after dependency audit under Option A;
- a newly required component is created in `main/components/` and catalogued in the same development cycle;
- physical moves/renames/removals occur only after a usage audit.

---

## 10. Construction artifacts

Every modular block must declare whether it is:

```text
PASTEABLE
INSTRUCTIONAL
OPTIONAL_SEED
ARCHIVED
```

A `.pa.yaml` extension must not imply pasteability if the file contains conceptual pseudo-operations.

Pasteable Power Apps Source Code must begin with a schema-valid root such as:

```text
Screens:
ComponentDefinitions:
```

Conceptual operations such as `PATCH`, `ADD CHILD` or `REPLACE CONTROL` belong in instructions/metadata and must not be represented as invalid PaYaml nodes.

---

## 11. Root cleanliness

Allowed at repository root:

- `README.md`;
- `.gitignore`;
- essential repository-level config files;
- canonical top-level directories.

Historical delivery reports/manifests must live under:

```text
docs/archive/deliveries/<date-or-epic>/
```

---

## 12. AI retrieval rule

When an agent needs context, use this authority order:

```text
1. canonical runtime source (`main/`, `sql/`, `office-scripts/`)
2. normative docs (`docs/governance`, `docs/design-system`, `docs/architecture`)
3. active specifications/development workspaces
4. reference
5. analysis
6. archive only when history is explicitly needed
```

For reusable Power Apps components, `main/components/` is the active source set. Do not select component source from `docs/archive/components/` for new work unless an explicit decision reactivates it.

Do not infer current behavior from an archived delivery report when current source exists.

---

## 13. Change policy

Repository reorganization must be incremental:

1. establish target path;
2. copy/move artifact;
3. update internal links/references;
4. verify repository search for old path;
5. remove/redirect old path;
6. commit the batch with a migration message.

Do not mix structural cleanup with unrelated runtime behavior changes in the same commit.
