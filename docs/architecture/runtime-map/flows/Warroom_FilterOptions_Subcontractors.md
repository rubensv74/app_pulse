# Warroom_FilterOptions_Subcontractors

## Evidencia

- Workflow: `Warroom_FilterOptions_Subcontractors-F4D7C6A0-CB8C-F111-AB10-000D3A21CE45.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `69e66016ed8137928840e11d79ea1589a62edddcea6af721570c34dd5d869d16`
- Estado de referencia Canvas: `NO_CANVAS_REFERENCE_OBSERVED`

## Consumidores Canvas observados

- Ninguno observado.

## Trigger

- `Request`

## Procedimientos ejecutados

- Ninguno observado.

## Conectores

- `shared_sqldw`

## Operaciones

- `ExecutePassThroughNativeQueryV2`

## Consultas SQL directas detectadas

- `select DISTINCT SubcontractCode from Subcontracts
where ProjectId = @{triggerBody()['number']}`

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
