# DF-05A — Manage → definition-load validation hook

**Type:** `I — Integration`  
**Artifact:** property-only guide  
**Purpose:** temporarily connect the existing Punch Review **Manage** action to the new host definition-load service so DF-05A can be validated before DF-06 introduces the actual modal.

## Target

`cmpPR_CustomFieldValues.OnManageFieldsRequested`

Location:

`conPR_RightColumn → conPR_CustomFieldsHost → cmpPR_CustomFieldValues`

## Replace only this property

Replace the current informational placeholder formula in `OnManageFieldsRequested` with:

```powerfx
=Select(btnPR_LoadCustomFieldDefs);
If(
    IsBlank(varPunchReviewFieldDefsError),
    Notify(
        Text(CountRows(colPunchReviewFieldDefsAdmin)) &
        " Custom Field definitions loaded.",
        NotificationType.Success
    ),
    Notify(
        varPunchReviewFieldDefsError,
        NotificationType.Error
    )
)
```

## Do not modify

- component geometry;
- `cmp_CustomFieldValuesPro` definition;
- Custom Field value load/save behavior;
- Comments;
- Review Progress;
- Dirty Guard;
- theme/color properties.

## Validation

1. Select a real project.
2. Open a Punch in Punch Review.
3. Press **Manage** in Custom Fields.
4. Confirm the success notification reports the number of definitions loaded.
5. Inspect `colPunchReviewFieldDefsAdmin` if needed and confirm both active and inactive definitions are present.
6. Confirm `varPunchReviewFieldDefsError` is blank.
7. Confirm no visual geometry changes occur.
8. Test with no project selected: the action must show the host error instead of calling the flow successfully.

## Lifecycle

This notification hook is intentionally temporary. DF-06 will replace it with the real modal-open lifecycle while preserving `Select(btnPR_LoadCustomFieldDefs)` as the host read service.
