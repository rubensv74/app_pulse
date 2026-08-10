$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$failures = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Message
    )

    if ($Condition) {
        Write-Output "PASS $Message"
    }
    else {
        $failures.Add($Message)
        Write-Output "FAIL $Message"
    }
}

Write-Output 'JSON'
Add-Type -AssemblyName System.Web.Extensions
$jsonParser = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
$jsonParser.MaxJsonLength = [int]::MaxValue

$jsonFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter '*.json'
foreach ($file in $jsonFiles) {
    try {
        $null = $jsonParser.DeserializeObject(
            (Get-Content -Raw -LiteralPath $file.FullName))
        Write-Output "PASS JSON $($file.FullName.Substring($repoRoot.Length + 1))"
    }
    catch {
        $failures.Add("Invalid JSON: $($file.FullName)")
        Write-Output "FAIL JSON $($file.FullName): $($_.Exception.Message)"
    }
}

$flowPath = Join-Path $repoRoot (
    'main\power-automate\Warroom_ExportPunchesToExcel_Codex\definition.deploy.json'
)
$flow = Get-Content -Raw -LiteralPath $flowPath | ConvertFrom-Json
$actions = $flow.properties.definition.actions

Write-Output 'FLOW'
Assert-True (
    $flow.properties.displayName -eq 'Warroom_ExportPunchesToExcel_Codex'
) 'Flow display name'
Assert-True (
    $actions.Compose_SelectedColumns_Safe.inputs.Contains("['text_9']")
) 'SelectedColumns uses trigger key text_9'
Assert-True (
    $actions.Compose_ExportMode_Safe.inputs.Contains("['text_8']")
) 'ExportMode uses trigger key text_8'
Assert-True (
    $actions.SQL_RegisterExportSnapshot.inputs.parameters.procedure -eq
        '[warroom].[usp_RegisterPunchExportSnapshot]'
) 'Snapshot procedure action'
Assert-True (
    $actions.SP_GetTemplateFileContent.runAfter.PSObject.Properties.Name -contains
        'SQL_RegisterExportSnapshot'
) 'Snapshot completes before template read'
Assert-True (
    $actions.SQL_CompleteExportBatch.inputs.parameters.procedure -eq
        '[warroom].[usp_CompletePunchExportBatch]'
) 'Batch completion procedure action'
Assert-True (
    $actions.Respond_to_a_Power_App_or_flow.runAfter.PSObject.Properties.Name -contains
        'SQL_CompleteExportBatch'
) 'READY transition completes before success response'
Assert-True (
    $null -ne $actions.Respond_ExportFailure
) 'Structured failure response'


$solutionFlowPath = Join-Path $repoRoot (
    'power-platform\solutions\PULSE\pulse\src\Workflows\' +
    'Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json'
)
$solutionFlow = Get-Content -Raw -LiteralPath $solutionFlowPath |
    ConvertFrom-Json
$solutionActions = $solutionFlow.properties.definition.actions
Assert-True (
    $solutionActions.SQL_RegisterExportSnapshot.inputs.parameters.procedure -eq
        '[warroom].[usp_RegisterPunchExportSnapshot]' -and
    $solutionActions.SQL_CompleteExportBatch.inputs.parameters.procedure -eq
        '[warroom].[usp_CompletePunchExportBatch]'
) 'Unpacked solution contains deployable snapshot lifecycle'
Write-Output 'OFFICE SCRIPT'
$officeScript = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\office-scripts\BuildPunchExport.ts'
)
foreach ($column in @(
    'ExportBatchId',
    'ProjectId',
    'TemplateId',
    'WorkItemId',
    'RowVersion',
    'ExportedAtUtc',
    'RowChecksum'
)) {
    Assert-True ($officeScript.Contains('"' + $column + '"')) (
        "Office Script metadata $column"
    )
}
Assert-True (
    $officeScript.Contains('header !== "OriginalValuesJson"')
) 'OriginalValuesJson excluded from workbook'
Assert-True (
    $officeScript.Contains('parsed as unknown as T')
) 'Office Scripts TS2352 compatibility'

Write-Output 'SQL'
$foundation = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\sql\import\001_import_foundations.sql'
)
$exportSql = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\sql\export\usp_ExportProjectPunchesExtended_Pivoted.sql'
)
$snapshotSql = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\sql\export\002_register_punch_export_snapshot.sql'
)
Assert-True (
    $foundation -match '\[ExportBatchId\]\s+bigint NOT NULL'
) 'ExportBatchId uses BIGINT'
Assert-True (
    $foundation -match '\[RowVersion\]\s+binary\(8\) NULL'
) 'RowVersion is nullable'
Assert-True (
    $exportSql.Contains('FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES')
) 'Canonical standard JSON'
Assert-True (
    $exportSql.Contains('ORDER BY valuesByKey.ColumnName')
) 'Canonical sorted custom values'
Assert-True (
    $exportSql.Contains('HASHBYTES(')
) 'SHA-256 export checksum'
Assert-True (
    $snapshotSql.Contains('BEGIN TRANSACTION') -and
    $snapshotSql.Contains('ROLLBACK TRANSACTION')
) 'Transactional snapshot and completion'
Assert-True (
    $snapshotSql.Contains('[warroom].[usp_RegisterPunchExportSnapshot]') -and
    $snapshotSql.Contains('[warroom].[usp_CompletePunchExportBatch]')
) 'Snapshot lifecycle procedures'

Write-Output 'POWER APPS'
$screen = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\screens\Punches\scr_Punches_1.pa.yaml'
)
Assert-True (
    $screen.Contains('Warroom_ExportPunchesToExcel_Codex.Run(')
) 'Power Apps references Codex Flow'
Assert-True (
    -not $screen.Contains('colPunchExportRequestColumns')
) 'Power Apps does not append technical columns'

Write-Output 'CONTRACT'
$contract = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\contracts\excel-import\export-columns.v3.json'
) | ConvertFrom-Json
$mapping = Get-Content -Raw -LiteralPath (
    Join-Path $repoRoot 'main\mappings\excel-import\punch-columns.v3.json'
) | ConvertFrom-Json

$contractColumns = @($contract.technicalColumns.columnKey)
$mappingColumns = @($mapping.columns.excelColumn)
Assert-True (
    $contract.flow -eq 'Warroom_ExportPunchesToExcel_Codex'
) 'Contract Flow name'
Assert-True (
    $contractColumns.Count -eq 7 -and
    @($contractColumns | Where-Object { $_ -notin $mappingColumns }).Count -eq 0
) 'Contract and mapping technical columns'
Assert-True (
    @($mapping.columns | Where-Object editable).Count -eq 0
) 'Technical mapping is non-editable'

if ($failures.Count -gt 0) {
    throw "I01.1 local validation failed: $($failures -join '; ')"
}

Write-Output 'PASS I01.1 local validation completed.'
