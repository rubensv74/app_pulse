# PULSE Repository Structure Standard

**Status:** Normative  
**Version:** 1.0  
**Scope:** `rubensv74/app_pulse`

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
- reusable Canvas component source belongs in `main/components/`;
- contracts and mappings belong under their dedicated folders;
- modular construction blocks, design notes and user guides do **not** belong in `main/`;
- source filenames ending in `_old`, `_backup`, `_copy`, `_final2`, etc. are prohibited in the active source area unless temporarily required during a documented migration.

---

## 4. `sql/` — Executable SQL and database technical assets

Target model:

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
The only normative location for PULSE UI/UX standards, SaaS archetypes, component specifications and visual QA guardrails.

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

Runtime screen/component identities are exempt when Power Apps compatibility requires preserving their names.

---

## 9. Component lifecycle

Every reusable component should be catalogued as one of:

```text
ACTIVE
PDS_CANDIDATE
LEGACY_SUPPORTED
DEPRECATED
ARCHIVED
```

Rules:

- only `ACTIVE`, `PDS_CANDIDATE` and intentionally supported legacy components remain discoverable as normal reuse candidates;
- explicitly old/unused components must not remain unclassified in the active component pool;
- physical moves to legacy/archive occur only after a usage audit.

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
