# WarRoom_EnabledProjects_GetActive

## Evidencia

- Workflow: `WarRoom_EnabledProjects_GetActive-8C5B533A-CC8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `1c66707ccc0c89de4c91f05793c817400d281f66ade295cb4d605b68985599f7`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `app:Properties`
- `screen:scr_SuperAdmin`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_EnabledProjects_GetActive`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
