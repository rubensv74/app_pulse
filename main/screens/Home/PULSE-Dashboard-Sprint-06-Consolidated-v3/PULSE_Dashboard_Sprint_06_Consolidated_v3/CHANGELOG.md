# Changelog

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
