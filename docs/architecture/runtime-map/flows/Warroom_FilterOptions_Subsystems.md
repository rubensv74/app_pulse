# Warroom_FilterOptions_Subsystems

## Evidencia

- Workflow: `Warroom_FilterOptions_Subsystems-B2D7C6A0-CB8C-F111-AB10-000D3A21CE45.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `a0ba161068355448009e180ca407d49fbf9e70181ca85ca7e22fa9d4d14aee43`
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

- `select SUBSYSTEM_CODE as 'Code' from getProjectSubSystems(@{triggerBody()['number']}) `

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
