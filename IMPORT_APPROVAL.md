# Import approval — `PULSE_I01_1_unmanaged.zip`

## Conclusion

**FAIL**

## Decision rationale

Import is not authorized. The physical package contains a complete Canvas App
and two pre-existing workflows in addition to the intended Codex workflow. The
package does not contain evidence of the versions currently deployed in the
target environment, so it is impossible to prove that importing it will not
overwrite newer environment changes. The embedded Canvas App also reports 58
binding errors in its own `Properties.json`.

## Audited artifact

- Physical path:
  `power-platform/build/PULSE/dist/PULSE_I01_1_unmanaged.zip`
- SHA-256:
  `CCF75ED2088E248AE5D778ACACD50AE8D75F9069AF78291284A910D17C5B7233`
- Compressed size: 3,000,940 bytes
- ZIP entries: 9
- Total uncompressed size: 3,431,290 bytes
- ZIP path traversal check: PASS
- Extraction and XML/JSON parsing: PASS

The ZIP was opened and extracted to
`.import-audit/PULSE_I01_1_unmanaged`. This assessment is based on the
extracted binary artifact, not on the unpacked solution source.

## Physical contents

| Entry | Bytes | SHA-256 |
|---|---:|---|
| `[Content_Types].xml` | 419 | `6A61D015FB5C7A39CA1A8B19DB8B38B261A25EF2FBB6DC31DA2C796AFA496ACA` |
| `solution.xml` | 5,470 | `0A10B9749C7F48E00D5D67A0C1228FA243A7677522213B00BC6293C3EA4DB8A6` |
| `customizations.xml` | 64,232 | `120F733B33DA49AB1D336224ABA64AF7CE8308A266F0638C4BD0A5DC45535CE5` |
| `CanvasApps/new_pulse_9584c_AdditionalUris0_identity.json` | 44,583 | `EAF12F1129B1FD3941A8D82DD7EB8AE7655A63921AC12D89BCFCA5BF60EC2AE3` |
| `CanvasApps/new_pulse_9584c_BackgroundImageUri` | 64,326 | `B811065CC3E91C90A018CED08A2AA1B42C7033AC098C50D2867C75EF937C494C` |
| `CanvasApps/new_pulse_9584c_DocumentUri.msapp` | 3,102,914 | `648A8D87C246BFB6BA8B482D6C0F7AEF94D173DBC22C538627A2F6C4333E730F` |
| `Workflows/Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json` | 118,724 | `2DE7C9FFFCE881171D26FF36E808DA5BA6DCC0B8872E68DD53481CD40C24422C` |
| `Workflows/Warroom_ExportPunchesToExcel-776AED9C-298B-F111-AB10-000D3A25AA91.json` | 27,022 | `424FC300D0CC20C3D5D84EF21959999952F6671FA60D7BDD061141C55A7C5841` |
| `Workflows/warroom_GetPunchDashboardBundle-4AA15D31-858A-F111-AB10-000D3A21CE45.json` | 3,600 | `06C57E380849EFF7CEDA9B86619A613F6AA78EAD6267F540DF44B50268EB3C37` |

## Solution manifest

- Unique name: `pulse`
- Version: `1.0.0.0`
- Type: unmanaged
- Publisher: `pulse`
- Customization prefix: `pls`

`solution.xml` declares four root components:

| Type | Component | ID/schema name | Import effect |
|---:|---|---|---|
| 29 | Modern Flow | `1d37f98f-2d8b-f111-ab10-000d3a21ce45` | Create or update `Warroom_ExportPunchesToExcel_Codex` |
| 29 | Modern Flow | `4aa15d31-858a-f111-ab10-000d3a21ce45` | Update or create `warroom_GetPunchDashboardBundle` |
| 29 | Modern Flow | `776aed9c-298b-f111-ab10-000d3a25aa91` | Update or create `Warroom_ExportPunchesToExcel` |
| 300 | Canvas App | `new_pulse_9584c` | Update or create the complete `PULSE` Canvas App |

Therefore the import is not scoped to the new Codex workflow.

## Connection references

`customizations.xml` contains five solution connection references that the
import can create, update, or require rebinding:

| Logical name | Connector |
|---|---|
| `pls_sharedexcelonlinebusiness_1f1af` | Excel Online (Business) |
| `pls_sharedsharepointonline_facb1` | SharePoint |
| `pls_sharedsqldw_39bdc` | Azure SQL Data Warehouse |
| `pls_sharedsqldw_771b7` | Azure SQL Data Warehouse |
| `pls_sharedsqldw_b88bf` | Azure SQL Data Warehouse |

The Canvas App additionally embeds 58 local connector references: 54 Logic
Flows, two Azure SQL Data Warehouse, one Office 365 Outlook, and one Office 365
Users reference. Those embedded dependencies increase the impact of replacing
the app.

## Canvas App assessment

The package contains the complete app `PULSE`:

- Schema name: `new_pulse_9584c`
- App ID inside the `.msapp`: `4c9ca730-fe37-4da4-9711-a9379b79a7bc`
- Packaged AppVersion: `2026-06-19T10:35:15Z`
- Siena/client version: `3.26062.6.0`
- Originating document version: `1.348`
- Status: `Ready`
- Parser errors recorded in `.msapp`: 0
- Binding errors recorded in `.msapp`: 58
- Third-party PCF controls: false

The `.msapp` was itself extracted and inspected. It contains eight screens,
four component source files, control definitions, assets, data-source
references, publish metadata, and 738 App Checker results.

No target-environment export, environment API result, or deployment inventory
was available to establish the currently published Canvas App version,
modification timestamp, or content hash. Consequently:

1. The packaged `2026-06-19T10:35:15Z` version cannot be proven equal to or
   newer than the environment version.
2. It cannot be proven that the environment has no unpublished or newer app
   changes.
3. The 58 recorded binding errors cannot be shown to be harmless in the target
   environment.

Importing the Canvas App is therefore not demonstrably safe.

## Other component categories

| Category | Result |
|---|---|
| Entities/tables | None |
| Security roles | None |
| Field security profiles | None |
| Templates | None |
| Entity maps | None |
| Entity relationships | None |
| Global option sets | None |
| Custom controls | None |
| Entity data providers | None |
| Environment variable definitions/values | None |
| Canvas Apps | One complete app |
| Workflows | Three |
| Connection references | Five |

## Components that would be updated or created

An unmanaged import would potentially write all of the following:

1. `Warroom_ExportPunchesToExcel_Codex`.
2. Existing flow `Warroom_ExportPunchesToExcel`.
3. Existing flow `warroom_GetPunchDashboardBundle`.
4. Complete Canvas App `PULSE` (`new_pulse_9584c`).
5. Five solution connection-reference components and their environment
   bindings.

Because current target-environment versions were not independently obtained,
the package cannot be approved for import.

