# DF-03A — Definition draft initialization property guide

**Purpose:** initialize the local DF-03 draft whenever the user selects an existing definition or starts a new one.

**Important:** this is a property-adjustment guide, not Power Apps Source Code. Do not paste this complete file into Source Code.

Apply the changes below to the existing DF-02 catalog inside `cmp_CustomFieldsEditorPro`.

## A. `btnCFDEPro_AddField.OnSelect`

Replace the current formula with:

```powerfx
=Set(varCFDEPro_EditMode, "ADD");
Set(varCFDEPro_SelectedFieldKey, "");
Set(varCFDEPro_Draft_FieldDefId, 0);
Set(varCFDEPro_Draft_FieldKey, "");
Set(varCFDEPro_Draft_Label, "");
Set(varCFDEPro_Draft_FieldType, "Text");
Set(varCFDEPro_Draft_HelpText, "");
Set(varCFDEPro_Draft_IsRequired, false);
Set(varCFDEPro_Draft_IsPinned, true);
Set(varCFDEPro_Draft_IsActive, true);
Set(varCFDEPro_Draft_SortOrder, 100);
Set(varCFDEPro_Draft_OptionsJson, "[]");
Set(varCFDEPro_Draft_IsFilterable, false);
Set(varCFDEPro_Draft_ShowInQuickFilters, false);
Set(varCFDEPro_Draft_FilterOrder, 100);
Set(varCFDEPro_Draft_FilterMode, "Equals");
Set(varCFDEPro_DraftDirty, false);
cmp_CustomFieldsEditorPro.OnAddRequested()
```

## B. `btnCFDEPro_RowSelect.OnSelect`

Replace the current formula with:

```powerfx
=Set(varCFDEPro_SelectedFieldKey, ThisItem.FieldKey);
Set(varCFDEPro_EditMode, "EDIT");
Set(varCFDEPro_Draft_FieldDefId, Coalesce(ThisItem.FieldDefId, 0));
Set(varCFDEPro_Draft_FieldKey, Coalesce(ThisItem.FieldKey, ""));
Set(varCFDEPro_Draft_Label, Coalesce(ThisItem.Label, ""));
Set(varCFDEPro_Draft_FieldType, Coalesce(ThisItem.FieldType, "Text"));
Set(varCFDEPro_Draft_HelpText, Coalesce(ThisItem.HelpText, ""));
Set(varCFDEPro_Draft_IsRequired, Coalesce(ThisItem.IsRequired, false));
Set(varCFDEPro_Draft_IsPinned, Coalesce(ThisItem.IsPinned, false));
Set(varCFDEPro_Draft_IsActive, Coalesce(ThisItem.IsActive, true));
Set(varCFDEPro_Draft_SortOrder, Coalesce(ThisItem.SortOrder, 100));
Set(varCFDEPro_Draft_OptionsJson, Coalesce(ThisItem.OptionsJson, "[]"));
Set(varCFDEPro_Draft_IsFilterable, Coalesce(ThisItem.IsFilterable, false));
Set(varCFDEPro_Draft_ShowInQuickFilters, Coalesce(ThisItem.ShowInQuickFilters, false));
Set(varCFDEPro_Draft_FilterOrder, Coalesce(ThisItem.FilterOrder, 100));
Set(varCFDEPro_Draft_FilterMode, Coalesce(ThisItem.FilterMode, "Equals"));
Set(varCFDEPro_DraftDirty, false)
```

## C. Row label click delegation

Replace the `OnSelect` formula of these controls:

- `lblCFDEPro_DefLabel`
- `lblCFDEPro_DefKey`
- `lblCFDEPro_DefMeta`
- `lblCFDEPro_DefStatus`

with:

```powerfx
=Select(btnCFDEPro_RowSelect)
```

This centralizes all draft initialization in one formula and prevents the labels from drifting away from the row-selection behavior.

## Validation

1. Click `Vendor Package`: the DF-03 center form must show its current values and `Loaded`.
2. Edit one property: the editor status becomes `Modified`.
3. Select another row: that row's definition becomes the new draft and status returns to `Loaded`.
4. Click `+ Add field`: label/key are blank, type=`Text`, Active=true, Pinned=true, SortOrder=100 and status=`New draft`.
5. No Power Automate flow is called.

## Compatibility notes

- Numeric variables are explicitly initialized with numeric values.
- No `Reset()` is introduced.
- The guide changes existing properties only, so it is intentionally `.property-guide.md` rather than `.pa.yaml`.
