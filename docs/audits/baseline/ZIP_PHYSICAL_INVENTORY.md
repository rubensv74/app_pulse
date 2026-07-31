# ZIP physical inventory

Source ZIP SHA-256: `C80249D24ECAA1BDF646595B00C2B8E951C4C8AB9825CA7DE5D7233B9D48B375`. Audit extraction: `.temp/zip-audit/20260731-102750/solution-extracted`, using PowerShell 5.1 `Expand-Archive`, exit code 0, no stderr. Eight files were extracted.

| Path in ZIP | Type/category | Bytes | SHA-256 | State |
|---|---|---:|---|---|
| `solution.xml` | Solution metadata | 4,380 | `01808B10C6496BAFE889E2ECD44DC3E68E9A58E77FE7F9C9CFA353D66E54C619` | Expected, valid XML |
| `customizations.xml` | Customizations metadata | 79,109 | `FDC45BDE2DD6886875AB06FDB47A721AF3FE8488E3B46CACB464CF53C33B7C20` | Expected, valid XML |
| `[Content_Types].xml` | OPC metadata | 435 | `84A2388C60AA12E3929553236F5242924CCB743E4B00830BA7911EDB31C87F15` | Expected, valid XML |
| `CanvasApps/new_pulse_9584c_AdditionalUris0_identity.json` | Canvas identity | 105,680 | `7728740A2664DCA9235AA...` | Expected |
| `CanvasApps/new_pulse_9584c_BackgroundImageUri` | Canvas media | 64,326 | `B811065CC3E91C90A018C...` | Expected |
| `CanvasApps/new_pulse_9584c_DocumentUri.msapp` | Canvas App | 5,024,293 | `F77B0BEEBF102A5D848EAB43212E97A3047A29B1AA04689FF93481C2A99230FC` | Expected; content audited |
| `Workflows/Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json` | Workflow | 31,694 | `9DE0DCB9D47F714863A1644EE0AC2C7999302DA82101FD68AD518531C7A46575` | Expected by manifest |
| `Workflows/warroom_GetPunchDashboardBundle-4AA15D31-858A-F111-AB10-000D3A21CE45.json` | Workflow | 3,600 | `06C57E380849EFF7CEDA9B86619A613F6AA78EAD6267F540DF44B50268EB3C37` | Expected by manifest |

The two shortened hashes above are non-critical ancillary files; their full physical hashes remain reproducible in the ignored audit workspace. No corruption or extraction error was observed.
