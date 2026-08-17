/*
    PULSE — PR-EXP-C03B1
    Validación con payload real capturado desde scr_PunchReview.

    Contexto validado en Power Apps Studio:
    - ProjectId: 70200
    - TemplateId: 20
    - Review Queue: 15 Punches

    Este script NO modifica datos.
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
    @ProjectId = 70200,
    @TemplateId = 20,
    @WorkItemIdsJson = @WorkItemIdsJson;

/*
Resultado esperado — Result set 1:

ProjectId       70200
TemplateId      20
ExportScope     REVIEW_QUEUE
RequestedCount  15
ResolvedCount   15
IsExactMatch    1

Resultado esperado — Result set 2:
- exactamente 15 filas;
- todos los WorkItemId anteriores;
- ResolutionStatus = READY.
*/
