# cmp_CustomFieldValuesPro — Plan incremental

## Estado

- `VF-01` — publicado; pendiente de validación en Power Apps Studio.
- `VF-02` y siguientes — bloqueados hasta validar VF-01 en Power Apps Studio.

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

- working buffer;
- dirty tracking por `FieldKey`;
- `DirtyItems`;
- `IsDirty`;
- `DirtyCount`;
- Save requested;
- Cancel/Reset requested;
- Refresh requested;
- Manage Fields requested.

Gate: una edición produce un único dirty row por FieldKey y Cancel restaura el input vigente.

## VF-04 — Punch Review integration

Objetivo: sustituir el bloque visual actual de Custom Fields por una instancia de `cmp_CustomFieldValuesPro`.

Se mantienen los servicios host existentes y el Dirty Guard del Bloque 13.

Gate: Load / edit / Save / Cancel / cambio de Punch funcionan con datos reales.

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
