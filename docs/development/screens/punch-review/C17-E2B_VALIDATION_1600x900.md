# C17-E2B — Validación visual y funcional 1600×900

**Estado:** READY FOR STUDIO VALIDATION  
**Pantalla:** `scr_PunchReview`  
**Objetivo:** validar el layout premium y los contratos funcionales de Punch Review en un escritorio de referencia 1600×900 sin introducir cambios de geometría salvo que aparezca una regresión demostrable.

## Principio

C17-E2B es un gate de validación, no un bloque de rediseño.

La geometría aprobada en C17-A/C17-E2A se considera congelada mientras no exista clipping, solape, pérdida de controles o una reducción de legibilidad/operabilidad en 1600×900.

## Preparación

1. Abrir PULSE en Power Apps Studio/Preview con una ventana equivalente a 1600×900.
2. Seleccionar un proyecto real.
3. Entrar a Punch Review desde Home con una queue de al menos 5 registros.
4. Usar un Punch con Custom Fields cuando sea posible.
5. Generar al menos 2 eventos en Session Activity durante la prueba.

## Gate visual

La captura completa debe demostrar simultáneamente:

- Sidebar completo y sin clipping.
- Header de Punch Review en una sola banda estable.
- Project y Punch template visibles completos o con truncado controlado, nunca superpuestos.
- Botón Back completamente visible.
- Review Queue completa en la columna izquierda.
- Área central claramente dominante en anchura.
- Punch Overview legible sin invadir el rail derecho.
- Comments y Custom Fields en dos columnas, con footer visible.
- Review Progress íntegro en el rail derecho.
- Session Activity debajo de Review Progress y sin corte lateral.
- No aparece scroll horizontal de pantalla.
- Ningún dropdown, combobox, date picker o botón queda cortado.
- Tipografía secundaria sigue siendo legible después de DF-07B-FIX1.

## Gate funcional

Validar en la misma sesión:

1. Cambiar de Punch dentro de Review Queue.
2. Marcar al menos dos Punches como Reviewed.
3. Session Activity debe conservar todos los eventos de la sesión, no solo el Punch actual.
4. Modificar un Custom Field y confirmar Dirty/Save.
5. Abrir Manage Custom Fields y cerrar sin perder el Punch actual.
6. Abrir Help y comprobar que no hay solapes en el bloque introductorio.
7. Punch Review → Open Punch List debe mostrar el Punch actual en Focus Mode.
8. Back debe regresar al mismo Punch Review con queue, reviewed marks y Session Activity intactos.
9. El template heredado debe seguir siendo el correcto después de reentrar.

## Criterios de fallo

Abrir `C17-E2B-FIX1` únicamente si aparece uno de estos defectos:

- clipping real;
- solape;
- rail derecho fuera de pantalla;
- footer Save/Cancel inaccesible;
- controles de Custom Fields recortados;
- pérdida de legibilidad significativa;
- contexto/queue/session state perdido durante navegación auxiliar.

No abrir un FIX solo por diferencias menores de whitespace o preferencias estéticas mientras la composición siga equilibrada y operativa.

## Evidencia esperada

Una captura completa de `scr_PunchReview` a 1600×900 con:

- queue visible;
- Punch actual seleccionado;
- Custom Fields visibles;
- al menos un evento en Session Activity;
- Review Progress visible completo.

Si el gate pasa, continuar con `C17-E2C — 1920×1080`.

## Criterio de cierre

`C17-E2B = VALIDATED` cuando la pantalla mantiene la jerarquía visual premium, no presenta clipping ni solapes y los contratos funcionales de sesión/navegación permanecen intactos en 1600×900.
