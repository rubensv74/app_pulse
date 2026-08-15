# WarRoom_ListCustomFieldDefs

## Evidencia

- Workflow: `WarRoom_ListCustomFieldDefs-7D10EE65-CC8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `fd453db53b13aea61905dbb6efcfa42d09571328acf2796694f18cf87611f11d`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `screen:scr_Home`
- `screen:scr_PunchReview`
- `screen:scr_Punches`
- `screen:scr_Tasks`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_CustomField_ListJson`

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecuteProcedureV2`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
