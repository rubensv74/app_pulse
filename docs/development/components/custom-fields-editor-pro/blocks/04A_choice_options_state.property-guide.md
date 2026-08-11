# DF-04A — Choice / MultiChoice options state property guide

**Purpose:** initialize and maintain the human-readable options list used by DF-04 while preserving the existing `OptionsJson` backend contract.

**Important:** this is a property-adjustment guide, not Power Apps Source Code. Do not paste this complete file into Source Code.

Apply these property changes to the existing DF-02 / DF-03 controls inside `cmp_CustomFieldsEditorPro` **before** replacing `conCFDEPro_OptionsNotice` with the DF-04 control.

## A. `btnCFDEPro_AddField.OnSelect`

Keep the DF-03A formula and add these assignments immediately after `Set(varCFDEPro_Draft_OptionsJson, "[]");`:

```powerfx
Set(varCFDEPro_Draft_OptionsText, "");
Set(varCFDEPro_OptionsError, "");
```

Expected new-draft state:

- `varCFDEPro_Draft_OptionsJson = "[]"`
- `varCFDEPro_Draft_OptionsText = ""`

## B. `btnCFDEPro_RowSelect.OnSelect`

In the current DF-03A formula, replace the single OptionsJson assignment with this block:

```powerfx
Set(
    varCFDEPro_Draft_OptionsJson,
    If(
        ThisItem.FieldType = "Choice" || ThisItem.FieldType = "MultiChoice",
        Coalesce(ThisItem.OptionsJson, "[]"),
        "[]"
    )
);
Set(
    varCFDEPro_Draft_OptionsText,
    If(
        ThisItem.FieldType = "Choice" || ThisItem.FieldType = "MultiChoice",
        IfError(
            Concat(
                Table(
                    ParseJSON(
                        Coalesce(ThisItem.OptionsJson, "[]")
                    )
                ),
                Text(ThisRecord.Value),
                Char(10)
            ),
            ""
        ),
        ""
    )
);
Set(varCFDEPro_OptionsError, "");
```

This converts the stored JSON string array into the editor's one-option-per-line representation.

Examples:

- `["PKG-01","PKG-02","PKG-03"]` becomes three visible lines.
- `[]` becomes an empty editor.
- malformed JSON falls back to an empty editor instead of blocking selection.

## C. `ddCFDEPro_FieldType.OnChange`

Replace the current DF-03 formula with:

```powerfx
=Set(varCFDEPro_Draft_FieldType, Self.Selected.Value);
If(
    varCFDEPro_Draft_FieldType <> "Choice" &&
    varCFDEPro_Draft_FieldType <> "MultiChoice",
    Set(varCFDEPro_Draft_OptionsText, "");
    Set(varCFDEPro_Draft_OptionsJson, "[]")
);
Set(varCFDEPro_DraftDirty, true)
```

This preserves options when switching between `Choice` and `MultiChoice`, but clears them if a new field changes to a non-choice type.

Existing definitions are unaffected because DF-03 keeps FieldType read-only in `EDIT` mode.

## D. Row label click delegation remains unchanged

Keep these DF-03A formulas as:

```powerfx
=Select(btnCFDEPro_RowSelect)
```

for:

- `lblCFDEPro_DefLabel`
- `lblCFDEPro_DefKey`
- `lblCFDEPro_DefMeta`
- `lblCFDEPro_DefStatus`

This is important because the full option-state initialization now lives only in `btnCFDEPro_RowSelect.OnSelect`.

## Validation

1. Select `Vendor Package` from the DF-01A seed.
2. Confirm that the editor receives three visible lines: `PKG-01`, `PKG-02`, `PKG-03`.
3. Select `Affected Disciplines`: confirm the three discipline options appear.
4. Select `Completion Note`: the options editor must be hidden and the local options state must be empty.
5. Start a new `Choice` field: options begin empty.
6. Change that new field from Choice to MultiChoice: existing option lines remain.
7. Change it from MultiChoice to Text: options are cleared and `OptionsJson` returns to `[]`.
8. No flow is called.

## Compatibility notes

- No `Reset()` is introduced.
- `ParseJSON` is only used to translate the existing string-array contract into editable lines.
- Malformed OptionsJson is handled locally with `IfError`.
- Serialization back to JSON is performed by DF-04 with `JSON(..., JSONFormat.Compact)`, never manual quote escaping.
- This file changes existing properties only, so it is intentionally a `.property-guide.md` artifact.
