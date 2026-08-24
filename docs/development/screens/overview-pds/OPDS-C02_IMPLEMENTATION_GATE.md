# OPDS-C02 — paquete de implementación hasta el gate de runtime

## Decisión autorizada

Cuando existe configuración publicada pero todavía no existe un snapshot de Overview,
Pulse mostrará el estado explícito `SNAPSHOT_REQUIRED`. La generación continuará siendo
una acción consciente del usuario; no se ejecutará automáticamente cada vez que se abre
la pantalla.

## Capability Card

**Capability:** OPDS-C02 — report snapshot workspace  
**Objective:** cargar y actualizar Overview con estados reales, exclusivos y explicables.  
**Risk:** C para el cambio contractual SQL/Flow; B para el binding de la pantalla.  
**Scope:** contrato SQL v2, payload del flow, estado local OPDS y superficies conectadas.  
**Dependencies:** `ReportConfigVersion`, tablas `OverviewSnapshot*`, dos flows existentes y `scr_Overview_PDS`.  
**Acceptance:** `NO_CONFIGURATION`, `SNAPSHOT_REQUIRED`, `NO_DATA`, `READY` y `ERROR` activan una sola superficie; un filtro vacío no se confunde con ausencia global de datos.  
**Validation:** SQL no destructivo, ejecución real del flow y una validación agrupada en Studio.  
**Representative data:** un proyecto real por estado cuando esté disponible.  
**Manual validation budget:** 1 normal + 1 FIX consolidado.  
**Gate:** aplicar el contrato en Development y proporcionar los resultados reales antes de afirmar `DATA_CONNECTED` o `RUNTIME_PROVEN`.

## Orden de aplicación

1. Ejecutar `001_alter_usp_GetOverviewSnapshot_v2.sql` en Development.
2. Sustituir la expresión de `cmpPayload` usando `003_power_automate_cmpPayload_v2.txt`.
3. Guardar el flow y ejecutar una prueba con un proyecto conocido.
4. Confirmar que `result` contiene `statusCode`, `hasPublishedConfig` y `hasSnapshot`.
5. Aplicar después el bloque acumulativo de Power Apps preparado para C02.
6. Validar los cinco estados en una sola sesión de Studio/runtime.

## Resultado esperado del productor

```json
{
  "statusCode": "SNAPSHOT_REQUIRED",
  "hasPublishedConfig": true,
  "publishedVersionId": 123,
  "publishedVersionNo": 4,
  "hasSnapshot": false,
  "subsystems": [],
  "headers": [],
  "metrics": [],
  "totalCount": 0,
  "generatedOn": ""
}
```

## Regla importante sobre filtros

Un proyecto `READY` puede devolver cero subsistemas para un filtro concreto. Eso es
`NO_RESULTS`, un estado de interacción local, y no cambia el `statusCode` global del
proyecto a `NO_DATA`. El procedimiento calcula el estado global antes de aplicar el
filtro.

## Rollback

- SQL: volver a aplicar la definición anterior archivada en el catálogo del esquema.
- Flow: restaurar la expresión anterior de `cmpPayload`; los parámetros y la salida
  pública no cambian.
- Power Apps: conservar `scr_Overview` como ruta operativa y no promover
  `scr_Overview_PDS` hasta completar las pruebas.

## Estado de validación

| Criterio obligatorio | Resultado actual | Motivo |
|---|---|---|
| Contrato diseñado desde persistencia real | `PASS` | Inspección de tablas y procedimientos |
| Script SQL estructuralmente preparado | `PASS` | Revisión estática; no equivale a ejecución |
| Expresión del flow preparada | `PASS` | Conserva trigger, parámetros y salida |
| SQL aplicado en Development | `NOT_RUN` | Requiere ejecución en el entorno |
| Flow guardado y probado | `GATED` | Depende del cambio SQL aplicado |
| Pantalla conectada y aceptada por Studio | `GATED` | Depende del payload real v2 |
| Cinco estados reproducidos | `GATED` | Depende del productor desplegado y de casos reales |

El paquete está preparado, pero no está desplegado ni validado en runtime.
