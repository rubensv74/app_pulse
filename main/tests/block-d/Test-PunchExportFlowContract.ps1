$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$canvasRoot = Join-Path $repoRoot (
    'power-platform\solutions\PULSE\CanvasApps\new_pulse_9584c_src'
)

$yamlFiles = Get-ChildItem -Path $canvasRoot -Recurse -Filter '*.yaml'
foreach ($file in $yamlFiles) {
    $text = Get-Content -Raw -LiteralPath $file.FullName
    if ($text.Contains('Warroom_ExportPunchesToExcel.Run(')) {
        throw "Legacy Flow call remains in $($file.FullName)."
    }
}
Write-Output 'PASS Canvas YAML contains no legacy Flow call.'

$dataSourcePath = Join-Path $canvasRoot (
    'DataSources\Warroom_ExportPunchesToExcel_Codex.json'
)
$legacyDataSourcePath = Join-Path $canvasRoot (
    'DataSources\Warroom_ExportPunchesToExcel.json'
)
$dataSource = Get-Content -Raw -LiteralPath $dataSourcePath | ConvertFrom-Json
if (Test-Path -LiteralPath $legacyDataSourcePath) {
    throw 'Legacy export DataSource still exists.'
}
if ($dataSource[0].Name -ne 'Warroom_ExportPunchesToExcel_Codex') {
    throw 'Codex DataSource name is incorrect.'
}
Write-Output 'PASS Canvas exposes only the Codex export DataSource.'

$connectionsPath = Join-Path $canvasRoot 'Connections\Connections.json'
$connections = Get-Content -Raw -LiteralPath $connectionsPath | ConvertFrom-Json
$flowConnection = $connections.PSObject.Properties |
    Where-Object {
        $_.Value.dataSources -contains 'Warroom_ExportPunchesToExcel_Codex'
    } |
    Select-Object -First 1
$sqlDependencies = @(
    $flowConnection.Value.dependencies.PSObject.Properties.Name |
        Where-Object { $_ -like 'shared_sqldw*' }
)
if ($sqlDependencies.Count -ne 1 -or $sqlDependencies[0] -ne 'shared_sqldw') {
    throw "Canvas Flow SQL dependencies are: $($sqlDependencies -join ', ')."
}
Write-Output 'PASS Canvas Flow connection uses one SQL alias.'

$flowFiles = @(
    'flows\Warroom_ExportPunchesToExcel_Codex\definition.deploy.json',
    'power-platform\solutions\PULSE\Workflows\Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json',
    'power-platform\build\PULSE\pulse\src\Workflows\Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json'
)

foreach ($relativePath in $flowFiles) {
    $flow = Get-Content -Raw -LiteralPath (Join-Path $repoRoot $relativePath) |
        ConvertFrom-Json
    $properties = $flow.properties
    $triggerSchema = $properties.definition.triggers.manual.inputs.schema
    $successResponse = $properties.definition.actions.
        Respond_to_a_Power_App_or_flow.inputs.schema.properties
    $sqlAliases = @(
        $properties.connectionReferences.PSObject.Properties.Name |
            Where-Object { $_ -like 'shared_sqldw*' }
    )
    $actionSqlAliases = @(
        $properties.definition.actions.PSObject.Properties.Value |
            Where-Object {
                $_.inputs.host.apiId -eq
                '/providers/Microsoft.PowerApps/apis/shared_sqldw'
            } |
            ForEach-Object { $_.inputs.host.connectionName } |
            Sort-Object -Unique
    )

    if (@($triggerSchema.properties.PSObject.Properties).Count -ne 12 -or
        @($triggerSchema.required).Count -ne 12) {
        throw "$relativePath does not expose 12 required inputs."
    }
    if (@($successResponse.PSObject.Properties).Count -ne 5) {
        throw "$relativePath does not expose the five-field success response."
    }
    if ($sqlAliases.Count -ne 1 -or $sqlAliases[0] -ne 'shared_sqldw') {
        throw "$relativePath connection references are: $($sqlAliases -join ', ')."
    }
    if ($actionSqlAliases.Count -ne 1 -or
        $actionSqlAliases[0] -ne 'shared_sqldw') {
        throw "$relativePath SQL action aliases are: $($actionSqlAliases -join ', ')."
    }

    Write-Output "PASS ${relativePath}: 12-in/5-out and one SQL alias."
}

Write-Output 'PASS Block D Punches-to-Flow contract.'
