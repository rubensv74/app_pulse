# Warroom_ExportPunchesToExcel_Codex

## Evidencia

- Workflow: `Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `9de0dcb9d47f714863a1644ee0ac2c7999302da82101fd68ad518531c7a46575`
- Estado de referencia Canvas: `ACTIVE_OBSERVED`

## Consumidores Canvas observados

- `screen:scr_Punches`

## Trigger

- `Request`

## Procedimientos ejecutados

- `warroom.usp_CompletePunchExportBatch`
- `warroom.usp_ExportProjectPunchesExtended_Pivoted`
- `warroom.usp_GetPunchExportColumnMap`
- `warroom.usp_PunchExportLog_Complete`
- `warroom.usp_PunchExportLog_Start`
- `warroom.usp_RegisterPunchExportSnapshot`

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
