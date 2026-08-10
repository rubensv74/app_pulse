# Office Scripts

**Status:** canonical  
**Purpose:** Office Scripts used by PULSE export/import automation

Current source includes:

```text
BuildPunchExport.ts
```

Rules:

- canonical Office Script source lives here;
- do not duplicate active script source under `docs/`;
- documentation of integration behavior belongs under `docs/architecture/` or `docs/reference/`;
- contract changes affecting Power Automate, Excel or SQL must follow the incremental implementation protocol and be validated in the target runtime.
