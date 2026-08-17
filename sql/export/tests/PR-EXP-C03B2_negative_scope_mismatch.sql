/*
    PULSE — PR-EXP-C03B2 negative gate

    Purpose:
    prove that the extended ACTIVE export procedure refuses a partial
    Review Queue export.

    Confirmed active SQL procedure:
      warroom.usp_ExportProjectPunchesExtended

    One valid WorkItemId from the validated queue is replaced with 999999999.
    Expected result: SQL error 52116 and NO partial result set.
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

EXEC [warroom].[usp_ExportProjectPunchesExtended]
    @ProjectId = 4049,
    @TemplateId = 20,
    @WorkItemIdsJson = @WorkItemIdsJson;

/*
    EXPECTED:

    Msg 52116 ...
    Review Queue export scope mismatch.
    Requested=15; Resolved=14; ...
    Partial export is forbidden.
*/
