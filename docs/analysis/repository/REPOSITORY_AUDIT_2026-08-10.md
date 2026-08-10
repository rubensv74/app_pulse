# PULSE Repository Audit — 2026-08-10

**Repository:** `rubensv74/app_pulse`  
**Baseline commit:** `1b8c8dffd1185a5f775934b0fceeff3cbe642c55`  
**Scope:** repository structure, document lifecycle, discoverability, source/document separation, AI retrieval safety  
**Runtime changes:** none

---

## 1. Executive conclusion

The repository contains valuable source code and documentation, but its information architecture has grown incrementally and now exposes several competing organizational models at the same time.

The main problem is not the amount of content. The problem is **lack of one canonical place for each type of content**.

Current symptoms include:

- runtime source and construction artifacts mixed under `main/`;
- multiple documentation areas with overlapping purposes;
- old and new Design System documents coexisting without lifecycle markers;
- SQL knowledge split across `database/`, `sql/` and `docs/SQL/`;
- stale delivery manifests at repository root;
- active, experimental and explicitly old components mixed in one flat folder;
- inconsistent construction-workspace locations between Punch Review and Home_PDS;
- no root README or canonical repository map.

This creates a concrete risk for humans and AI agents: the correct file may exist, but a stale or secondary file can be selected first and treated as authoritative.

---

## 2. Current top-level structure

```text
/
├── DELIVERY_MANIFEST.json
├── DELIVERY_REPORT.md
├── database/
├── docs/
├── main/
├── office-scripts/
└── sql/
```

There is currently no root `README.md` explaining which area is canonical for Power Apps source, SQL, documentation, contracts, build artifacts or historical deliveries.

---

## 3. Findings

### R-001 — Missing repository entry point — HIGH

There is no root README.

Impact:

- new contributors cannot understand the repository quickly;
- AI agents have no canonical navigation map;
- old delivery files at root appear more authoritative than they are.

Action: create a root `README.md` with the canonical map, authority rules and current development focus.

---

### R-002 — Stale delivery artifacts at root — HIGH

`DELIVERY_MANIFEST.json` and `DELIVERY_REPORT.md` describe EPIC-01 Executive Home and reference paths such as `main/screens/Home/scr_Home_1.pa.yaml` and old documentation locations.

The current canonical Home source is `main/screens/Home/scr_Home.pa.yaml`.

There is also a second `main/DELIVERY_MANIFEST.json`, again referring to `scr_Home_1.pa.yaml`.

Impact:

- root gives a stale picture of current product state;
- duplicate manifests create ambiguity;
- AI retrieval can infer that `scr_Home_1` is current.

Target: archive these delivery artifacts under a dated legacy-delivery area and remove them from the root after references are checked.

---

### R-003 — Two conflicting Design System generations — CRITICAL

`docs/guides/DESIGN_SYSTEM.md` is an older design description. It includes, among other things, a purple brand accent and a radius model up to 16–18 px for dashboard panels.

The current canonical `docs/design-system/PULSE_DESIGN_SYSTEM.md` defines the PDS model used by Home_PDS: brand cyan `#00C8FF`, interaction blue `#1677FF`, `RadiusControl=8`, `RadiusPanel=12`, `RadiusModal=16`, and explicit migration rules.

Impact:

- an agent can apply the wrong palette, radii or typography;
- visual inconsistency becomes structurally reinforced.

Action: `docs/design-system/PULSE_DESIGN_SYSTEM.md` must be the only normative PDS source. The old guide must be archived or replaced with a short redirect/deprecation notice.

---

### R-004 — `docs/guides/` mixes unrelated lifecycle types — HIGH

The folder contains architecture, design system, sprint readmes, roadmap, E2E validation, remediation, import architecture and a large Home consolidation guide.

These are not all “guides”. They represent different content types:

```text
architecture
standard
development protocol
workstream evidence
migration/remediation
historical sprint record
product roadmap
operational guide
```

Impact: search results are noisy and lifecycle status is unclear.

Action: keep `docs/guides/` only for genuinely reusable operator/developer guides. Move other documents to architecture, development/workstreams, specifications or archive according to role.

---

### R-005 — Construction workspaces are inconsistent — HIGH

Home_PDS construction artifacts are correctly isolated under:

```text
docs/development/screens/home-pds/
```

Punch Review construction artifacts are under:

```text
main/punch-review/
```

The latter lives beside canonical Power Apps source even though it contains README files, compatibility notes, optional seeds, incremental construction blocks and a user guide.

Impact:

- `main/` no longer means only canonical implementation source;
- agents may treat construction blocks as runtime source;
- the same kind of work is stored in two different places.

Target: migrate `main/punch-review/` to `docs/development/screens/punch-review/`, leaving canonical runtime source only in `main/screens/PunchReview/`.

---

### R-006 — Potentially misleading PaYaml construction artifacts — HIGH

Punch Review contains historical files named like:

```text
*.incremental-patch.pa.yaml
*.replace-control.pa.yaml
*.add-child.pa.yaml
```

Recent Studio learning established that conceptual construction operations such as `Patch:` are not valid top-level PaYaml schema nodes.

Not every historical artifact is necessarily invalid, but filenames and lifecycle are not sufficient to tell an agent whether a file is directly pasteable, instructional, optional or historical.

Action:

- classify each block as `PASTEABLE`, `INSTRUCTIONAL`, `OPTIONAL_SEED` or `ARCHIVED`;
- do not leave conceptual patch artifacts in a location that looks canonical;
- apply the same block metadata contract used by Home_PDS.

---

### R-007 — SQL is split across three roots — HIGH

Warroom SQL knowledge currently appears in:

```text
database/warroom/tools/
sql/schema_warroom/
docs/SQL/
```

The first contains schema-extraction tools, the second contains exported schema artifacts, and the third contains stored-procedure documentation.

Impact:

- unclear source of truth;
- duplicate schema extraction scripts are easy to create;
- inconsistent naming (`SQL` vs `sql`);
- harder retrieval for AI agents.

Target model:

```text
sql/
├── export/
├── import/
├── schema/warroom/
└── tools/warroom-schema/

docs/reference/sql/warroom/
```

`database/` should disappear after its tools are migrated.

---

### R-008 — Component lifecycle is not explicit — HIGH

`main/components/` mixes modern premium components with older executive components and an explicitly named old component:

```text
cmp_KpiCardPro
cmp_DataTableProV2
cmp_HeatMapPro
cmp_PieChartPro
cmp_ActionToolbarPro
...
cmp_ExecutiveKpiCard
cmp_ExecutiveInsightCard
cmp_ExecutiveAlertBanner
cmp_DashboardSectionHeader
cmp_DetailDrawer_old
```

Impact:

- an agent cannot know which component should be reused;
- “old” source can be selected accidentally;
- migration work creates more near-duplicates.

Action: create a component catalog with lifecycle state:

```text
ACTIVE
PDS_CANDIDATE
LEGACY_SUPPORTED
DEPRECATED
ARCHIVED
```

Only after a usage audit should physical moves to `main/components/legacy/` occur.

---

### R-009 — Naming conventions are inconsistent — MEDIUM

Examples:

- `docs/SQL/` uses uppercase while executable code uses `sql/`;
- `sql/schema_warroom/` uses an underscore while other paths use nested folders;
- `EXTRACCIÓN DE DEFINICIONES DEL ESQUEMA WARROOM.md` uses spaces and accented uppercase text in a machine-oriented source area;
- `scr_Punches_1.pa.yaml` uses an instance/version suffix while Home and Punch Review do not.

These names are workable for humans but reduce predictability for tooling and agents.

Action: adopt lower-kebab-case for documentation and lower-case directory names; do not rename runtime screen/component identities without a separate Studio-safe migration.

---

### R-010 — Documentation has no universal status convention — HIGH

Some documents are clearly current, some historical, some proposals and some implementation evidence, but there is no repository-wide header convention such as:

```text
Status: normative | active | draft | superseded | archived
Canonical: yes | no
Supersedes: ...
Superseded by: ...
Last reviewed: ...
```

Impact: “latest modified” can be mistaken for “authoritative”.

Action: add a lightweight document lifecycle standard and apply it first to high-risk overlapping documents.

---

## 4. Canonical target structure

The recommended structure deliberately keeps `main/` to avoid a disruptive repository-wide source rename.

```text
/
├── README.md
│
├── main/                         # Canonical Power Apps/source contracts
│   ├── screens/
│   ├── components/
│   ├── contracts/
│   ├── mappings/
│   ├── tests/                    # keep initially; optional later top-level move
│   └── CHANGELOG.md
│
├── sql/                          # Executable SQL + database snapshots/tools
│   ├── export/
│   ├── import/
│   ├── schema/
│   │   └── warroom/
│   └── tools/
│       └── warroom-schema/
│
├── office-scripts/
│
└── docs/
    ├── README.md
    ├── governance/
    │   └── REPOSITORY_STRUCTURE_STANDARD.md
    ├── architecture/
    ├── design-system/
    │   ├── PULSE_DESIGN_SYSTEM.md
    │   ├── SAAS_INTERFACE_ARCHETYPES.md
    │   ├── POWER_APPS_VISUAL_QA_GUARDRAILS.md
    │   └── components/
    ├── specifications/
    ├── development/
    │   ├── protocols/
    │   ├── templates/
    │   ├── screens/
    │   │   ├── home-pds/
    │   │   └── punch-review/
    │   └── excel-import/
    ├── reference/
    │   └── sql/
    │       └── warroom/
    ├── analysis/
    │   ├── repository/
    │   └── punch-review-workspace/
    ├── guides/
    └── archive/
        ├── deliveries/
        ├── sprints/
        └── superseded-docs/
```

---

## 5. Authority rules

After migration, the repository should obey these rules:

1. `main/screens/` contains canonical full screen source only.
2. `main/components/` contains reusable source components; lifecycle is documented in the component catalog.
3. Construction blocks never live beside canonical screen source.
4. `docs/design-system/` is the only normative source for visual standards.
5. `docs/development/screens/<screen>/` contains modular construction evidence and block artifacts.
6. `sql/` contains executable SQL, schema snapshots and SQL tooling.
7. `docs/reference/sql/` contains explanatory SQL documentation, not executable source of truth.
8. Historical delivery/sprint artifacts live under `docs/archive/`, never at repository root.
9. Every overlapping document must declare whether it is canonical, superseded or archived.
10. The repository root stays minimal.

---

## 6. Migration plan

### Phase 0 — Navigation and governance — SAFE / NON-DESTRUCTIVE

- create root README;
- create docs index;
- publish repository structure standard;
- publish this audit.

### Phase 1 — Documentation authority cleanup — LOW RISK

- mark old `docs/guides/DESIGN_SYSTEM.md` as superseded;
- classify roadmap/sprint/remediation docs;
- move or archive historical docs;
- preserve redirects where useful.

### Phase 2 — Development workspace unification — MEDIUM RISK

- migrate `main/punch-review/` → `docs/development/screens/punch-review/`;
- keep `main/screens/PunchReview/scr_PunchReview.pa.yaml` as the only canonical runtime screen source;
- classify historical block artifacts.

### Phase 3 — SQL consolidation — MEDIUM RISK

- migrate `database/warroom/tools/` → `sql/tools/warroom-schema/`;
- migrate `sql/schema_warroom/` → `sql/schema/warroom/`;
- migrate `docs/SQL/` → `docs/reference/sql/warroom/`;
- update all links.

### Phase 4 — Component lifecycle cleanup — MEDIUM RISK

- audit actual references from canonical screens;
- publish component catalog;
- move only confirmed deprecated/unused components into a legacy/archive area.

### Phase 5 — Delivery/archive cleanup — LOW RISK

- archive root delivery report/manifests;
- remove stale root clutter;
- preserve historical evidence under dated archive folders.

### Phase 6 — Link and retrieval QA — REQUIRED

- verify all Markdown links;
- search for stale paths (`scr_Home_1`, old docs paths, `database/warroom/tools`, etc.);
- verify the root README and docs index point only to canonical paths;
- confirm Home_PDS and Punch Review development instructions still resolve.

---

## 7. Migration constraints

Do not reorganize runtime source merely for aesthetics.

The following require targeted validation before any physical rename/move:

- Power Apps screen/component source relied on by external tooling;
- test scripts with hardcoded paths;
- SQL scripts referenced by operational runbooks;
- current development block paths being used in an active Studio session.

For this reason, Phase 0 is executed first and all destructive/move operations are performed in controlled batches with link updates.

---

## 8. Audit decision

**Repository reorganization is required.**

The recommended approach is evolutionary rather than a single bulk move. The first goal is to establish canonical authority; the second is to move content safely.

Until migration is complete, the root `README.md` and `docs/README.md` are the navigation authority for humans and AI agents.
