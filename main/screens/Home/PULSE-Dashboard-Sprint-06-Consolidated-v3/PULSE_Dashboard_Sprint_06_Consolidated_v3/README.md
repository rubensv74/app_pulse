# PULSE Dashboard — Sprint 06 Consolidated v3

Entregable consolidado para completar el Dashboard Executive de Punches sobre la pantalla Home actual.

## Orden de aplicación

1. Ejecutar `sql/warroom.usp_GetPunchDashboardBundle.sql`.
2. Verificar que el Flow `Warroom_GetPunchDashboardBundle` ejecuta dicho procedimiento y devuelve la columna `result`.
3. Sustituir la pantalla Home por `screens/Home/scr_Home_1.pa.yaml` mediante Power Apps Source Code.
4. Seleccionar un proyecto y una plantilla de punches.
5. Validar KPIs, timeline, heat map, resúmenes y Executive Insights.

## Cambio funcional principal

Se añade una tarjeta **Executive Insights** con hasta cinco señales priorizadas y drill-through hacia Punch List cuando el insight contiene filtros accionables.
