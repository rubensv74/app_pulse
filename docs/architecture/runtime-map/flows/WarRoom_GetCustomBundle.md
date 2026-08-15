# WarRoom_GetCustomBundle

## Evidencia

- Workflow: `WarRoom_GetCustomBundle-581FCF60-CC8C-F111-AB10-7CED8D917E8A.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `19a1cafc4af4546db4e3a67f6185f720d0dbd06f603dba3516454aacead89a66`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `component:cmp_DetailDrawer_old`
- `screen:scr_Home`
- `screen:scr_PunchReview`
- `screen:scr_Punches`
- `screen:scr_Tasks`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_CustomBundle_GetJson`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
