# C17-C — Guía de implementación y validación

## Objetivo

Convertir el espacio libre debajo de `Punch Overview` en el workspace operativo principal mediante dos paneles en paralelo:

```text
Comments | Custom Fields
```

El rail derecho debe quedar reservado exclusivamente para:

```text
Review Progress
Session Activity
```

## Precondiciones

- C17-A aplicado.
- C17-B aplicado.
- `cmpPR_ReviewProgress` visible arriba del rail.
- `conPR_HistoryCard` debajo.
- No existen errores de fórmula conocidos en esos dos módulos.

## Orden obligatorio

### 1. Añadir `conPR_CollaborationRow`

Target:

`conPR_CenterColumn`

Archivo:

`C17-C_collaboration_row.add-child.pa.yaml`

Pegar como nuevo hijo después de `conPR_OverviewCard`.

Guardar y confirmar en el árbol antes de mover ningún control.

### 2. Mover `conPR_CommentsCard`

Mover el control existente desde `conPR_RightColumn` a `conPR_CollaborationRow`.

No copiarlo.

Aplicar las propiedades indicadas en:

`C17-C_collaboration_workspace.property-guide.md`

### 3. Mover `conPR_CustomFieldsHost`

Mover el control existente desde `conPR_RightColumn` a `conPR_CollaborationRow`, como segundo hijo.

Aplicar las propiedades indicadas en la misma guía.

### 4. Confirmar árbol final

```text
conPR_CenterColumn
├── cmpPR_Actions
├── conPR_OverviewCard
└── conPR_CollaborationRow
    ├── conPR_CommentsCard
    └── conPR_CustomFieldsHost

conPR_RightColumn
├── cmpPR_ReviewProgress
└── conPR_HistoryCard
```

## Smoke test funcional mínimo

Con proyecto y Punch real seleccionados:

1. seleccionar varios Punches consecutivos en Review Queue;
2. confirmar que Comments cambia con el Punch actual;
3. confirmar que Custom Fields cambia con el Punch actual;
4. escribir un comentario sin guardarlo y comprobar que el composer sigue operativo;
5. editar un Custom Field y comprobar `Dirty`/Save/Cancel;
6. pulsar Mark Reviewed y verificar que Review Progress se actualiza;
7. verificar que Session Activity refleja la acción;
8. confirmar que Manage sigue abriendo el modal de definiciones.

No es necesario persistir cambios si la prueba se realiza sobre datos que no deban modificarse.

## Visual QA

### Desktop amplio

Debe observarse:

- Main workspace claramente dominante;
- Comments y Custom Fields aproximadamente 50/50;
- ninguna columna invadiendo la otra;
- headers completos;
- composer de Comments visible;
- footer Save/Cancel de Custom Fields visible;
- rail derecho estable en 260–280 px;
- Progress y Session Activity sin competir en ancho con el workspace.

### Contenido representativo

Validar al menos:

- Comments vacío;
- Comments con varias entradas;
- Custom Fields vacío;
- Custom Fields con 7+ campos;
- Review Progress parcial;
- Session Activity vacío y con varios eventos.

## Defectos que NO deben resolverse ensanchando el rail

Si Comments o Custom Fields presentan clipping tras el movimiento:

```text
NO → aumentar conPR_RightColumn.Width
SÍ → revisar geometría interna del panel afectado en un FIX posterior
```

El ancho del rail es una decisión estructural ya validada.

## Gate

C17-C puede considerarse aprobado cuando:

```text
COLLABORATION ROW        PASS
COMMENTS MOVED           PASS
CUSTOM FIELDS MOVED      PASS
RIGHT RAIL ONLY CONTEXT  PASS
NO DUPLICATE CONTROLS    PASS
NO NEW FORMULA ERRORS    PASS
```

Después se pasa a `C17-D — Custom Field Values modern renderers`.
