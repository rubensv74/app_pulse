# PR-IMP-C05B — Guía detallada para construir `Warroom_StagePunchCommentImport`

**Pantalla relacionada:** `scr_PunchImport`  
**Objetivo de este bloque:** construir el Flow real que recibe el Excel temporal de SharePoint, lee únicamente el contrato de importación de comentarios, ejecuta Stage + Validate en SQL y devuelve una respuesta tipada a Power Apps.  
**Importante:** este Flow **NO aplica comentarios en producción**. Su misión termina en `READY`, `BLOCKED` o `FAILED`.

---

# 1. Qué vamos a construir

El circuito de C05B será este:

```text
Power Apps (V2)
    ↓
Recibe StagingItemId + ProjectId + RequestedBy
    ↓
SharePoint — lee el único attachment del item temporal
    ↓
SharePoint — copia ese Excel a PreservOne/Pulse/ImportStaging
    ↓
Excel Online — ejecuta ReadPunchCommentImport
    ↓
SQL — usp_StageValidatePunchCommentImport
    ↓
Devuelve a Power Apps:
READY / BLOCKED / FAILED + contadores + ImportBatchId
```

En este punto todavía **no existe Commit**.

Aunque el Excel contenga un `New Comment`, el procedimiento SQL usado en este Flow solo crea o actualiza registros de staging en:

```text
warroom.ImportBatch
warroom.ImportBatchRow
```

No inserta, modifica ni elimina filas de:

```text
warroom.PunchComment
```

---

# 2. Recursos que ya hemos confirmado

Usaremos exactamente estos recursos.

## SharePoint

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

Lista temporal
PULSE_ImportStaging

Biblioteca documental
PreservOne

Carpeta temporal
Pulse/ImportStaging
```

En algunas acciones de SharePoint el diseñador mostrará la carpeta como:

```text
/PreservOne/Pulse/ImportStaging
```

En otras, primero seleccionarás la biblioteca `PreservOne` y después la carpeta `Pulse/ImportStaging`.

Ambas formas representan el mismo destino.

## Office Script

```text
ReadPunchCommentImport
```

Código fuente en el repositorio:

```text
office-scripts/ReadPunchCommentImport.ts
```

## SQL

```text
Server
 dbs-hointegration-dev.database.windows.net

Database
 db-homeoffice-dev

Stored Procedure
 [warroom].[usp_StageValidatePunchCommentImport]
```

Siempre que sea posible, reutiliza las mismas conexiones de SharePoint, Excel Online y SQL que ya utiliza el circuito de Export de PULSE.

---

# 3. Crear el Flow

En Power Automate:

1. Pulsa **Create**.
2. Selecciona **Instant cloud flow**.
3. Como trigger selecciona:

```text
Power Apps (V2)
```

4. Nombre del Flow:

```text
Warroom_StagePunchCommentImport
```

5. Pulsa **Create**.

No añadas todavía ninguna acción adicional hasta configurar los inputs del trigger.

---

# 4. Configurar el trigger `Power Apps (V2)`

En la tarjeta `Power Apps (V2)` pulsa **Add an input** tres veces.

Debes crear exactamente estos inputs y en este orden:

| Orden | Nombre | Tipo |
|---:|---|---|
| 1 | `StagingItemId` | Number |
| 2 | `ProjectId` | Number |
| 3 | `RequestedBy` | Text |

## Qué significa cada input

### `StagingItemId`

Es el ID del item que Power Apps creará en la lista:

```text
PULSE_ImportStaging
```

Ese item contendrá el Excel como attachment.

### `ProjectId`

Es el **ID interno SQL** del proyecto.

Ejemplo real del proyecto visible como `70200`:

```text
Project visible para el usuario = 70200
ProjectId interno SQL            = 4049
```

El usuario nunca lo escribe. Power Apps lo enviará automáticamente.

### `RequestedBy`

Será el correo del usuario que está realizando la importación.

Ejemplo desde Power Apps:

```powerfx
User().Email
```

---

# 5. Regla importante antes de continuar: renombra cada acción al crearla

Esta guía utiliza expresiones como:

```text
outputs('Compose_AttachmentCount')
variables('varProjectId')
body('SP_GetAttachments')
```

Para que estas expresiones sean fáciles de seguir:

1. crea una acción;
2. renómbrala inmediatamente;
3. después configura sus expresiones.

No esperes hasta el final para renombrar todas las acciones.

Por ejemplo:

```text
Nombre visual                Nombre usado en expresiones
SP GetAttachments            SP_GetAttachments
Compose AttachmentCount      Compose_AttachmentCount
SQL StageValidateImport      SQL_StageValidateImport
```

Power Automate sustituye los espacios por `_` al crear la referencia interna.

---

# 6. Crear las variables de runtime

Justo debajo del trigger añade siete acciones **Initialize variable**.

Hazlo una por una.

---

## 6.1 `varStagingItemId`

Acción:

```text
Initialize variable
```

Renombra:

```text
Init varStagingItemId
```

Configura:

```text
Name   varStagingItemId
Type   Integer
Value  StagingItemId
```

Para `Value` NO escribas el nombre manualmente.

Pulsa en el campo y selecciona desde **Dynamic content**:

```text
StagingItemId
```

del trigger Power Apps (V2).

---

## 6.2 `varProjectId`

```text
Name   varProjectId
Type   Integer
Value  ProjectId     ← Dynamic content del trigger
```

---

## 6.3 `varRequestedBy`

```text
Name   varRequestedBy
Type   String
Value  RequestedBy   ← Dynamic content del trigger
```

---

## 6.4 `varOriginalFileName`

```text
Name   varOriginalFileName
Type   String
Value  dejar vacío
```

Esta variable guardará el nombre original del Excel adjunto.

Ejemplo:

```text
PULSE_Punches_Project_4049_20260818_095000.xlsx
```

---

## 6.5 `varTempFileIdentifier`

```text
Name   varTempFileIdentifier
Type   String
Value  dejar vacío
```

Guardará el `Identifier` del fichero temporal creado en SharePoint.

Lo necesitaremos para:

- ejecutar Office Script;
- eliminar el fichero al terminar.

---

## 6.6 `varInputValid`

```text
Name   varInputValid
Type   Boolean
Value  false
```

Debe ser Boolean real.

No escribas:

```text
"false"
```

Debe ser:

```text
false
```

---

## 6.7 `varFailureMessage`

```text
Name   varFailureMessage
Type   String
Value  dejar vacío
```

---

# 7. Leer los attachments del item temporal

Añade la acción SharePoint:

```text
Get attachments
```

Renombra inmediatamente:

```text
SP GetAttachments
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

List Name
PULSE_ImportStaging

Id
varStagingItemId
```

Para `Id` usa **Dynamic content** y selecciona la variable:

```text
varStagingItemId
```

## Qué hace esta acción

Todavía no descarga el Excel.

Únicamente obtiene la lista de archivos adjuntos del item temporal.

Nuestro contrato exige:

```text
exactamente 1 attachment
```

No aceptaremos:

```text
0 attachments
2 attachments
3 attachments
...
```

---

# 8. Contar cuántos attachments existen

Añade acción:

```text
Compose
```

Renombra:

```text
Compose AttachmentCount
```

En **Inputs** selecciona la pestaña **Expression** e introduce exactamente:

```text
length(body('SP_GetAttachments'))
```

Pulsa **OK / Update**.

## Resultado esperado

Si hay un único Excel:

```text
1
```

---

# 9. Validar que existe exactamente un attachment

Añade una acción:

```text
Condition
```

Renombra:

```text
Condition ExactlyOneAttachment
```

Puedes configurarla visualmente así:

```text
Compose AttachmentCount   is equal to   1
```

O mediante expresión:

```text
equals(outputs('Compose_AttachmentCount'), 1)
```

Ahora tendrás dos ramas:

```text
If yes
If no
```

---

# 10. Rama NO de `ExactlyOneAttachment`

Dentro de **If no** añade:

```text
Set variable
```

Renombra:

```text
Set FailureMessage AttachmentCount
```

Configura:

```text
Name
varFailureMessage

Value
Exactly one .xlsx attachment is required.
```

No respondas todavía a Power Apps desde esta rama.

Solo dejamos:

```text
varInputValid = false
varFailureMessage = mensaje
```

Después todas las rutas volverán a una única comprobación `InputValid`.

---

# 11. Rama YES de `ExactlyOneAttachment`

Dentro de **If yes** debemos obtener el nombre del fichero.

Añade:

```text
Compose
```

Renombra:

```text
Compose AttachmentName
```

Expression:

```text
first(body('SP_GetAttachments'))?['DisplayName']
```

Después añade:

```text
Set variable
```

Renombra:

```text
Set OriginalFileName
```

Configura:

```text
Name
varOriginalFileName

Value
outputs('Compose_AttachmentName')
```

---

# 12. Validar que el archivo es `.xlsx`

Todavía dentro del YES anterior, añade otra acción:

```text
Condition
```

Renombra:

```text
Condition IsXlsx
```

Usa esta expresión:

```text
endsWith(
    toLower(outputs('Compose_AttachmentName')),
    '.xlsx'
)
```

## Rama YES de `IsXlsx`

Añade:

```text
Set variable
```

Renombra:

```text
Set InputValid True
```

Configura:

```text
Name
varInputValid

Value
true
```

## Rama NO de `IsXlsx`

Añade:

```text
Set variable
```

Renombra:

```text
Set FailureMessage FileType
```

Configura:

```text
Name
varFailureMessage

Value
Only .xlsx INTERNAL workbooks are accepted.
```

`varInputValid` permanece en `false`.

---

# 13. Crear una condición superior: ¿el input es válido?

Fuera de `Condition ExactlyOneAttachment`, añade otra `Condition`.

Muy importante: esta nueva condición debe quedar **después de que haya terminado completamente la condición anterior**, no dentro de una de sus ramas.

Renombra:

```text
Condition InputValid
```

Configura:

```text
varInputValid   is equal to   true
```

O expresión:

```text
equals(variables('varInputValid'), true)
```

A partir de aquí tenemos dos grandes rutas:

```text
NO  = entrada incorrecta → limpiar → responder FAILED
YES = Excel aparentemente válido → leer → validar con SQL
```

---

# 14. Rama NO de `Condition InputValid`

Esta es una salida controlada, no un error técnico.

El usuario ha enviado algo que no cumple el contrato de entrada.

---

## 14.1 Eliminar el item temporal de SharePoint

Añade SharePoint:

```text
Delete item
```

Renombra:

```text
SP DeleteRejectedStagingItem
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

List Name
PULSE_ImportStaging

Id
varStagingItemId
```

Esto elimina el item junto con su attachment temporal.

---

## 14.2 Responder a Power Apps

Añade:

```text
Respond to a Power App or flow
```

Renombra:

```text
Respond InputRejected
```

Añade exactamente estos 18 outputs.

### Boolean

```text
success = false
canCommit = false
```

### Text

```text
importBatchId = ''
status        = FAILED
fileName      = varOriginalFileName
message       = varFailureMessage
errorsJson    = []
```

### Number

```text
totalRows       = 0
changedRows     = 0
unchangedRows   = 0
validRows       = 0
warningRows     = 0
errorRows       = 0
conflictRows    = 0
appliedRows     = 0
failedRows      = 0
projectId       = varProjectId
templateId      = 0
```

## Regla de tipos

Cuando añadas cada output usa el tipo correcto desde el diseñador:

```text
Boolean
Text
Number
```

No devuelvas:

```text
"0"
"false"
```

porque serían textos.

Esto es importante: en PULSE ya hemos reproducido el error de Power Apps:

```text
JSON parsing error, expected 'number' but got 'string'
```

Por eso aquí congelamos tipos estrictos.

---

# 15. Rama YES de `Condition InputValid`

Ahora comienza la ingestión real.

Dentro de la rama YES añade:

```text
Scope
```

Renombra:

```text
Scope StageImport
```

Todo lo que realmente lee y valida el Excel debe quedar dentro de este Scope.

Esto luego nos permitirá controlar `Run after` de una forma limpia.

---

# 16. `Scope StageImport` — obtener contenido del Excel adjunto

Dentro de `Scope StageImport` añade SharePoint:

```text
Get attachment content
```

Renombra:

```text
SP GetAttachmentContent
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

List Name
PULSE_ImportStaging

Id
varStagingItemId
```

Para **File Identifier** utiliza la expresión:

```text
first(body('SP_GetAttachments'))?['Id']
```

## Qué obtenemos

Ahora sí recuperamos el contenido binario real del `.xlsx`.

Aún no puede ser leído por Excel Online de la manera que necesitamos, por eso a continuación creamos una copia temporal en la biblioteca documental.

---

# 17. Crear el workbook temporal en `PreservOne/Pulse/ImportStaging`

Añade SharePoint:

```text
Create file
```

Renombra:

```text
SP CreateTempWorkbook
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows
```

En función de cómo se muestre tu diseñador:

```text
Document Library
PreservOne

Folder Path
Pulse/ImportStaging
```

O directamente:

```text
Folder Path
/PreservOne/Pulse/ImportStaging
```

## File Name

No reutilices directamente el nombre original porque podrían existir dos importaciones simultáneas con el mismo nombre.

En **Expression** introduce:

```text
concat(
  'PULSE_IMPORT_',
  string(variables('varStagingItemId')),
  '_',
  formatDateTime(utcNow(),'yyyyMMdd_HHmmssfff'),
  '.xlsx'
)
```

Ejemplo generado:

```text
PULSE_IMPORT_37_20260818_095945327.xlsx
```

## File Content

Selecciona desde Dynamic content el contenido devuelto por:

```text
SP GetAttachmentContent
```

Normalmente aparecerá como:

```text
File Content
Attachment Content
Body
```

Usa el token binario de la acción, no el nombre del attachment.

---

# 18. Guardar el Identifier del fichero temporal

Inmediatamente después de `SP CreateTempWorkbook`, añade:

```text
Set variable
```

Renombra:

```text
Set TempFileIdentifier
```

Configura:

```text
Name
varTempFileIdentifier

Value
Identifier
```

El valor `Identifier` debe venir mediante Dynamic content de:

```text
SP CreateTempWorkbook
```

No uses `Path` ni `Name` si el diseñador te ofrece `Identifier`.

El `Identifier` es la referencia más segura para las siguientes acciones.

---

# 19. Ejecutar `ReadPunchCommentImport`

Añade el conector:

```text
Excel Online (Business)
```

Acción:

```text
Run script
```

Renombra:

```text
Excel ReadPunchCommentImport
```

Configura:

```text
Location
https://trsa.sharepoint.com/sites/rpa_flows

Document Library
PreservOne

File
varTempFileIdentifier

Script
ReadPunchCommentImport
```

Para `File`, selecciona la variable:

```text
varTempFileIdentifier
```

Si el diseñador no acepta directamente la variable, pulsa el icono para introducir un valor personalizado y selecciona después el contenido dinámico.

## Qué hace el Office Script

No envía todas las columnas del Excel.

Únicamente devuelve:

```text
Export Batch ID
ProjectId
TemplateId
Work Item ID
Row Checksum
New Comment
```

Por ejemplo:

```json
[
  {
    "Export Batch ID": 12345,
    "ProjectId": 4049,
    "TemplateId": 20,
    "Work Item ID": 1292427,
    "Row Checksum": "FADE678E...",
    "New Comment": "Nuevo comentario de reunión"
  }
]
```

Esto es importante porque:

- `New Comment` es el único campo de negocio importable en v1;
- Custom Fields quedan fuera;
- `Last Comment` es solo lectura;
- las columnas técnicas permiten verificar que el workbook pertenece al export correcto.

El Office Script devuelve un **String JSON** en su output:

```text
result
```

No conviertas ese `result` de nuevo a JSON en el Flow.

Lo enviaremos tal cual al procedimiento SQL.

---

# 20. Ejecutar Stage + Validate en SQL

Añade el conector:

```text
SQL Server
```

Acción:

```text
Execute stored procedure (V2)
```

Renombra:

```text
SQL StageValidateImport
```

Configura:

```text
Server name
 dbs-hointegration-dev.database.windows.net

Database name
 db-homeoffice-dev

Procedure name
 [warroom].[usp_StageValidatePunchCommentImport]
```

Al seleccionar el procedimiento deberían aparecer sus cuatro parámetros.

Configúralos así:

```text
ProjectId
variables('varProjectId')

FileName
variables('varOriginalFileName')

RequestedBy
variables('varRequestedBy')

RowsJson
result de Excel ReadPunchCommentImport
```

Para `RowsJson`, preferiblemente selecciona el token dinámico:

```text
result
```

que pertenece a `Excel ReadPunchCommentImport`.

No uses:

```text
json(result)
string(result)
```

El procedimiento espera un `nvarchar(max)` que contiene el array JSON.

---

# 21. Qué devuelve SQL

`usp_StageValidatePunchCommentImport` devuelve una fila resumen.

Ejemplo conceptual:

```text
success          1
importBatchId    GUID
status           READY
fileName         archivo.xlsx
totalRows        3
changedRows      1
unchangedRows    2
validRows        3
warningRows      0
errorRows        0
conflictRows     0
appliedRows      0
failedRows       0
canCommit        1
message          The workbook is valid and ready for preview.
errorsJson       []
projectId        4049
templateId       20
```

O, si el workbook está bloqueado:

```text
status       BLOCKED
errorRows    1
canCommit    0
```

`BLOCKED` no significa que el Flow haya fallado.

Es una respuesta de negocio válida: el usuario debe poder llegar al Preview y ver por qué no puede continuar.

---

# 22. Extraer la primera fila devuelta por SQL

Añade:

```text
Compose
```

Renombra:

```text
Compose StageRow
```

Prueba primero esta expresión:

```text
first(outputs('SQL_StageValidateImport')?['body/resultsets/Table1'])
```

Dependiendo de la versión del conector SQL, Power Automate puede generar la propiedad con un casing ligeramente diferente.

Si el diseñador te muestra un token `ResultSets`, puedes insertar ese Dynamic content y comprobar la expresión generada.

La lógica que necesitamos siempre es:

```text
Table1 → primera fila
```

Es decir:

```text
Table1[0]
```

No necesitamos recorrer las filas porque el procedimiento devuelve **una sola fila resumen**.

---

# 23. Crear `Scope Success`

Después de `Scope StageImport`, todavía dentro del YES de `Condition InputValid`, añade otro:

```text
Scope
```

Renombra:

```text
Scope Success
```

Ahora abre los tres puntos `...` de `Scope Success` y selecciona:

```text
Configure run after
```

Marca únicamente:

```text
is successful
```

para:

```text
Scope StageImport
```

Así `Scope Success` solo se ejecutará si:

- el attachment se pudo leer;
- el fichero temporal se creó;
- Office Script terminó correctamente;
- SQL terminó correctamente;
- `Compose StageRow` terminó correctamente.

---

# 24. `Scope Success` — eliminar el workbook temporal

Dentro de `Scope Success` añade SharePoint:

```text
Delete file
```

Renombra:

```text
SP DeleteTempWorkbook Success
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

File Identifier
varTempFileIdentifier
```

---

# 25. `Scope Success` — eliminar el item de staging

Añade SharePoint:

```text
Delete item
```

Renombra:

```text
SP DeleteStagingItem Success
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

List Name
PULSE_ImportStaging

Id
varStagingItemId
```

Después de estas dos acciones no debería quedar ningún fichero de transporte temporal.

La evidencia funcional queda en SQL.

---

# 26. `Scope Success` — responder a Power Apps

Añade:

```text
Respond to a Power App or flow
```

Renombra:

```text
Respond StageResult
```

Debemos crear exactamente **18 outputs**.

Hazlo con paciencia porque esta parte es muy importante.

---

## 26.1 Output `success`

Tipo:

```text
Boolean
```

Expression:

```text
bool(coalesce(outputs('Compose_StageRow')?['success'], false))
```

---

## 26.2 `importBatchId`

Tipo:

```text
Text
```

Expression:

```text
string(coalesce(outputs('Compose_StageRow')?['importBatchId'], ''))
```

---

## 26.3 `status`

Tipo:

```text
Text
```

Expression:

```text
string(coalesce(outputs('Compose_StageRow')?['status'], 'FAILED'))
```

---

## 26.4 `fileName`

Tipo:

```text
Text
```

Expression:

```text
string(
  coalesce(
    outputs('Compose_StageRow')?['fileName'],
    variables('varOriginalFileName')
  )
)
```

---

## 26.5 Contadores numéricos

Todos deben ser tipo:

```text
Number
```

### `totalRows`

```text
int(coalesce(outputs('Compose_StageRow')?['totalRows'], 0))
```

### `changedRows`

```text
int(coalesce(outputs('Compose_StageRow')?['changedRows'], 0))
```

### `unchangedRows`

```text
int(coalesce(outputs('Compose_StageRow')?['unchangedRows'], 0))
```

### `validRows`

```text
int(coalesce(outputs('Compose_StageRow')?['validRows'], 0))
```

### `warningRows`

```text
int(coalesce(outputs('Compose_StageRow')?['warningRows'], 0))
```

### `errorRows`

```text
int(coalesce(outputs('Compose_StageRow')?['errorRows'], 0))
```

### `conflictRows`

```text
int(coalesce(outputs('Compose_StageRow')?['conflictRows'], 0))
```

### `appliedRows`

```text
int(coalesce(outputs('Compose_StageRow')?['appliedRows'], 0))
```

### `failedRows`

```text
int(coalesce(outputs('Compose_StageRow')?['failedRows'], 0))
```

---

## 26.6 `canCommit`

Tipo:

```text
Boolean
```

Expression:

```text
bool(coalesce(outputs('Compose_StageRow')?['canCommit'], false))
```

---

## 26.7 `message`

Tipo:

```text
Text
```

Expression:

```text
string(coalesce(outputs('Compose_StageRow')?['message'], ''))
```

---

## 26.8 `errorsJson`

Tipo:

```text
Text
```

Expression:

```text
string(coalesce(outputs('Compose_StageRow')?['errorsJson'], '[]'))
```

---

## 26.9 `projectId`

Tipo:

```text
Number
```

Expression:

```text
int(
  coalesce(
    outputs('Compose_StageRow')?['projectId'],
    variables('varProjectId')
  )
)
```

---

## 26.10 `templateId`

Tipo:

```text
Number
```

Expression:

```text
int(coalesce(outputs('Compose_StageRow')?['templateId'], 0))
```

---

# 27. Resumen exacto de outputs del Flow

Al final `Respond StageResult` debe tener:

| Output | Tipo |
|---|---|
| success | Boolean |
| importBatchId | Text |
| status | Text |
| fileName | Text |
| totalRows | Number |
| changedRows | Number |
| unchangedRows | Number |
| validRows | Number |
| warningRows | Number |
| errorRows | Number |
| conflictRows | Number |
| appliedRows | Number |
| failedRows | Number |
| canCommit | Boolean |
| message | Text |
| errorsJson | Text |
| projectId | Number |
| templateId | Number |

Cuenta final:

```text
18 outputs
```

No cambies nombres ni tipos porque Power Apps dependerá de este contrato.

---

# 28. Crear la ruta de fallo técnico

Ahora necesitamos una segunda salida para casos como:

- SharePoint no responde;
- no se puede crear el fichero temporal;
- Excel Online falla;
- Office Script falla;
- SQL falla;
- `Compose StageRow` falla.

Después de `Scope StageImport` crea una rama paralela.

Añade:

```text
Scope
```

Renombra:

```text
Scope FailureCleanup
```

Abre:

```text
... → Configure run after
```

Para `Scope StageImport`, marca:

```text
has failed
has timed out
```

Puedes marcar también `is skipped` únicamente si tu estructura final lo necesitara, pero para la arquitectura descrita aquí `failed + timed out` es suficiente.

---

# 29. `Scope FailureCleanup` — intentar borrar el fichero temporal

Dentro añade:

```text
Condition
```

Renombra:

```text
Condition HasTempFile
```

Expression:

```text
not(empty(variables('varTempFileIdentifier')))
```

## If yes

Añade SharePoint:

```text
Delete file
```

Renombra:

```text
SP DeleteTempWorkbook Failure
```

File Identifier:

```text
varTempFileIdentifier
```

## If no

No añadas nada.

---

# 30. `Scope FailureCleanup` — eliminar siempre el item de staging

Después de `Condition HasTempFile` añade:

```text
Delete item
```

Renombra:

```text
SP DeleteStagingItem Failure
```

Configura:

```text
Site Address
https://trsa.sharepoint.com/sites/rpa_flows

List Name
PULSE_ImportStaging

Id
varStagingItemId
```

Después abre:

```text
... → Configure run after
```

sobre esta acción y permite que se ejecute cuando la condición anterior:

```text
is successful
has failed
is skipped
```

La razón es sencilla:

> Si borrar el fichero temporal falla, todavía queremos intentar borrar el item de staging.

Una limpieza no debe impedir la otra.

---

# 31. Respuesta de fallo técnico

Después añade:

```text
Respond to a Power App or flow
```

Renombra:

```text
Respond TechnicalFailure
```

Configura `Run after` para que se ejecute aunque `SP DeleteStagingItem Failure` haya fallado.

Permite:

```text
is successful
has failed
```

Devuelve los mismos 18 outputs.

## Boolean

```text
success    = false
canCommit  = false
```

## Text

```text
importBatchId = ''
status        = FAILED
fileName      = varOriginalFileName
message       = The workbook could not be staged. Review the failed Flow action.
errorsJson    = []
```

## Number

```text
totalRows       = 0
changedRows     = 0
unchangedRows   = 0
validRows       = 0
warningRows     = 0
errorRows       = 0
conflictRows    = 0
appliedRows     = 0
failedRows      = 0
projectId       = varProjectId
templateId      = 0
```

No devuelvas el texto completo de la excepción técnica al usuario final.

Para diagnóstico usaremos el **Run history** del Flow.

---

# 32. Estructura final esperada en el diseñador

Cuando termines, el Flow debe verse aproximadamente así:

```text
Power Apps (V2)
│
├─ Init varStagingItemId
├─ Init varProjectId
├─ Init varRequestedBy
├─ Init varOriginalFileName
├─ Init varTempFileIdentifier
├─ Init varInputValid
├─ Init varFailureMessage
│
├─ SP GetAttachments
├─ Compose AttachmentCount
│
├─ Condition ExactlyOneAttachment
│  │
│  ├─ YES
│  │   ├─ Compose AttachmentName
│  │   ├─ Set OriginalFileName
│  │   └─ Condition IsXlsx
│  │       ├─ YES → Set InputValid True
│  │       └─ NO  → Set FailureMessage FileType
│  │
│  └─ NO
│      └─ Set FailureMessage AttachmentCount
│
└─ Condition InputValid
   │
   ├─ NO
   │   ├─ SP DeleteRejectedStagingItem
   │   └─ Respond InputRejected
   │
   └─ YES
       │
       ├─ Scope StageImport
       │   ├─ SP GetAttachmentContent
       │   ├─ SP CreateTempWorkbook
       │   ├─ Set TempFileIdentifier
       │   ├─ Excel ReadPunchCommentImport
       │   ├─ SQL StageValidateImport
       │   └─ Compose StageRow
       │
       ├─ Scope Success
       │   ├─ SP DeleteTempWorkbook Success
       │   ├─ SP DeleteStagingItem Success
       │   └─ Respond StageResult
       │
       └─ Scope FailureCleanup
           ├─ Condition HasTempFile
           │   └─ YES → SP DeleteTempWorkbook Failure
           ├─ SP DeleteStagingItem Failure
           └─ Respond TechnicalFailure
```

---

# 33. Qué estados puede devolver el Flow

## `READY`

Significa:

```text
Workbook válido
Sin errores de checksum
Sin errores de estructura
Al menos un New Comment nuevo
```

Power Apps podrá pasar a:

```text
PREVIEW
```

`canCommit` será normalmente:

```text
true
```

pero todavía no ejecutaremos Commit en C05.

---

## `BLOCKED`

Significa que el Flow ha funcionado correctamente, pero SQL ha encontrado un problema funcional.

Ejemplos:

```text
CHECKSUM_MISMATCH
PROJECT_MISMATCH
TEMPLATE_MISMATCH
WORKITEM_NOT_IN_EXPORT
FILE_ROW_COUNT_MISMATCH
```

Power Apps debe pasar igualmente a Preview para mostrar esos errores.

```text
success   = true
status    = BLOCKED
canCommit = false
```

No conviertas `BLOCKED` en una excepción del Flow.

---

## `FAILED`

Significa fallo de transporte o infraestructura.

Ejemplos:

```text
SharePoint connector failure
Excel Online failure
Office Script exception
SQL connector failure
```

En ese caso:

```text
success   = false
status    = FAILED
canCommit = false
```

Power Apps permanecerá en Upload.

---

# 34. Qué NO debemos hacer en C05B

No añadas todavía:

```text
usp_AddPunchComment
INSERT PunchComment
Apply comments
Commit Import
```

Tampoco conectes todavía el botón real de Power Apps.

C05B termina cuando el Flow:

```text
se construye
se guarda sin errores
mantiene el contrato tipado
```

El primer recorrido real desde `scr_PunchImport` se hará en C05C.

---

# 35. Checklist antes de guardar

Comprueba uno por uno:

```text
[ ] Flow = Warroom_StagePunchCommentImport

[ ] Trigger = Power Apps (V2)

[ ] StagingItemId = Number
[ ] ProjectId = Number
[ ] RequestedBy = Text

[ ] Site = https://trsa.sharepoint.com/sites/rpa_flows
[ ] List = PULSE_ImportStaging
[ ] Library = PreservOne
[ ] Temp folder = Pulse/ImportStaging

[ ] Exactly one attachment
[ ] Extension .xlsx

[ ] Office Script = ReadPunchCommentImport

[ ] SQL Server = dbs-hointegration-dev.database.windows.net
[ ] Database = db-homeoffice-dev
[ ] Procedure = warroom.usp_StageValidatePunchCommentImport

[ ] RowsJson recibe directamente el result del Office Script

[ ] Respond StageResult tiene 18 outputs
[ ] Respond InputRejected tiene los mismos 18 outputs
[ ] Respond TechnicalFailure tiene los mismos 18 outputs

[ ] totalRows etc. son Number, no Text
[ ] success y canCommit son Boolean, no Text

[ ] Success limpia temp file + staging item
[ ] Failure intenta limpiar temp file + staging item

[ ] No existe ninguna llamada que escriba PunchComment
```

---

# 36. Gate de C05B

Cuando el Flow se guarde correctamente, necesito una captura general donde pueda verse:

```text
Power Apps (V2)
GetAttachments
Input validation
Scope StageImport
Scope Success
Scope FailureCleanup
```

No hace falta todavía ejecutar una importación real.

Estado esperado del bloque:

```text
C05B = BUILT / NOT_RUN
ProductionCommentDelta = 0
```

---

# 37. Siguiente incremento

Después de revisar visualmente el Flow pasaremos a:

```text
PR-IMP-C05C — Real Attachment Form in scr_PunchImport
```

Ahí sustituiremos el selector sintético de C04E por:

```text
EditForm
  + Attachments
  + SubmitForm
  + LastSubmit.ID
  + Warroom_StagePunchCommentImport.Run(...)
```

Y entonces realizaremos el primer recorrido real:

```text
Excel INTERNAL
→ Power Apps
→ SharePoint staging
→ Office Script
→ SQL Stage/Validate
→ READY o BLOCKED
→ Preview
```

Aun en ese punto:

```text
ProductionCommentDelta = 0
```
