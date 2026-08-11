# cmp_CustomFieldEditorPro — Plan de implementación incremental

## Objetivo

Construir `cmp_CustomFieldEditorPro` por piezas pequeñas y validables antes de sustituir el bloque actual de Custom Fields en Punch Review.

Se aplica el Protocolo de Implementación Incremental Asistida y el gate PRE-YAML de Punch Review.

## Secuencia

### CF-01 — Component shell

**Objetivo:** validar que Studio acepta la nueva definición de componente, sus inputs básicos y el shell visual premium.

Incluye:

- definición `CanvasComponent`;
- contrato inicial de `Items`;
- colores y textos principales;
- cabecera;
- status pill;
- acciones visuales Refresh / Reset / Save;
- body placeholder/empty summary;
- outputs simples `HasFields` y `FieldCount`.

No incluye todavía edición ni working buffer.

**Gate:** Studio debe aceptar el componente sin errores antes de CF-02.

---

### CF-02 — Working buffer y estados internos

**Objetivo:** crear estado local del componente sin backend.

Incluye:

- working table inicializada desde `Items`;
- dirty tracking por `FieldKey`;
- outputs `EditedItems`, `DirtyItems`, `IsDirty`, `DirtyCount`, `LastChangedFieldKey`;
- Reset interno;
- status Saved / Unsaved calculado desde estado real.

No se conectan todavía flows.

**Gate:** cambiar un valor de prueba debe producir un solo dirty item por `FieldKey` y Reset debe volver al input original.

---

### CF-03 — Renderizado por FieldType

**Objetivo:** sustituir el placeholder por Gallery premium con los seis editores reales.

Tipos:

- Text;
- Number;
- Date;
- YesNo;
- Choice;
- MultiChoice.

Incluye:

- label;
- technical key opcional;
- help text opcional;
- required marker;
- modified marker;
- control específico por tipo.

**Gate:** todos los tipos se renderizan correctamente con un seed local y conservan sus valores al hacer scroll.

---

### CF-04 — Eventos del host

**Objetivo:** completar el contrato host/componente.

Incluye:

- `OnRefresh`;
- `OnChange`;
- `OnResetRequested`;
- `OnSaveRequested`;
- estados Loading / Saving / Error / Empty.

**Gate:** los eventos se disparan sin que el componente llame directamente a servicios externos.

---

### CF-05 — Integración Punch Review

**Objetivo:** sustituir el contenido visual actual de `conPR_CustomFieldsCard` por una instancia de `cmp_CustomFieldEditorPro`.

Se mantienen como servicios host:

- `btnPR_LoadCustomFields`;
- `btnPR_SaveCustomFields`.

Se mantienen las colecciones y variables actuales para no romper Block 13 Dirty Guard.

La instancia sincroniza `EditedItems` y `DirtyItems` con el host en `OnChange`.

**Gate:** Load / edit / Reset / Save funcionan con un Punch real y el Dirty Guard sigue protegiendo la navegación.

---

### CF-06 — Visual polish y responsive

**Objetivo:** optimizar el componente en el ancho real de Punch Review.

Incluye:

- spacing;
- alturas;
- densidad;
- scroll;
- estados hover/focus;
- comportamiento en 1366×768, 1600×900 y 1920×1080;
- revisión del panel derecho completo junto a Comments.

**Gate:** no hay clipping, solapamientos ni pérdida de legibilidad.

---

### CF-07 — Consolidación y documentación

**Objetivo:** convertir la construcción validada en fuente canónica.

Incluye:

- consolidar `power-apps/components/cmp_CustomFieldEditorPro.pa.yaml`;
- actualizar README de componentes;
- actualizar Punch Review README;
- actualizar manual de usuario;
- actualizar help modal si cambia la interacción;
- documentar incompatibilidades nuevas, si aparecen.

**Gate:** componente y Punch Review quedan listos para retomar Block 16.

## Política de avance

No se redacta el siguiente bloque si el bloque actual produce un error de Studio.

Ante cualquier error:

1. detener;
2. registrar detalle y Session ID;
3. actualizar `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`;
4. corregir el archivo fuente del repositorio;
5. volver a validar;
6. continuar solo después de confirmación.

## Artefactos previstos

```text
docs/development/components/custom-field-editor-pro/
├── README.md
├── IMPLEMENTATION_PLAN.md
└── blocks/
    ├── 01_component_shell.pa.yaml
    ├── 02_working_buffer.pa.yaml
    ├── 03_field_renderers.pa.yaml
    ├── 04_host_events.pa.yaml
    ├── 05_punch_review_integration.pa.yaml
    ├── 06_visual_polish.pa.yaml
    └── 07_consolidation.md
```

Los nombres de archivos posteriores son orientativos hasta que el bloque precedente quede validado.