/*
    PULSE — PR-EXP-C03C1 positive gate

    Run ONLY after:
      sql/export/005_pr_exp_c03c1_extend_pivoted_export_exact_scope.sql

    Target procedure:
      warroom.usp_ExportProjectPunchesExtended_Pivoted

    Context:
    - Visible PULSE project code: 70200
    - Internal ProjectId used by wap_PunchPaged: 4049
    - TemplateId: 20
    - Exact Review Queue: 15 WorkItems

    READ ONLY with respect to business data.
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

/*
    GATE ESPERADO
    -------------
    1. Termina sin error.
    2. Devuelve exactamente 15 filas.
    3. PunchId contiene exactamente los 15 WorkItemId del payload.
    4. TotalRows = 15 en las filas devueltas.
    5. Conserva la forma PIVOTED que necesita el Flow/Office Script.
    6. No aparece ningún Punch ajeno a la Review Queue.
*/
