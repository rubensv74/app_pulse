# PULSE Repository Structure v2 — Migration Checklist

**Status:** active during migration  
**Date:** 2026-08-10

## Target

```text
/
├── power-apps/
│   ├── screens/
│   ├── components/
│   ├── contracts/
│   ├── mappings/
│   ├── tests/
│   └── CHANGELOG.md
├── sql/
├── office-scripts/
└── docs/
```

## Checklist

- [ ] rename repository source root `main/` → `power-apps/` without content changes;
- [ ] update root README;
- [ ] update repository structure standard;
- [ ] update component catalog paths;
- [ ] update Home_PDS and Punch Review development workspaces;
- [ ] update architectural/specification references;
- [ ] delete obsolete compatibility redirect `docs/guides/DESIGN_SYSTEM.md` after references are repaired;
- [ ] delete archived inactive component copies now that Git history preserves them;
- [ ] review remaining `docs/archive/` content and delete material that is superseded-only and not needed by active protocol/traceability;
- [ ] keep live `LEGACY_SUPPORTED` component source until the dependent screen is incrementally migrated and Studio-validated;
- [ ] search for stale `main/screens`, `main/components`, `main/contracts`, `main/mappings`, `main/tests` paths;
- [ ] verify repository root and canonical source paths;
- [ ] publish closeout document.

No runtime behavior change is authorized by this migration.
