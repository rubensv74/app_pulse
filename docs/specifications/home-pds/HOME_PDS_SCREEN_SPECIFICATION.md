# HOME_PDS — Especificación de Pantalla

**Estado:** Block 00 validated / Ready for Block 01  
**Screen name recomendado:** `scr_Home_PDS`  
**Display title recomendado:** `Punch Control Tower`  
**Arquetipo primario:** Operational Control Tower  
**Patrón secundario:** Data Explorer  
**Design System:** PULSE Design System v1  
**Método de construcción:** Protocolo de Construcción Modular de Pantallas Power Apps Asistida por IA  
**Fecha de validación Block 00:** 2026-08-07  

---

# 1. Decisión arquitectónica

La nueva Home PDS **no sustituirá inicialmente `scr_Home` ni se construirá modificando su layout actual**.

Se creará una pantalla paralela desde cero:

```text
scr_Home        → referencia funcional estable / fallback
scr_Home_PDS    → nueva implementación PDS
```

Objetivos:

- eliminar riesgo de regresión durante la modernización;
- permitir comparar versión actual y versión PDS;
- reutilizar contratos, flows y componentes sin copiar deuda visual;
- construir el nuevo layout por bloques pequeños YAML;
- poder descartar o corregir un bloque sin afectar Home actual;
- mantener rollback inmediato hasta el gate final.

`StartScreen` y la navegación principal no deben apuntar a `scr_Home_PDS` hasta que la nueva pantalla supere la aceptación final.

---

# 2. Fuentes de referencia

Obligatorias antes del Bloque 01:

```text
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/specifications/home-pds/BLOCK_00_FOUNDATION_AUDIT.md
```

Referencias funcionales y visuales:

```text
scr_Home         → contratos, datos, acciones y componentes ya probados
scr_PunchReview  → referencia de arquitectura SaaS, densidad, estados y organización por módulos
```

Baselines congelados por Block 00:

```text
Screens / Components:
3b71b860ed869a970a5a1b43cc137a580118b30c

SQL schema_warroom:
17bbe86e25bbb3962df237420136600b6aca12e2
```

---

# 3. Objetivo funcional

Crear una Home que funcione como **Punch Control Tower** y permita pasar de la visión ejecutiva a la investigación operativa sin perder contexto.

Debe responder rápidamente:

1. ¿Cuántos punches existen y cuál es su evolución?
2. ¿Dónde se concentran los open punches?
3. ¿Qué contratistas, categorías o disciplinas requieren atención?
4. ¿Qué contexto está seleccionado?
5. ¿Qué punches forman ese contexto?
6. ¿Qué acción puede ejecutar el usuario desde ahí?

---

# 4. Principios UX específicos

## 4.1. De dashboard a Control Tower

La pantalla no debe limitarse a mostrar KPIs y gráficos. Toda visualización debe poder conducir hacia un contexto accionable.

## 4.2. Contexto persistente

Una selección en Heatmap o Discipline Distribution debe reflejarse en:

- Active Context;
- grid;
- acciones disponibles;
- contadores relevantes.

## 4.3. Color con significado

- colores de disciplina: exclusivamente data visualization;
- azul PDS: selección/interacción;
- rojo: error/critical/destructive, no `Clear filters`;
- verde: éxito/completado;
- amber: warning real.

## 4.4. Densidad intencionada

- KPI / analytics: densidad ejecutiva;
- heatmap / table: densidad alta;
- context/action toolbar: compacta;
- no grandes espacios muertos sin función.

## 4.5. Arquitectura desacoplada

Los módulos principales deben poder cargar y fallar de forma independiente cuando técnicamente sea viable.

---

# 5. Arquitectura visual objetivo

```text
scr_Home_PDS
└── conHPDS_Root
    ├── cmpHPDS_Sidebar
    └── conHPDS_ContentShell
        ├── conHPDS_PageHeader
        │   ├── Identity
        │   ├── Project Context
        │   ├── Punch Template Context
        │   ├── Last Refresh
        │   └── Refresh / Help
        │
        ├── conHPDS_KpiStrip
        │   ├── Total Punches
        │   ├── Open Punches
        │   ├── Closed Punches
        │   └── Completion
        │
        ├── conHPDS_Analytics
        │   ├── conHPDS_HeatmapPanel
        │   │   └── Open Punch Concentration
        │   └── conHPDS_DisciplinePanel
        │       ├── Pie chart
        │       └── Interactive discipline bars
        │
        ├── conHPDS_ActiveContext
        │   ├── Context summary / chips
        │   └── Action toolbar
        │
        ├── conHPDS_DataExplorer
        │   ├── Explorer header / filters / view controls
        │   ├── DataTable
        │   └── Pagination
        │
        └── conHPDS_OverlayLayer
            ├── Loading / errors if global
            ├── Help modal
            └── Future contextual drawers
```

El árbol detallado está congelado en `SCREEN_ARCHITECTURE.md` tras la validación de Block 00.

---

# 6. Page Header objetivo

El header debe seguir el PDS y no comportarse como una card decorativa independiente.

Contenido objetivo:

```text
Punch Control Tower
Open punch concentration, discipline distribution and operational drill-through

Project: 70200 · OSTROŁĘKA Project
Template: Master Punch List
Last refresh: 07/08/2026 13:50
[Refresh] [Help]
```

Reglas:

- altura compacta;
- título 20 semibold;
- subtítulo 10;
- context controls visualmente homogéneos;
- `Refresh` es utility action, no compite con acciones operativas;
- no usar sombra de card normal;
- borde/divisor sutil.

---

# 7. KPI Strip

KPIs iniciales:

```text
Total Punches
Open Punches
Closed Punches
Completion
```

Se deben reutilizar componentes premium existentes cuando el contrato sea válido.

Reglas semánticas:

- Total: neutral / interactive blue;
- Open: neutral salvo que exista condición de riesgo real;
- Closed: success;
- Completion: neutral/success según semántica;
- delta positivo/negativo debe interpretarse según la métrica, no solo por signo.

---

# 8. Operational Analytics

## 8.1. Open Punch Concentration

Heatmap de open punches por dimensiones operativas existentes.

Debe mantener:

- selección interactiva;
- contexto activo;
- tooltip;
- orden útil;
- scroll controlado;
- total visible;
- estados loading/empty/error.

## 8.2. Discipline Distribution

La composición validada del panel es:

```text
cmp_PieChartPro
    +
interactive horizontal discipline bars
```

El **pie chart** es la visualización principal de composición porque permite percibir mejor el reparto del total entre disciplinas que un aro fino. Las barras complementan la lectura permitiendo comparar con mayor precisión magnitudes y ranking.

El pie y las barras **no son dos filtros independientes**. Ambos representan la misma dimensión y deben compartir una única selección.

Contrato conceptual:

```text
Pie segment ─────┐
                 ├──> Selected Discipline ──> Active Context ──> Data Explorer
Discipline bar ──┘
```

El panel debe mostrar:

- pie proporcional;
- barras por disciplina;
- count;
- porcentaje;
- color estable por disciplina;
- selección de pie o barra como el mismo filtro;
- estados loading/empty/error.

Reglas de selección:

- el segmento y la barra conservan el color de disciplina;
- el selected container usa `SelectedBg` / `SelectedBorder` PDS;
- Active Context se actualiza;
- el Data Explorer se recarga o filtra con el mismo contrato funcional validado.

`cmp_DonutPro` queda fuera de este caso de uso concreto. Sigue siendo válido para completion, utilization, capacity, readiness u otras métricas donde el valor central y el progreso circular sean la lectura principal.

---

# 9. Active Context + Actions

Debe existir una franja compacta entre analytics y grid.

Ejemplo:

```text
JWW INVEST S.A. × CATEGORY C × CIVIL
0 open punches

[Review] [Open Punch List] [Refresh] [Export] [Comment] [Columns] [Density] [More]
```

Jerarquía:

```text
PRIMARY      Review
SECONDARY    Open Punch List
UTILITY      Refresh · Export · Comment
VIEW         Columns · Density
OVERFLOW     More
NEUTRAL      Clear filters/context
```

`Clear` no debe usar danger/red salvo que realmente destruya información.

---

# 10. Data Explorer

Debe reutilizar el DataTable premium existente cuando sea compatible, con:

- sorting;
- configurable columns;
- density;
- selection;
- pagination;
- empty/no-results;
- loading;
- error;
- responsible party;
- status;
- description legible.

El grid no debe ocupar un enorme espacio vacío sin un estado diseñado. Cuando no existan registros debe presentar un Empty/No Results state PDS con explicación y acción contextual cuando proceda.

---

# 11. Reutilización validada

Block 00 clasifica los elementos mediante:

```text
REUSE_AS_IS
REUSE_WITH_PDS_INPUTS
REUSE_LOGIC_ONLY
REIMPLEMENT
DO_NOT_REUSE
```

Decisiones principales:

```text
cmp_SidebarNav       → REUSE_AS_IS inicialmente
cmp_KpiCardPro       → REUSE_WITH_PDS_INPUTS
cmp_HeatMapPro       → REUSE_WITH_PDS_INPUTS
cmp_PieChartPro      → REUSE_WITH_PDS_INPUTS / disciplina
cmp_DonutPro         → no usar para Discipline Distribution
cmp_ActionToolbarPro → REUSE_WITH_PDS_INPUTS
cmp_DataTableProV2   → REUSE_WITH_PDS_INPUTS
cmp_EmptyState       → REUSE_WITH_PDS_INPUTS / hardening posterior
cmp_SkeletonLoader   → REUSE_WITH_PDS_INPUTS / hardening posterior
cmp_DashboardSectionHeader → REIMPLEMENT como patrón PDS cuando corresponda
```

No debe asumirse el nombre exacto ni contrato de ningún elemento adicional sin verificar el repositorio/solución.

---

# 12. Política de datos

Home_PDS debe reutilizar, siempre que sigan siendo válidos:

- ProjectId;
- PunchTemplateId;
- snapshot/load contracts;
- summary collections;
- heatmap collections;
- distribution collections;
- grid pagination contract;
- discipline filter contract;
- selection context contract.

No debe duplicarse un flow solo para alimentar la nueva pantalla si el contrato existente ya resuelve la necesidad.

La nueva pantalla puede tener variables de UI propias con prefijo `varHPDS_` cuando ayude a aislar el desarrollo.

SQL/Flow siguen siendo autoridad de snapshot, agregación y paginación. Home_PDS no cargará toda la población de punches para reagruparla en cliente.

---

# 13. Plan de bloques validado

```text
00  Foundation audit and reuse matrix                    VALIDATED
01  Blank screen shell + shared sidebar + content shell NEXT
02  PDS Page Header component contract / implementation
03  Home_PDS header integration
04  Workspace/body structural layout + placeholders
05  Minimum typed runtime state
06  KPI strip with static/test presentation model
07  Real punch-template context selector
08  Dashboard bundle remote read service
09  Dashboard bundle parser / presentation model
10  KPI real-data integration
11  Heatmap panel integration
12  Heatmap selection and active context
13  Discipline pie integration
14  Discipline bars + shared discipline selection
15  Action toolbar integration
16  Cell-details remote read service
17  DataTableProV2 integration + SQL-authoritative paging
18  Search/sort/column/density/selection behavior
19  Home → Punch Review contextual navigation
20  Loading / empty / error hardening
21  Help + accessibility + responsive pass
22  Remove test scaffolding / final visual QA
23  Canonical consolidation + user guide + cutover decision
```

Regla: no publicar el siguiente bloque si el anterior requerido está `failed`.

---

# 14. Carpeta de construcción

```text
docs/development/screens/home-pds/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
│   ├── 01_screen_shell.pa.yaml
│   ├── 02_page_header.*
│   └── ...
└── user-guide/
    └── MANUAL_USUARIO_HOME_PDS.md
```

Los bloques son artefactos de construcción y no reemplazan el source canónico hasta el gate de consolidación.

---

# 15. Gates visuales

```text
V1  Shell + Page Header + layout
V2  KPI + analytics panels
V3  Active Context + grid
V4  real data + states
V5  full comparison against current Home
```

En V5 se revisa lado a lado:

- Home actual;
- Home_PDS;
- Punch Review como referencia PDS/UX.

---

# 16. Criterios de aceptación

Home_PDS no podrá sustituir Home hasta cumplir:

```text
[ ] No rompe scr_Home
[ ] No modifica StartScreen durante construcción
[ ] Project/template context correcto
[ ] KPIs equivalentes o mejorados
[ ] Heatmap funcional
[ ] Pie de disciplinas proporcional y legible
[ ] Discipline bars interactivas
[ ] Pie + bars comparten una única selección
[ ] Active Context coherente
[ ] Review drill-through correcto
[ ] Punch List drill-through correcto
[ ] Grid con paginación y estados
[ ] Loading/empty/error resueltos
[ ] Selection language PDS uniforme
[ ] Action hierarchy correcta
[ ] Sin hardcodes visuales nuevos fuera del PDS
[ ] App Checker sin nuevos errores atribuibles
[ ] Responsive validado
[ ] Manual actualizado
[ ] Test scaffolding eliminado
[ ] Comparación funcional con Home cerrada
[ ] Rollback documentado
```

---

# 17. Resultado de Phase 0 / Block 00

La información requerida para iniciar la construcción ha sido auditada y congelada:

- YAML/source actual de `scr_Home`;
- YAML/source actual de `scr_PunchReview`;
- componentes premium candidatos;
- contratos Power Apps relevantes;
- snapshot y procedimientos SQL de `warroom`;
- matriz de reutilización;
- arquitectura objetivo;
- riesgos y reglas de no invención.

Block 00 fue aceptado explícitamente el **2026-08-07**.

---

# 18. Decisión final de esta especificación

La estrategia aprobada es **construcción paralela desde cero**, no refactorización destructiva de Home.

La arquitectura inicial queda congelada y el siguiente trabajo permitido es:

```text
BLOCK 01 — BLANK SCREEN SHELL
```

Esto permite que PDS, arquetipos y protocolo modular se prueben juntos sobre un caso real de alto valor sin poner en riesgo la pantalla operativa existente.
