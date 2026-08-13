# C17-E — Cleanup + Responsive + Visual QA

Estado: READY FOR FINAL STUDIO PASS
Pantalla: scr_PunchReview
Fecha: 2026-08-13

## Fuente revisada

Se ha revisado el Source Code completo actual exportado desde Power Apps Studio el 2026-08-13, junto con el Source Code actual de `cmp_CustomFieldValuesPro`.

La evidencia confirma:

- template heredado correctamente desde Home;
- Queue Scope oculto;
- Comments y Custom Fields en el workspace central;
- Review Progress y Session Activity en el rail derecho;
- rail derecho sin clipping;
- Choice/MultiChoice ya modernizados;
- Number con apariencia Outline.

## Pre-gate C17-D-FIX1

Antes del cleanup final debe cerrarse un defecto funcional detectado en el componente de valores:

- `galCFVPro_Values.OnSelect` no debe ejecutar una cancelación del borrador;
- `cmbCFVPro_Choice` debe usar la misma política read-only/edit que Text, Number, Date y YesNo;
- el comportamiento searchable del ModernCombobox debe quedar explícito.

Referencia: `C17-D-FIX1_custom_field_renderer_safety.md`.

## Cleanup estructural de pantalla

Después de validar C17-D-FIX1:

- retirar del header `conPR_QueueScopeContext`; conservar `varPunchReviewQueueScope` únicamente como metadata interna de sesión;
- retirar físicamente `conPR_RelatedCard`, ya fuera de la arquitectura aprobada;
- limpiar `X/Y` residuales de `conPR_CustomFieldsHost`, gobernado por el AutoLayout de `conPR_CollaborationRow`;
- limpiar `X` residual de `conPR_RightColumn`, gobernado por `conPR_UpperGrid`;
- mantener Width, Height, LayoutMinWidth, LayoutMinHeight, FillPortions y el breakpoint de 1320 px que forman parte del width budget validado.

## Navegación contextual

`btnPR_Back` conserva su Dirty Guard y el comportamiento `Back()`.

Solo cambia el texto visible:

- origen Home -> `Back to Home`;
- origen Punch List -> `Back to Punch List`;
- otro origen -> `Back`.

## Session Activity

Existe una inconsistencia nominal entre el evento generado al guardar Custom Fields (`CUSTOM_FIELDS_SAVED`) y el tipo visual esperado por Session Activity (`FIELDS_SAVED`).

C17-E debe normalizar nuevos eventos a `FIELDS_SAVED` y mantener compatibilidad visual temporal con ambos valores para no perder el estilo de eventos ya creados durante una sesión.

## Help bilingüe

Actualizar el contenido obsoleto del modal de ayuda:

- Review Progress ya está implementado;
- Related ya no forma parte del workspace;
- Dirty Guard ya está implementado;
- Custom Fields usa `Cancel`, no el antiguo término `Reset`;
- Reviewed permanece session-only y no modifica el estado operativo real del Punch.

## Responsive QA

Validar al menos:

- 1366 x 768;
- 1600 x 900;
- 1920 x 1080.

En cada tamaño comprobar Review Queue, workspace dominante, rail completo, ausencia de scroll horizontal global, Comments composer, Custom Fields footer, Review Progress y Session Activity.

## Custom Fields QA

Probar Text, Number, Date, YesNo, Choice y MultiChoice con valores vacíos/existentes, dirty add/revert, Save, Cancel, scroll de Gallery y retorno a la fila.

## Review Progress QA

Probar 0%, porcentaje parcial y 100% reviewed.

## Session Activity QA

Probar vacío, un evento, varios eventos, texto largo y scroll cuando aplique.

## Queue QA

Probar cola vacía, una fila, cola larga, search, All/Remaining/Reviewed y selección primero/intermedio/último.

## Navigation QA

Validar entrada y salida desde Home y Punch List. El label Back debe describir el origen real y el Dirty Guard debe permanecer operativo.

## Gate de cierre C17

STRUCTURE PASS
SOURCE REVIEW PASS
MAIN WIDTH PASS
RIGHT RAIL PASS
COMMENTS PASS
CUSTOM VALUES PASS
REVIEW PROGRESS PASS
SESSION ACTIVITY PASS
QUEUE PASS
RESPONSIVE PASS
WIDTH BUDGET PASS
NO GLOBAL CLIPPING PASS
NO NEW FORMULA ERRORS PASS

Solo después de este gate C17 puede marcarse CLOSED y reanudarse DF-07B.