# PR-IMP-C05A — Real file ingestion foundation

**Pantalla:** `scr_PunchImport`  
**Objetivo:** sustituir el selector sintético de C04E por un transporte de fichero soportado y gobernado.  
**Este bloque no aplica comentarios.**

## 1. Por qué necesitamos un pequeño staging de SharePoint

El control estándar `Attachments` de Canvas Apps puede seleccionar archivos, pero la carga/eliminación solo funciona dentro de un Form conectado a Microsoft Lists o Dataverse.

PULSE ya usa SharePoint/Excel Online en el circuito de exportación. Para v1 usamos una lista SharePoint temporal como puente de subida; SQL sigue siendo la autoridad del Import Batch.

Arquitectura:

```text
scr_PunchImport
  -> EditForm + Attachments
  -> SharePoint PULSE_ImportStaging
  -> Warroom_StagePunchCommentImport
  -> fichero temporal en área SharePoint PULSE
  -> Office Script ReadPunchCommentImport
  -> warroom.usp_StageValidatePunchCommentImport
  -> respuesta tipada a Power Apps
```

## 2. Gate C05A — crear el recurso de staging

En el mismo sitio SharePoint gobernado donde se almacenan los Excel de PULSE, crea una **Microsoft List** llamada exactamente:

```text
PULSE_ImportStaging
```

Configuración mínima:

```text
Attachments    Enabled
Title          texto estándar (puede mantenerse)
Versioning     opcional; no es autoridad funcional
```

No necesitamos crear columnas funcionales en esta fase. ProjectId, usuario y contexto viajan desde Power Apps al Flow; el fichero viaja como attachment.

Permisos:

- usuarios de PULSE que importen necesitan permiso para crear el item y adjuntar el workbook;
- la conexión del Flow necesita leer y borrar esos items/attachments;
- el Flow necesita crear/borrar el fichero temporal usado por Excel Online.

## 3. Carpeta temporal

En el área documental de SharePoint usada por PULSE crea o reserva:

```text
Pulse/ImportStaging
```

El nombre físico puede adaptarse a la biblioteca real del entorno, pero debe existir una carpeta dedicada y no compartirse con exports finales.

Los ficheros de esta carpeta son temporales. No son la evidencia de auditoría; la evidencia se conserva en `warroom.ImportBatch`, `warroom.ImportBatchRow` e `warroom.ImportAudit`.

## 4. Crear el Office Script

Crea un Office Script llamado exactamente:

```text
ReadPunchCommentImport
```

Copia el código completo desde:

`office-scripts/ReadPunchCommentImport.ts`

El script lee exclusivamente `tblPunches` y devuelve a SQL solo:

```text
Export Batch ID
ProjectId
TemplateId
Work Item ID
Row Checksum
New Comment
```

Por tanto:

- una exportación CLIENT falla porque carece del contrato técnico;
- Custom Fields editados no se envían en Comments-only v1;
- `Last Comment` no se interpreta como campo editable;
- blank `New Comment` sigue significando no change.

## 5. Flow que construiremos en C05B

Nombre:

```text
Warroom_StagePunchCommentImport
```

Contrato completo:

`power-automate/contracts/Warroom_StagePunchCommentImport.v1.md`

En C05B lo construiremos y probaremos directamente desde Power Automate antes de tocar el botón real de Power Apps.

## 6. No modificar todavía scr_PunchImport

C05A es infraestructura de transporte. Mantén la UI de C04E tal como está.

Antes de la prueba C05B, fuerza una nueva entrada a `scr_PunchImport` para ejecutar el OnVisible de C04D. Comprueba que vuelven a aparecer:

```text
Punch template   <label actual>
Batch status     NOT STARTED
Upload           Current step
```

## 7. Evidencia necesaria para superar C05A

Necesito únicamente confirmar:

```text
[ ] PULSE_ImportStaging existe y permite attachments
[ ] Pulse/ImportStaging existe (o me indicas la carpeta temporal equivalente)
[ ] ReadPunchCommentImport está creado en Office Scripts
```

No subas todavía ningún Excel desde Power Apps. La primera ingestión real se hará de forma controlada en C05B.

## 8. Qué viene inmediatamente después

```text
C05A  File ingestion foundation       <-- gate actual
C05B  Build + test Stage Flow
C05C  Real Attachment Form in UI
C05D  Validate file -> READY/BLOCKED -> Preview
```

Commit continúa fuera de alcance.
