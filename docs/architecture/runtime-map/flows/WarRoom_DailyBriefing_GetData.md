# WarRoom_DailyBriefing_GetData

## Evidencia

- Workflow: `WarRoom_DailyBriefing_GetData-8B5B533A-CC8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `e930c823cdb1589d146e3b1d11540c1bdd26d532b6a25e8d0e3d2df1a94acff9`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `screen:scr_Briefing`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_DailyBriefing_GetEvents`
- `warroom.usp_DailyBriefing_GetKpis`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
