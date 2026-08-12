# C17 — Punch Review Workspace Recomposition

**Tipo:** `S/C — Structural + Component evolution`  
**Estado:** IN PROGRESS — C17-A publicado y pendiente de validación en Power Apps Studio.  
**Pantalla:** `scr_PunchReview`

## Motivo

La validación visual del Punch Review Workspace ha mostrado que la composición actual funciona, pero no prioriza bien las tareas que el usuario realiza durante una revisión:

- Comments y Custom Fields son áreas de trabajo activas y necesitan la mayor parte del ancho útil;
- Session Activity es contexto pasivo y funciona mejor como rail lateral estrecho;
- Review Progress también es contexto persistente de sesión y encaja mejor en el rail derecho, por encima de Session Activity;
- el rail contextual no debe competir en anchura con el workspace operativo central;
- Related in Queue aporta poco valor en la composición actual y ya se ha dejado `Visible=false`;
- `cmp_CustomFieldValuesPro` mezcla renderers modernos con `Classic/ComboBox@2.4.0` para Choice/MultiChoice, produciendo una experiencia visual inconsistente.

La reordenación debe ejecutarse antes del acabado DF-07B del editor de definiciones para no pulir una pantalla cuya geometría principal todavía va a cambiar.

## Principio rector de anchura

La distribución debe seguir esta prioridad:

```text
1. Main workspace — máxima anchura disponible
2. Review Queue — anchura operativa estable
3. Right context rail — anchura mínima suficiente
```

Review Progress y Session Activity deben permanecer visibles, pero no deben reducir innecesariamente el espacio destinado a Punch Overview, Comments y Custom Fields.

## Decisiones

### 1. DF-07B queda temporalmente PAUSED

No se cancela. Se reanuda cuando C17 haya estabilizado el host real donde se usa Custom Fields.

### 2. Related in Queue sale del layout operativo

`conPR_RelatedCard` permanece temporalmente en código con `Visible=false` durante la transición. Se decidirá su eliminación física en el cleanup final de C17.

### 3. Review Progress permanece como tarjeta contextual y pasa a la parte superior del rail derecho

La composición definitiva será:

```text
Right rail
├── Review Progress
└── Session Activity
```

Esto mantiene juntos los dos elementos de contexto de sesión:

- Review Progress responde a «cómo avanza la sesión»;
- Session Activity responde a «qué hemos hecho durante la sesión».

El usuario no necesita dedicarles el área principal de trabajo, pero sí conviene mantenerlos visibles durante la revisión.

#### Anchura del rail

Objetivo desktop:

```text
Preferred width: ~280 px
Minimum useful width: ~260 px
Maximum target width: ~300 px
```

No debe crecer proporcionalmente si el workspace central puede aprovechar ese espacio.

#### Review Progress / donut

El `cmp_ReviewProgressPro` actual tiene una geometría nominal aproximada de `354 x 164` con donut `108 x 108`, por lo que C17-B deberá adaptar su presentación a un rail de 260–280 px sin limitarse a comprimir la instancia externamente.

Objetivo visual:

```text
Card width: rail completo (~260–280 px nominal)
Card height: ~130–150 px
Donut: ~76–88 px
```

Reviewed / Remaining / Current Position deben seguir siendo legibles y no sufrir clipping.

### 4. Comments + Custom Fields forman el workspace activo

Debajo de Punch Overview se crea una fila de trabajo con dos columnas:

```text
Comments | Custom Fields
```

Ambas zonas deben disponer de altura y anchura suficientes para lectura/edición continua.

El aumento de anchura del main workspace es una condición explícita de C17.

### 5. Session Activity pasa debajo de Review Progress en el rail derecho

`conPR_HistoryCard` se reubica en `conPR_RightColumn`, inmediatamente debajo de Review Progress.

Session Activity debe utilizar el resto de la altura disponible del rail y aceptar una presentación más estrecha, con wrapping/overflow controlado de sus textos en lugar de reclamar anchura adicional al main workspace.

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

## Árbol objetivo corregido

```text
scr_PunchReview
└── conPR_Body
    ├── conPR_QueueCard
    └── conPR_Workspace
        └── conPR_UpperGrid
            ├── conPR_MainColumn
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
Right context rail         280 px preferred >=1500
                           260 px entre 1320–1499
                           300 px máximo objetivo
```

Dentro del main workspace:

```text
Action toolbar             ~60 px
Punch Overview             ~210 px
Comments / Custom Fields   resto de la altura
```

Dentro del rail derecho:

```text
Review Progress            ~130–150 px
Session Activity           resto de la altura
```

### Regla de distribución horizontal

No usar un `FillPortions` simétrico entre main y right rail.

El main workspace debe absorber prácticamente todo el crecimiento horizontal de la pantalla. El rail contextual debe mantenerse dentro de su banda estrecha.

### Comments / Custom Fields

En pantallas suficientemente anchas deben comenzar aproximadamente 50/50 dentro del main workspace.

Si el ancho útil conjunto cae por debajo de un nivel cómodo para dos editores operativos, la solución preferida es apilar Comments y Custom Fields, no volver a ensanchar el rail derecho.

## Breakpoints de C17-A

C17-A fija explícitamente:

```text
>= 1500 px   Right rail = 280 px
1320–1499    Right rail = 260 px
< 1320       Main + Right Rail apilados, ancho completo
```

## Secuencia incremental

### C17-A — Target layout / geometry

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

Artefactos:

- `C17-A_target_layout_geometry.property-guide.md`
- `C17-A_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad única:

- liberar la altura que todavía reservaba Related;
- convertir el centro en workspace dominante mediante `FillPortions`;
- fijar el rail derecho a 260/280 px en desktop;
- mantener apilado bajo 1320 px;
- no mover todavía hijos entre columnas.

Durante C17-A es normal que los paneles aún alojados en la columna antigua se vean temporalmente comprimidos. No deben corregirse internamente hasta C17-B/C.

### C17-B — Right rail integration

Responsabilidad única: reubicar Review Progress arriba y `conPR_HistoryCard` debajo.

Debe adaptar Review Progress al rail estrecho sin degradar su contrato ni recurrir a clipping.

### C17-C — Collaboration workspace

Responsabilidad única: reubicar Comments y Custom Fields como dos columnas bajo Overview y validar que el ancho recuperado por el rail estrecho mejora realmente ambos paneles.

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
- definición del modal `cmp_CustomFieldsEditorPro` salvo defecto independiente confirmado.

## Gate de cierre

C17 solo queda cerrado cuando Power Apps Studio confirme:

```text
STRUCTURE        APPROVED
MAIN WIDTH       DOMINANT / APPROVED
RIGHT RAIL       COMPACT / APPROVED
COMMENTS         FUNCTIONAL_FROZEN
CUSTOM VALUES    FUNCTIONAL_FROZEN
SESSION ACTIVITY FUNCTIONAL_FROZEN
PROGRESS         VISUAL_APPROVED
RESPONSIVE       PASS
NO CLIPPING      PASS
NO NEW FORMULA ERRORS
```

Después se reanuda DF-07B sobre la geometría definitiva.
