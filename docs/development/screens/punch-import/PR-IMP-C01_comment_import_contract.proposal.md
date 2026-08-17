# PR-IMP-C01 — Comment import contract proposal

Fecha: 2026-08-17

Estado: PRODUCT GATE — requiere aprobar el alcance de escritura del primer release antes de construir Stage/Validate SQL.

## 1. Hallazgo que abre el gate

El workbook INTERNAL validado permite actualmente editar dos familias distintas:

1. `New Comment` — verde.
2. Custom Fields autorizados por el mapa backend — azul, por ejemplo Punch Location, Critical, Level Criticity, Person Responsible y Target Date.

El encargo original del módulo de Import pide cargar una plantilla Excel, previsualizar cambios y aplicar cambios sobre comentarios.

Si construimos el backend sin congelar esta frontera, el Excel puede invitar al usuario a editar campos que después el Import no aplicaría, o ampliar silenciosamente el alcance de escritura.

## 2. Contrato recomendado para v1

### Única escritura de negocio

`NewComment`

Semántica:

- celda vacía = sin cambio;
- texto informado = añadir un nuevo comentario al historial del Punch;
- nunca sustituye ni modifica `LastCommentText`;
- nunca borra comentarios existentes;
- no existe `CLEAR` para comentarios en v1;
- una fila puede añadir como máximo un nuevo comentario en un intento de importación;
- el autor registrado será el usuario que confirma el Import en PULSE, no un valor editable del Excel;
- `CommentType` se establecerá mediante un valor técnico fijo para imports, recomendado `EXCEL_IMPORT`, o NULL si se decide conservar la semántica actual sin tipo específico.

### Persistencia

La escritura debe ser append-only sobre `warroom.PunchComment`.

Existe ya `warroom.usp_AddPunchComment` con el contrato:

- `@ProjectId`
- `@PunchId`
- `@CommentText`
- `@CommentType`
- `@CreatedByEmail`
- `@CreatedByName`

El procedimiento valida que el comentario no esté vacío y crea una nueva fila de historial. El Import debe preservar esta semántica, preferiblemente mediante un procedimiento de commit por lote que realice la misma inserción de forma transaccional y auditada.

## 3. Columnas que NO deben producir escritura en v1

- `LastCommentText`
- `LastCommentOn`
- `CommentCount`
- cualquier columna técnica
- cualquier columna auxiliar
- Custom Fields azules, aunque el workbook actual permita editarlos

Si cualquiera de esos valores cambia en el archivo, Stage/Validate debe ignorarlo solo cuando sea una columna estrictamente de solo lectura sin posibilidad de confusión, o preferiblemente marcarlo como `ERROR / COLUMN_NOT_ALLOWED` cuando el cambio afecte una columna de negocio no incluida en el contrato v1.

## 4. Recomendación de UX para evitar expectativas falsas

Mientras v1 solo importe comentarios, el perfil INTERNAL originado desde Punch Review debería evolucionar a un subperfil `Comment import` donde únicamente `New Comment` quede editable.

Los Custom Fields pueden habilitarse en una capacidad posterior cuando exista su propio contrato Stage/Preview/Commit.

Esto no exige rehacer el workbook base: `BuildPunchExport.ts` ya diferencia columnas editables mediante metadata y puede recibir un mapa filtrado/específico para el escenario.

## 5. Concurrencia

El comentario nuevo es append-only, pero la identidad del Punch y la integridad del snapshot siguen siendo obligatorias.

Stage/Validate debe comprobar como mínimo:

- ExportBatch válido y no expirado/revocado;
- ProjectId y TemplateId correctos;
- WorkItemId perteneciente al ExportBatch;
- RowChecksum original válido;
- fila no duplicada;
- `NewComment` dentro del contrato;
- ninguna columna de escritura no autorizada modificada.

Para `NewComment`, un cambio concurrente en otros comentarios no necesita bloquear automáticamente la inserción si el Punch sigue siendo válido, porque añadir un comentario no sobrescribe historia. Sin embargo, cualquier cambio concurrente en campos que formen parte del checksum debe mostrarse en Preview como advertencia o conflicto según la política general del lote.

## 6. Auditoría

Al hacer Commit:

- crear la fila `PunchComment`;
- registrar `ImportAudit` con `ColumnName = 'NewComment'`;
- `OldValue = NULL` porque no existe valor reemplazado;
- `NewValue = comentario importado`;
- `ChangedBy = usuario que confirma`;
- mantener relación con `ImportBatchId` y `WorkItemId`.

## 7. Decisión pendiente

### Opción recomendada A — Comments only v1

Importa únicamente `NewComment`.

Ventajas:

- coincide exactamente con el encargo inicial;
- es append-only y de bajo riesgo;
- no sobreescribe datos existentes;
- permite construir Stage/Preview/Commit de manera pequeña y verificable;
- deja Custom Fields para una capacidad posterior independiente.

### Opción B — Comments + Custom Fields v1

Importa `NewComment` y todos los campos con `IsEditableInExcel = true`.

Ventaja: aprovecha todo el workbook INTERNAL actual.

Coste/riesgo: requiere definir persistencia, clear semantics, tipos, validaciones y concurrencia para Text, Number, Date, YesNo, Choice y MultiChoice antes de escribir Stage/Validate.

## Recomendación final

Aprobar **Opción A — Comments only v1**.

Después de esa aprobación, el siguiente incremento será `PR-IMP-C02 — Stage + Validate SQL`, comenzando con un workbook real como el que ya hemos generado y garantizando que ninguna validación toca producción.