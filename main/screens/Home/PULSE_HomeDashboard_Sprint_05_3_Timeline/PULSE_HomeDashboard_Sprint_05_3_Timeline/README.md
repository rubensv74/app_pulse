# PULSE Home Dashboard — Sprint 05.3 Timeline

## Incluido
- Histórico de los siete últimos snapshots.
- Timeline visual Open / Cleared / Closed.
- Variación del número de Open respecto al snapshot anterior.
- Estados sin histórico y con un único snapshot.
- Contrato 2.3.
- Firma del Flow sin cambios.

## Integración
1. Ejecutar `PULSE_PunchDashboard_Sprint_05_3_Timeline.sql`.
2. Mantener el Flow devolviendo la columna `result`.
3. Sustituir Home por `scr_Home_1_Sprint05_3_Timeline.pa.yaml`.
4. Generar varios snapshots para comprobar la evolución.
5. Validar:
   - orden cronológico;
   - barras Open/Cleared/Closed;
   - delta del último snapshot;
   - estado “Not enough snapshots” con un solo registro.

## Observación sobre estados
El SQL identifica Open, Cleared y Closed por `StatusCode` o `StatusName`. Si el proyecto utiliza códigos distintos, deben incorporarse en los bloques `IN (...)` del procedimiento.
