# HOME_PDS — Especificación de Pantalla

**Estado:** Proposed / Ready for Phase 0 audit  
**Screen name recomendado:** `scr_Home_PDS`  
**Display title recomendado:** `Punch Control Tower`  
**Arquetipo primario:** Operational Control Tower  
**Patrón secundario:** Data Explorer  
**Design System:** PULSE Design System v1  
**Método de construcción:** Protocolo de Construcción Modular de Pantallas Power Apps Asistida por IA  

---

# 1. Decisión arquitectónica

La nueva Home PDS **no sustituirá inicialmente `scr_Home` ni se construirá modificando su layout actual**.

Se creará una pantalla paralela desde cero:

```text
scr_Home        → referencia funcional estable / fallback
scr_Home_PDS    → nueva implementación PDS
```

Objetivos de esta decisión:

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
```

Referencias funcionales y visuales:

```text
scr_Home         → contratos, datos, acciones y componentes ya probados
scr_PunchReview  → referencia de arquitectura SaaS, densidad, estados y organización por módulos
```

Antes de construir debe inspeccionarse el YAML canónico actualizado de ambas pantallas y los componentes realmente disponibles en la solución.

---

# 3. Objetivo funcional

Crear una Home que funcione como **Punch Control Tower** y permita pasar de la visión ejecutiva a la investigación operativa sin perder contexto.

La pantalla debe responder rápidamente:

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
        │       └── Donut + interactive discipline bars
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

El árbol exacto debe congelarse después de la auditoría Phase 0 y antes de crear YAML productivo.

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

Un único panel coherente con:

- donut proporcional;
- barras por disciplina;
- count;
- porcentaje;
- color estable por disciplina;
- selección de barra como filtro.

Al seleccionar una disciplina:

- la barra mantiene su color de datos;
- el contenedor usa SelectedBg/SelectedBorder PDS;
- Active Context se actualiza;
- el Data Explorer se recarga o filtra con el mismo contrato funcional validado.

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

# 11. Reutilización permitida

La auditoría debe clasificar los elementos de Home actual en:

```text
REUSE_AS_IS
REUSE_WITH_PDS_INPUTS
REUSE_LOGIC_ONLY
REIMPLEMENT
DO_NOT_REUSE
```

Candidatos esperados a inspección:

- SidebarNav;
- KpiCard premium;
- Heatmap premium;
- Donut / discipline distribution;
- DataTable premium;
- action/filter components;
- current dashboard data-loading buttons;
- collections and normalized grid contracts;
- flow calls;
- snapshot handling;
- project/template selection.

No debe asumirse el nombre exacto ni contrato de un componente hasta verificar el estado actual del repositorio/solución.

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

---

# 13. Plan inicial de bloques

La secuencia exacta se congela tras Phase 0. Propuesta inicial:

```text
00  Repository + compatibility audit
01  Screen shell + isolated navigation-safe root
02  PDS Page Header
03  Main Control Tower layout + placeholders
04  Typed runtime UI state
05  KPI strip with test/local values
06  Heatmap panel shell + existing component contract
07  Discipline distribution panel shell + existing component contract
08  Local selection + Active Context
09  Action toolbar hierarchy
10  Data Explorer shell + DataTable contract
11  First real dashboard read integration
12  Heatmap + discipline real data wiring
13  Grid real data + discipline/heatmap filters
14  Review / Punch List integration
15  Refresh / snapshot / project-template change
16  Loading / empty / error hardening
17  Help modal + user guide
18  Responsive + accessibility + visual QA
19  Remove test scaffolding / placeholders
20  Canonical consolidation
21  Parallel comparison with scr_Home
22  Navigation cutover decision
```

Regla: no publicar el siguiente bloque si el anterior está `failed`.

---

# 14. Carpeta de construcción propuesta

```text
docs/development/screens/home-pds/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── DESIGN_DECISIONS.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
│   ├── 01_screen_shell.pa.yaml
│   ├── 02_page_header.children.pa.yaml
│   ├── 03_control_tower_layout.children.pa.yaml
│   ├── 04_runtime_state.onvisible.pa.yaml
│   └── ...
└── user-guide/
    └── MANUAL_USUARIO_HOME_PDS.md
```

Esta carpeta se crea al iniciar Phase 0/Bloque 01, no antes de conocer las rutas reales de la solución.

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
[ ] Discipline bars interactivas
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

# 17. Información necesaria antes de iniciar Phase 0

Para trabajar con precisión debe estar actualizado en el repositorio remoto:

1. YAML/source actual de `scr_Home`;
2. YAML/source actual de `scr_PunchReview`;
3. componentes premium actualmente usados por Home;
4. cualquier componente candidato a reutilización;
5. contracts/flows que alimentan el Punch dashboard.

Si el repositorio remoto no contiene el último estado de Studio, debe sincronizarse antes de auditar. No se debe construir Home_PDS contra una versión obsoleta de Home.

---

# 18. Decisión final de esta especificación

La estrategia recomendada es **construcción paralela desde cero**, no refactorización destructiva de Home.

Esto permite que PDS, arquetipos y protocolo modular se prueben juntos sobre un caso real de alto valor sin poner en riesgo la pantalla operativa existente.