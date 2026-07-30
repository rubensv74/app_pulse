$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$files = @(
    'main\screens\Punches\scr_Punches_1.pa.yaml',
    'power-platform\solutions\PULSE\CanvasApps\new_pulse_9584c_src\Other\Src\scr_Punches_1.pa.yaml',
    'power-platform\solutions\PULSE\CanvasApps\new_pulse_9584c_src\Src\scr_Punches_1.fx.yaml'
)

foreach ($relativePath in $files) {
    $text = Get-Content -Raw -LiteralPath (Join-Path $repoRoot $relativePath)

    $assertions = [ordered]@{
        'duplicate ColumnKey validation' =
            $text.Contains('CountRows(Distinct(colPunchExportColumns, ColumnKey))')
        'CLIENT profile selects only public columns' =
            $text.Contains('IsSelected: !c.IsSensitive')
        'Select public uses the CLIENT rule' =
            $text.Contains('IsSelected: !IsSensitive') -and
            -not $text.Contains('IsSelected: !IsSensitive || IsRequired')
        'INTERNAL profile selects all columns' =
            $text.Contains('IsSelected: true')
        'Clear all label is present' =
            $text.Contains('Text: ="Clear all"')
        'legacy Clear optional label is absent' =
            -not $text.Contains('Text: ="Clear optional"')
        'manual toggle is enabled for every row' =
            $text.Contains('DisplayMode: =DisplayMode.Edit')
        'JSON is built from selected collection rows' =
            $text.Contains('Filter(') -and
            $text.Contains('colPunchExportColumns') -and
            $text.Contains('JSONFormat.Compact')
        'Continue blocks an empty selection' =
            $text.Contains('"Select at least one export column."')
    }

    foreach ($assertion in $assertions.GetEnumerator()) {
        if (-not $assertion.Value) {
            throw "$relativePath failed: $($assertion.Key)."
        }
    }

    Write-Output "PASS ${relativePath}: modal contract."
}

Write-Output 'PASS Block C Punch export column modal.'
