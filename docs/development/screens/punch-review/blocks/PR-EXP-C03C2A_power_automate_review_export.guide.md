# PR-EXP-C03C2A — Flow dedicado para exportar Punch Review

**Objetivo:** crear un Flow específico para Punch Review reutilizando la arquitectura validada de `Warroom_ExportPunchesToExcel_Codex`, sin modificar todavía el Flow productivo usado por `scr_Punches`.

## Qué vamos a crear

Nombre exacto recomendado:

```text
Warroom_ExportPunchReviewToExcel
```

Este Flow será una copia del actual:

```text
Warroom_ExportPunchesToExcel_Codex
```

La única diferencia funcional de C03C2A será que recibirá además la lista exacta de Punches de la Review Queue y la enviará al SP pivotado.

## Regla de seguridad

Durante este bloque:

- NO modificar `Warroom_ExportPunchesToExcel_Codex`;
- NO modificar `scr_Punches`;
- NO activar todavía `Generate Excel` en Punch Review;
- NO cambiar Office Script, SharePoint, snapshot ni responses;
- trabajar únicamente sobre la nueva copia.

---

# PASO 1 — Crear una copia del Flow

Abre `Warroom_ExportPunchesToExcel_Codex` en Power Automate.

Usa **Save as / Guardar como** para crear una copia con este nombre exacto:

```text
Warroom_ExportPunchReviewToExcel
```

Abre la copia y confirma que conserva las mismas acciones que el Flow actual, especialmente:

```text
SQL StartExportLog
SQL ExportPunchesPivoted
SQL GetColumnMap
SQL RegisterExportSnapshot
Run script
SQL CompleteExportBatch
Respond to a Power App or flow
Respond ExportFailure
```

No cambies todavía ninguna de ellas.

---

# PASO 2 — Añadir WorkItemIdsJson al trigger

En el trigger **Power Apps (V2)** añade al final un nuevo input de tipo **Text**.

Nombre exacto:

```text
WorkItemIdsJson
```

Debe quedar después de:

```text
SelectedColumnsJson
```

El trigger tendrá por tanto 13 inputs:

```text
ProjectId
SubsystemCode
TemplateId
CategoryCode
StatusCode
PunchDiscipline
Subcontractor
CustomFiltersJson
RequestedByEmail
RequestedByName
ExportMode
SelectedColumnsJson
WorkItemIdsJson
```

No renombres los 12 existentes.

---

# PASO 3 — Refrescar SQL ExportPunchesPivoted

Abre la acción:

```text
SQL ExportPunchesPivoted
```

El procedimiento debe seguir siendo:

```text
[warroom].[usp_ExportProjectPunchesExtended_Pivoted]
```

Como el procedimiento acaba de incorporar un nuevo parámetro, Power Automate puede conservar la metadata anterior en caché.

Si `WorkItemIdsJson` no aparece entre los parámetros:

1. abre el selector de **Procedure name**;
2. vuelve a seleccionar `[warroom].[usp_ExportProjectPunchesExtended_Pivoted]`;
3. espera a que Power Automate regenere los parámetros.

No elimines ni cambies los parámetros existentes.

Debe aparecer un nuevo parámetro:

```text
WorkItemIdsJson
```

---

# PASO 4 — Conectar WorkItemIdsJson

En el nuevo parámetro SQL `WorkItemIdsJson`, NO dejes un valor vacío por defecto.

La ruta normal será usar el contenido dinámico:

```text
WorkItemIdsJson
```

que viene del trigger.

Para que el Flow específico de Punch Review falle de forma segura si por error recibe un payload vacío, la expresión recomendada es:

```text
if(empty(triggerBody()?['text_10']), '[]', triggerBody()?['text_10'])
```

IMPORTANTE: `text_10` es el nombre interno esperado si Power Automate añade el nuevo Text inmediatamente después de `SelectedColumnsJson` (`text_9`).

Si Power Automate genera otro nombre interno, NO fuerces `text_10`: selecciona el token dinámico **WorkItemIdsJson** generado por el trigger. El requisito funcional es que el nuevo parámetro SQL reciba exactamente ese input.

La razón de convertir un vacío en `[]` es deliberada: SQL rechazará `[]` y evitará que un error de Punch Review pueda convertirse accidentalmente en un export global por filtros.

---

# PASO 5 — No cambiar el resto del Flow

En C03C2A se mantienen exactamente como están:

- `SQL StartExportLog`;
- `SQL GetColumnMap`;
- `Compose ExportRows`;
- `Compose ColumnMap`;
- `Compose RowCount`;
- `SQL RegisterExportSnapshot`;
- lectura de `Template.xlsx`;
- creación de fichero en SharePoint;
- Office Script;
- sharing link;
- `usp_PunchExportLog_Complete`;
- `usp_CompletePunchExportBatch`;
- response success;
- response failure.

La definición recuperada del baseline confirma que el Flow actual obtiene las filas desde:

```text
body('SQL_ExportPunchesPivoted')?['ResultSets']?['Table1']
```

Por eso no necesitamos crear una segunda lógica de Excel: al limitar el SP pivotado, todo el pipeline posterior recibe automáticamente solo la Review Queue.

---

# PASO 6 — Guardar

Guarda el Flow:

```text
Warroom_ExportPunchReviewToExcel
```

No hace falta conectarlo todavía a Power Apps.

---

# GATE C03C2A

Antes de avanzar necesito comprobar solo dos cosas en Power Automate:

## Evidencia A — trigger

Captura donde se vea al final:

```text
SelectedColumnsJson
WorkItemIdsJson
```

## Evidencia B — SQL ExportPunchesPivoted

Captura donde se vea:

```text
Procedure name
[warroom].[usp_ExportProjectPunchesExtended_Pivoted]
```

y el nuevo parámetro:

```text
WorkItemIdsJson = <WorkItemIdsJson del trigger>
```

Si ambas evidencias son correctas:

```text
PR-EXP-C03C2A = PASS
```

El siguiente bloque será:

```text
PR-EXP-C03C2B — Power Apps connection + Generate Excel
```

En C03C2B añadiremos el nuevo Flow a PULSE, construiremos los argumentos del modal y activaremos `Generate Excel` para una prueba end-to-end con la misma Review Queue de 15 Punches.
