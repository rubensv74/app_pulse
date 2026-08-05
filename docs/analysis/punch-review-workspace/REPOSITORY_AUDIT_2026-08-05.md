# PULSE — Auditoría actualizada de Home, Punches y Punch Review Workspace

**Fecha:** 2026-08-05  
**Rama auditada:** `main`  
**Commit de partida:** `0e4bcefcbaa9a4179bd36835317c188fbc807be1`  
**Alcance:** `main/screens/Home`, `main/screens/Punches`, `main/components` y `sql/schema_warroom`.

## 1. Resumen ejecutivo

El repositorio ya permite reconstruir con suficiente precisión el estado actual del dashboard y del detalle de Punches. La situación no responde a un único defecto visual; existen varios problemas de integración superpuestos:

1. La navegación aplica un prerrequisito global de configuración publicada a pantallas que no lo necesitan.
2. Home referencia una instancia `cmpHomePunchSmartFilterBar` que no existe en el árbol de controles.
3. `cmp_DataTableProV2_1` está conectado explícitamente a dos filas de demostración, totales ficticios y un ancho fijo de 1380 px.
4. `cmp_DonutPro` recibe datos válidos —la leyenda se dibuja—, pero el anillo depende de un SVG directo dentro de `HtmlViewer`; esa es la frontera que no está renderizando en la aplicación actual.
5. El panel de detalle seleccionado no contiene ningún donut ni gráfico de barras. Solo muestra textos, porcentajes y navegación a Punches.
6. La consulta de detalle de celda devuelve una página de Punches y no devuelve agregados completos por prioridad o disciplina. Calcular gráficos sobre esa página produciría resultados parciales.
7. El drawer actual de Punches mezcla contratos de Tasks y Punches. La paginación de comentarios cambia el orden de parámetros entre la carga inicial y los botones siguiente/anterior.
8. No existe en SQL una entidad persistente de revisión de Punches (`IsReviewed`, sesión, revisor, fecha o control de concurrencia).

La estrategia correcta es una remediación por capas: estabilizar navegación y Home, conectar SmartBar y grid real, corregir el render del donut, añadir agregados completos de celda y construir un `scr_PunchReview` dedicado que reutilice las operaciones de comentarios y custom fields sin reutilizar el drawer como contenedor principal.

## 2. Inventario relevante confirmado

### Pantallas

- `main/screens/Home/scr_Home_1.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`

### Componentes

- `cmp_DonutPro.pa.yaml`
- `cmp_DataTableProV2.pa.yaml`
- `cmp_SmartFilterBarPro.pa.yaml`
- `cmp_HeatMapPro.pa.yaml`
- `cmp_KpiCardPro.pa.yaml`
- `cmp_CustomFieldEditor.pa.yaml`
- `cmp_DetailDrawer_old.pa.yaml`
- componentes visuales ejecutivos y de navegación.

### SQL y contratos recuperados

- `usp_GetPunchDashboardBundle`
- `usp_GetPunchDashboardCellDetailsPaged`
- `usp_GetPunchCommentsPaged`
- `usp_AddPunchComment`
- `usp_DeletePunchComment`
- `usp_CustomBundle_GetJson`
- `usp_CustomSaveBulk_GetJson`
- `usp_CustomField_ListJson`
- `usp_CustomField_Upsert_AndListJson`
- `usp_CustomField_SetActive`
- `usp_ActivityLog_Insert`
- tablas `CustomFieldDef`, `CustomFieldValue`, `PunchComment` y `ActivityLog`.

La correspondencia Flow/SP no es literalmente idéntica en todos los casos. Por ejemplo, Canvas llama a `warroom_GetPunchDashboardCellDetails`, mientras SQL expone `usp_GetPunchDashboardCellDetailsPaged`; el flow genérico de comentarios recibe `EntityType`, mientras SQL mantiene procedimientos separados para Task y Punch. Esto no impide trabajar, pero obliga a documentar el enrutamiento real.

## 3. Hallazgos priorizados

| ID | Severidad | Hallazgo | Impacto | Acción |
|---|---|---|---|---|
| A-01 | Crítica | `cmp_NavApp_2` y `cmp_NavApp_Punches_2` calculan `_hasConfig = varProjectHasReportConfig || varHomeHiveLoaded || varProjectHasPHRData` y bloquean Overview, Tasks, Punches, Briefing, Config y Skyline en conjunto. | Un proyecto seleccionado no puede abrir Punches ni Config si no existe configuración publicada. | Sustituir la barrera global por prerrequisitos por destino. |
| A-02 | Alta | Home ejecuta `Reset(cmpHomePunchSmartFilterBar)`, pero no existe una instancia del componente en la pantalla. | Referencia colgante y SmartBar ausente. | Insertar `cmp_SmartFilterBarPro_Stable` con el nombre esperado o eliminar todas las referencias. La guía adopta la inserción. |
| A-03 | Crítica | `cmp_DataTableProV2_1.Rows` contiene `PULSE-02457` y `PULSE-02459`; `TotalCount=248`, `TotalPages=10`, `Width=1380`. | Datos falsos, paginación falsa y grid recortado. | Enlazar `Rows=colHomePunchGridView`, metadatos reales y ancho relativo al padre. |
| A-04 | Alta | El componente donut dibuja el anillo con SVG directo en `HtmlViewer@2.1.0`; la leyenda usa controles nativos y sí aparece. | Tarjeta sin visual principal aunque la colección es válida. | Migrar únicamente la capa gráfica a `Image@2.2.3` con URI SVG y `EncodeUrl`, conservando leyenda y contrato. |
| A-05 | Media | `cmp_DonutPro` usa la variable global `varDNP_SelectedSegmentKey`. | Dos instancias comparten selección. | Desactivar selección en donuts de Home o introducir `InstanceKey` y estado por instancia. |
| A-06 | Alta | `conPunchExecutiveDetailSlot` no contiene gráficos. | El requisito de donut + distribución por disciplina no está implementado. | Incorporar colección agregada completa y dos visuales; no calcular sobre una sola página. |
| A-07 | Alta | `usp_GetPunchDashboardCellDetailsPaged` devuelve filas paginadas, pero no distribuciones agregadas. | Un gráfico generado desde `colPunchExecutiveGridFiltered` representa solo la página actual. | Extender el contrato o crear un endpoint de analítica de celda. |
| A-08 | Alta | Header de 56 px con bloques cuyo mínimo conjunto supera el ancho disponible. El título declara `LayoutMinWidth=220`, su bloque 390 px y los selectores/refresh tienen anchos rígidos. | Compresión, solapamiento y aspecto roto. | Agrupar acciones y aplicar layout responsive en dos niveles. |
| A-09 | Crítica | El drawer usa `Warroom_GetTaskCommentsPaged` para Punches; carga inicial y recarga usan `(ProjectId, RecordId, Page, Size, EntityType)`, pero siguiente/anterior usan `(ProjectId, EntityType, RecordId, Page, Size)`. | Paginación de comentarios potencialmente inválida. | Unificar el orden en todas las llamadas y validar el enrutamiento del flow. |
| A-10 | Alta | El tab History del drawer no tiene carga funcional demostrable. | No existe trazabilidad visible de la revisión. | Consumir `ActivityLog` o crear un endpoint específico de historial. |
| A-11 | Alta | No existe estado persistente de Punch Review ni `RowVersion`. | “Marcar revisado” solo puede ser temporal y no es seguro ante concurrencia. | Añadir tabla de estado, historial y SP de escritura optimista. |
| A-12 | Media | `cmp_CustomFieldEditor` representa todos los tipos con un único `TextInput` y no expone una colección de valores editados. | No sustituye la lógica tipada del drawer. | Usarlo solo como shell visual o evolucionarlo antes de reutilizarlo. |
| A-13 | Media | SmartBar y Donut almacenan estado interno en variables globales. | Colisiones entre instancias y pantallas. | Mantener una instancia por pantalla en el MVP y planificar estado por `InstanceKey`. |
| A-14 | Media | El filtrado SmartBar sobre la colección cargada es local a la página de servidor. | Conteos/paginación pueden no representar todo el conjunto. | Etiquetar el alcance en el MVP y mover búsqueda/orden/filtros al backend en la fase siguiente. |

## 4. Diagnóstico específico de `cmp_DonutPro.pa.yaml`

El contrato del componente es correcto para el dashboard. `Items` exige:

- `SegmentKey`
- `SegmentLabel`
- `SegmentValue`
- `SegmentColor`
- `SegmentOrder`

Home genera `colHomePunchDonutItems` con ese esquema y la captura muestra leyenda, valores y porcentajes. Por tanto, no hay evidencia de que el problema primario sea la colección.

La parte que falta se concentra en `htmlDNP_Donut`:

- control `HtmlViewer@2.1.0`;
- SVG directo dentro de `HtmlText`;
- leyenda fuera del HTML mediante una gallery nativa.

La misma pantalla ya demuestra un patrón que sí funciona: controles `Image@2.2.3` con `"data:image/svg+xml;utf8," & EncodeUrl(svg)`. La remediación debe reutilizar ese patrón en el componente.

Además, `varDNP_SelectedSegmentKey` es global. Si el dashboard incorpora un segundo donut, ambos compartirán selección. Para Home se recomienda `EnableSelection=false` en las dos instancias hasta introducir estado por instancia.

## 5. Diagnóstico del grid y SmartBar

Home ya contiene la cadena de colecciones y variables necesaria:

- `colPunchExecutiveGridFiltered`
- `colHomePunchGridNormalized`
- `colHomePunchGridView`
- `varHomePunchSearchText`
- `varHomePunchQuickFilter`
- `varHomePunchGridDensity`
- `varHomePunchGridSortKey`
- `varHomePunchGridSortDirection`
- paginación `varPunchExecutiveGrid*`.

También existe `btnHome_RebuildPunchGridView`, que normaliza la página de servidor y aplica búsqueda, quick filter y ordenación. El defecto es de enlace: la instancia visible de `cmp_DataTableProV2` ignora esa cadena y utiliza una tabla literal.

La SmartBar validada está definida bajo el nombre de componente `cmp_SmartFilterBarPro_Stable`, aunque el archivo se llama `cmp_SmartFilterBarPro.pa.yaml`. Este nombre debe respetarse al insertarla.

## 6. Diagnóstico del panel de detalle

`conPunchExecutiveDetailSlot` solo contiene:

- estado vacío;
- botón Clear Selection;
- contexto fila × columna;
- PunchCount;
- porcentajes;
- botón Open in Punch List.

No contiene una instancia de donut ni una gallery de barras.

La celda de heatmap representa un subcontractor/categoría y el SP de detalle restringe los resultados a estados abiertos. Por eso un donut de Status o Category sería prácticamente monocolor. Para que aporte información, la propuesta de implementación utiliza:

- donut por prioridad;
- barras horizontales por disciplina.

Ambos deben calcularse sobre el conjunto completo de la celda, no sobre la página visible.

## 7. Decisión de arquitectura para Punch Review Workspace

Se descarta ampliar `cmp_DetailDrawer_old` como workspace principal por cuatro razones:

1. Está acoplado a variables globales y `AccessAppScope`.
2. Su anchura máxima aproximada es 720 px, insuficiente para cola + detalle + colaboración.
3. Mezcla contratos de Task y Punch.
4. No implementa historial ni estado persistente de revisión.

La solución recomendada es una pantalla dedicada `scr_PunchReview`, abierta desde Home y Punches mediante una cola normalizada. El drawer puede seguir existiendo durante la transición y servir como referencia funcional, pero no como nuevo contenedor.

### Alcance MVP seguro

- cola formada por las filas actualmente cargadas;
- navegación anterior/siguiente;
- Overview;
- comentarios;
- custom fields;
- estado local “revisado en esta sesión”;
- retorno al origen.

### Alcance persistente posterior

- estado revisado en SQL;
- historial;
- control de concurrencia;
- cola estable superior a una página;
- exportación por estado de revisión.

## 8. Riesgos que no deben ocultarse

- Los gráficos de celda serán incorrectos si se agregan desde una página paginada.
- La SmartBar será page-local mientras el SP no acepte sus criterios.
- Marcar revisado no debe presentarse como persistente hasta disponer de SQL y flow.
- No debe reutilizarse el orden de parámetros defectuoso del drawer.
- La correspondencia entre nombres de flows y SP debe verificarse por cada operación, no asumirse globalmente.

## 9. Orden de implementación recomendado

1. Corregir navegación.
2. Reparar header.
3. Sustituir render del donut.
4. Insertar SmartBar y conectar DataTable real.
5. Incorporar analítica completa de celda.
6. Crear `scr_PunchReview` MVP.
7. Corregir comentarios y custom fields compartidos.
8. Añadir persistencia de revisión e historial.
9. Ejecutar pruebas de regresión en Home y Punches.

La guía ejecutable asociada se archiva en `docs/guides/PUNCH_REVIEW_WORKSPACE_HOME_REMEDIATION_GUIDE.md`.
