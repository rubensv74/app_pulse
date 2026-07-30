# PULSE — Auditoría de filtros y exportación de Punches

Fecha de auditoría: 2026-07-30
Rama inspeccionada: `main`
Commit inspeccionado: `bde5781492562b831eb077087732adbd31cc88bc`
Alcance: auditoría estática previa a cualquier corrección

## 1. Resumen ejecutivo

La cadena Home → Punches → Power Automate → SQL → Office Script está
implementada, pero el baseline no es internamente consistente y todavía no
puede considerarse estable.

Se han identificado cuatro causas raíz principales:

1. **El procedimiento de snapshot y el DDL versionado no describen el mismo
   modelo SQL.** El procedimiento actual espera `ExportBatchId
   uniqueidentifier` y una columna `PunchExportLogId`; el DDL de
   `001_import_foundations.sql` crea `ExportBatchId bigint`, no crea
   `PunchExportLogId` y declara `ExportBatchRow.RowVersion binary(8) NULL`.
2. **El error de `RowVersion` solo es compatible con un esquema desplegado
   distinto del DDL versionado.** El procedimiento inserta explícitamente
   `NULL`. Si el entorno rechaza ese valor, su columna es `NOT NULL`, tiene
   otra definición o existe otro objeto/trigger no representado en Git.
3. **La navegación desde Home no establece un contrato completo de filtros.**
   Algunos KPI inicializan todos los filtros, otros solo una parte y varios
   accesos genéricos no inicializan ninguno. `scr_Punches_1.OnVisible`
   conserva el estado previo cuando el origen es `Dashboard`, permitiendo que
   filtros antiguos contaminen el listado y la exportación.
4. **La solución activa sigue conectada al Flow legado.** El source de la
   solución llama a `Warroom_ExportPunchesToExcel`, mientras la copia de
   trabajo y el contrato v3 llaman a
   `Warroom_ExportPunchesToExcel_Codex`.

El modal usa `colPunchExportColumns` como fuente de verdad y su JSON se genera
desde esa colección. Sin embargo, la selección se representa con botones
simulados, existen varias copias divergentes de la pantalla y no hay evidencia
runtime que demuestre que la galería refresca de forma coherente después de
`UpdateIf`. El problema visual comunicado no puede atribuirse todavía a una
única fórmula sin reproducirlo en Power Apps Studio.

No se ha consultado el entorno Azure/Power Platform desplegado. Por ello, toda
afirmación sobre el entorno se marca como pendiente de verificación y no se
presupone que coincida con Git.

## 2. Estado e inventario

### 2.1. Git

- Worktree limpio al comenzar la auditoría.
- Rama actual: `main`.
- Último commit:
  `bde5781 refactor: Enhance validation and structure of Punch export snapshot procedures`.
- Ese commit modifica únicamente:
  `sql/export/002_register_punch_export_snapshot.sql`.
- No se ha creado la rama recomendada porque esta fase solo autoriza auditoría.

### 2.2. Power Apps

Archivos fuente principales:

- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Src/App.fx.yaml`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Src/scr_Home_1.fx.yaml`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Src/scr_Punches_1.fx.yaml`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Other/Src/scr_Home_1.pa.yaml`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Other/Src/scr_Punches_1.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`

Conexión del Flow:

- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Connections/Connections.json`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/DataSources/Warroom_ExportPunchesToExcel.json`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/pkgs/Wadl/Warroom_ExportPunchesToExcel.xml`

### 2.3. Power Automate

- `flows/Warroom_ExportPunchesToExcel_Codex/definition.deploy.json`
- `flows/Warroom_ExportPunchesToExcel_Codex/definition.corrected.json`
- `flows/Warroom_ExportPunchesToExcel_Codex/definition.source.json`
- `flows/Warroom_ExportPunchesToExcel_Codex/Warroom_ExportPunchesToExcel_Codex.zip`
- `power-platform/solutions/PULSE/Workflows/Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json`

### 2.4. SQL

- `sql/import/001_import_foundations.sql`
- `sql/import/003_seed_import_columns_v3.sql`
- `sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
- `sql/export/002_register_punch_export_snapshot.sql`

### 2.5. Office Scripts

- `office-scripts/BuildPunchExport.ts`

### 2.6. Contratos, pruebas y documentación

- `main/contracts/excel-import/export-columns.v3.json`
- `main/mappings/excel-import/punch-columns.v3.json`
- `main/tests/excel-export/Inspect-PunchExport.ps1`
- `main/tests/i01.1/Test-I01_1.ps1`
- `docs/I01_1_E2E_VALIDATION.md`
- `docs/EXCEL_IMPORT_ARCHITECTURE.md`
- `docs/README_SPRINT_I01_1.md`
- `flows/Warroom_ExportPunchesToExcel_Codex/README.md`

## 3. Flujo real reconstruido

### 3.1. Home → Punches

Existen varias rutas:

1. El KPI general `cmpHomeKpiPunches` establece:
   `ReturnView`, `ContextSource`, `FilterSource = "Dashboard"` y
   `CustomFiltersJson = "[]"`, pero no limpia ni establece Template,
   Subsystem, Category, Status, Discipline o Subcontractor.
2. Las celdas de status de la matriz establecen Template, Status y Category y
   limpian los demás filtros.
3. Las filas de subsystem establecen Template, Status, Category y Subsystem.
4. Las filas de subcontractor/discipline establecen Template, Status,
   Category, Subcontractor y Discipline.
5. Los Executive Insights solo establecen Template; no limpian el resto.
6. Los accesos genéricos `View punches` y navegación lateral solo navegan y no
   establecen un contrato completo de contexto.

Después se ejecuta `Navigate(scr_Punches, ScreenTransition.None)`.

### 3.2. `scr_Punches_1.OnVisible`

El evento:

- limpia Subsystem únicamente cuando `FilterSource <> "Dashboard"`;
- cuando el origen es `Dashboard`, conserva todos los filtros recibidos y
  también cualquier filtro antiguo no sobrescrito;
- activa `HasSearched`, página 1 y `AutoLoad`;
- carga catálogos si procede;
- al final ejecuta el botón oculto de carga si `AutoLoad = true`.

No existe una operación atómica que reciba un registro de contexto completo.
El contrato se implementa mediante variables globales independientes.

### 3.3. Carga del listado

`Warroom_Punches_Filtered_Paged.Run(...)` recibe:

1. ProjectId
2. SubsystemsCsv
3. PunchDiscipline
4. Subcontractor
5. Page
6. PageSize
7. TemplateId
8. CategoryCode
9. StatusCode
10. CustomFiltersJson

Normalización observada:

- texto vacío → `" "`;
- Template vacío → `0`;
- JSON vacío → `"[]"`;
- página y tamaño → valores numéricos.

### 3.4. Apertura y selección del modal

Al pulsar Export:

- se fuerza el modo `CLIENT`;
- se reconstruye `colPunchExportColumns`;
- las columnas públicas se crean con `IsSelected = true`;
- las sensibles se crean con `IsSelected = false`;
- los custom fields se consideran sensibles y comienzan desmarcados.

El modo `CLIENT` reconstruye la colección con:
`IsSelected = !IsSensitive`.

El modo `INTERNAL` reconstruye la colección con:
`IsSelected = true`.

La galería usa la colección ordenada por `SortOrder`. Cada fila contiene un
botón visual que alterna:

`UpdateIf(colPunchExportColumns, ColumnKey = ThisItem.ColumnKey, ...)`.

`Select all` ejecuta `UpdateIf(..., true, {IsSelected: true})`.

`Clear optional` no es realmente `Clear all`: conserva seleccionadas las
columnas `IsRequired`. Esto no satisface literalmente la regla solicitada de
establecer todas las filas a `false`.

El botón Continue se deshabilita cuando no hay filas seleccionadas y vuelve a
validar esa condición en `OnSelect`.

### 3.5. Punches → Flow

La copia activa de la solución llama:

`Warroom_ExportPunchesToExcel.Run(...)`.

La copia `main/screens/Punches/scr_Punches_1.pa.yaml` llama:

`Warroom_ExportPunchesToExcel_Codex.Run(...)`.

Los 12 argumentos tienen el orden contractual correcto:

1. ProjectId
2. SubsystemCode/SubsystemsCsv
3. TemplateId
4. CategoryCode
5. StatusCode
6. PunchDiscipline
7. Subcontractor
8. CustomFiltersJson
9. RequestedByEmail
10. RequestedByName
11. ExportMode
12. SelectedColumnsJson

El listado y la exportación leen las mismas variables base de filtros. La
exportación vuelve a normalizarlas, de forma equivalente pero no compartiendo
una única función o registro inmutable.

### 3.6. Flow → SQL → Excel

La definición desplegable `_Codex`:

1. normaliza modo y columnas;
2. inicia `PunchExportLog`;
3. obtiene filas pivotadas;
4. obtiene el mapa de columnas;
5. registra el snapshot;
6. solo después lee la plantilla y crea el archivo;
7. ejecuta `BuildPunchExport`;
8. crea el enlace;
9. completa el log;
10. completa el batch;
11. devuelve la respuesta a Power Apps.

Respuesta:

- `success`
- `fileurl`
- `filename`
- `rowcount`
- `message`

## 4. Causas raíz y respuestas obligatorias

### 4.1. SQL snapshot y `RowVersion`

#### ¿Qué tabla e INSERT provocan el NULL?

En el repositorio, el único INSERT relevante es el de
`warroom.ExportBatchRow` dentro de
`warroom.usp_RegisterPunchExportSnapshot`.

El procedimiento incluye explícitamente `RowVersion` en la lista de columnas
y proyecta `RowVersion = NULL`.

El mensaje observado indica que la tabla desplegada que recibe ese INSERT
rechaza el NULL. Con los archivos de Git no se puede demostrar si existe un
trigger que redirige el dato a otra tabla, pero no hay tal trigger versionado.

#### ¿Qué definición tiene `RowVersion`?

En Git:

`binary(8) NULL`

No es una columna SQL `rowversion/timestamp`. Es una columna binaria nullable
reservada para una futura versión de fila procedente de la tabla Punch.

El contrato v3 también declara el campo nullable y la documentación afirma que
debe quedar vacío hasta que el origen exponga un rowversion real.

#### ¿Debe omitirse del INSERT?

Con el diseño versionado, tanto omitirla como insertar `NULL` son válidos
porque la columna admite NULL. Omitirla expresa mejor que el valor todavía no
existe, pero no arreglaría un esquema desplegado `NOT NULL` sin default.

No debe inventarse `0x0000000000000000`, un timestamp ni otro valor
arbitrario. Primero debe decidirse y migrarse el esquema canónico.

#### ¿Existe default?

El DDL versionado no define default para `ExportBatchRow.RowVersion`.

#### ¿Repositorio y entorno difieren?

Sí, al menos por inferencia obligada por el error: el DDL versionado admite
NULL y el entorno comunicado lo rechaza.

Además, Git difiere consigo mismo:

- `001_import_foundations.sql`: `ExportBatchId bigint`.
- procedimiento actual: variable `ExportBatchId uniqueidentifier`.
- `001_import_foundations.sql`: no tiene columna `PunchExportLogId`.
- procedimiento actual: consulta e inserta `PunchExportLogId`.

El procedimiento actual no puede ejecutarse contra una base creada únicamente
con el DDL actual del repositorio.

#### ¿Quedan batches huérfanos?

El INSERT de `ExportBatch` y el INSERT de `ExportBatchRow` están dentro de la
misma transacción con `XACT_ABORT ON` y rollback en `CATCH`. Un fallo de
`RowVersion` debería revertir ambos, por lo que no debería dejar un
`ExportBatch` sin sus filas.

Sí puede quedar un `PunchExportLog` iniciado y no completado, porque
`usp_PunchExportLog_Start` se ejecuta antes y fuera de esa transacción. El Flow
no tiene una acción SQL de compensación que marque ese log como fallido.

El archivo tampoco debería existir todavía: el Flow condiciona la lectura de
plantilla a que el registro del snapshot termine correctamente.

La existencia real de huérfanos debe comprobarse en el entorno.

#### ¿Cómo asegurar idempotencia?

- clave única estable por `PunchExportLogId`;
- bloqueo `UPDLOCK, HOLDLOCK` al consultar el batch;
- comparación de datos inmutables y row count en reintentos;
- transacción única para cabecera y filas;
- finalización `CREATED → READY` idempotente;
- compensación explícita del `PunchExportLog` cuando el snapshot o pasos
  posteriores fallen;
- no reutilizar el mismo log con payload diferente.

El procedimiento actual intenta implementar estas reglas, pero no puede
validarse hasta alinear el esquema.

### 4.2. Home → Punches

#### ¿Qué KPI fallan?

La evidencia runtime no está disponible. Estáticamente son candidatos:

- `cmpHomeKpiPunches`;
- ambos `cmpPunchInsight...`;
- `cmpPunchInsightsHeader.OnAction`;
- navegación genérica a Punches.

Las celdas de matriz y filas de subsystem/subcontractor inicializan más
campos y son menos propensas a heredar contexto, aunque requieren prueba.

#### ¿Qué variables establece cada uno?

- KPI general: origen/contexto y JSON, sin filtros específicos.
- Insights: origen/contexto, JSON y Template.
- Matriz: Template, Status, Category y limpieza de filtros restantes.
- Subsystem: Template, Status, Category y Subsystem.
- Subcontractor: Template, Status, Category, Subcontractor y Discipline.
- Accesos genéricos: navegación/vista, sin contrato completo.

#### ¿Qué consume Punches?

Consume directamente:

- `varProjectId`
- `varFilter_SubsystemsCsv`
- `varFilter_Subsystem`
- `varFilter_PunchTemplateId`
- `varFilter_PunchCategoryCode`
- `varFilter_PunchStatusCode`
- `varFilter_PunchDiscipline`
- `varFilter_Subcontractor`
- `varPunchCustomFiltersJson`
- `varPunches_FilterSource`
- `varPunches_AutoLoad`

#### ¿Qué acción las borra?

`OnVisible` solo limpia Subsystem cuando el origen no es Dashboard. Los KPI
específicos limpian selectivamente variables antes de navegar. No hay un reset
centralizado de todo el contexto.

#### ¿La carga ocurre antes de recibir filtros?

En las rutas específicas, los `Set(...)` preceden a `Navigate(...)`, por lo
que los filtros deberían existir antes de `OnVisible`. El problema principal
no es el orden, sino los campos no inicializados que conservan valores previos.

#### ¿Listado y exportación comparten estado?

Sí, ambos leen las mismas variables globales. No obstante, cada camino aplica
su propia normalización y no existe un snapshot de filtros común, por lo que un
cambio de variable entre carga y exportación podría producir divergencia.

#### ¿`OnVisible` resetea filtros?

Parcialmente. Para Dashboard los preserva; para Manual solo limpia Subsystem.
No resetea de forma uniforme Template, Category, Status, Discipline,
Subcontractor ni CustomFiltersJson.

### 4.3. Modal de columnas

#### ¿La fuente de verdad es la colección?

Sí. UI, contador, habilitación de Continue y JSON leen
`colPunchExportColumns`.

#### ¿`Default = ThisItem.IsSelected`?

No existe un control CheckBox. El check es un botón cuyo borde, relleno y texto
dependen de `ThisItem.IsSelected`.

#### ¿Los Patch apuntan al registro correcto?

No se usa `Patch`; se usa `UpdateIf` por `ColumnKey`. La fórmula es
razonable si `ColumnKey` es único, pero debe validarse en Studio porque el
problema visual comunicado puede depender del refresco del registro de
galería.

#### ¿Select All modifica toda la colección?

Sí, estáticamente usa condición `true`. No hay `Reset` posterior.

#### ¿Hace falta Reset?

Con botones dependientes directamente de `ThisItem.IsSelected`, no debería ser
necesario. Si se sustituye por CheckBox, el requisito dependerá del patrón
elegido y deberá evitarse estado interno separado de la colección.

#### ¿INTERNAL/CLIENT reconstruyen bien el estado?

- INTERNAL: todas las filas a `true`.
- CLIENT: públicas a `true`, sensibles a `false`.

La fórmula CLIENT no incluye explícitamente `|| IsRequired`; hoy las columnas
required conocidas no son sensibles. El botón `Select public`, en cambio, sí
usa `!IsSensitive || IsRequired`. Hay una inconsistencia de reglas.

#### ¿El JSON coincide con la selección?

Estáticamente sí: filtra `IsSelected`, ordena y proyecta `ColumnKey`,
`ColumnLabel` y `SortOrder`.

#### ¿Hay clave única estable?

Las columnas fijas usan claves literales. Los custom fields usan
`"CF__" & FieldKey`. No hay validación local de duplicados. Debe comprobarse
unicidad en los datos de `colCT_Defs_Admin`.

#### Causa raíz más probable

No se puede confirmar una sola causa sin reproducción. Los factores concretos
son:

- múltiples copias divergentes de la pantalla;
- controles visuales simulados en lugar de CheckBox;
- ausencia de reset explícito tras operaciones masivas;
- reglas CLIENT ligeramente distintas entre selector de modo y Select public;
- falta de validación de unicidad de `ColumnKey`;
- `Clear optional` no implementa el `Clear all` solicitado.

### 4.4. Flow

#### ¿Los 12 inputs llegan bien?

La definición `_Codex` declara las 12 claves correctas y obligatorias. La copia
de trabajo `_Codex` respeta el orden. La solución activa, sin embargo, llama al
Flow legado, por lo que no está demostrado que use esa definición.

#### ¿Los vacíos se normalizan igual?

Listado y exportación usan `" "`, `0` y `"[]"` de forma equivalente, aunque en
fórmulas duplicadas. El Flow normaliza modo y columnas, pero pasa los filtros
textuales a SQL según los valores recibidos.

#### ¿Hay una única connection reference SQL?

No. La definición contiene los alias:

- `shared_sqldw`
- `shared_sqldw_2`
- `shared_sqldw_3`

En la solución apuntan al mismo logical name, pero siguen siendo tres alias de
conexión. En las definiciones fuente aparecen conexiones físicas diferentes.
No satisface todavía el criterio de una única referencia SQL aprobada.

#### ¿La acción SQL usa la firma actual?

El Flow pasa los ocho parámetros requeridos por el procedimiento actual. El
problema es la incompatibilidad entre el procedimiento y el esquema de tablas,
no la lista de parámetros del Flow.

#### ¿Git y entorno divergen?

Git contiene cuatro variantes:

- `definition.source.json`: Flow legado sin snapshot.
- `definition.corrected.json`: legado corregido, aún sin snapshot.
- `definition.deploy.json`: `_Codex` con snapshot.
- Workflow de la solución: acciones equivalentes a deploy.

No se dispone de export reciente del Flow desplegado ni de run-history
completo para compararlo.

#### ¿La respuesta coincide con Power Apps?

La definición `_Codex` devuelve los cinco campos consumidos por la fórmula.
La conexión Canvas activa pertenece al Flow legado, por lo que su metadata
puede no representar esa respuesta.

## 5. Office Script

Contrato:

- `rowsJson`
- `columnMapJson`
- `exportInfoJson`
- `exportMode`
- `selectedColumnsJson`

Comportamiento verificado estáticamente:

- crea/reutiliza las hojas gestionadas;
- crea `tblPunches`;
- añade `ExportBatchId`, `WorkItemId`, `RowVersion`, `ExportedAtUtc` y
  `RowChecksum`;
- fija `RowVersion` a cadena vacía;
- excluye `OriginalValuesJson`;
- en CLIENT elimina hojas técnicas y fuerza `CanBeImported = false`;
- protege la hoja;
- aplica selección de columnas únicamente a CLIENT; INTERNAL usa todas las
  columnas finales.

Riesgo contractual: el script deriva `ExportBatchId` de `PunchExportLogId`,
mientras el procedimiento SQL de `bde5781` separa ambos identificadores y crea
un GUID nuevo. El workbook y el snapshot dejarían de compartir el mismo
`ExportBatchId`. Esta es otra incompatibilidad introducida por el modelo SQL
actual.

## 6. Discrepancias consolidadas

| Área | Artefacto A | Artefacto B | Impacto |
|---|---|---|---|
| SQL ID | DDL: `ExportBatchId bigint` | SP: `uniqueidentifier` | El SP no compila/ejecuta contra el DDL. |
| SQL relación | DDL sin `PunchExportLogId` | SP usa esa columna | Error de columna inexistente contra el DDL. |
| RowVersion | Git: `binary(8) NULL` | Entorno comunicado: rechaza NULL | Migración o despliegue divergente. |
| Workbook ID | Script usa PunchExportLogId | SP genera GUID | Excel no referencia el batch persistido. |
| Canvas Flow | Solución usa Flow legado | Contrato usa `_Codex` | Firma/respuesta y acciones pueden divergir. |
| SQL connections | Tres alias SQL | Criterio exige una | Rebinding y gobernanza frágiles. |
| Home context | Rutas completas y parciales | OnVisible preserva estado | Filtros obsoletos. |
| Modal CLIENT | `!IsSensitive` | Select public: `!IsSensitive || IsRequired` | Reglas no idénticas. |
| Clear | `Clear optional` | Requisito `Clear all` | Comportamiento funcional distinto. |
| Pruebas/docs | rutas `main/...` antiguas | baseline usa carpetas raíz | Pruebas estáticas fallan por ruta. |

## 7. Plan del sprint de estabilización

### Bloque A — SQL snapshot

#### Archivos

- `sql/import/001_import_foundations.sql`
- `sql/export/002_register_punch_export_snapshot.sql`
- `main/contracts/excel-import/export-columns.v3.json`
- `main/mappings/excel-import/punch-columns.v3.json`
- `office-scripts/BuildPunchExport.ts`, solo si cambia el identificador
  canónico.

#### Acciones

1. Extraer del entorno el DDL real de ambas tablas, constraints, defaults,
   índices y triggers, y el texto de ambos procedimientos.
2. Elegir un único modelo de identidad:
   - mantener `ExportBatchId = PunchExportLogId bigint`, o
   - separar GUID y log, migrando contrato, workbook y FKs.
3. Definir `RowVersion` como nullable mientras el origen no exponga un
   rowversion real.
4. Crear una migración explícita e idempotente; no depender solo de
   `CREATE TABLE IF NOT EXISTS`.
5. Añadir compensación/estado fallido para `PunchExportLog`.
6. Consultar y clasificar posibles logs/batches huérfanos antes de corregirlos.

#### Pruebas

- despliegue desde cero;
- migración sobre esquema existente;
- snapshot nuevo;
- reintento idéntico;
- reintento con payload distinto;
- fallo durante filas y rollback;
- finalización repetida;
- comprobación de huérfanos.

#### Rollback

- script inverso de migración probado;
- backup de definiciones y datos afectados;
- no borrar batches/logs automáticamente;
- restaurar SP anterior si falla la migración.

#### Aceptación

- DDL, SP, contrato y Office Script usan el mismo identificador;
- NULL de RowVersion aceptado de forma intencional;
- cabecera y filas atómicas;
- batch termina READY;
- no aparecen nuevos huérfanos.

### Bloque B — filtros Home → Punches

#### Archivos

- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Src/scr_Home_1.fx.yaml`
- `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_src/Src/scr_Punches_1.fx.yaml`
- representaciones `.pa.yaml` regeneradas;
- `.msapp` regenerado mediante herramienta/Studio.

#### Acciones

1. Definir un contrato único de navegación con todos los filtros.
2. Hacer que cada KPI establezca explícitamente cada campo, incluido Blank.
3. Evitar herencia accidental de variables antiguas.
4. Aplicar el contexto antes de activar AutoLoad.
5. Capturar un snapshot de filtros para que listado y exportación usen el mismo
   estado.

#### Pruebas

- cada KPI desde estado limpio;
- cada KPI después de otro KPI distinto;
- navegación manual después de Dashboard;
- vuelta Home → Punches repetida;
- comparación de parámetros de listado y exportación.

#### Rollback

- restaurar fórmulas de navegación y OnVisible del commit base;
- no alterar componentes visuales.

#### Aceptación

- controles, listado y exportación reflejan el mismo contexto;
- ningún filtro anterior sobrevive si la ruta no lo especifica;
- carga automática ocurre una sola vez con el contexto completo.

### Bloque C — modal de columnas

#### Archivos

- `scr_Punches_1.fx.yaml`
- representaciones derivadas de la Canvas App.

#### Acciones

1. Mantener la colección como única fuente de verdad.
2. Validar unicidad de `ColumnKey`.
3. Unificar la regla CLIENT en todas las acciones.
4. Implementar el comportamiento exacto de Clear all.
5. Confirmar si el botón simulado refresca correctamente; usar CheckBox solo
   si la reproducción demuestra que es necesario y sin rediseñar el modal.
6. Generar el JSON únicamente al continuar y desde la colección vigente.

#### Pruebas

- defaults CLIENT e INTERNAL;
- selección múltiple manual;
- toggles repetidos;
- Select all;
- Clear all;
- cambio CLIENT ↔ INTERNAL;
- custom fields;
- comparación UI/colección/JSON.

#### Rollback

- restaurar únicamente fórmulas del modal;
- preservar catálogo y diseño visual existentes.

#### Aceptación

- UI, colección y JSON coinciden en todos los casos;
- cero columnas bloquea Continue;
- Select all y Clear all afectan todas las filas;
- perfiles aplican reglas documentadas.

### Bloque D — contrato Punches → Flow

#### Archivos

- DataSource, Connections y WADL de Canvas;
- `scr_Punches_1.fx.yaml`;
- Workflow `_Codex`;
- `definition.deploy.json`;
- paquete del Flow;
- pruebas y README.

#### Acciones

1. Conectar la Canvas únicamente a `_Codex`.
2. Retirar la referencia activa al Flow legado.
3. Consolidar a una única connection reference SQL aprobada.
4. Comparar export real del Flow desplegado con Git.
5. Verificar firma de 12 entradas y respuesta de cinco campos.
6. Regenerar artefactos derivados, sin editar el `.msapp` manualmente.

#### Pruebas

- JSON estricto;
- Flow Checker;
- App Checker;
- guardado y reapertura del Flow;
- llamada desde Power Apps;
- fallo estructurado.

#### Rollback

- export de seguridad del Flow y Canvas actuales;
- conservar temporalmente el Flow legado desactivado, sin eliminarlo hasta
  completar E2E;
- restaurar connection reference anterior si falla la importación.

#### Aceptación

- una sola referencia funcional `_Codex`;
- una sola referencia SQL;
- 12 entradas y cinco salidas estables;
- sin errores de checker.

### Bloque E — pruebas E2E

#### Archivos/evidencias

- `main/tests/i01.1/Test-I01_1.ps1`
- `main/tests/excel-export/Inspect-PunchExport.ps1`
- `docs/I01_1_E2E_VALIDATION.md`
- evidencia de SQL, run history, checker y workbook.

#### Acciones y pruebas

Ejecutar:

- sin filtros;
- KPI Home;
- subsystem;
- status/category;
- CLIENT;
- INTERNAL;
- selección manual;
- Select all;
- Clear all;
- error controlado;
- reintento.

Para cada caso relevante comparar:

- variables Power Apps;
- inputs del Flow;
- parámetros SQL;
- filas del listado;
- filas del snapshot;
- filas de `tblPunches`;
- respuesta `rowcount`.

#### Rollback

- ejecutar solo en no producción;
- revocar/eliminar archivos de prueba;
- conservar logs y batches de prueba identificables hasta cerrar evidencia;
- restaurar versiones exportadas si falla la importación.

#### Aceptación

- todos los criterios funcionales del encargo;
- cero errores en Flow Checker;
- Excel y enlace correctos;
- batch READY;
- checksums coherentes;
- sin nuevos logs o batches huérfanos.

## 8. Riesgos y dependencias

1. Acceso de solo lectura al SQL desplegado para obtener esquema y objetos.
2. Export actual del Flow desplegado y run history del fallo.
3. Power Apps Studio para reproducir el modal y regenerar conexiones.
4. Permisos y connection references de SQL, SharePoint y Excel Online.
5. `scriptId`, drive, biblioteca y rutas SharePoint ligados al entorno.
6. Riesgo de romper FKs si se cambia bigint por GUID sin migración integral.
7. Riesgo de invalidar workbooks existentes si cambia la semántica de
   `ExportBatchId`.
8. Posibles `PunchExportLog` abiertos por fallos previos.
9. Copias múltiples de Canvas/Flow que pueden volver a divergir.
10. Pruebas y documentación con rutas anteriores al baseline.

## 9. Criterios globales de cierre

El sprint se considerará cerrado únicamente cuando:

- el esquema desplegado coincida con el DDL versionado;
- `RowVersion` tenga una decisión documentada, migrada y probada;
- no haya incompatibilidad entre ExportBatchId y PunchExportLogId;
- todos los KPI probados apliquen el contexto correcto;
- listado y exportación usen exactamente los mismos filtros;
- modal, colección y JSON coincidan;
- la Canvas use únicamente `_Codex`;
- exista una sola referencia SQL aprobada;
- Flow Checker y App Checker no reporten errores nuevos;
- las pruebas E2E requeridas pasen;
- no se creen huérfanos;
- el workbook supere el inspector estructural.

## 10. Siguiente paso exacto

Antes de implementar, obtener del entorno no productivo y adjuntar a la
evidencia del sprint:

1. DDL real de `warroom.ExportBatch` y `warroom.ExportBatchRow`, incluidos
   constraints, defaults, índices y triggers.
2. Definición real de `warroom.usp_RegisterPunchExportSnapshot` y
   `warroom.usp_CompletePunchExportBatch`.
3. Export actual de `Warroom_ExportPunchesToExcel_Codex`.
4. Inputs/outputs y error completo de una ejecución fallida en
   `SQL_RegisterExportSnapshot`.
5. Consulta de `PunchExportLog`, `ExportBatch` y `ExportBatchRow` para el ID
   fallido.

Con esa evidencia se podrá aprobar el modelo SQL canónico y comenzar el Bloque
A en una rama nueva `fix/punch-export-filter-audit`. No debe modificarse código
antes de resolver esa decisión de esquema.
