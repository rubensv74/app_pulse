# HOME_PDS — BLOCK 01A — SIDEBAR INSTANCE HYDRATION

**Status:** CORRECTIVE PATH — PENDING POWER APPS STUDIO VALIDATION  
**Target:** `scr_Home_PDS`  
**Component:** `cmp_SidebarNav`

## Evidence from Studio — 2026-08-11

After applying Block 01 to the restarted empty `scr_Home_PDS`, the visual shell rendered successfully:

- PULSE sidebar visible at the left;
- Home visually active;
- empty PDS content surface fills the remaining screen;
- no visible structural failure.

However, the sidebar footer displayed the literal default values:

```text
CURRENT PROJECT
Text
Text
```

This is not the intended Block 01 result. The Block 01 source assigns:

```text
ProjectCode = Coalesce(varSelectedProject.ProjectCode, "")
ProjectName = Coalesce(varSelectedProject.ProjectName, "")
```

while `cmp_SidebarNav` defines default `ProjectCode` / `ProjectName` values as `"Text"`.

Observed implication:

> The Source Code-created `cmpHPDS_Sidebar` body is hydrated enough to render, but its host-side custom Input assignments are not taking effect as expected in this restarted screen.

This is consistent with the previously observed host-side public-contract problem for `cmp_PageHeaderPro` and should be corrected operationally rather than by generating more equivalent screen YAML.

## Corrective strategy

Keep the validated shell geometry. Replace only the sidebar instance through Studio.

```text
keep conHPDS_ScreenRoot
keep conHPDS_ContentShell
→ delete only source-created cmpHPDS_Sidebar
→ Insert > Custom > cmp_SidebarNav in Studio
→ move the manual instance as the first child of conHPDS_ScreenRoot
→ rename it cmpHPDS_Sidebar
→ configure the required public inputs in Studio
→ save and validate once
```

Do not recreate the component definition.

## Required instance geometry

Set on the manually inserted `cmpHPDS_Sidebar`:

```text
Width  = 154
Height = Parent.Height
```

Because `conHPDS_ScreenRoot` is Horizontal AutoLayout, keep the sidebar as the first child and the content shell as the second child.

## Required public Inputs

Configure in Studio:

```text
ActiveKey        = "Home"
AppVersion       = "PULSE"
EnvironmentLabel = "ENV.PRE.TR.162"
IsCollapsed      = true
Items            = colSidebarNavItems
NavItems         = colSidebarNavItems
ProjectCode      = Coalesce(varSelectedProject.ProjectCode, "")
ProjectName      = Coalesce(varSelectedProject.ProjectName, "")
UserRole         = Coalesce(varUserRole, "reader")
```

Do not modify internal controls of the component.

## Acceptance

```text
PASS
- sidebar renders normally
- Home remains active
- footer no longer shows literal default "Text" / "Text"
- selected project code/name render when a project exists
- blank project state behaves according to component logic when none exists
- content shell remains empty and fills the remaining area
- save/reopen remains stable
- no new App Checker error attributable to Block 01A
```

If the manually inserted sidebar does not expose the expected public Inputs, stop and report that contract-visibility failure. Do not generate another screen Source Code variant.

## Consequence

If Block 01A passes:

```text
BLOCK 01 = VALIDATED AFTER MANUAL SIDEBAR HYDRATION
→ proceed directly to Block 03C Page Header integration
```

Block 02 does not need to be repeated because `cmp_PageHeaderPro` already has retained `DEFINITION_ACCEPTED = PASS` and `INSTANCE_SAFE = PASS` evidence.
