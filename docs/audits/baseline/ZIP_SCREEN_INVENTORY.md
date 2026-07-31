# ZIP screen inventory

All paths are inside `CanvasApps/new_pulse_9584c_DocumentUri.msapp!/Src/`. Presence is physically verified in the audit copy.

| Screen | Bytes | SHA-256 | Observation |
|---|---:|---|---|
| `Screen1` | 703 | `6FE535CC3AEFC8B617CE98829BD298B5B5BE3518BFEB03FF3598829C1C14D6F0` | Unexpected generic screen; unexplained |
| `scr_Briefing` | 68,361 | `7CA55125D330327982F35986BFBB21890C375641E0C41BFA1601E6C931D25514` | Expected equivalent |
| `scr_Config_NEW` | 173,181 | `408BF1FEBFE18155CC16061A12B34078E69DE5FB344E5C9A1E73E038049B34A9` | Config variant |
| `scr_DeliveryPackagesAdmin` | 76,618 | `9B93425A9AEA70B69C1408015F91EA38C25EBAB18BA2F39E8AF0349B565E07A7` | Additional admin screen |
| `scr_Home` | 209,843 | `DB17AEEDF734C72956B4890BD864ACDFD5E50A003318FE8335AD2EB04B843D42` | Home variant 1 |
| `scr_Home_1` | 348,898 | `98B2B45255DD8F4D6E4C844243A2DFEB86CE4A580311418F42663CD0D6D0F203` | Home variant 2; duplicate intent unresolved |
| `scr_Overview` | 157,569 | `65EA4ABA8BEDC2CF5E5DA6230DFF59B158333F0DAF5EBA6D89C942F90FAED402` | Expected equivalent |
| `scr_Punches` | 233,132 | `9A2D9423036E95FCC28DECD0AEB68F660613C1D806728D1DDF0B047BB65853D8` | Punches variant 1 |
| `scr_Punches_1` | 244,135 | `C81242123AA072C2C3926037C7C6D8685B489A5A432F817B8FBB9767F166C529` | Punches variant 2; duplicate intent unresolved |
| `scr_Skyline` | 122,966 | `FE98D60854396313E315C4AC0F855BCF632CC74FB8517DA9ECBCB8C2700DDD67` | Additional screen |
| `scr_SuperAdmin` | 34,456 | `036674A7EBF78430F7450EE1F3923AA9AF51B01930F8A3CA07637BF2CE78C5D6` | Expected equivalent |
| `scr_Tasks` | 146,500 | `60DEF89ACDD4B6837E263A0724FBEC6855A6DE9C2641F9F8A3A975AC6A9C4B3A` | Expected equivalent |

Total: 12. No screen named exactly “Punch List”; `scr_Punches*` are possible equivalents. Completeness/currentness is `UNVERIFIABLE` pending an authoritative environment/export comparison.
