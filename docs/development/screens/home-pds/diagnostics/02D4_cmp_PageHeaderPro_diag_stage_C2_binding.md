# HOME_PDS — cmp_PageHeaderPro diagnostic reduction — Stage C2

**Artifact type:** INSTRUCTIONAL DIAGNOSTIC  
**Canonical product source:** NO  
**Depends on:** PASS_C1  
**Target diagnostic component:** `cmp_PageHeaderPro_DiagC`

## Purpose

Test only the binding between the already Studio-created `Input/Text` custom property `TitleText` and the existing title `ModernText`.

This stage must not recreate or inject `CustomProperties:` through Source Code.

## Preconditions

```text
PASS_A
PASS_B
PASS_C1
```

`cmp_PageHeaderPro_DiagC.TitleText` already exists because it was created manually in Power Apps Studio.

## Exact change

In the Source Code for `cmp_PageHeaderPro_DiagC`, locate:

```yaml
Text: ="Punch Control Tower"
```

inside `lblPHDC_Title` and replace only that property with:

```yaml
Text: =cmp_PageHeaderPro_DiagC.TitleText
```

Do not modify any other line.

The resulting title control must be:

```yaml
- lblPHDC_Title:
    Control: ModernText@1.0.0
    Properties:
      AutoHeight: =true
      Color: =ColorValue("#0F172A")
      FontWeight: =FontWeight.Semibold
      Height: =30
      Size: =20
      Text: =cmp_PageHeaderPro_DiagC.TitleText
      Width: =Parent.Width-32
      Wrap: =false
      X: =16
      Y: =13
```

## Validation

1. Apply only the one-line binding change.
2. Save the component.
3. Insert one fresh instance on the diagnostic screen, or if an existing instance is already present, confirm it remains stable and then insert a second temporary instance only if Studio remains stable.
4. Do not bind screen variables or change component size.
5. Confirm that the rendered title is `Punch Control Tower`.
6. Confirm that Studio remains open.

Result semantics:

```text
PASS_C2 = binding resolves, title renders and Studio remains stable
FAIL_C2 = Studio closes/rejects or the binding cannot resolve
```

If PASS_C2, the diagnostic has proven that a Studio-created `Input/Text` custom property can be consumed from the component body safely in this app. The next stage may add additional non-event public properties incrementally.

If FAIL_C2, the smallest failing surface becomes the body-to-custom-property binding path; stop before adding any additional property type.
