# PULSE Repository Structure Standard

**Status:** normative  
**Canonical:** yes  
**Version:** 2.1  
**Scope:** `rubensv74/app_pulse`  
**Last reviewed:** 2026-08-10

---

## 1. Purpose

This standard defines one canonical location for every PULSE artifact so humans and AI agents can find the current source without guessing.

> **One content type, one canonical home.**

Historical recovery belongs to Git history. The working tree should not retain duplicate legacy copies merely for caution.

---

## 2. Canonical top-level structure

```text
/
├── README.md
├── power-apps/
├── power-automate/
├── sql/
├── office-scripts/
└── docs/
```

The Git branch may be named `main`; there is deliberately no repository source folder named `main`.

---

## 3. `power-apps/` — canonical Canvas application source

```text
power-apps/
├── screens/
├── components/
├── contracts/
├── mappings/
├── tests/
└── CHANGELOG.md
```

Rules:

- canonical full screen source belongs in `power-apps/screens/<Screen>/`;
- reusable Canvas component source required by current runtime or approved active work belongs in `power-apps/components/`;
- Power Apps-specific contracts and mappings belong under their dedicated folders;
- tests belong in `power-apps/tests/`;
- modular construction blocks, design notes and user guides do **not** belong in `power-apps/`;
- new source must not use `_old`, `_backup`, `_copy`, `_final2`, etc.; a pre-existing live identity may keep such a name only as a documented `LEGACY_SUPPORTED` exception until migrated.

### Active component policy

`power-apps/components/` is an active source pool, not a historical library.

It contains:

```text
1. components used by current canonical runtime screens;
2. components actively required by approved current work;
3. components newly created/evolved for current PDS/product development.
```

When a new reusable component is required:

1. create its canonical source under `power-apps/components/` in the same development cycle;
2. update `docs/design-system/COMPONENT_CATALOG.md`;
3. if reusable/PDS, create or update its specification under `docs/design-system/components/`;
4. validate it in Power Apps Studio before treating it as installed/usable;
5. after block validation, ensure the canonical complete source reflects the accepted implementation.

A component source file existing in Git is not sufficient evidence that the component can be safely imported or instantiated in Studio. Reusable component acceptance requires the component validation gate defined by the incremental protocol and its compatibility/QA rules.

---

## 4. `power-automate/` — canonical flow source and contracts

```text
power-automate/
├── README.md
├── flows/
└── contracts/
```

Rules:

- real exported/deployable definitions of currently active flows belong in `power-automate/flows/`;
- stable flow interface contracts belong in `power-automate/contracts/` when useful independently from the definition;
- never reconstruct or invent a flow definition from a Power Apps `.Run(...)` call;
- when a flow definition has not yet been captured, the real Power Automate environment remains the execution authority;
- missing definitions are coverage gaps and must be closed progressively from the real environment;
- superseded-only definitions leave the working tree after migration; Git history provides recovery;
- flow changes require validation in the real Power Automate environment, not only static JSON inspection.

Progressive capture follows:

```text
identify active caller
→ verify real flow
→ export/read real definition
→ save under power-automate/flows/
→ document/update contract if useful
→ validate caller/flow compatibility
```

---

## 5. `sql/` — executable database source

```text
sql/
├── export/
├── import/
├── schema/
│   └── warroom/
└── tools/
    └── warroom-schema/
```

Executable SQL belongs here. Stable explanatory reference belongs under `docs/reference/sql/`.

---

## 6. `office-scripts/`

Canonical Office Scripts source used by flows/export/import automation.

---

## 7. `docs/` — current engineering knowledge

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
└── guides/
```

### `docs/governance/`
Normative repository, lifecycle and naming rules.

### `docs/architecture/`
Current system/integration architecture.

### `docs/design-system/`
The only normative PULSE UI/UX location: PDS, archetypes, visual QA, component catalog and component specs.

### `docs/specifications/`
Current functional/design specifications.

### `docs/development/`
Implementation protocols, templates and active incremental workspaces.

Screen workspace pattern:

```text
docs/development/screens/<screen-key>/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
└── user-guide/
```

### `docs/reference/`
Stable technical reference.

### `docs/analysis/`
Point-in-time audits and decision briefs. Analysis is evidence, not current implementation authority.

### `docs/guides/`
Only current reusable step-by-step guidance.

There is no permanent `docs/archive/` area. Superseded-only artifacts are removed from the working tree after safe migration; Git history provides recovery.

---

## 8. Legacy policy

An artifact is `LEGACY` when it is superseded and is not required by current runtime, current contracts, current specifications, current validation evidence or reusable learned knowledge.

Legacy artifacts are deleted from the working tree once safe to do so.

A `LEGACY_SUPPORTED` artifact may remain temporarily only because current runtime still depends on it. Its removal must be handled as an explicit incremental migration and validated in the target tool.

Reusable lessons are not deleted: they are consolidated into current compatibility, QA or knowledge documents before obsolete evidence is removed.

---

## 9. Naming rules

Directories:

```text
lowercase
kebab-case preferred
no spaces
```

Major normative documents may use `UPPER_SNAKE_CASE.md`; domain/reference notes may use `lower-kebab-case.md`.

Runtime screen/component identities are exempt when changing the name could break Power Apps. Such exceptions belong in `docs/governance/NAMING_EXCEPTIONS.md` and must have an exit condition.

---

## 10. Component lifecycle

Catalog states:

```text
ACTIVE
PDS_CANDIDATE
LEGACY_SUPPORTED
REVIEW_REQUIRED
```

`DEPRECATED`/`ARCHIVED` are not long-lived source states under this policy: once dependency audit confirms safe removal, the source leaves the working tree.

---

## 11. Construction artifacts

Every incremental artifact must declare whether it is:

```text
PASTEABLE
INSTRUCTIONAL
OPTIONAL_SEED
```

Pasteable Power Apps Source Code must use a schema-valid root such as:

```text
Screens:
ComponentDefinitions:
```

Conceptual operations such as `PATCH`, `ADD CHILD` or `REPLACE CONTROL` belong in instructions/metadata and must not be represented as invalid PaYaml nodes.

---

## 12. Root cleanliness

Allowed at repository root:

- `README.md`;
- `.gitignore`;
- essential repository-level configuration;
- `power-apps/`;
- `power-automate/`;
- `sql/`;
- `office-scripts/`;
- `docs/`.

No delivery manifests, temporary exports, sprint reports or superseded implementation files belong at root.

---

## 13. AI retrieval rule

Use this authority order:

```text
1. canonical runtime/source (`power-apps/`, `power-automate/`, `sql/`, `office-scripts/`)
2. normative docs (`docs/governance`, `docs/design-system`, `docs/architecture`)
3. active specifications/development workspaces
4. reference
5. analysis
```

Do not use point-in-time analysis to override current source. Do not infer missing Power Automate internals from caller code.

---

## 14. Incremental change policy

Repository or runtime migration follows the same incremental discipline as application work:

1. audit current dependency/source;
2. define target and scope;
3. perform one structural/functional responsibility per increment;
4. save/version the change;
5. repair references;
6. validate the target environment when runtime is affected;
7. remove legacy only after the dependency is proven gone;
8. consolidate reusable learning;
9. close the increment before continuing.

Do not mix repository restructuring with unrelated runtime behavior changes.
