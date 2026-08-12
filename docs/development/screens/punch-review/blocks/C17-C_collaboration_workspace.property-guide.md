# C17-C — Collaboration Workspace · guía de reubicación y propiedades

**Tipo:** `S/I — Structural / Integration`  
**Pantalla:** `scr_PunchReview`  
**Objetivo único:** mover Comments y Custom Fields desde el rail derecho al workspace central y hacer que compartan el espacio operativo disponible.

## Estado de partida confirmado

Tras C17-B, el árbol real contiene en `conPR_RightColumn`:

```text
conPR_RightColumn
├── cmpPR_ReviewProgress
├── conPR_HistoryCard
├── conPR_CommentsCard
└── conPR_CustomFieldsHost
```

El panel central contiene:

```text
conPR_CenterColumn
├── cmpPR_Actions
└── conPR_OverviewCard
```

C17-C debe terminar con:

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

## Regla crítica

**MOVER, NO DUPLICAR.**

No crear una segunda copia de `conPR_CommentsCard` ni de `conPR_CustomFieldsHost`. Ambos controles contienen servicios, referencias por nombre y estado existente. La operación correcta en Studio es cortar y pegar/reubicar los controles existentes.

---

## Paso 1 — Crear el host

Seleccionar:

`conPR_CenterColumn`

Añadir como nuevo hijo, después de `conPR_OverviewCard`, el archivo:

`C17-C_collaboration_row.add-child.pa.yaml`

Resultado esperado:

`conPR_CollaborationRow` aparece como tercer hijo de `conPR_CenterColumn`.

Guardar antes de continuar.

---

## Paso 2 — Mover Comments

En el árbol de Studio:

1. seleccionar `conPR_CommentsCard` dentro de `conPR_RightColumn`;
2. cortar el control;
3. seleccionar `conPR_CollaborationRow`;
4. pegar como hijo;
5. dejarlo como primer hijo.

Después aplicar estas propiedades a `conPR_CommentsCard`:

```text
FillPortions   = 1
Height         = Parent.Height
LayoutMinHeight= 280
LayoutMinWidth = 360
Width          = Parent.Width
```

No modificar controles internos, flows, gallery, composer ni paginación.

---

## Paso 3 — Mover Custom Fields

En el árbol de Studio:

1. seleccionar `conPR_CustomFieldsHost` dentro de `conPR_RightColumn`;
2. cortar el control;
3. seleccionar `conPR_CollaborationRow`;
4. pegar como hijo;
5. dejarlo como segundo hijo.

Aplicar estas propiedades a `conPR_CustomFieldsHost`:

```text
FillPortions   = 1
Height         = Parent.Height
LayoutMinHeight= 280
LayoutMinWidth = 400
Width          = Parent.Width
```

Mantener:

```text
cmpPR_CustomFieldValues.Height = Parent.Height
cmpPR_CustomFieldValues.Width  = Parent.Width
```

No modificar los servicios invisibles `btnPR_*`, dirty state, definición modal ni flows.

---

## Paso 4 — Verificar el rail derecho

Tras mover ambos controles, `conPR_RightColumn` debe contener únicamente:

```text
cmpPR_ReviewProgress
conPR_HistoryCard
```

No ensanchar el rail para compensar problemas de Comments o Custom Fields. El rail debe conservar la geometría C17-A/B:

```text
>=1500 px  → 280 px
1320–1499  → 260 px
```

El ancho recuperado pertenece al workspace activo.

---

## Distribución dentro del workspace

`conPR_CollaborationRow` utiliza reparto 1:1 mediante `FillPortions=1` en ambos hijos.

Objetivo inicial:

```text
Comments      50%
Custom Fields 50%
```

No introducir 55/45 todavía. Primero validar con contenido real. Si Studio demuestra una necesidad persistente, se abrirá un FIX visual explícito.

---

## No modificar

- `cmpPR_Actions`;
- `conPR_OverviewCard`;
- `cmpPR_ReviewProgress`;
- `conPR_HistoryCard`;
- Queue;
- Comments backend;
- Custom Field Values backend;
- DF-05 / DF-06;
- Dirty Guard;
- modal de definiciones;
- Related, que permanece fuera del layout operativo.

## Resultado esperado

En desktop ancho:

```text
Review Queue | Main workspace                           | Context rail
             | Actions                                  | Review Progress
             | Punch Overview                           | Session Activity
             | Comments        | Custom Fields          |
```

El gran vacío central debe desaparecer y convertirse en superficie de trabajo útil.
