# C16-FIX2 — Guía de validación de `cmp_ReviewProgressPro`

## Clasificación

`C — Component / FIX`

## Motivo del cambio

La prueba en Power Apps Studio confirma que modificar `DonutThickness` en `cmp_DonutPro` no produce un cambio visual suficiente, ni en la instancia de Punch Review ni en la propia definición del componente.

No se continuará reparando `cmp_DonutPro` para este caso compacto. Ese componente queda preservado para sus usos actuales.

Para Punch Review se crea un componente específico: `cmp_ReviewProgressPro`.

## Objetivo

Reproducir el patrón visual aprobado para Review Progress:

- donut compacto y claramente grueso;
- total en el centro;
- Reviewed in Session con valor y porcentaje;
- Remaining con valor y porcentaje;
- Current Position;
- estados ready / loading / empty / error;
- sin Flow ni SQL.

## Elementos congelados que NO deben modificarse

- `conPR_RightColumn`;
- Comments;
- Custom Fields;
- Review Queue;
- Punch Overview;
- Session Activity;
- navegación y cabecera;
- backend de Punch Review;
- `cmp_DonutPro`.

## Paso 1 — Crear el componente

Abre el archivo:

`docs/development/components/review-progress-pro/blocks/C16-FIX2_review_progress_component.pa.yaml`

Crea/importa el componente completo `cmp_ReviewProgressPro` en Power Apps Studio.

No lo insertes todavía en `scr_PunchReview`.

## Paso 2 — Validación aislada

Inserta temporalmente una instancia en una pantalla de prueba.

El componente incluye valores de demostración por defecto:

- TotalCount = 48
- ReviewedCount = 18
- CurrentPosition = 12

El resultado esperado es:

- donut con aro claramente más grueso que `cmp_DonutPro`;
- centro: `48` / `TOTAL`;
- Reviewed in Session: `18 (38%)` aproximadamente;
- Remaining: `30 (63%)` aproximadamente;
- Current Position: `12 of 48`.

## Paso 3 — Probar comportamiento

Cambia los inputs de la instancia:

### Caso A

- TotalCount = 5
- ReviewedCount = 2
- CurrentPosition = 2

Esperado:

- Reviewed = 2 (40%)
- Remaining = 3 (60%)
- Current Position = 2 of 5

### Caso B

- TotalCount = 5
- ReviewedCount = 5
- CurrentPosition = 5

Esperado:

- donut completamente azul;
- Reviewed = 5 (100%)
- Remaining = 0 (0%).

### Caso C

- TotalCount = 0
- State = "empty"

Esperado:

- desaparece el donut;
- aparece el mensaje de estado vacío.

### Caso D

- State = "error"

Esperado:

- aparece `Review progress unavailable.`

## Decisión técnica

Este componente no expone `DonutThickness`.

El grosor premium está fijado deliberadamente dentro del componente porque Review Progress tiene una geometría compacta y conocida. De esta forma no dependemos del comportamiento visual inconsistente observado en el donut universal.

El color continúa gobernado mediante propiedades semánticas/HEX y puede ajustarse posteriormente sin reabrir estructura o comportamiento.

## Gate

Si Studio acepta `cmp_ReviewProgressPro` y el resultado visual es correcto, confirmar:

`C16-FIX2 integrado sin errores.`

Después se preparará el bloque de integración que sustituirá únicamente el actual panel `conPR_ReviewProgressCard` por una instancia de `cmp_ReviewProgressPro` conectada a `colPunchReviewQueue` y `varPunchReviewCurrentIndex`.

Tras esa validación se podrá continuar con DF-05.
