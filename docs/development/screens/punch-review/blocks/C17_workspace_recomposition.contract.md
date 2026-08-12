# C17 — Punch Review Workspace Recomposition

**Tipo:** `S/C — Structural + Component evolution`  
**Estado:** PLANNED — composición corregida por el usuario antes de iniciar C17-A.  
**Pantalla:** `scr_PunchReview`

## Motivo

La validación visual del Punch Review Workspace ha mostrado que la composición actual funciona, pero no prioriza bien las tareas que el usuario realiza durante una revisión:

- Comments y Custom Fields son áreas de trabajo activas y necesitan más espacio útil;
- Session Activity es contexto pasivo y funciona mejor como rail lateral;
- Review Progress también es contexto persistente de sesión y encaja mejor en el rail derecho, por encima de Session Activity;
- Related in Queue aporta poco valor en la composición actual y ya se ha dejado `Visible=false`;
- `cmp_CustomFieldValuesPro` mezcla renderers modernos con `Classic/ComboBox@2.4.0` para Choice/MultiChoice, produciendo una experiencia visual inconsistente.

La reordenación debe ejecutarse antes del acabado DF-07B del editor de definiciones para no pulir una pantalla cuya geometría principal todavía va a cambiar.

## Decisiones

### 1. DF-07B queda temporalmente PAUSED

No se cancela. Se reanuda cuando C17 haya estabilizado el host real donde se usa Custom Fields.

### 2. Related in Queue sale del layout operativo

`conPR_RelatedCard` permanece temporalmente en código con `Visible=false` durante la transición. Se decidirá su eliminación física en el cleanup final de C17.

### 3. Review Progress permanece como tarjeta contextual y pasa a la parte superior del rail derecho

Se corrige la propuesta inicial de situarlo junto a `cmpPR_Actions`.

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

#### Donut

No se creará de entrada un segundo componente compacto.

Primero se reutilizará `cmp_ReviewProgressPro` en el rail derecho y se validará su geometría real en Studio. El componente actual tiene una geometría nominal aproximada de `354 x 164` con donut `108 x 108`.

Objetivo visual para C17:

```text
Card height: aproximadamente 140–165 px
Rail width: aproximadamente 330–360 px
Donut objetivo: aproximadamente 88–100 px si Studio confirma que 108 px domina demasiado
```

La reducción del donut, si es necesaria, será un ajuste visual explícito posterior y no una condición para construir primero la nueva estructura.

No se degradará la legibilidad de Reviewed / Remaining / Current Position para ganar unos pocos píxeles.

### 4. Comments + Custom Fields forman el workspace activo

Debajo de Punch Overview se crea una fila de trabajo con dos columnas:

```text
Comments | Custom Fields
```

Ambas zonas deben disponer de altura suficiente para lectura/edición continua.

Esta fila ocupará el espacio actualmente consumido en gran parte por Session Activity en la columna central.

### 5. Session Activity pasa debajo de Review Progress en el rail derecho

`conPR_HistoryCard` se reubica en `conPR_RightColumn`, inmediatamente debajo de Review Progress.

Session Activity debe utilizar el resto de la altura disponible del rail para mostrar eventos sin competir con Comments o Custom Fields.

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

A partir de 1320 px:

```text
Queue                    330 px
Main workspace            flexible / dominante
Right context rail        330–360 px
```

Dentro del main workspace:

```text
Action toolbar             ~60 px
Punch Overview             ~210 px
Comments / Custom Fields   resto de la altura
```

Dentro del rail derecho:

```text
Review Progress            ~140–165 px
Session Activity           resto de la altura
```

Comments y Custom Fields deben partir aproximadamente 50/50, permitiendo ajustar posteriormente a 55/45 si la validación real demuestra que Comments necesita más ancho.

## Responsive

Por debajo del breakpoint desktop:

- el rail derecho completo `Review Progress + Session Activity` podrá apilarse debajo del main workspace;
- Comments y Custom Fields podrán apilarse verticalmente si el ancho no permite dos columnas útiles;
- Review Progress debe conservar sus tres métricas sin clipping;
- el donut podrá reducirse de forma controlada si el rail disponible lo exige.

No se resolverá responsive mediante clipping.

## Secuencia incremental corregida

### C17-A — Target layout / geometry

Responsabilidad única: estabilizar la nueva composición y proporciones usando contenedores/slots, sin modernizar controles.

Debe dejar preparado:

- main workspace dominante;
- collaboration row para Comments + Custom Fields;
- rail derecho con slot superior de Review Progress y slot inferior de Session Activity.

### C17-B — Right rail integration

Responsabilidad única: reubicar el `cmp_ReviewProgressPro` existente arriba y `conPR_HistoryCard` debajo.

Primero se reutiliza el componente existente. Solo si Studio demuestra que el donut de 108 px domina demasiado se abre un ajuste visual aislado para llevarlo aproximadamente a 88–100 px.

### C17-C — Collaboration workspace

Responsabilidad única: reubicar Comments y Custom Fields como dos columnas bajo Overview.

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
