# Comparison: rejected 1.0.0.1 vs candidate 1.0.0.2

| Property | 1.0.0.1 | 1.0.0.2 | Result |
|---|---|---|---|
| ZIP bytes / SHA-256 | 4,924,908 / `C80249D2…B375` | 5,033,101 / `7E764687…9D77` | MODIFIED |
| Solution | `baseline_pulse` 1.0.0.1 Unmanaged | `baseline_pulse` 1.0.0.2 Unmanaged | IMPROVED |
| Root components | 3: app + 2 flows | 70: app + 69 flows | IMPROVED |
| Canvas App | 1, hash `F77B0BEE…30FC` | Same hash | UNCHANGED |
| Screens/components | 12 / 27 | 12 / 27 | UNCHANGED |
| Environment variables | 0 | 0 | UNCHANGED |
| Connection-ref roots | 0 | 0 | UNCHANGED |
| Physical files | 8 | 75 | IMPROVED: 67 workflows added; metadata modified; six former payload files unchanged |

| Previous finding | State in 1.0.0.2 | Evidence | Result |
|---|---|---|---|
| 73 flow references | 73 remain | Identical `.msapp` | UNCHANGED |
| Only 2 workflows included | 69 included | 69 roots and physical files | FIXED/IMPROVED |
| Missing `Warroom_ExportPunchesToExcel` | Included | GUID `776AED9C…AA91` | FIXED, but not app-bound |
| Only `_Codex` variant included | Both variants included | Two distinct root flows | IMPROVED; canonical replacement unresolved |
| Connection refs not roots | Still zero type-10078 roots | Four logical names remain | UNCHANGED / FAIL |
| `.msapp` differs from repo | Still differs | Candidate app is byte-identical to old ZIP | UNCHANGED |
| `Screen1` | Present, empty/default | Only editor-state reference | UNCHANGED / RESIDUAL |
| `Component ------------` | Present, empty | Only editor-state reference | UNCHANGED / RESIDUAL |
| `cmp_DetailDrawer_old` | Present and actively instantiated | Four screens reference it | NEW FINDING: active but unjustified |
| PAC CLI absent | Still unavailable | Prior tool discovery | UNCHANGED operational warning only |

The new ZIP meaningfully improves workflow membership but does not resolve all prior blockers and introduces clearer evidence of three active unmatched flow bindings.
