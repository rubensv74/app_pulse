#!/usr/bin/env bash
set -euo pipefail

screen="${1:-power-apps/screens/Overview/scr_Overview.pa.yaml}"

test -f "$screen"

grep -Fq '"Overview could not be loaded"' "$screen"
grep -Fq '"Overview is not configured for this project"' "$screen"
grep -Fq '"No report data is available"' "$screen"
grep -Fq '"no published report configuration" in Lower(varPHR_LastErrorMessage)' "$screen"
grep -Fq 'Set(varOverviewNoData, false);' "$screen"
grep -Fq 'Warroom_GetOverviewSnapshot.Run(' "$screen"
grep -Fq 'warroom_GenerateOverviewSnapshot.Run(' "$screen"
grep -Fq 'Navigate(scr_Tasks, ScreenTransition.None);' "$screen"
grep -Fq 'Navigate(scr_Punches, ScreenTransition.None);' "$screen"

if grep -Fq 'Set(varOverviewNoConfig, true);' "$screen"; then
    echo "Unexpected unconditional no-configuration classification remains." >&2
    exit 1
fi

echo "OVR-01 static source checks passed."
