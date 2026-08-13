# C17-E2A-FIX1 — Session Activity

Cambiar el alcance visual de Session Activity de Punch actual a sesión completa.

Targets:
- lblPR_HistoryBadge.Text: Text(CountRows(colPunchReviewSessionEvents)) & " events"
- galPR_History.Items: SortByColumns(colPunchReviewSessionEvents, "EventOn", SortOrder.Descending)
- galPR_History.Visible: CountRows(colPunchReviewSessionEvents) > 0
- conPR_HistoryEmpty.Visible: CountRows(colPunchReviewSessionEvents) = 0
- lblPR_HistoryEmptyTitle.Text: "No session activity yet"
- lblPR_HistoryEmptyText.Text: "Actions performed during this review session will appear here."

No modificar los Collect que generan los eventos. Validar revisando A, B y C y comprobando que el feed conserva todos los eventos al cambiar de Punch.