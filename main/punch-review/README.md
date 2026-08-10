# Fase 7 — Punch Review Workspace

Esta carpeta contiene los bloques incrementales para construir `scr_PunchReview` en Power Apps Studio sin pegar una pantalla monolítica.

## Rama de publicación

Los bloques listos para utilizar se publican directamente en `main`:

```text
main/punch-review/blocks/
```

## Regla de uso

Los archivos de `blocks/` no sustituyen automáticamente los YAML canónicos de `main/screens`. Son bloques controlados para copiar en Studio o incorporar al archivo canónico después de validar cada incremento.

Cada bloque indica:

- archivo y control afectados;
- operación exacta: crear, añadir como hijo o sustituir propiedad/control;
- dependencias previas;
- prueba mínima;
- criterio de aceptación.

## Gate obligatorio antes de cualquier YAML

Antes de redactar, corregir o publicar cualquier archivo `.pa.yaml` debe consultarse primero la versión actual de:

```text
main/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
```

No se debe trabajar de memoria. Cada nuevo error confirmado se incorpora a ese archivo y se convierte en una regla preventiva para los siguientes bloques.

## Orden obligatorio y estado

1. `01_screen_shell.pa.yaml` — validado
2. `02_header_premium.children.pa.yaml` — validado
3. `03_workspace_layout.children.pa.yaml` — validado
4. `04_runtime_state.onvisible.pa.yaml` — validado tras corrección tipada
5. `05_review_queue.replace-control.pa.yaml` — validado
6. `05A_review_queue_test_seed.optional.powerfx` — opcional para pruebas
7. `06_punch_overview.replace-control.pa.yaml` — validado
8. `07_review_actions.replace-control.pa.yaml` — validado
9. `08_session_activity.replace-control.pa.yaml` — validado
10. `08A_help_trigger.add-child.pa.yaml` — validado tras eliminar `Reset(TabList)`
11. `08B_bilingual_help_modal.add-screen-child.pa.yaml` — validado
12. `09_comments.replace-control.pa.yaml` — integrado; validar en Studio con Punch real
13. `09A_comments_selection_hook.replace-formula.powerfx` — hook de selección de Comments
14. `09B_comments_test_seed.optional.powerfx` — opcional para pruebas visuales
15. `09C_help_comments.incremental-patch.pa.yaml` — ayuda bilingüe de Comments
16. `10_custom_fields.replace-control.pa.yaml` — integrado
17. `10A_custom_fields_selection_hook.replace-formula.powerfx` — sustituye a 09A y carga Comments + Custom Fields; incluye bloqueo temporal de cambios sin guardar
18. `10B_custom_fields_test_seed.optional.powerfx` — opcional para probar los seis tipos de campo sin flows
19. `10C_yesno_initial_state.incremental-patch.pa.yaml` — parche para vincular `Toggle.Checked` a `ValueBool`
20. `10D_help_custom_fields.incremental-patch.pa.yaml` — ayuda bilingüe de Custom Fields
21. `11_review_progress.replace-control.pa.yaml` — corregido tras PA2301; pendiente de revalidación en Studio
22. `11A_help_review_progress.incremental-patch.pa.yaml` — aplicar después de validar el Bloque 11 y después de 10D

No se debe iniciar el Bloque 12 hasta que Review Progress se importe sin errores y responda correctamente a Mark Reviewed / Undo Review.

## Contratos del Bloque 09

Carga confirmada desde la pantalla Punches:

```text
Warroom_GetTaskCommentsPaged.Run(
    ProjectId,
    RecordId,
    Page,
    PageSize,
    EntityType
)
```

Alta utilizada por la arquitectura de comentarios:

```text
Warroom_AddTaskComment.Run(
    ProjectId,
    RecordId,
    CommentHtml,
    UserEmail,
    EntityType,
    UserName,
    CommentType
)
```

La validación visual con los Punches ficticios del Bloque 05A debe realizarse mediante `09B_comments_test_seed.optional.powerfx`. La validación de flows necesita un Punch real.

## Contratos del Bloque 10

Carga de campos personalizados:

```text
WarRoom_GetCustomBundle.Run(
    ProjectId,
    EntityType,
    RecordId
).bundlejson
```

El editor utiliza `bundlejson.merged` como fuente de definiciones y valores actuales.

Guardado masivo:

```text
WarRoom_SaveCustomBulk.Run(
    ProjectId,
    EntityType,
    RecordId,
    JSON(colDirty, JSONFormat.Compact),
    UserEmail
)
```

El resultado de guardado se vuelve a materializar desde el `merged` devuelto por el servicio. Los tipos soportados son `Text`, `Number`, `YesNo`, `Date`, `Choice` y `MultiChoice`.

La edición mantiene la misma regla de permisos que el drawer existente: `manager` puede editar, guardar y restablecer; los demás roles son de solo lectura.

Hasta el Bloque 13, `10A_custom_fields_selection_hook.replace-formula.powerfx` bloquea cualquier cambio o recarga de Punch mientras existan campos personalizados sin guardar. El usuario debe usar Save o Reset antes de continuar.

## Contrato del Bloque 11

Review Progress es un indicador exclusivamente local de la sesión y se calcula directamente sobre:

```text
colPunchReviewQueue
```

Usa:

```text
IsReviewedInSession
```

para separar:

```text
Reviewed
Remaining
```

El porcentaje central se calcula como:

```text
Reviewed / Total queue
```

No utiliza flows, SQL ni la colección filtrada visible. Por diseño, cambiar entre `All`, `Remaining` y `Reviewed` no altera el porcentaje: el denominador sigue siendo la cola completa cargada.

### Corrección PR-SC-005

La primera versión del Bloque 11 intentó instanciar:

```text
cmp_DonutPro
```

como `CanvasComponent`. Power Apps Studio devolvió `PA2301` porque el componente, aunque existe como archivo en GitHub, no está instalado en la app activa.

La versión corregida de `11_review_progress.replace-control.pa.yaml` ya no depende de ningún Canvas Component. El panel es autocontenido y usa:

```text
GroupContainer@1.5.0
Image@2.2.3
Label@2.5.1
Rectangle@2.3.0
```

El donut se genera mediante SVG dentro de `Image@2.2.3`.

Representa progreso de **revisión de la sesión**, no progreso de cierre técnico del Punch.

## Manual de usuario

El manual funcional en español se mantiene en:

```text
main/punch-review/user-guide/MANUAL_USUARIO_PUNCH_REVIEW.md
```

Es un documento vivo y debe actualizarse cuando se valida una nueva función de la pantalla.

La pantalla también incorpora una ayuda resumida bilingüe mediante un modal con dos pestañas modernas:

```text
Español | English
```

## Registro de compatibilidad

Antes de crear o modificar un bloque debe revisarse:

```text
main/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
```

Reglas confirmadas:

```text
Label@2.5.1 no admite RadiusBottomLeft, RadiusBottomRight, RadiusTopLeft ni RadiusTopRight.
Classic/Button@2.2.0 no admite AccessibleLabel en el Source Code utilizado por PULSE.
TabList@2.2.30 no es reseteable mediante Reset().
Una variable numérica nueva debe recibir primero una asignación numérica inequívoca.
Toggle moderno utiliza Checked para representar el valor Boolean inicial.
Un CanvasComponent debe existir realmente en la app activa; que exista en GitHub no es suficiente.
```

Para una píldora redondeada se utiliza un `GroupContainer@1.5.0` con radios y un `Label@2.5.1` sin radios en su interior.

## Convención de nombres

- Pantalla: `scr_PunchReview`
- Controles: prefijo `PR`
- Colecciones: prefijo `colPunchReview`
- Variables: prefijo `varPunchReview`
- Controles internos de servicio: prefijo `btnPR_`

## Validación mínima por bloque

1. Consultar `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` antes de redactar o corregir YAML.
2. Ejecutar `git pull origin main`.
3. Guardar el bloque en Studio.
4. Esperar a que termine la validación de fórmulas.
5. Abrir App Checker.
6. Navegar a la pantalla.
7. Confirmar que no existen solapamientos ni referencias rotas.
8. No continuar si aparece PA1001, PA2108, PA2301, una propiedad no soportada o un error de tipo.

## Fuente de verdad

Las referencias visuales y funcionales se basan en:

- `main/screens/Home/scr_Home.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`
- `main/components/cmp_SidebarNav.pa.yaml`
- `main/components/cmp_DetailDrawer_old.pa.yaml`
- resto de componentes actualizados en `main/components/`

La existencia de un componente en `main/components/` no demuestra por sí sola que esté instalado dentro de la app activa de Power Apps Studio.
