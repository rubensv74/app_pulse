# Warroom_GetPunchDashboardBundle — contrato v3.0

## Trigger
Power Apps (V2)

## Entradas

| Nombre | Tipo |
|---|---|
| ProjectId | Number |
| TemplateId | Number |

## Acción SQL
Ejecutar el procedimiento:

`warroom.usp_GetPunchDashboardBundle`

Parámetros:

- `@ProjectId` = `ProjectId`
- `@TemplateId` = `TemplateId`

## Respuesta a Power Apps
Añadir **Respond to a PowerApp or flow** con una salida de texto:

- Nombre: `result`
- Valor: la columna `result` de la primera fila devuelta por SQL.

La firma del Flow no cambia respecto a la versión consumida por `scr_Home_1`.
