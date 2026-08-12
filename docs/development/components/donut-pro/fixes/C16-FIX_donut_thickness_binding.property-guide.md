# C16-FIX — Vinculación del grosor del donut en Punch Review

## Clasificación

`C — Component / FIX`

## Problema

En la tarjeta `Review Progress` de Punch Review, cambiar `cmpPR_ReviewProgressDonut.DonutThickness` en la instancia del componente no produce el cambio visual esperado.

El código canónico actual de `cmp_DonutPro` **sí** vincula `DonutThickness` a los dos trazos SVG de `imgDNP_Donut.Image`:

- grosor del track de fondo (`stroke-width`);
- grosor de cada segmento de datos (`stroke-width`).

Por tanto, la primera reparación consiste en sincronizar la fórmula `imgDNP_Donut.Image` del componente activo con la versión canónica del repositorio antes de rediseñar geometría o modificar controles no relacionados.

## Objetivo

Definición del componente:

`cmp_DonutPro > conDNP_Root > imgDNP_Donut`

Propiedad:

`Image`

## Operación

Reemplazar la fórmula completa de `Image` por la fórmula almacenada en:

`C16-FIX_imgDNP_Donut.Image.powerfx`

Archivo directo en el repositorio:

`docs/development/components/donut-pro/fixes/C16-FIX_imgDNP_Donut.Image.powerfx`

## Dependencias

- `cmp_DonutPro` ya existe en la aplicación activa.
- `cmpPR_ReviewProgressDonut` ya existe en Punch Review.
- No se introduce ninguna instancia nueva de componente.

## Modifica

- Únicamente `cmp_DonutPro.imgDNP_Donut.Image`.

## No modificar

- geometría de Punch Review;
- `conPR_ReviewProgressCard`;
- Comments;
- Custom Fields;
- Review Queue;
- CustomProperties del componente;
- contrato de `Items`;
- colores;
- backend.

## Por qué este es el primer FIX correcto

La implementación del repositorio ya utiliza `cmp_DonutPro.DonutThickness` tanto para el track como para los segmentos. Si la instancia activa no reacciona a esa propiedad, primero hay que alinear la definición del componente de la aplicación activa con la fórmula canónica conocida. Así evitamos introducir un modelo de renderizado nuevo antes de comprobar que el contrato existente funciona como está diseñado.

## Validación

Después de reemplazar la fórmula:

1. Volver a `scr_PunchReview`.
2. Seleccionar `cmpPR_ReviewProgressDonut`.
3. Establecer `DonutThickness = 8` y observar el anillo.
4. Establecer `DonutThickness = 20` y volver a observarlo.
5. La diferencia debe ser claramente visible sin modificar `Width` ni `Height`.
6. Restaurar después el valor preferido; para la tarjeta compacta actual de Review Progress comenzar con `18`.
7. Confirmar que los valores Reviewed/Remaining siguen actualizándose correctamente.
8. Confirmar que no se ha alterado ningún otro comportamiento de `cmp_DonutPro`.

## Gate

Si después de sincronizar esta fórmula sigue sin existir una diferencia visual entre `8` y `20`, detenerse. No continuar todavía con DF-05. La siguiente reparación deberá aislarse como un FIX específico del escalado/renderizado SVG a ancho compacto; no se debe modificar la estructura ni el color de Punch Review para compensarlo.

## Estado esperado después de validar

`C16 — FUNCTIONAL_FROZEN`

El color puede permanecer en estado `PENDING` de forma independiente.
