# cmp_CustomFieldValuesPro — Plan incremental

## Estado

- `VF-01` — completado como base del componente.
- `VF-02` — completado como base de renderizado de los seis tipos.
- `VF-03` — completado como base de edición + dirty state; requiere VF-03A aplicada.
- `VF-03A` — corrección obligatoria de Cancel para evitar `Reset()` no validado sobre Gallery.
- `VF-04` — publicado; pendiente de validación en Punch Review con un Punch real.
- `VF-04A` — patch obligatorio para rebase del componente cuando la cola queda vacía.
- `VF-05` — bloqueado hasta validar VF-04 + VF-04A.

## VF-01 — Component shell

Objetivo: validar la definición del nuevo componente y su shell compacto antes de introducir editores o estado local complejo.

Incluye:

- definición `CanvasComponent`;
- contrato inicial `Items`;
- título y contexto del Punch;
- estado visual Ready / Empty / Loading / Saving / Error / Unsaved;
- acción Refresh;
- acción Manage Fields;
- footer visual Cancel / Save preparado para fases posteriores;
- outputs simples `HasFields` y `FieldCount`.

No incluye working buffer, dirty payload, editores, flows ni integración en Punch Review.

## VF-02 — Value renderers

Objetivo: convertir el cuerpo en la lista compacta de valores reales para Text, Number, Date, YesNo, Choice y MultiChoice.

## VF-03 — Editing + dirty state

Objetivo: incorporar edición local sin backend dentro del componente.

Incluye:

- working buffer `colCFVPro_Working`;
- baseline `colCFVPro_Base`;
- dirty tracking por `FieldKey` en `colCFVPro_Dirty`;
- outputs `EditedItems`, `DirtyItems`, `IsDirty`, `DirtyCount` y `LastChangedFieldKey`;
- editores reales para los seis tipos;
- eliminación automática del dirty row al volver al baseline;
- `OnValueChanged`, Save, Cancel, Refresh y Manage Fields requested;
- serialización MultiChoice con `JSON(Value, JSONFormat.Compact)`.

`AccessAppScope` está habilitado porque esta versión utiliza colecciones/variable transitorias namespaced del componente. Hasta que exista aislamiento por instancia, PULSE debe mantener una sola instancia activa de `cmp_CustomFieldValuesPro` cada vez.

### VF-03A — corrección obligatoria

`03A_cancel_without_gallery_reset.mandatory-patch.pa.yaml` elimina el `Reset(galCFVPro_Values)` del primer borrador. Cancel restaura el working buffer desde el baseline, limpia dirty state y emite `OnCancelRequested`.

## VF-04 — Punch Review integration

Archivo principal:

`04_punch_review_integration.replace-control.pa.yaml`

Objetivo: sustituir el bloque visual actual `conPR_CustomFieldsCard` por un host ligero que conserva los servicios de pantalla e instala una instancia productiva `cmpPR_CustomFieldValues`.

Responsabilidades integradas:

- `colPunchReviewFieldsUI` -> `cmpPR_CustomFieldValues.Items`;
- `cmpPR_CustomFieldValues.EditedItems` -> `colPunchReviewFieldsUI`;
- `cmpPR_CustomFieldValues.DirtyItems` -> `colPunchReviewFieldsDirty`;
- `cmpPR_CustomFieldValues.IsDirty` -> `varPunchReviewDirty` y `colPunchReviewQueue.IsDirty`;
- `OnSaveRequested` -> `btnPR_SaveCustomFields`;
- `OnRefresh` -> `btnPR_LoadCustomFields`;
- `OnCancelRequested` -> limpieza de host dirty state y restauración del baseline interno;
- `OnManageFieldsRequested` -> mensaje temporal hasta la fase DF;
- load/save autoritativos -> `Reset(cmpPR_CustomFieldValues)` para rebase desde la tabla de servidor.

Se mantienen sin cambios de contrato:

- `WarRoom_GetCustomBundle`;
- `WarRoom_SaveCustomBulk`;
- `colPunchReviewFieldsUI`;
- `colPunchReviewFieldsBase`;
- `colPunchReviewFieldsDirty`;
- `varPunchReviewDirty`;
- Block 13 Dirty Guard.

### VF-04A — empty queue rebase

`04A_empty_queue_component_rebase.incremental-patch.powerfx` añade `Reset(cmpPR_CustomFieldValues)` a la rama de cola vacía de `btnPR_SelectCurrent.OnSelect`.

Es necesario porque el componente mantiene working/base internos. Limpiar únicamente las colecciones host no garantiza que desaparezca visualmente el último Punch si la cola queda vacía.

Gate VF-04:

- seleccionar Punch real carga valores;
- la instancia muestra el mismo bundle que el host;
- editar cambia el estado a Unsaved y activa el Dirty Guard;
- Cancel recupera el baseline y deja `varPunchReviewDirty=false`;
- Save utiliza el servicio real y rebasa desde el bundle devuelto por servidor;
- un fallo de Save conserva el dirty state;
- cambiar de Punch después de Save/Discard carga y rebasa correctamente;
- cola vacía muestra Empty sin valores residuales;
- manager edita; otros roles ven solo lectura;
- no aparecen errores Source Code, propiedades no soportadas o fórmulas inválidas.

## VF-05 — Visual polish

Objetivo: ajustar la columna derecha completa de Punch Review.

Incluye densidad, altura, scroll, alineación con Comments y Review Progress, y responsive 1366×768, 1600×900 y 1920×1080.

Gate: sin clipping ni solapamientos y con jerarquía visual coherente.

## Política

No se redacta el siguiente YAML si el actual falla en Studio. Todo nuevo error se registra en `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` antes de continuar.
