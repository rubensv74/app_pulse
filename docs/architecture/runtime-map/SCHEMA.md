# Contrato del mapa runtime

Tipos de nodo: `app`, `screen`, `component`, `flow`, `stored_procedure`, `table`, `connector`.

Relaciones: `CALLS`, `EXECUTES`, `READS`, `WRITES`, `NAVIGATES_TO`, `USES_CONNECTOR`.

Confianza:

- `observed`: aparece directamente en el source exportado.
- `derived`: se obtiene mediante análisis estático de una definición.
- `manual`: añadido y revisado por una persona.

Una ausencia de relación observada no demuestra ausencia de uso en runtime.
