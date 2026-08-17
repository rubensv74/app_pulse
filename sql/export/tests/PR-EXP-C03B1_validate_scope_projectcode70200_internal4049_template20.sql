/*
    PULSE — PR-EXP-C03B1
    Corrected validation using the real internal project identifier.

    User-visible project:
    - ProjectCode: 70200

    SQL / integration context:
    - Internal ProjectId: 4049
    - TemplateId: 20
    - Review Queue: 15 Punches

    IMPORTANT:
    The Export modal shows ProjectCode 70200 to the user, but the backend must
    filter wap_PunchPaged with the internal ProjectId held by varProjectId.

    This script is READ ONLY.
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
  {"WorkItemId":1267968}
]';

EXEC [warroom].[usp_ValidatePunchReviewExportScope]
    @ProjectId = 4049,
    @TemplateId = 20,
    @WorkItemIdsJson = @WorkItemIdsJson;

/*
Expected result set 1:

ProjectId       4049
TemplateId      20
ExportScope     REVIEW_QUEUE
RequestedCount  15
ResolvedCount   15
IsExactMatch    1

Expected result set 2:
- exactly 15 rows;
- the 15 WorkItemIds above;
- ResolutionStatus = READY.
*/
