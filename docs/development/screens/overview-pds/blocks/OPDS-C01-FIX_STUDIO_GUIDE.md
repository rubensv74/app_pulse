# OPDS-C01-FIX — native header and Sidebar bindings

## Why this FIX exists

The first Studio validation proved three useful facts:

- the complete screen Source Code is accepted;
- the loading and ready visual surfaces render;
- the two manually inserted reusable components did not hydrate as required.

`cmp_SidebarNav` rendered with default `Text` values and only the default Home item.
`cmp_PageHeaderPro` remained blank and its host instance exposed only a minimal generic
contract. This reproduces the known host hydration boundary from Home PDS.

The FIX stops only the failed reuse path. It keeps `cmp_SidebarNav`, whose body and
public inputs are visible, and replaces the blank Page Header component with a native
premium header inside the already validated host.

## One consolidated Studio intervention

### 1. Replace the complete screen source

1. Select `scr_Overview_PDS`.
2. Open **Source code** for the complete screen.
3. Replace it with the current complete contents of:
   `power-apps/screens/OverviewPDS/scr_Overview_PDS.pa.yaml`.
4. Save and wait for Studio validation.

This clean replacement removes both failed component instances and installs the
screen-native premium header. The Sidebar host remains empty by design.

### 2. Insert and configure only the Sidebar

1. Use **Insert > Custom** and insert `cmp_SidebarNav`.
2. Move it into `conOPDS_SidebarHost`.
3. Rename it `cmpOPDS_Sidebar`.
4. Configure all of these properties in the same pass:

| Property | Formula |
|---|---|
| `Width` | `Parent.Width` |
| `Height` | `Parent.Height` |
| `Fill` | `varTheme_NavBg` |
| `ActiveKey` | `"overview"` |
| `AppVersion` | `"PULSE"` |
| `EnvironmentLabel` | `"VISUAL CANDIDATE"` |
| `IsCollapsed` | `true` |
| `Items` | `colSidebarNavItems` |
| `NavItems` | `colSidebarNavItems` |
| `ProjectCode` | `Coalesce(varSelectedProject.ProjectCode, "")` |
| `ProjectName` | `Coalesce(varSelectedProject.ProjectName, "")` |
| `UserRole` | `Coalesce(varUserRole, "reader")` |
| `OnSelectItem` | `Notify("Overview PDS is in visual test mode.", NotificationType.Information)` |

If Studio does not expose one of these properties, report its exact name and stop the
Sidebar integration. Do not accept the literal defaults `Text` / `Text`.

### 3. Validate the complete visual capability

Save, reopen the screen and check:

| Check | Expected result |
|---|---|
| Native premium header | Title, subtitle, project, visual state, evidence, Loading and Help render. |
| Header interaction | Loading changes only the local test state; Help shows an informational message. |
| Sidebar | Overview is active; no `Text` defaults remain; selecting an item does not navigate. |
| Six surfaces | Loading, No project, No config, No data, Error and Ready each render alone. |
| Visual quality | No overlap, clipping or accidental scrollbars at 1600×900. |
| App Checker | No new blocking error under `scr_Overview_PDS`. Existing errors elsewhere are not attributed to C01. |
| Save/reopen | Header, Sidebar bindings and all six states remain available. |
| Isolation | No Overview flow runs and `scr_Overview` remains unchanged. |

Return one Ready screenshot, one screenshot of any defect and the result of every row.
This is the second and final planned Studio round-trip for OPDS-C01.

