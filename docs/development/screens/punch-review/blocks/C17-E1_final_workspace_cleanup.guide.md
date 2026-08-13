# C17-E1 — Final workspace cleanup

Estado: READY FOR STUDIO

Objetivo: cerrar residuos visuales y de navegación de la recomposición C17 sin cambiar backend ni geometría aprobada.

## Cambios

1. `conPR_QueueScopeContext`: retirar este bloque del header. `varPunchReviewQueueScope` permanece como metadata de sesión.
2. `conPR_RelatedCard`: retirar este bloque del workspace porque ya no forma parte de la composición aprobada.
3. `conPR_CustomFieldsHost`: quitar las coordenadas residuales `X` y `Y`; su posición la gobierna `conPR_CollaborationRow`.
4. `conPR_RightColumn`: quitar la coordenada residual `X`; su posición la gobierna `conPR_UpperGrid`.
5. `btnPR_Back.Text`: hacerlo contextual según `varPunchReviewSource`: Home -> `Back to Home`; Punches -> `Back to Punch List`; otro -> `Back`. No cambiar su `OnSelect` ni el Dirty Guard.
6. Session Activity: normalizar nuevos eventos de guardado de Custom Fields a `FIELDS_SAVED` y mantener compatibilidad visual temporal con `CUSTOM_FIELDS_SAVED`.
7. Help ES/EN: actualizar la ayuda para reflejar que Review Progress y Dirty Guard ya están implementados, Related ya no forma parte del workspace y la acción de Custom Fields se denomina `Cancel`.

## No tocar

Template heredado, Review Queue, Comments, `cmp_CustomFieldValuesPro`, Review Progress, Session Activity geometry, DF-05/DF-06, flows host, Dirty Guard y modal de definiciones.

## Validación

- entrada desde Home: label `Back to Home` y retorno correcto;
- entrada desde Punch List: label `Back to Punch List` y retorno correcto;
- header sin Queue Scope;
- workspace sin Related;
- geometría central y rail sin cambios;
- Custom Fields Save visible correctamente en Session Activity;
- Help ES/EN actualizado;
- cero errores nuevos de Studio.

Después de este gate: C17-E2 Responsive + final Visual QA.