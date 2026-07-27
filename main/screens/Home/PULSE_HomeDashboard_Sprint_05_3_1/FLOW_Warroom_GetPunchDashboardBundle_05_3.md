# Flow — Warroom_GetPunchDashboardBundle · Sprint 05.3

La firma pública no cambia.

## Entradas
- `ProjectId`
- `TemplateId`

## SQL
Ejecutar `warroom.usp_GetPunchDashboardBundle`.

## Salida
Mantener una única salida de texto:
- `result`: valor de la columna `result` devuelta por SQL.

El Flow no debe aplicar Parse JSON. El nuevo nodo `timeline` se transporta sin transformación.
