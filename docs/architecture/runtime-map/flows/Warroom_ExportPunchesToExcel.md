# Warroom_ExportPunchesToExcel

## Evidencia

- Workflow: `Warroom_ExportPunchesToExcel-776AED9C-298B-F111-AB10-000D3A25AA91.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `424fc300d0cc20c3d5d84ef21959999952f6671fa60d7bdd061141c55a7c5841`
- Estado de referencia Canvas: `NO_CANVAS_REFERENCE_OBSERVED`

## Consumidores Canvas observados

- Ninguno observado.

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_ExportProjectPunchesExtended_Pivoted`
- `warroom.usp_GetPunchExportColumnMap`
- `warroom.usp_PunchExportLog_Complete`
- `warroom.usp_PunchExportLog_Start`

## Conectores

- `shared_excelonlinebusiness`
- `shared_sharepointonline`
- `shared_sqldw`

## Operaciones

- `CreateFile`
- `CreateSharingLink`
- `ExecuteProcedureV2`
- `GetFileContentByPath`
- `RunScriptProd`

## Consultas SQL directas detectadas

- Ninguno observado.

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
