/*
    PULSE — PR-EXP-C03C1 negative gate

    Target:
      warroom.usp_ExportProjectPunchesExtended_Pivoted

    Purpose:
    Prove that a Review Queue request is rejected if one requested WorkItem
    cannot resolve after the normal project/template/export eligibility rules.

    Expected result:
      error 52216
      Requested=15
      Resolved=14
      WorkItemId 999999999 appears as unresolved/ineligible/filtered
      NO partial 14-row export is returned.
*/

DECLARE @WorkItemIdsJson NVARCHAR(MAX) = N'[
  {"WorkItemId":70381},
  {"WorkItemId":653757},
  {"WorkItemId":653765},
  {"WorkItemId":653771},
  {"WorkItemId":724141},
  {"WorkItemId":760975},
  {"WorkItemId":835783},
  {"WorkItemId":967776},
  {"WorkItemId":967856},
  {"WorkItemId":1071084},
  {"WorkItemId":1071086},
  {"WorkItemId":1185186},
  {"WorkItemId":1202830},
  {"WorkItemId":1202843},
  {"WorkItemId":999999999}
]';

EXEC [warroom].[usp_ExportProjectPunchesExtended_Pivoted]
    @ProjectId = 4049,
    @SubsystemCode = NULL,
    @TemplateId = 20,
    @CategoryCode = NULL,
    @StatusCode = NULL,
    @PunchDiscipline = NULL,
    @Subcontractor = NULL,
    @CustomFiltersJson = NULL,
    @PunchExportLogId = NULL,
    @MaxRows = 50000,
    @WorkItemIdsJson = @WorkItemIdsJson;
