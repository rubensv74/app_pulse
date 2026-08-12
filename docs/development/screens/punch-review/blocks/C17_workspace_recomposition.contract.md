# C17 — Punch Review Workspace Recomposition

**Tipo:** `S/C — Structural + Component evolution`  
**Estado:** PLANNED — aprobado conceptualmente para ejecutar antes de continuar DF-07B.  
**Pantalla:** `scr_PunchReview`

## Motivo

La validación visual del Punch Review Workspace ha mostrado que la composición actual funciona, pero no prioriza bien las tareas que el usuario realiza durante una revisión:

- Comments y Custom Fields son áreas de trabajo activas y necesitan más espacio útil;
- Session Activity es contexto pasivo y funciona mejor como rail lateral;
- Review Progress ocupa demasiado espacio como tarjeta independiente y encaja mejor junto a las acciones de revisión;
- Related in Queue aporta poco valor en la composición actual y ya se ha dejado `Visible=false`;
- `cmp_CustomFieldValuesPro` mezcla renderers modernos con `Classic/ComboBox@2.4.0` para Choice/MultiChoice, produciendo una experiencia visual inconsistente.

La reordenación debe ejecutarse antes del acabado DF-07B del editor de definiciones para no pulir una pantalla cuya geometría principal todavía va a cambiar.

## Decisiones

### 1. DF-07B queda temporalmente PAUSED

No se cancela. Se reanuda cuando C17 haya estabilizado el host real donde se usa Custom Fields.

### 2. Related in Queue sale del layout operativo

`conPR_RelatedCard` permanece temporalmente en código con `Visible=false` durante la transición. Se decidirá su eliminación física en el cleanup final de C17.

### 3. Review Progress pasa al strip de acciones

No se utilizará la tarjeta vertical actual en la columna derecha.

Se creará una variante compacta específica para cabecera/toolbar, manteniendo el contrato funcional:

- TotalCount;
- ReviewedCount;
- RemainingCount;
- CurrentPosition;
- State.

Objetivo visual aproximado para desktop:

```text
Height: 56–64 px
Width: 280–340 px
Donut: 42–48 px
```

No se reducirá simplemente la instancia actual porque `cmp_ReviewProgressPro` utiliza geometría interna absoluta (`164 x 354`, donut `108 x 108`). La variante compacta debe ser una pieza aislada para no degradar el componente ya aprobado.

### 4. Comments + Custom Fields forman el workspace activo

Debajo de Punch Overview se crea una fila de trabajo con dos columnas:

```text
Comments | Custom Fields
```

Ambas zonas deben disponer de altura suficiente para lectura/edición continua.

### 5. Session Activity pasa al rail derecho

`conPR_HistoryCard` se convierte en la pieza principal de `conPR_RightColumn`.

Es coherente con su naturaleza: contexto de sesión, no tarea primaria.

### 6. Custom Field Values se moderniza antes del cierre visual

La auditoría del componente vigente confirma:

- Text: `ModernTextInput@1.1.1`;
- Number: `ModernNumberInput@1.1.1`;
- Date: `ModernDatePicker@1.0.1`;
- YesNo: `Toggle@1.1.5`;
- Choice / MultiChoice: `Classic/ComboBox@2.4.0`.

El aspecto antiguo observado no procede por tanto de todos los renderers, sino principalmente de Choice/MultiChoice y de una jerarquía visual todavía demasiado legacy.

La modernización debe preservar íntegramente:

- `colCFVPro_Base`;
- `colCFVPro_Working`;
- `colCFVPro_Dirty`;
- dirty comparison;
- `EditedItems`;
- `DirtyItems`;
- `OnValueChanged`;
- `OnSaveRequested`;
- JSON de MultiChoice.

## Árbol objetivo

```text
scr_PunchReview
└── conPR_Body
    ├── conPR_QueueCard
    └── conPR_Workspace
        └── conPR_UpperGrid
            ├── conPR_MainColumn
            │   ├── conPR_ActionProgressRow
            │   │   ├── cmpPR_Actions
            │   │   └── cmpPR_ReviewProgressCompact
            │   ├── conPR_OverviewCard
            │   └── conPR_CollaborationRow
            │       ├── conPR_CommentsCard
            │       └── conPR_CustomFieldsHost
            └── conPR_RightColumn
                └── conPR_HistoryCard
```

`conPR_RelatedCard` no forma parte del árbol operativo objetivo.

## Proporciones desktop objetivo

A partir de 1320 px:

```text
Queue                    330 px
Main workspace            flexible / dominante
Session Activity rail     300–340 px
```

Dentro del main workspace:

```text
Action + Progress strip    60–64 px
Punch Overview             ~210 px
Comments / Custom Fields   resto de la altura
```

Comments y Custom Fields deben partir aproximadamente 50/50, permitiendo ajustar posteriormente a 55/45 si la validación real demuestra que Comments necesita más ancho.

## Responsive

Por debajo del breakpoint desktop:

- el rail derecho podrá apilarse debajo del main workspace;
- Comments y Custom Fields podrán apilarse verticalmente si el ancho no permite dos columnas útiles;
- Review Progress Compact no debe forzar scroll horizontal en el action strip.

No se resolverá responsive mediante clipping.

## Secuencia incremental

### C17-A — Target layout / geometry

Responsabilidad única: estabilizar la nueva composición y proporciones usando contenedores/slots, sin modernizar controles.

### C17-B — Compact Review Progress

Responsabilidad única: crear `cmp_ReviewProgressCompactPro` y situarlo junto a `cmpPR_Actions`.

### C17-C — Collaboration workspace

Responsabilidad única: reubicar Comments y Custom Fields como dos columnas bajo Overview y mover Session Activity al rail derecho.

### C17-D — Custom Field Values modern renderers

Responsabilidad única: modernizar la capa visual de los value renderers, especialmente Choice/MultiChoice, preservando contratos y dirty state.

### C17-E — Cleanup + responsive + Visual QA

Responsabilidad:

- confirmar Related fuera del layout;
- eliminar residuos/slots temporales;
- MIN/NOMINAL/MAX host sizes;
- second-order clipping pass;
- scroll intencional;
- validar Text/Number/Date/YesNo/Choice/MultiChoice;
- validar Comments largos y 7+ Custom Fields;
- validar Session Activity vacío/con eventos;
- validar queue vacía y cola larga.

## Congelado durante C17

No modificar incidentalmente:

- DF-05 definition backend;
- DF-06 definition modal integration;
- Dirty Guard;
- Comments flows;
- Custom Field values backend load/save;
- Mark Reviewed / Undo Review;
- Queue filtering;
- Punch Overview data contract;
- definición del modal `cmp_CustomFieldsEditorPro` salvo defecto independiente confirmado.

## Gate de cierre

C17 solo queda cerrado cuando Power Apps Studio confirme:

```text
STRUCTURE        APPROVED
COMMENTS         FUNCTIONAL_FROZEN
CUSTOM VALUES    FUNCTIONAL_FROZEN
SESSION ACTIVITY FUNCTIONAL_FROZEN
PROGRESS         VISUAL_APPROVED
RESPONSIVE       PASS
NO CLIPPING      PASS
NO NEW FORMULA ERRORS
```

Después se reanuda DF-07B sobre la geometría definitiva.