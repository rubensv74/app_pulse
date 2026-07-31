# EPIC 02 — Executive Layout

Status: **IMPLEMENTED — PENDING INTEGRATION VALIDATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Objective delivered

Constructed the canonical Executive Dashboard layout inside `Home_1` without introducing business logic:

- five equal KPI slots;
- analytical workspace with a 70% Heatmap area;
- 30% right column with Donut above Selected Cell Details;
- full-width Punch Grid workspace;
- existing header, template selector, loading/state layers, Flow, collections, and navigation preserved.

## Modified Canvas controls

Created:

- `conPunchExecutiveKpiStrip` with five equal KPI containers and canonical titles;
- `conPunchExecutiveAnalyticsWorkspace`;
- `conPunchExecutiveHeatmapSlot`;
- `conPunchExecutiveRightColumn`;
- `conPunchExecutiveDonutSlot`;
- `conPunchExecutiveDetailSlot`;
- `conPunchExecutiveGridWorkspace`;
- presentation-only title/state labels within those containers.

Changed in place:

- `conPunchKpiSection.Visible = false`;
- `conPunchMatrixCard.Visible = false`.

Existing KPI and matrix controls remain intact for functional reconnection in later EPICs.

## Layout contract

| Zone | Implementation |
|---|---|
| Header | Existing `conPunchDashboardContext`, unchanged |
| KPI strip | Five cards, equal width `(Parent.Width - 48) / 5`, 12 px gaps |
| Analytics | 420 px layout band, proportional width |
| Heatmap | `(Parent.Width - 12) * 0.7` |
| Right column | `(Parent.Width - 12) * 0.3` |
| Donut / Details | 56% / 44% height with 12 px gap |
| Grid | Full width, 292 px foundation slot |

## Intentional neutral state

KPI values display `—`, and Heatmap/Donut/Grid areas display EPIC handoff labels. The current Dashboard Bundle contract does not expose confirmed fields for Overdue Punches and This Week Closed. EPIC 02 does not invent calculations or add backend queries. Functional bindings belong to their respective later EPICs or require an accepted data-contract extension.

## Repository validation

| Check | Evidence | Result |
|---|---|---|
| YAML diff hygiene | `git diff --check` | PASS |
| Control identity | 263 named controls, 0 duplicates | PASS |
| Major layout controls | Seven expected controls, each exactly once | PASS |
| Dashboard Bundle calls | 1 before / 1 after | PASS |
| Navigation calls | 22 before / 22 after | PASS |
| Flow/SQL/component/other-screen changes | None | PASS |
| Pre-change SHA-256 | `D8CE52CF2DBFF43846F983A3BB05EDED826572F5E84E0339AF83A29AE8219163` | RECORDED |
| Post-change SHA-256 | `AB6172F599F95EBCF39E3CC6DCCCECA6B9BA4FE82656E45C375821C11A5D4B27` | RECORDED |

## Product Owner integration validation

Include in the next periodic integration cycle:

- Studio compilation and control support;
- no grey screen or overlay regression;
- five cards align at 1920×1080, 1600×900, 1440×900, and 1366×768;
- no horizontal scrolling;
- Heatmap remains visually dominant;
- Donut and Detail remain vertically stacked;
- grid spans the complete dashboard width;
- hidden legacy KPI/matrix blocks consume no layout space;
- project, template, refresh, loading, empty/error states, and navigation remain operational.

These checks do not block repository progression under the Autonomous EPIC Execution policy.

## Risks and technical debt

- KPI business fields for Overdue and This Week Closed are not confirmed in the current payload.
- Layout uses neutral handoff content until EPICs 03–05 bind functional components.
- Runtime responsive behaviour cannot be proven statically.
- The packaged `.msapp` is unchanged; packaging remains outside this EPIC.

## Rollback

Revert the EPIC 02 commit. This removes the new layout controls and restores visibility of the existing KPI and matrix presentations. EPIC 01 and the restored baseline remain intact.

## Next EPIC

EPIC 03 — Executive Heatmap: bind the existing matrix collection to the approved Subsystem × Category matrix, totals, colour scale, selection, and synchronization state without direct Flow execution.
