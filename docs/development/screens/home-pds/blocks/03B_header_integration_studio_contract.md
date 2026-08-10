# HOME_PDS — BLOCK 03B — PAGE HEADER INTEGRATION THROUGH STUDIO-RESOLVED CONTRACT

**Status:** CORRECTED CANDIDATE — PENDING POWER APPS STUDIO VALIDATION  
**Target:** `scr_Home_PDS`  
**Replaces:** `03_header_integration.children.pa.yaml` and `03A_header_integration.full-screen.pa.yaml`

## Confirmed evidence

Block 03 and 03A both produced `PA2108 Unknown property` for every `cmp_PageHeaderPro` custom property assigned from screen Source Code.

The same failure occurred in:

- a partial child/control Source Code edit surface; and
- a complete `Screens:` Source Code replacement.

Therefore the earlier hypothesis that the failure was caused by the partial edit surface is **refuted for this incident**.

Standard CanvasComponent properties such as `Height` and `Width` were accepted, while component-specific properties such as `Context1Value`, `Context1Interactive`, `ShowHelp` and `UtilityEnabled` were rejected.

Operational interpretation:

> In the current app state, the screen Source Code parser resolves the `cmp_PageHeaderPro` instance as a generic `CanvasComponent` for host-side assignment and does not resolve its component-specific public properties.

This statement describes the observed Source Code boundary. It does not claim the internal Power Apps metadata cause.

## Positive reference

`cmp_SidebarNav` proves that screen Source Code can serialize custom component instance properties when Studio recognizes the public contract. `scr_PunchReview` contains working assignments such as `ActiveKey`, `ProjectCode`, `ProjectName` and `UserRole`.

Therefore the problem is not the generic syntax:

```yaml
Control: CanvasComponent
ComponentName: <component>
Properties:
  <custom property>: =...
```

The remaining differential is the **host-visible/Studio-resolved public contract of this specific component**.

## Corrective method

Do not rewrite `cmp_PageHeaderPro` again and do not create another microtest sequence.

Use a hybrid integration path:

1. create the header host and the component instance using only standard CanvasComponent properties in Source Code;
2. save;
3. select the instance in Studio;
4. configure its public properties from the Studio property selector / formula bar;
5. save and let Studio own the host-side binding representation.

If Studio exposes the expected public properties, configure all required Block 03 bindings in one pass.

If Studio does **not** expose `Context1Value` (or the other public properties) on the selected instance, stop. That result means the public contract is not host-visible in Studio and the next correction is contract re-registration in Studio, not more screen YAML.

## Base Source Code fragment

Insert as the first child under `conHPDS_ContentShell.Children`:

```yaml
- conHPDS_PageHeaderHost:
    Control: GroupContainer@1.5.0
    Variant: ManualLayout
    Properties:
      AlignInContainer: =AlignInContainer.Stretch
      DropShadow: =DropShadow.None
      Fill: =varTheme_Surface
      FillPortions: =0
      Height: =80
      LayoutMinHeight: =80
      LayoutMinWidth: =320
      RadiusBottomLeft: =0
      RadiusBottomRight: =0
      RadiusTopLeft: =0
      RadiusTopRight: =0
      Width: =Parent.Width
    Children:
      - cmpHPDS_PageHeader:
          Control: CanvasComponent
          ComponentName: cmp_PageHeaderPro
          Properties:
            Height: =Parent.Height
            Width: =Parent.Width
```

## Studio formulas — configure in one pass

Select `cmpHPDS_PageHeader` and set these component properties through Studio:

### `Context1Interactive`

```powerfx
false
```

### `Context1Value`

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

### `Context2Interactive`

```powerfx
false
```

### `Context3Interactive`

```powerfx
false
```

### `Context3Value`

```powerfx
"Not loaded"
```

### `ShowHelp`

```powerfx
false
```

### `UtilityEnabled`

```powerfx
false
```

No other custom property needs to be overridden in Block 03 because the component defaults already provide the correct title, subtitle, labels, visibility, `Master Punch List`, `Refresh` text and utility visibility.

## Acceptance

```text
PASS
- base instance compiles with no PA2108
- Studio property selector exposes Context1Value and the other public properties
- all seven formulas can be assigned in one pass
- header renders with current project / Master Punch List / Not loaded
- Refresh disabled
- Help hidden
- no clipping/scrollbar regression

FAIL-CONTRACT-NOT-VISIBLE
- custom properties are absent from the selected instance property selector
→ re-register the public contract in Studio; do not continue screen YAML diagnosis
```
