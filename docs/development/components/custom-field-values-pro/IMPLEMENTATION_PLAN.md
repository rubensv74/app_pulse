# cmp_CustomFieldValuesPro — Plan incremental

## Estado

- `VF-01` — completado como base del componente.
- `VF-02` — completado como base de renderizado de los seis tipos.
- `VF-03` — publicado; pendiente de validación en Power Apps Studio.
- `VF-03A` — corrección obligatoria de Cancel para evitar `Reset()` no validado sobre Gallery.
- `VF-04` y siguientes — bloqueados hasta validar VF-03 + VF-03A.

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

No incluye:

- working buffer;
- dirty payload;
- editores por tipo;
- flows;
- integración en Punch Review.

Gate: Studio debe aceptar el componente sin errores y el shell debe verse correctamente en un ancho aproximado de 420–600 px.

## VF-02 — Value renderers

Objetivo: convertir el cuerpo en la lista compacta de valores reales.

Tipos:

- Text;
- Number;
- Date;
- YesNo;
- Choice;
- MultiChoice.

Gate: los seis tipos muestran correctamente el valor recibido y se mantienen estables al hacer scroll.

## VF-03 — Editing + dirty state

Objetivo: incorporar edición local sin backend dentro del componente.

Incluye:

- working buffer `colCFVPro_Working`;
- baseline `colCFVPro_Base`;
- dirty tracking por `FieldKey` en `colCFVPro_Dirty`;
- outputs `EditedItems`, `DirtyItems`, `IsDirty`, `DirtyCount` y `LastChangedFieldKey`;
- editores reales para Text, Number, Date, YesNo, Choice y MultiChoice;
- eliminación automática del dirty row cuando el valor vuelve a su baseline;
- `OnValueChanged`;
- Save requested;
- Cancel requested;
- Refresh requested;
- Manage Fields requested;
- serialización MultiChoice mediante `JSON(Value, JSONFormat.Compact)`.

`AccessAppScope` está habilitado porque esta versión utiliza colecciones/variable transitorias namespaced del componente. Hasta que exista aislamiento por instancia, PULSE debe mantener una sola instancia activa de `cmp_CustomFieldValuesPro` cada vez.

El host deberá resetear la instancia del componente después de entregar una tabla `Items` autoritativa nueva. Esa orquestación se implementará y validará en VF-04; VF-03 valida primero el comportamiento interno del componente.

### VF-03A — corrección obligatoria

El primer borrador de VF-03 incluía `Reset(galCFVPro_Values)` al cancelar. El registro de compatibilidad prohíbe asumir que un control es reseteable sin validación previa. Por ello `03A_cancel_without_gallery_reset.mandatory-patch.pa.yaml` debe aplicarse inmediatamente después de VF-03 y antes de probarlo en Studio.

Cancel restaura `colCFVPro_Working` desde `colCFVPro_Base`, limpia el dirty payload y emite `OnCancelRequested`. Si algún editor concreto no refleja visualmente el baseline tras la recolección, se documentará ese control específico antes de introducir cualquier mecanismo de reset.

Gate VF-03:

- los seis editores muestran el baseline;
- una edición crea un solo dirty row por `FieldKey`;
- ediciones repetidas del mismo campo no duplican dirty rows;
- volver al baseline elimina su dirty row;
- dos campos distintos producen `DirtyCount = 2`;
- Cancel deja `DirtyCount = 0` y recupera visualmente el baseline;
- Save requested no borra dirty state por sí mismo;
- MultiChoice produce un `ValueJson` válido;
- `CanEdit=false` y `IsEditable=false` dejan los editores en lectura;
- no aparecen errores Source Code ni de fórmula.

## VF-04 — Punch Review integration

Objetivo: sustituir el bloque visual actual de Custom Fields por una instancia de `cmp_CustomFieldValuesPro`.

Se mantienen los servicios host existentes y el Dirty Guard del Bloque 13.

VF-04 será responsable de sincronizar:

- `colPunchReviewFieldsUI` -> `Items`;
- `DirtyItems` -> `colPunchReviewFieldsDirty`;
- `IsDirty` -> `varPunchReviewDirty` y `colPunchReviewQueue.IsDirty`;
- `OnSaveRequested` -> `btnPR_SaveCustomFields`;
- `OnRefresh` -> `btnPR_LoadCustomFields`;
- `OnCancelRequested` -> restauración host;
- `OnManageFieldsRequested` -> futura apertura del editor de definiciones;
- reset/rebase del componente después de load/save/cambio de Punch.

Gate: Load / edit / Save / Cancel / cambio de Punch funcionan con datos reales y el Dirty Guard no tiene regresiones.

## VF-05 — Visual polish

Objetivo: ajustar la columna derecha completa de Punch Review.

Incluye:

- densidad;
- altura del panel;
- scroll;
- alineación con Comments;
- Review Progress;
- responsive 1366×768, 1600×900 y 1920×1080.

Gate: sin clipping ni solapamientos y con jerarquía visual coherente.

## Política

No se redacta el siguiente YAML si el actual falla en Studio. Todo nuevo error se registra en `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` antes de continuar.
