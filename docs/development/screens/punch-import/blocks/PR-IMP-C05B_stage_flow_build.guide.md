# PR-IMP-C05B — Build `Warroom_StagePunchCommentImport`

**Pantalla:** `scr_PunchImport`  
**Objetivo:** construir el Flow real que recibe el item temporal de SharePoint, lee el workbook y ejecuta Stage + Validate en SQL.  
**Este bloque NO aplica comentarios.**

## 0. Contrato congelado

Flow:

```text
Warroom_StagePunchCommentImport
```

SharePoint:

```text
Site        https://trsa.sharepoint.com/sites/rpa_flows
List        PULSE_ImportStaging
Library     PreservOne
Temp folder /PreservOne/Pulse/ImportStaging
```

Office Script:

```text
ReadPunchCommentImport
```

SQL:

```text
Server     dbs-hointegration-dev.database.windows.net
Database   db-homeoffice-dev
Procedure  [warroom].[usp_StageValidatePunchCommentImport]
```

Use the existing governed connections already used by the PULSE export Flow whenever possible.

---

## 1. Create the Flow

Create an **Instant cloud flow** with trigger:

```text
Power Apps (V2)
```

Name:

```text
Warroom_StagePunchCommentImport
```

Add these trigger inputs in this exact order:

| # | Name | Type |
|---:|---|---|
| 1 | `StagingItemId` | Number |
| 2 | `ProjectId` | Number |
| 3 | `RequestedBy` | Text |

Do not use raw trigger keys such as `number`, `number_1` or `text` in later expressions. Normalize the three trigger values into variables using the trigger's dynamic-content tokens.

---

## 2. Normalize runtime values

Add these **Initialize variable** actions immediately after the trigger:

```text
varStagingItemId       Integer   = StagingItemId
varProjectId           Integer   = ProjectId
varRequestedBy         String    = RequestedBy
varOriginalFileName    String    = ''
varTempFileIdentifier  String    = ''
varInputValid          Boolean   = false
varFailureMessage      String    = ''
```

The first three values must use the Power Apps trigger dynamic-content tokens.

---

## 3. Read the staging attachment

Add SharePoint action **Get attachments**.

Rename it:

```text
SP GetAttachments
```

Configure:

```text
Site Address   https://trsa.sharepoint.com/sites/rpa_flows
List Name      PULSE_ImportStaging
Id             varStagingItemId
```

Add **Compose** and rename it:

```text
Compose AttachmentCount
```

Expression:

```text
length(body('SP_GetAttachments'))
```

Microsoft's SharePoint connector returns an array of list-item attachments. Each attachment exposes `Id`, `AbsoluteUri` and `DisplayName`.

---

## 4. Fail closed unless there is exactly one `.xlsx`

Add Condition:

```text
AttachmentCount = 1
```

Expression form:

```text
equals(outputs('Compose_AttachmentCount'), 1)
```

### NO branch

Set:

```text
varFailureMessage = Exactly one .xlsx attachment is required.
```

Leave `varInputValid = false`.

### YES branch

Add Compose:

```text
Compose AttachmentName
```

Expression:

```text
first(body('SP_GetAttachments'))?['DisplayName']
```

Then:

```text
Set variable varOriginalFileName = outputs('Compose_AttachmentName')
```

Add another Condition:

```text
endsWith(toLower(outputs('Compose_AttachmentName')), '.xlsx')
```

If YES:

```text
Set variable varInputValid = true
```

If NO:

```text
Set variable varFailureMessage = Only .xlsx INTERNAL workbooks are accepted.
```

---

## 5. Route valid / invalid input

After the complete attachment-validation Condition, add a new top-level Condition:

```text
varInputValid is equal to true
```

### NO — handled transport rejection

1. SharePoint — **Delete item**

```text
Site Address   https://trsa.sharepoint.com/sites/rpa_flows
List Name      PULSE_ImportStaging
Id             varStagingItemId
```

2. Add **Respond to a Power App or flow** named:

```text
Respond InputRejected
```

Outputs must use the exact types below:

```text
success         Boolean  false
importBatchId   Text     ''
status          Text     FAILED
fileName        Text     varOriginalFileName
totalRows       Number   0
changedRows     Number   0
unchangedRows   Number   0
validRows       Number   0
warningRows     Number   0
errorRows       Number   0
conflictRows    Number   0
appliedRows     Number   0
failedRows      Number   0
canCommit       Boolean  false
message         Text     varFailureMessage
errorsJson      Text     []
projectId       Number   varProjectId
templateId      Number   0
```

Do not type `"false"` or `"0"` into Boolean/Number outputs. Use the correct response-field type.

---

## 6. YES — Stage the real workbook

Inside the YES branch add a Scope named:

```text
Scope StageImport
```

### 6.1 Get attachment content

SharePoint — **Get attachment content**.

Rename:

```text
SP GetAttachmentContent
```

Configure:

```text
Site Address       https://trsa.sharepoint.com/sites/rpa_flows
List Name          PULSE_ImportStaging
Id                 varStagingItemId
File Identifier    first(body('SP_GetAttachments'))?['Id']
```

### 6.2 Create temporary workbook

SharePoint — **Create file**.

Rename:

```text
SP CreateTempWorkbook
```

Configure:

```text
Site Address   https://trsa.sharepoint.com/sites/rpa_flows
Folder Path    /PreservOne/Pulse/ImportStaging
File Name      expression below
File Content   Attachment Content from SP GetAttachmentContent
```

File-name expression:

```text
concat(
  'PULSE_IMPORT_',
  string(variables('varStagingItemId')),
  '_',
  formatDateTime(utcNow(),'yyyyMMdd_HHmmssfff'),
  '.xlsx'
)
```

Immediately after Create file:

```text
Set variable varTempFileIdentifier = Identifier from SP CreateTempWorkbook
```

### 6.3 Run Office Script

Excel Online (Business) — **Run script**.

Rename:

```text
Excel ReadPunchCommentImport
```

Configure:

```text
Location / Workbook Location   https://trsa.sharepoint.com/sites/rpa_flows
Document Library               PreservOne
File                           varTempFileIdentifier
Script                         ReadPunchCommentImport
```

Use **Run script** when the Office Script is stored in its default OneDrive script location. If the script itself was deliberately stored in SharePoint, use **Run script from SharePoint library** and point the script-location fields to that library.

The script result is a **string containing the RowsJson array**. In the next action, select its dynamic output named `result`; do not wrap it in another `json()` or `string()` conversion.

### 6.4 Execute Stage + Validate SQL

SQL Server — **Execute stored procedure (V2)**.

Rename:

```text
SQL StageValidateImport
```

Configure:

```text
Server name       dbs-hointegration-dev.database.windows.net
Database name     db-homeoffice-dev
Procedure name    [warroom].[usp_StageValidatePunchCommentImport]
```

Parameters:

```text
ProjectId     = varProjectId
FileName      = varOriginalFileName
RequestedBy   = varRequestedBy
RowsJson      = result from Excel ReadPunchCommentImport
```

The stored procedure is already validated as Stage-only and returns one summary row in result set `Table1`.

### 6.5 Normalize the first SQL row

Add Compose:

```text
Compose StageRow
```

Expression:

```text
first(outputs('SQL_StageValidateImport')?['body/resultsets/Table1'])
```

If the designer exposes the object as `ResultSets` rather than `resultsets`, insert the SQL action's ResultSets dynamic token first and inspect the generated expression; the required logical path is `Table1[0]`.

---

## 7. Success cleanup + typed response

After `Scope StageImport`, add a Scope named:

```text
Scope Success
```

Configure **Run after** so it runs only when `Scope StageImport` **is successful**.

Inside:

### 7.1 Delete temporary workbook

SharePoint — Delete file:

```text
Site Address     https://trsa.sharepoint.com/sites/rpa_flows
File Identifier varTempFileIdentifier
```

### 7.2 Delete staging list item

SharePoint — Delete item:

```text
Site Address   https://trsa.sharepoint.com/sites/rpa_flows
List Name      PULSE_ImportStaging
Id             varStagingItemId
```

### 7.3 Respond to Power Apps

Add **Respond to a Power App or flow** named:

```text
Respond StageResult
```

Create these outputs with exactly these types and expressions. `Compose_StageRow` below means the internal reference generated by the action named `Compose StageRow`.

```text
success       Boolean  bool(coalesce(outputs('Compose_StageRow')?['success'], false))
importBatchId Text     string(coalesce(outputs('Compose_StageRow')?['importBatchId'], ''))
status        Text     string(coalesce(outputs('Compose_StageRow')?['status'], 'FAILED'))
fileName      Text     string(coalesce(outputs('Compose_StageRow')?['fileName'], variables('varOriginalFileName')))
totalRows     Number   int(coalesce(outputs('Compose_StageRow')?['totalRows'], 0))
changedRows   Number   int(coalesce(outputs('Compose_StageRow')?['changedRows'], 0))
unchangedRows Number   int(coalesce(outputs('Compose_StageRow')?['unchangedRows'], 0))
validRows     Number   int(coalesce(outputs('Compose_StageRow')?['validRows'], 0))
warningRows   Number   int(coalesce(outputs('Compose_StageRow')?['warningRows'], 0))
errorRows     Number   int(coalesce(outputs('Compose_StageRow')?['errorRows'], 0))
conflictRows  Number   int(coalesce(outputs('Compose_StageRow')?['conflictRows'], 0))
appliedRows   Number   int(coalesce(outputs('Compose_StageRow')?['appliedRows'], 0))
failedRows    Number   int(coalesce(outputs('Compose_StageRow')?['failedRows'], 0))
canCommit     Boolean  bool(coalesce(outputs('Compose_StageRow')?['canCommit'], false))
message       Text     string(coalesce(outputs('Compose_StageRow')?['message'], ''))
errorsJson    Text     string(coalesce(outputs('Compose_StageRow')?['errorsJson'], '[]'))
projectId     Number   int(coalesce(outputs('Compose_StageRow')?['projectId'], variables('varProjectId')))
templateId    Number   int(coalesce(outputs('Compose_StageRow')?['templateId'], 0))
```

This explicit typing is mandatory. PULSE already reproduced a Power Apps JSON error when a Number output was returned as Text.

---

## 8. Unexpected failure cleanup

Create a **parallel branch** after `Scope StageImport` and add a Scope named:

```text
Scope FailureCleanup
```

Configure Run after:

```text
Scope StageImport
  has failed
  has timed out
```

Inside:

1. Condition:

```text
not(empty(variables('varTempFileIdentifier')))
```

If true, SharePoint **Delete file** using `varTempFileIdentifier`.

2. SharePoint **Delete item** for `PULSE_ImportStaging / varStagingItemId`.

Configure this Delete item so it may run after the preceding temp-file cleanup Condition is successful, failed or skipped. Cleanup of one transport artifact must not prevent cleanup of the other.

3. Add `Respond to a Power App or flow` named:

```text
Respond TechnicalFailure
```

Configure it to run after the Delete item action whether that cleanup action succeeds or fails.

Response:

```text
success         Boolean  false
importBatchId   Text     ''
status          Text     FAILED
fileName        Text     varOriginalFileName
totalRows       Number   0
changedRows     Number   0
unchangedRows   Number   0
validRows       Number   0
warningRows     Number   0
errorRows       Number   0
conflictRows    Number   0
appliedRows     Number   0
failedRows      Number   0
canCommit       Boolean  false
message         Text     The workbook could not be staged. Review the failed Flow action.
errorsJson      Text     []
projectId       Number   varProjectId
templateId      Number   0
```

Do not expose raw connector exception text to end users in v1. The Flow run history remains the diagnostic source.

---

## 9. Expected designer structure

```text
Power Apps (V2)
├─ Initialize runtime variables
├─ SP GetAttachments
├─ Compose AttachmentCount
├─ Condition ExactlyOneAttachment
│  ├─ YES -> AttachmentName -> .xlsx condition -> varInputValid
│  └─ NO  -> varFailureMessage
└─ Condition InputValid
   ├─ NO
   │  ├─ SP DeleteStagingItem
   │  └─ Respond InputRejected
   └─ YES
      ├─ Scope StageImport
      │  ├─ SP GetAttachmentContent
      │  ├─ SP CreateTempWorkbook
      │  ├─ Set varTempFileIdentifier
      │  ├─ Excel ReadPunchCommentImport
      │  ├─ SQL StageValidateImport
      │  └─ Compose StageRow
      ├─ Scope Success        [run after StageImport succeeded]
      │  ├─ Delete temp workbook
      │  ├─ Delete staging item
      │  └─ Respond StageResult
      └─ Scope FailureCleanup [parallel; run after failed/timed out]
         ├─ best-effort delete temp workbook
         ├─ best-effort delete staging item
         └─ Respond TechnicalFailure
```

---

## 10. C05B gate

At the end of C05B, save the Flow and confirm:

```text
[ ] trigger inputs are StagingItemId / ProjectId / RequestedBy with correct types
[ ] SharePoint site/list/folder are the confirmed PULSE staging resources
[ ] Office Script = ReadPunchCommentImport
[ ] SQL procedure = warroom.usp_StageValidatePunchCommentImport
[ ] success response has 18 outputs with Boolean/Number/Text types preserved
[ ] handled rejection response has the same 18 outputs and types
[ ] technical-failure response has the same 18 outputs and types
[ ] Flow saves without designer errors
```

**Runtime is intentionally NOT_RUN at this gate.** The first real invocation will occur in C05C when the `EditForm + Attachments` control creates a real `PULSE_ImportStaging` item and calls the Flow from `Form.OnSuccess`.

Production comment delta remains `0` throughout C05B.

---

## 11. Next increment

```text
C05C — Real Attachment Form in scr_PunchImport
```

That increment replaces the synthetic `Choose Excel file` behavior with the supported SharePoint form/attachment transport and performs the first end-to-end real workbook test.