# Current repository inventory

Inventory method: recursive filesystem scan including ignored files; Git state from `git ls-files`, `git status`, and `git check-ignore`. Total workspace at discovery: 733 files / 142,345,426 bytes. Power Platform-relevant groups:

| Path/group | Count | Git state | Classification | Notes |
|---|---:|---|---|---|
| `baseline/incoming/*.zip` | 1 | tracked | BASELINE_CANDIDATE | New immutable candidate |
| `power-platform/solutions/PULSE/**` | 367 | tracked | KEEP/REVIEW | Existing unpacked solution; do not modify |
| `.import-audit/**` | 46 | tracked | REVIEW | Historical audit copy |
| `power-platform/build/**` | 20 ignored files | ignored | GENERATED | Includes two build ZIPs |
| `flows/**` | multiple | tracked | REVIEW | Standalone flow sources/packages |
| `main/screens/**`, `main/components/**` | multiple | tracked | KEEP/REVIEW | Hand-maintained sources, not proof of exported baseline |
| `docs/**`, `sql/**`, `tests/**`, `office-scripts/**` | 24 classified files | tracked | KEEP | Engineering evidence/source |

Extensions observed outside `.git`/audit temp: 213 JSON, 116 XML, 96 YAML, 20 Markdown, 7 SQL, 7 ZIP, 4 MSAPP, 4 PNG, 2 SARIF, 2 logs, 2 TXT, 1 TypeScript and build metadata.

No root `.gitignore` or `.gitattributes` existed initially. `.git/info/exclude` contained only comments. A new `.gitignore` containing only `.temp/` was added to satisfy the required audit-workspace isolation.
