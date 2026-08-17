/*
    PULSE — PR-EXP-C03C1 legacy compatibility smoke

    Purpose:
    Prove that the restored pivoted procedure still accepts the old Flow call
    without @WorkItemIdsJson.

    HOLD is used intentionally to keep this smoke test small. The absence of
    @WorkItemIdsJson must select the legacy filtered behaviour.

    Expected:
      - no parameter error;
      - no PR-EXP-C03C1 exact-scope error;
      - zero rows is acceptable for this smoke test.
*/

EXEC [warroom].[usp_ExportProjectPunchesExtended_Pivoted]
    @ProjectId = 4049,
    @SubsystemCode = NULL,
    @TemplateId = 20,
    @CategoryCode = NULL,
    @StatusCode = N'HOLD',
    @PunchDiscipline = NULL,
    @Subcontractor = NULL,
    @CustomFiltersJson = NULL,
    @PunchExportLogId = NULL,
    @MaxRows = 50000;
