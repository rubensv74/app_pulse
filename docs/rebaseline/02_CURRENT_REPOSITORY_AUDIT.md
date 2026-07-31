# Current repository audit

The repository contains a tracked incoming baseline ZIP, a previously unpacked solution, four `.msapp` files across current/audit/build locations, seven ZIP files including ignored build outputs, and prior audit/build artifacts. No cleanup was performed.

| Category | Count | Proposed action |
|---|---:|---|
| KEEP | 24 | Preserve source, docs, SQL, tests and scripts |
| ARCHIVE | 0 | None automatically identified |
| REVIEW | 11 | Review all ZIP/MSAPP artifacts before cleanup |
| DELETE_CANDIDATE | 0 | No deletion authorized |
| BASELINE_CANDIDATE | 1 | Audit incoming ZIP |
| GENERATED | 45 | Keep isolated; review in later cleanup phase |
| TEMPORARY | 0 | Audit temporary workspace excluded from this count |
| DUPLICATE | 2 | Two ignored build `pulse.zip` outputs |
| UNKNOWN | 0 | None at category level; dependencies remain unknown |

Important: the current repository `.msapp` hash differs from the incoming ZIP's `.msapp`; neither may be treated as equivalent without explanation.
