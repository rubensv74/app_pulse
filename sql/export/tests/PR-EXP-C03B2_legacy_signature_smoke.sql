/*
    PULSE — PR-EXP-C03B2 legacy-path smoke gate

    Purpose:
    prove that callers which do NOT send @WorkItemIdsJson still execute the
    stored procedure through the previous FILTERED_LIST path.

    Confirmed active SQL procedure:
      warroom.usp_ExportProjectPunchesExtended

    @StatusCode = 'HOLD' is used deliberately so the current global export
    eligibility rule returns no business rows and the smoke test stays small.
*/

EXEC [warroom].[usp_ExportProjectPunchesExtended]
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

/*
    EXPECTED:
    - no parameter error;
    - no PR-EXP-C03B2 scope error;
    - zero rows is acceptable for this smoke test;
    - the absence of @WorkItemIdsJson selects the legacy behaviour.
*/
