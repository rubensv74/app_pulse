# SQL Source

**Status:** canonical  
**Purpose:** executable database source, schema snapshots and SQL tooling for PULSE

```text
sql/
├── export/            export-related executable SQL
├── import/            import-related executable SQL
├── schema/warroom/    current warroom schema snapshot
└── tools/warroom-schema/  extraction/generation tooling for repository context
```

Rules:

- executable SQL belongs under `sql/`;
- explanatory/reference documentation belongs under `docs/reference/sql/`;
- do not create a competing `database/` root;
- current schema snapshots use `sql/schema/<schema>/`;
- any SQL change that affects runtime contracts follows the incremental implementation protocol and must be validated against the target database before being considered complete.

Normative method:

```text
docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md
```
