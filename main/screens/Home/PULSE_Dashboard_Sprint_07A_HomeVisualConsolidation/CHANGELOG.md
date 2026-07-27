# Changelog

## Sprint 07A — Home Visual Consolidation

### Objective
- Consolidate the Home header into one compact executive bar without altering dashboard data loading, Flow calls, or SQL contracts.

### Changed
- Removed the redundant standalone `Home` header container and label.
- Moved `Executive Dashboard` and its contextual subtitle into the existing top bar.
- Added `AutoHeight` only to the two compatible `ModernText` controls in the consolidated header.
- Converted the top bar into a bordered surface aligned with the dashboard cards.
- Reduced the dashboard selector bar height after removing its duplicated title and subtitle.
- Repositioned the Punches and Tasks selectors vertically to preserve alignment in the reduced bar.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Source YAML structure loaded successfully with PyYAML `BaseLoader`, preserving Power Apps formula tags as scalar content.
- Control-name uniqueness verified across the complete screen source.
- Removed control references checked: `conView_Home_Header_1`, `lblHomeTitle_1`, `lblHomeDashboardTabsTitle`, and `lblHomeDashboardTabsSubtitle` are absent.
- Existing Flow call and SQL contract references remain byte-identical outside the localized visual section.

### Limitations
- Power Apps Studio import/compile was not available in the execution environment; validation is static.

### Open issues
- None identified within Sprint 07A scope.

## Sprint 06 — Consolidated Dashboard v3

### Added
- Nodo JSON `insights` en `warroom.usp_GetPunchDashboardBundle`.
- Generación determinista de señales sobre tendencia Open, tendencia Closed, hotspot, TOP Code y subcontractor.
- Colección Power Apps `colPunchDashboardInsights`.
- Tarjeta `conPunchExecutiveInsightsCard` con prioridad, severidad, métrica y drill-through.
- Contrato de datos 3.0 y guía de integración del Flow.

### Changed
- El procedimiento declara `contractVersion` y `DataVersion` como `3.0`.
- La pantalla limpia timeline e insights al recargar y al cambiar de proyecto.
- La tendencia del timeline usa los tokens existentes `varTheme_Green` y `varTheme_Red`.
