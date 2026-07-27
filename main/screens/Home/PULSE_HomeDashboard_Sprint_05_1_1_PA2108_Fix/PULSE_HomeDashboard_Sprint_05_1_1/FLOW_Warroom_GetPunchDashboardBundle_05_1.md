# Flow — Warroom_GetPunchDashboardBundle · Sprint 05.1

No se modifica la firma pública del Flow.

## Entrada

- `ProjectId`
- `TemplateId`

## Acción SQL

Ejecutar:

`warroom.usp_GetPunchDashboardBundle`

## Salida

Mantener una única salida de texto:

- Nombre: `result`
- Valor: columna `result` devuelta por SQL.

## Compatibilidad

El contrato conserva `snapshotInfo`, `summary`, `matrix`, `subsystems` y `subcontractors`.

Cada elemento de `summary` incorpora:

- `PreviousPunchCount`
- `Delta`
- `DeltaPercent`
- `Trend`

No es necesario agregar acciones Parse JSON dentro del Flow.
