# WarRoom_UpsertCustomFieldDef

## Evidencia

- Workflow: `WarRoom_UpsertCustomFieldDef-FED74CCC-CB8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `66e6fb3a1f2d5fa8729997b771a36728ee193b4e9760ac2a12ccc410f3915de9`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `screen:scr_Home`
- `screen:scr_PunchReview`
- `screen:scr_Punches`
- `screen:scr_Tasks`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_CustomField_Upsert_AndListJson`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
