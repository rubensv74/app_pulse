# Power Apps Source

**Status:** canonical  
**Purpose:** active Canvas application source for PULSE

```text
power-apps/
├── screens/      canonical complete screen source
├── components/   active reusable Canvas component source
├── contracts/    JSON/data contracts consumed by application workflows
├── mappings/     application mappings/configuration artifacts
├── tests/        test artifacts that belong to the Power Apps source layer
└── CHANGELOG.md
```

## Rules

- Full validated screen source belongs under `screens/<Screen>/`.
- Active reusable component source belongs under `components/`.
- Incremental construction blocks belong under `docs/development/screens/<screen>/blocks/`, not here.
- When a block introduces a new reusable component, create/update its complete canonical source under `components/` in the same development cycle.
- `power-apps/components/` is not a historical library. Remove inactive legacy source after dependency audit.
- Live legacy dependencies remain only as `LEGACY_SUPPORTED` until an explicit migration is validated in Power Apps Studio.
- Repository source and Studio installation are separate facts; a `.pa.yaml` file here does not prove the component/screen is already installed in the active app.

Normative governance:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/ACTIVE_SOURCE_POLICY.md
docs/design-system/COMPONENT_CATALOG.md
```
