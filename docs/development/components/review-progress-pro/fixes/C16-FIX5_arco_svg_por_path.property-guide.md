# C16-FIX5 — Corregir el arco del donut mediante un path SVG

## Clasificación

`C — Component / FIX`

## Problema observado

Tras C16-FIX4, los textos del componente ya muestran correctamente los porcentajes, por ejemplo:

- Reviewed in Session: `1 (20%)`
- Remaining: `4 (80%)`

Sin embargo, el donut sigue apareciendo prácticamente completo en azul.

Esto demuestra que el problema ya no está en los datos ni en los porcentajes. El fallo está en la forma en que el renderer de Power Apps interpreta `stroke-dasharray` dentro del SVG del componente.

## Decisión

Dejamos de usar `stroke-dasharray` para construir el segmento revisado.

C16-FIX5 dibuja:

1. un círculo gris completo como track;
2. un `path` SVG real para el arco azul;
3. el centro blanco y el total por encima.

El arco azul se calcula geométricamente a partir del porcentaje revisado.

## Target

Componente:

`cmp_ReviewProgressPro`

Control:

`conRPP_Root → imgRPP_Donut`

Propiedad:

`Image`

## Operación

Sustituir **solo** la propiedad `Image` por la fórmula completa contenida en:

`docs/development/components/review-progress-pro/fixes/C16-FIX5_imgRPP_Donut.Image.powerfx`

Enlace directo:

https://github.com/rubensv74/app_pulse/blob/main/docs/development/components/review-progress-pro/fixes/C16-FIX5_imgRPP_Donut.Image.powerfx

## No modificar

- `cmpPR_ReviewProgress` en la pantalla;
- `conPR_ReviewProgressCard`;
- TotalCount;
- ReviewedCount;
- CurrentPosition;
- labels de porcentajes;
- Comments;
- Custom Fields;
- layout de Punch Review;
- colores globales.

## Validación

Probar estos valores directamente en una instancia de `cmp_ReviewProgressPro`:

### Caso A

- TotalCount = 5
- ReviewedCount = 1

Resultado esperado:

- azul ≈ 20%;
- gris ≈ 80%;
- texto `1 (20%)`;
- texto `4 (80%)`.

### Caso B

- TotalCount = 5
- ReviewedCount = 2

Resultado esperado:

- azul ≈ 40%;
- gris ≈ 60%.

### Caso C

- TotalCount = 5
- ReviewedCount = 5

Resultado esperado:

- donut completamente azul.

### Caso D

- TotalCount = 5
- ReviewedCount = 0

Resultado esperado:

- donut completamente gris.

## Estado esperado

Si los cuatro casos se representan correctamente:

`C16 = FINAL_FROZEN`

La capa cromática continúa gobernada independientemente por el Design System.