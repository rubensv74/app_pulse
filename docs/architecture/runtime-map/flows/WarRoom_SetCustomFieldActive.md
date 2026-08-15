# WarRoom_SetCustomFieldActive

## Evidencia

- Workflow: `WarRoom_SetCustomFieldActive-2A1DAE46-CC8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `c8b085f1d13f26aa7aa0de28fdf3045072c43983028bd16e8cf8af6aba29f09b`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `screen:scr_Home`
- `screen:scr_PunchReview`
- `screen:scr_Punches`
- `screen:scr_Tasks`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_CustomField_SetActive`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
