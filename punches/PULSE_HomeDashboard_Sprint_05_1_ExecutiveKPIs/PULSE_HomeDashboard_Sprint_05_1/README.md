# PULSE Home Dashboard — Sprint 05.1

## Vertical funcional

**Executive KPIs**

Este ZIP es instalable sobre el Sprint 04 y contiene todos los cambios de la vertical:

- SQL Bundle actualizado.
- Contrato de datos 2.1.
- Guía de Flow.
- Pantalla Home completa.
- KPIs con valor actual, comparación, delta porcentual y tendencia.

## Orden de integración

1. Ejecutar `PULSE_PunchDashboard_Sprint_05_1_ExecutiveKPIs.sql`.
2. Confirmar que el Flow sigue devolviendo la columna `result`.
3. Sustituir Home por `scr_Home_1_Sprint05_1_ExecutiveKPIs.pa.yaml`.
4. Generar al menos dos snapshots del mismo proyecto y template.
5. Validar las tendencias de las tarjetas KPI.

## Compatibilidad

- No requiere tablas nuevas.
- No cambia la firma del Flow.
- Conserva todos los nodos JSON del Sprint 04.
- Si solo existe un snapshot, las tendencias se muestran neutrales.
