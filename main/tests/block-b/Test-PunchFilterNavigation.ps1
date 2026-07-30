$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$files = [ordered]@{
    'main\screens\Home\scr_Home_1.pa.yaml' = 5
    'power-platform\solutions\PULSE\CanvasApps\new_pulse_9584c_src\Other\Src\scr_Home_1.pa.yaml' = 9
    'power-platform\solutions\PULSE\CanvasApps\new_pulse_9584c_src\Src\scr_Home_1.fx.yaml' = 9
}
$requiredVariables = @(
    'varPunches_ReturnView',
    'varPunches_ContextSource',
    'varPunches_FilterSource',
    'varPunchCustomFiltersJson',
    'varFilter_PunchTemplateId',
    'varFilter_PunchStatusCode',
    'varFilter_PunchCategoryCode',
    'varFilter_SubsystemsCsv',
    'varFilter_Subsystem',
    'varFilter_Subcontractor',
    'varFilter_PunchDiscipline',
    'varPunches_Page',
    'varPunches_HasSearched',
    'varPunches_AutoLoad'
)

foreach ($relativePath in $files.Keys) {
    $path = Join-Path $repoRoot $relativePath
    $text = Get-Content -Raw -LiteralPath $path
    $routes = [regex]::Matches($text, 'Navigate\(scr_Punches,\s*ScreenTransition\.None\)')

    $expectedRoutes = $files[$relativePath]
    if ($routes.Count -ne $expectedRoutes) {
        throw "$relativePath contains $($routes.Count) Home-to-Punches routes; expected $expectedRoutes."
    }

    foreach ($route in $routes) {
        $start = [Math]::Max(0, $route.Index - 4000)
        $context = $text.Substring($start, $route.Index - $start)
        foreach ($variable in $requiredVariables) {
            if (-not $context.Contains("Set($variable,")) {
                throw "$relativePath route at offset $($route.Index) does not set $variable."
            }
        }
    }

    Write-Output "PASS ${relativePath}: $expectedRoutes routes with complete filter context."
}

Write-Output 'PASS Block B Home-to-Punches navigation contract.'
