# ZIP physical inventory — 1.0.0.2

Candidate: `baseline/incoming/baseline_pulse_1_0_0_2.zip`; preserved copy: `baseline/exported/2026-07-31/baseline_pulse_1_0_0_2.zip`.

- Size: 5,033,101 bytes
- SHA-256: `7E7646877DB8DF38CFCB5C2BF7896C598C4E772A1E2F667ACFDD9134C3959D77`
- Audit workspace: `.temp/zip-audit/baseline_pulse_1_0_0_2-20260731-105208/solution-extracted`
- Tool: PowerShell 5.1.22621.6931 `Expand-Archive`; exit code 0; stderr empty.
- Physical files: 75 (3 root metadata, 3 Canvas App artifacts, 69 workflow JSON files).

| Path | Type/category | Bytes | SHA-256 | State |
|---|---|---:|---|---|
| `solution.xml` | METADATA | 10,544 | `698A8A331D440F35CE906C50BFA6CFE56D79846E53CBC4AC48366E94D2738D47` | EXPECTED; valid XML |
| `customizations.xml` | METADATA | 162,343 | `50563008A600ADB8BA87A01CF700E9389970B606CA08E3A68FC0EE479F91311C` | EXPECTED; valid XML |
| `[Content_Types].xml` | METADATA | 435 | `84A2388C60AA12E3929553236F5242924CCB743E4B00830BA7911EDB31C87F15` | EXPECTED; valid XML |
| `CanvasApps/new_pulse_9584c_DocumentUri.msapp` | CANVAS_APP | 5,024,293 | `F77B0BEEBF102A5D848EAB43212E97A3047A29B1AA04689FF93481C2A99230FC` | EXPECTED |
| `CanvasApps/new_pulse_9584c_AdditionalUris0_identity.json` | CANVAS_APP | 105,680 | `7728740A2664DCA9235AA21359534A7B52791087110608DC2A78AAD53C5765DD` | EXPECTED |
| `CanvasApps/new_pulse_9584c_BackgroundImageUri` | CANVAS_APP | 64,326 | `B811065CC3E91C90A018CED08A2AA1B42C7033AC098C50D2867C75EF937C494C` | EXPECTED |
| `Workflows/*.json` | WORKFLOW | 69 files | Individual hashes recorded during audit; key hashes in workflow report | EXPECTED/REVIEW |

All root component files are physically present. No extraction error or corruption was detected.
