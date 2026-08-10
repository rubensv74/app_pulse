# HOME_PDS — BLOCK 03C — MANUAL INSTANCE HYDRATION IN STUDIO

**Status:** CORRECTIVE PATH — PENDING POWER APPS STUDIO VALIDATION  
**Target:** `scr_Home_PDS`  
**Component:** `cmp_PageHeaderPro`

## Evidence from Studio

After creating `cmpHPDS_PageHeader` from screen Source Code with:

```yaml
Control: CanvasComponent
ComponentName: cmp_PageHeaderPro
Properties:
  Height: =Parent.Height
  Width: =Parent.Width
```

Studio accepted the screen, but the selected instance did not expose the expected public Input properties. The property selector showed only generic component properties plus `OnUtility`; properties such as `Context1Value`, `Title`, `Subtitle`, `ShowHelp`, etc. were absent. The component also rendered as a blank surface rather than the expected Page Header body.

This is stronger evidence than the earlier PA2108 alone: the Source Code-created host object has not hydrated the same usable public contract/body that was demonstrated when the component was inserted manually in Studio.

## Corrective strategy

Do not re-register every property and do not generate another screen-YAML variant.

Use the already proven path:

```text
source-created generic instance
→ delete only cmpHPDS_PageHeader
→ keep conHPDS_PageHeaderHost
→ Insert > Custom > cmp_PageHeaderPro in Studio
→ move the manually created instance into conHPDS_PageHeaderHost
→ rename to cmpHPDS_PageHeader
→ set Width/Height to Parent
→ configure Block 03 inputs in one pass
```

Reason: the component itself already demonstrated `INSTANCE_SAFE = PASS` when inserted manually. The new evidence shows the source-created instance is not equivalent to that manual insertion path in this app state.

## Block 03 formulas after manual insertion

Configure these properties on the manually inserted instance:

```text
Context1Interactive = false
Context2Interactive = false
Context3Interactive = false
Context3Value       = "Not loaded"
ShowHelp            = false
UtilityEnabled      = false
```

`Context1Value`:

```powerfx
With(
    {
        _projectCode: Coalesce(varSelectedProject.ProjectCode, ""),
        _projectName: Coalesce(varSelectedProject.ProjectName, "")
    },
    If(
        IsBlank(_projectCode) && IsBlank(_projectName),
        "No project selected",
        _projectCode &
        If(
            !IsBlank(_projectCode) && !IsBlank(_projectName),
            " · ",
            ""
        ) &
        _projectName
    )
)
```

Instance geometry:

```powerfx
Width  = Parent.Width
Height = Parent.Height
```

## Acceptance

```text
PASS
- manually inserted component renders its body
- expected public properties appear in Studio
- all Block 03 bindings can be configured
- current project renders
- Master Punch List default renders
- Last refresh = Not loaded
- Refresh disabled
- Help hidden
- save/reopen remains stable

FAIL
- manual instance is blank or does not expose the expected public properties
→ reopen component contract itself; do not continue screen integration
```
