# C17 — Punch Review Workspace Recomposition

**Tipo:** `S/C — Structural + Component evolution`  
**Estado:** IN PROGRESS — C17-A/B/C integrados; C17-C-FIX1 publicado por clipping del rail derecho.  
**Pantalla:** `scr_PunchReview`

## Motivo

La validación visual del Punch Review Workspace mostró que la composición anterior funcionaba, pero no priorizaba correctamente las tareas de una sesión de revisión:

- Comments y Custom Fields son áreas de trabajo activas y necesitan la mayor parte del ancho útil;
- Session Activity es contexto pasivo y funciona mejor como rail lateral estrecho;
- Review Progress también es contexto persistente de sesión y encaja mejor en el rail derecho, por encima de Session Activity;
- el rail contextual no debe competir en anchura con el workspace operativo central;
- Related in Queue aporta poco valor en la composición actual y permanece `Visible=false`;
- `cmp_CustomFieldValuesPro` mezcla renderers modernos con `Classic/ComboBox@2.4.0` para Choice/MultiChoice, produciendo una experiencia visual inconsistente.

La recomposición se ejecuta antes del acabado DF-07B del editor de definiciones para no pulir una pantalla cuya geometría principal todavía estaba cambiando.

## Principio rector de anchura

La distribución sigue esta prioridad:

```text
1. Main workspace — máxima anchura disponible
2. Review Queue — anchura operativa estable
3. Right context rail — anchura mínima segura demostrada
```

Review Progress y Session Activity permanecen visibles, pero no deben reducir innecesariamente el espacio destinado a Punch Overview, Comments y Custom Fields.

### Regla de width budget

Después de revisar el Source Code completo de la pantalla el 2026-08-13, queda incorporada una regla adicional:

```text
Host Width
>= Host LayoutMinWidth
>= Critical descendant LayoutMinWidth
>= Minimum validated component width
```

No se permite estrechar un rail por debajo del mínimo geométrico real de sus componentes aunque visualmente interese recuperar unos píxeles para el centro.

## Decisiones

### 1. DF-07B queda temporalmente PAUSED

No se cancela. Se reanuda cuando C17 haya estabilizado el host real donde se usa Custom Fields.

### 2. Related in Queue sale del layout operativo

`conPR_RelatedCard` permanece temporalmente en código con `Visible=false` durante la transición. Su eliminación física se decidirá en C17-E.

### 3. Review Progress permanece como tarjeta contextual en la parte superior del rail derecho

Composición:

```text
Right rail
├── Review Progress
└── Session Activity
```

Review Progress responde a «cómo avanza la sesión» y Session Activity a «qué hemos hecho durante la sesión».

#### Anchura final del rail en desktop

La evidencia de Studio y del Source Code completo demuestra que 230 px es demasiado estrecho para la geometría compacta vigente. El rail queda fijado a:

```text
>= 1320 px  -> 260 px
< 1320 px   -> ancho completo / layout apilado
```

`260 px` es el **minimum safe width** actual. Mantiene el workspace central claramente dominante y evita clipping/solapamiento.

No reducir por debajo de 260 px mientras `cmp_ReviewProgressPro` conserve la geometría compacta de C17-B.

#### Review Progress / donut

El `cmp_ReviewProgressPro` original fue diseñado aproximadamente para `354 x 164` con donut `108 x 108`.

C17-B lo adapta a:

```text
Instance height: 140 px
Minimum host width: 260 px
Donut rendering: 82 x 82 px
Labels compactos: Reviewed / Remaining / Position
```

La fórmula del arco aprobada en C16-FIX5 permanece intacta.

### 4. Comments + Custom Fields forman el workspace activo

Debajo de Punch Overview existe una fila de trabajo con dos columnas:

```text
Comments | Custom Fields
```

Ambas zonas disponen de la anchura recuperada al convertir el rail derecho en un contexto compacto.

### 5. Session Activity permanece debajo de Review Progress

`conPR_HistoryCard` vive en `conPR_RightColumn` inmediatamente debajo de Review Progress y absorbe la altura restante.

Su shell debe aceptar 260 px sin mantener descendientes con `LayoutMinWidth` mayores que el propio rail.

### 6. Custom Field Values se moderniza antes del cierre visual

La auditoría del componente vigente confirma:

- Text: `ModernTextInput@1.1.1`;
- Number: `ModernNumberInput@1.1.1`;
- Date: `ModernDatePicker@1.0.1`;
- YesNo: `Toggle@1.1.5`;
- Choice / MultiChoice: `Classic/ComboBox@2.4.0`.

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
            ├── conPR_CenterColumn
            │   ├── cmpPR_Actions
            │   ├── conPR_OverviewCard
            │   └── conPR_CollaborationRow
            │       ├── conPR_CommentsCard
            │       └── conPR_CustomFieldsHost
            └── conPR_RightColumn
                ├── conPR_ReviewProgressCard
                │   └── cmpPR_ReviewProgress
                └── conPR_HistoryCard
```

`conPR_RelatedCard` no forma parte del árbol operativo objetivo.

## Proporciones desktop objetivo

```text
Queue                     ~330 px
Main workspace             flexible / claramente dominante
Right context rail         260 px
```

Dentro del main workspace:

```text
Action toolbar             ~60 px
Punch Overview             ~210 px
Comments / Custom Fields   resto de la altura
```

Dentro del rail derecho:

```text
Review Progress            140 px
Session Activity           resto de la altura
```

## Evidencia de Studio

### C17-A

Confirmó:

- Review Queue estable a la izquierda;
- main workspace claramente dominante;
- eliminación efectiva del espacio reservado a Related;
- Punch Overview aprovechando el ancho recuperado.

### C17-B

Confirmó conceptualmente:

- Review Progress arriba del rail;
- Session Activity debajo;
- donut compacto legible.

### C17-C

Confirmó:

- Comments y Custom Fields reubicados en dos columnas bajo Punch Overview;
- el workspace central obtiene una superficie de trabajo claramente superior.

La misma captura reveló un defecto estructural: el rail había acabado en 230 px mientras conservaba `LayoutMinWidth` de 260/280/300 px en distintos niveles. El borde derecho quedó recortado. Este defecto se corrige como `C17-C-FIX1` y no reabre la arquitectura de C17.

## Breakpoints vigentes

```text
>= 1320 px   Right rail = 260 px
< 1320 px    Main + Right Rail apilados, ancho completo
```

## Secuencia incremental

### C17-A — Target layout / geometry

**Estado:** VISUALLY VALIDATED IN STUDIO / SUPERSEDED ONLY IN RAIL WIDTH BY C17-C-FIX1.

### C17-B — Right rail integration

**Estado:** INTEGRATED / CONCEPT VISUALLY VALIDATED.

Responsabilidad:

- Review Progress al inicio del rail;
- geometría interna compacta;
- Session Activity debajo;
- main workspace dominante.

### C17-C — Collaboration workspace

**Estado:** INTEGRATED / VISUALLY VALIDATED WITH RIGHT-RAIL CLIPPING DEFECT.

Responsabilidad:

- Comments + Custom Fields bajo Overview;
- dos columnas de trabajo activas.

### C17-C-FIX1 — Right rail width budget reconciliation

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

Artefacto:

- `C17-C-FIX1_right_rail_width_budget.property-guide.md`

Responsabilidad única:

- restaurar un host mínimo seguro de 260 px;
- reconciliar `LayoutMinWidth` del rail y sus descendientes;
- corregir el wrapper vertical de Review Progress;
- evitar que Session Activity declare anchos mayores que su parent;
- no tocar lógica ni el workspace central.

### C17-D — Custom Field Values modern renderers

Responsabilidad única: modernizar la capa visual de los value renderers, especialmente Choice/MultiChoice, preservando contratos y dirty state.

### C17-E — Cleanup + responsive + Visual QA

Responsabilidad:

- confirmar Related fuera del layout;
- eliminar residuos de AutoLayout (`X/Y` heredados, widths redundantes, etc.);
- MIN/NOMINAL/MAX host sizes;
- width-budget audit;
- second-order clipping pass;
- scroll intencional;
- validar Text/Number/Date/YesNo/Choice/MultiChoice;
- validar Comments largos y 7+ Custom Fields;
- validar Review Progress con 0%, parcial y 100%;
- validar Session Activity vacío/con muchos eventos;
- validar queue vacía y cola larga;
- confirmar que el rail nunca roba anchura innecesaria al workspace central.

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
- definición funcional del modal `cmp_CustomFieldsEditorPro` salvo defecto independiente confirmado.

## Gate de cierre

C17 solo queda cerrado cuando Power Apps Studio confirme:

```text
STRUCTURE        APPROVED
MAIN WIDTH       DOMINANT / APPROVED
RIGHT RAIL       260 PX / NO CLIPPING
COMMENTS         FUNCTIONAL_FROZEN
CUSTOM VALUES    FUNCTIONAL_FROZEN
SESSION ACTIVITY FUNCTIONAL_FROZEN
PROGRESS         VISUAL_APPROVED
RESPONSIVE       PASS
WIDTH BUDGET     PASS
NO CLIPPING      PASS
NO NEW FORMULA ERRORS
```

Después se reanuda DF-07B sobre la geometría definitiva.
