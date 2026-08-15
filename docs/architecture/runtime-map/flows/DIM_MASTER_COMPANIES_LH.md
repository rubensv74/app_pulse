# DIM_MASTER_COMPANIES_LH

## Evidencia

- Workflow: `DIM_MASTER_COMPANIES_LH-60F81C09-CC8C-F111-AB10-7C1E5260DE41.json`
- Baseline: `baseline_pulse_1_0_0_5.zip`
- Hash SHA-256: `ba3e7281e33ec182b6818d8deecabd9f7f825596b947853b0a587f9e16ce5e0b`
- Estado de referencia Canvas: `NO_CANVAS_REFERENCE_OBSERVED`

## Consumidores Canvas observados

- Ninguno observado.

## Trigger

- `Request`

## Procedimientos ejecutados

- `dbo.usp_Upsert_MasterCompany_FromLakehouse_Batch`

## Conectores

- `shared_office365`
- `shared_sql`
- `shared_sqldw`

## Operaciones

- `ExecutePassThroughNativeQueryV2`
- `ExecutePassThroughNativeQuery_V2`
- `ExecuteProcedureV2`
- `SendEmailV2`

## Consultas SQL directas detectadas

- `@outputs('Compose_-_Lakehouse_paged_query')`
- `INSERT INTO dbo.LakehouseSyncLog
(
    ExecutionId,
    ProcessName,
    StartDate,
    EndDate,
    Status,
    ExpectedRows,
    ProcessedRows,
    ErrorMessage
)
VALUES
(
    '@{variables('varRunId')}',
    '@{variables('varProcessName')}',
    '@{variables('varRunStartDate')}',
    SYSUTCDATETIME(),
    'FAILED',
    @{variables('varExpectedRows')},
    @{variables('varTotalRowsProcessed')},
    'Review Power Automate run history.'
);`
- `INSERT INTO dbo.LakehouseSyncLog
(
    ExecutionId,
    ProcessName,
    StartDate,
    EndDate,
    Status,
    ExpectedRows,
    ProcessedRows,
    ErrorMessage
)
VALUES
(
    '@{variables('varRunId')}',
    '@{variables('varProcessName')}',
    '@{variables('varRunStartDate')}',
    SYSUTCDATETIME(),
    'SUCCESS',
    @{variables('varExpectedRows')},
    @{variables('varTotalRowsProcessed')},
    NULL
);`
- `SELECT COUNT(*) AS TotalRows
FROM
(
    SELECT
        ID_COMPANY,
        MAX(DS_COMPANY) AS DS_COMPANY,
        MAX(DS_SHORT_COMPANY) AS DS_SHORT_COMPANY
    FROM corp_itcs_trd272.DIM_MVW_MASTER_COMPANIES
    WHERE ID_COMPANY IS NOT NULL
    GROUP BY ID_COMPANY
) d;`

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
