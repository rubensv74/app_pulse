# DF-06A — Guía de implementación y validación

## Objetivo

Preparar `cmp_CustomFieldsEditorPro` para ser conectado a un host real sin introducir todavía el modal de Punch Review.

DF-06A tiene un único propósito: **convertir el draft local en un contrato consumible por el host y añadir acciones Save / Cancel dentro del propio componente**.

## Clasificación

`C — Component`

## Orden obligatorio

### Paso 1 — Crear el contrato host

Aplica primero:

`06A_component_host_contract.property-guide.md`

Debes terminar con estas cinco propiedades nuevas en `cmp_CustomFieldsEditorPro`:

- `DraftDefinition` — Output / Table
- `DraftDirty` — Output / Boolean
- `EditMode` — Output / Text
- `OnSaveRequested` — Event
- `OnCancelRequested` — Event

Guarda el componente antes de continuar.

### Paso 2 — Validar outputs

Con una instancia temporal:

1. selecciona una definición;
2. modifica su `Label`;
3. confirma `DraftDirty = true`;
4. confirma que `First(<instancia>.DraftDefinition).Label` contiene el valor editado;
5. pulsa `+ Add field` y confirma `EditMode = "ADD"`;
6. vuelve a una definición y confirma `EditMode = "EDIT"`.

No continúes si alguno de esos puntos falla.

### Paso 3 — Sustituir el control local-only

Dentro de:

`cmp_CustomFieldsEditorPro → conCFDEPro_Root → conCFDEPro_Body → conCFDEPro_Editor → conCFDEPro_Form`

localiza:

`lblCFDEPro_LocalOnly`

Reemplázalo completo por:

`06A_form_actions.replace-control.pa.yaml`

No reemplaces `conCFDEPro_Form` completo.

## Comportamiento esperado

### Save

- permanece deshabilitado sin cambios;
- permanece deshabilitado si falta Label o FieldKey;
- permanece deshabilitado para Choice/MultiChoice sin opciones;
- al pulsarlo solo dispara `OnSaveRequested`;
- no llama ningún Flow directamente.

### Cancel — EDIT

- restaura el draft desde `Definitions`;
- vuelve a `DraftDirty=false`;
- conserva la definición seleccionada;
- dispara `OnCancelRequested` después de restaurar.

### Cancel — ADD

- abandona el nuevo draft;
- limpia la selección;
- vuelve al estado vacío del editor/preview;
- deja `DraftDirty=false`;
- dispara `OnCancelRequested`.

## Qué queda congelado

DF-06A no autoriza cambios en:

- geometría general del componente;
- catálogo;
- Live Preview;
- General / Behavior / Filtering / Options;
- colores;
- backend;
- Punch Review.

## Gate de salida

DF-06A se considera validado cuando:

1. Studio acepta las cinco propiedades nuevas;
2. Studio acepta el reemplazo de `lblCFDEPro_LocalOnly`;
3. una instancia nueva del componente puede insertarse sin error;
4. Save y Cancel se comportan como se describe;
5. no aparece ningún error de fórmula.

## Siguiente bloque

Después de validar DF-06A:

`DF-06B — I · Integration — modal host en Punch Review`

DF-06B añadirá el overlay/modal, insertará una instancia de `cmp_CustomFieldsEditorPro` y conectará `Manage` con apertura + carga real de definiciones.
