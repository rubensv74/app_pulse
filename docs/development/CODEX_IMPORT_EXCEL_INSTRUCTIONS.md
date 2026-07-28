# CODEX — INSTRUCCIONES DE DESARROLLO

## EPIC: Importación de Excel en PULSE

Actúa como desarrollador principal del repositorio `app_pulse`.

Tu objetivo es implementar de forma incremental la funcionalidad de importación de Excel para PULSE, partiendo de los archivos reales existentes en el repositorio.

La importación recibirá como entrada un archivo Excel previamente exportado por PULSE. Los usuarios habrán modificado exclusivamente las columnas desbloqueadas. El sistema deberá validar el archivo, detectar diferencias, prevenir sobrescrituras incorrectas y aplicar únicamente los cambios autorizados.

---

# 1. Fuente de verdad

La única fuente de verdad es el estado actual del repositorio abierto en Visual Studio Code.

Antes de modificar nada:

1. Inspecciona la estructura completa del repositorio.
2. Localiza los módulos existentes relacionados con:

   * Exportación Excel.
   * Punch List.
   * Power Apps.
   * Power Automate.
   * Azure SQL.
   * Contratos de datos.
   * Mapeos.
   * Documentación técnica.
3. Identifica convenciones reales:

   * Nombres de carpetas.
   * Nombres de archivos.
   * Versionado.
   * Esquemas SQL.
   * Convenciones de Stored Procedures.
   * Formato de contratos.
   * Estructura de los archivos `.pa.yaml`.
4. No inventes rutas, carpetas ni nombres si ya existe una convención equivalente.
5. No sustituyas archivos sin inspeccionarlos antes.
6. No asumas que la documentación antigua representa el estado actual si contradice el código.

---

# 2. Forma de trabajo obligatoria

El desarrollo se ejecutará por sprints.

Cada sprint debe terminar con un entregable real y verificable dentro del repositorio.

No avances al siguiente sprint hasta que el sprint actual:

* Tenga los archivos creados o modificados.
* Tenga documentación de implementación.
* Tenga pruebas o validaciones ejecutadas.
* Tenga un changelog actualizado.
* No deje referencias rotas.
* No deje pseudocódigo presentado como implementación final.

Cuando el alcance completo no pueda cerrarse, implementa un incremento mínimo funcional, pero no declares cerrado el sprint completo.

---

# 3. Modalidad de entrega

Trabaja directamente sobre el repositorio.

Al finalizar cada sprint debes indicar:

1. Archivos creados.
2. Archivos modificados.
3. Archivos eliminados, si los hubiera.
4. Validaciones ejecutadas.
5. Resultado de cada validación.
6. Riesgos o incidencias reales pendientes.
7. Dependencias para el siguiente sprint.

No incluyas cambios que no estén físicamente implementados.

No declares que un archivo ha sido creado o modificado si no existe realmente en el repositorio.

---

# 4. Reglas de implementación

## 4.1 Power Apps

Las pantallas, componentes y modales deben entregarse como archivos completos en formato Source Code YAML:

```text
*.pa.yaml
```

Reglas obligatorias:

* No entregar fragmentos aislados cuando el archivo completo sea necesario.
* Mantener el esquema Source Code compatible con Power Apps.
* No usar propiedades no soportadas por el tipo de control.
* No usar `Tooltip` en controles ModernText si no está soportado.
* No usar propiedades `RadiusTopLeft`, `RadiusTopRight`, `RadiusBottomLeft` o `RadiusBottomRight` en `Label` o `Rectangle` si el compilador no las admite.
* No insertar componentes dentro de galerías cuando Power Apps no lo soporte.
* Mantener nombres de controles estables y semánticos.
* Evitar referencias a variables o colecciones no definidas.
* Verificar cambios de contexto dentro de galerías anidadas.
* Usar fórmulas completas y sintácticamente válidas.
* Mantener la compatibilidad con la configuración regional actual de fórmulas del proyecto.

Antes de cerrar cualquier cambio YAML:

* Validar indentación.
* Validar estructura.
* Buscar referencias rotas.
* Buscar propiedades incompatibles.
* Comprobar variables utilizadas y definidas.

## 4.2 SQL

Todos los scripts SQL deben ser:

* Idempotentes cuando sea razonable.
* Ejecutables de forma independiente o con dependencias documentadas.
* Totalmente cualificados con esquema.
* Compatibles con Azure SQL.
* Basados en operaciones set-based.
* Transaccionales cuando actualicen datos productivos.
* Auditables.
* Preparados para rollback ante fallo técnico.

No procesar una fila Excel mediante una llamada SQL independiente si puede resolverse en bloque.

Los procedimientos deben incluir:

* Validación de parámetros.
* Manejo de errores con `TRY/CATCH`.
* Transacciones cuando proceda.
* Resultados estructurados.
* Códigos de estado coherentes.
* Comentarios técnicos breves cuando aporten valor.

## 4.3 Power Automate

Los Flows deben documentarse como archivos reproducibles.

Cada definición debe incluir:

* Nombre del Flow.
* Trigger.
* Parámetros de entrada.
* Variables.
* Acciones en orden.
* Condiciones.
* Bucles.
* Expresiones exactas.
* Llamadas SQL.
* Gestión de errores.
* Salida completa.
* Contrato con Power Apps.
* Acciones de limpieza.

No describir el Flow de forma conceptual únicamente. Debe poder reconstruirse paso a paso.

## 4.4 Contratos

Todos los intercambios entre Power Apps, Power Automate y SQL deben tener contratos versionados.

Los contratos deben definir:

* Nombre del campo.
* Tipo.
* Nulabilidad.
* Descripción.
* Ejemplo.
* Reglas de validación.
* Compatibilidad entre versiones.

No modificar silenciosamente un contrato existente. Crear una nueva versión cuando haya cambios incompatibles.

## 4.5 Mapeos y configuración

Las columnas importables no deben estar codificadas únicamente en la interfaz.

Debe existir una lista blanca controlada en backend o configuración.

La configuración debe poder expresar al menos:

* Columna origen Excel.
* Campo destino.
* Tipo de dato.
* Editable o no editable.
* Obligatorio.
* Longitud máxima.
* Regla de validación.
* Template aplicable.
* Proyecto aplicable, cuando proceda.
* Orden de presentación.
* Nombre visible.

---

# 5. Principios funcionales de la importación

La importación no representa una sustitución completa de datos.

Representa un conjunto de cambios sobre un export generado previamente por PULSE.

Debe mantenerse esta secuencia:

```text
Seleccionar archivo
→ Analizar
→ Crear lote
→ Cargar staging
→ Validar
→ Detectar cambios
→ Mostrar previsualización
→ Confirmar
→ Revalidar
→ Aplicar
→ Auditar
```

Nunca actualizar directamente tablas productivas al subir el archivo.

---

# 6. Reglas funcionales obligatorias

La primera versión debe cumplir estas reglas:

1. Solo se aceptan archivos generados por PULSE.
2. El archivo debe pertenecer a un único proyecto.
3. El archivo debe pertenecer a un único template.
4. No se pueden mezclar MPL, CPL u otros templates.
5. Solo se actualizan registros existentes.
6. No se crean nuevos punches desde Excel.
7. No se eliminan registros.
8. Solo se modifican columnas incluidas en una lista blanca.
9. Las columnas bloqueadas no deben aplicarse aunque hayan sido manipuladas.
10. Debe detectarse cualquier fila duplicada.
11. Debe detectarse cualquier identificador inexistente.
12. Deben validarse tipos, longitudes y valores permitidos.
13. Debe existir control de concurrencia.
14. Debe evitarse reutilizar un lote ya importado.
15. Todos los cambios aplicados deben quedar auditados.
16. La importación debe poder cancelarse antes del commit.
17. La subida y la aplicación deben ser operaciones separadas.
18. Si existen errores bloqueantes, el commit completo debe quedar bloqueado en el MVP.

---

# 7. Metadatos técnicos requeridos en el export

El export debe conservar o incorporar estas columnas técnicas:

```text
ExportBatchId
ProjectId
TemplateId
WorkItemId
RowVersion
ExportedAtUtc
RowChecksum
```

Estas columnas deben:

* No ser editables.
* Estar protegidas.
* Ser validadas en backend.
* No considerarse confiables solo porque estén ocultas o bloqueadas en Excel.

El backend debe verificar los valores contra el lote original almacenado en SQL.

---

# 8. Modelo de datos objetivo

El modelo previsto incluye estas entidades:

```text
warroom.ExportBatch
warroom.ExportBatchRow
warroom.ImportBatch
warroom.ImportBatchRow
warroom.ImportAudit
```

Antes de crearlas, comprueba si ya existen tablas equivalentes.

Reutiliza estructuras existentes cuando cubran correctamente la necesidad.

No crees entidades duplicadas por diferencias menores de nomenclatura.

## ExportBatch

Debe identificar:

```text
ExportBatchId
ProjectId
TemplateId
ExportType
CreatedBy
CreatedAtUtc
ExpiresAtUtc
Status
FileName
RowCount
AllowedColumnsJson
```

## ExportBatchRow

Debe conservar:

```text
ExportBatchId
WorkItemId
RowVersion
OriginalValuesJson
RowChecksum
```

## ImportBatch

Debe contener, como mínimo:

```text
ImportBatchId
ExportBatchId
ProjectId
TemplateId
FileName
RequestedBy
RequestedAtUtc
ValidatedAtUtc
CommittedAtUtc
Status
TotalRows
ChangedRows
UnchangedRows
ValidRows
WarningRows
ErrorRows
ConflictRows
AppliedRows
FailedRows
ErrorMessage
```

## ImportBatchRow

Debe contener:

```text
ImportBatchRowId
ImportBatchId
ExcelRowNumber
WorkItemId
IncomingValuesJson
OriginalValuesJson
CurrentValuesJson
ChangedColumnsJson
ValidationStatus
ValidationErrorsJson
ValidationWarningsJson
ApplyStatus
ApplyError
```

## ImportAudit

Debe registrar:

```text
ImportAuditId
ImportBatchId
WorkItemId
ColumnName
OldValue
NewValue
ChangedBy
ChangedAtUtc
```

---

# 9. Control de concurrencia

Debe compararse el estado exportado con el estado actual.

La estrategia preferida será utilizar:

```text
RowVersion
```

o un mecanismo equivalente ya existente.

Debe detectarse el caso:

```text
Valor original exportado
Valor actual en SQL
Valor recibido desde Excel
```

Cuando el registro haya cambiado después de la exportación, la fila debe clasificarse como:

```text
CONFLICT
```

En el MVP, una fila en conflicto no debe actualizarse automáticamente.

No implementar sobrescritura forzada sin una decisión funcional explícita.

---

# 10. Stored Procedures objetivo

Los procedimientos previstos son:

```text
warroom.usp_CreateImportBatch
warroom.usp_StageImportRows
warroom.usp_ValidateImportBatch
warroom.usp_GetImportBatchSummary
warroom.usp_GetImportBatchErrors
warroom.usp_CommitImportBatch
warroom.usp_CancelImportBatch
```

Antes de crearlos:

* Comprueba si existen SP equivalentes.
* Respeta las convenciones reales del repositorio.
* Evita duplicidades.
* Documenta dependencias.

La validación debe ser set-based.

El commit debe:

1. Revalidar el lote.
2. Comprobar concurrencia otra vez.
3. Iniciar transacción.
4. Actualizar únicamente columnas autorizadas.
5. Escribir auditoría.
6. Actualizar estado del lote.
7. Confirmar la transacción.
8. Hacer rollback completo ante fallo técnico global.

---

# 11. Flows objetivo

## Flow de validación

Nombre orientativo:

```text
PULSE_ImportPunchExcel_Validate
```

Debe:

1. Recibir el archivo desde Power Apps.
2. Guardarlo temporalmente.
3. Leer la tabla estructurada de Excel.
4. Extraer los datos mediante Office Script o mecanismo eficiente equivalente.
5. Crear el lote de importación.
6. Enviar los datos a staging.
7. Ejecutar validaciones.
8. Devolver el resumen.
9. Limpiar recursos temporales cuando corresponda.

No utilizar una llamada SQL por fila.

## Flow de commit

Nombre orientativo:

```text
PULSE_ImportPunchExcel_Commit
```

Debe:

1. Recibir `ImportBatchId`.
2. Verificar que el lote está listo.
3. Revalidar antes de aplicar.
4. Ejecutar el commit SQL.
5. Devolver el resumen final.
6. Gestionar errores de forma estructurada.

---

# 12. Contrato de salida de validación

El resultado debe seguir una estructura equivalente a:

```json
{
  "success": true,
  "importBatchId": 4812,
  "status": "READY",
  "fileName": "Punches_4049_20260728.xlsx",
  "totalRows": 2450,
  "changedRows": 231,
  "unchangedRows": 2201,
  "validRows": 2208,
  "warningRows": 11,
  "errorRows": 7,
  "conflictRows": 4,
  "canCommit": false,
  "message": "The file was validated with blocking errors.",
  "errorsJson": "[]"
}
```

Ajusta los nombres a las convenciones reales del repositorio, pero mantén el significado funcional.

---

# 13. Interfaz Power Apps objetivo

La interfaz debe permitir:

```text
Seleccionar archivo
Validar archivo
Visualizar resumen
Visualizar errores
Visualizar advertencias
Visualizar conflictos
Cancelar
Confirmar importación
Descargar incidencias
```

La previsualización debe mostrar:

```text
Excel Row
Punch Code
Subsystem
Result
Changed Fields
Message
```

Estados funcionales:

```text
READY
UNCHANGED
WARNING
ERROR
CONFLICT
```

El modal o pantalla debe utilizar las variables globales y patrones de loading existentes en PULSE.

No crear un sistema visual paralelo si ya existe un patrón común de modales, drawers, banners, botones o loaders.

---

# 14. Rendimiento

Evitar:

* Procesamiento fila a fila en Power Automate.
* Múltiples llamadas SQL individuales.
* Carga completa de cientos de miles de filas.
* JSON excesivamente redundante.
* Fórmulas Power Apps que procesen todo el archivo localmente.

Usar:

* Tabla estructurada Excel.
* Office Script cuando sea adecuado.
* Carga por bloques.
* Staging SQL.
* Validaciones set-based.
* Paginación de errores.
* Filtros de exportación.

Límite inicial recomendado para el MVP:

```text
5.000 filas por archivo
```

No aplicar este límite si el repositorio ya define otro formalmente. En ese caso, documenta la diferencia.

---

# 15. Plan de sprints

## Sprint I01 — Fundaciones

Objetivo:

* Analizar el export existente.
* Añadir metadatos técnicos.
* Crear modelo SQL base.
* Crear contratos iniciales.
* Definir lista blanca de columnas.
* Documentar arquitectura.

Entregables esperados:

```text
SQL de tablas
Contratos JSON
Mapeo de columnas
Documentación del sprint
Actualización del export
CHANGELOG
```

## Sprint I02 — Validación backend

Objetivo:

* Crear lote.
* Cargar staging.
* Validar filas.
* Calcular diferencias.
* Detectar conflictos.

Entregables esperados:

```text
Stored Procedures completos
Reglas de validación
Mapeos
Casos de prueba
CHANGELOG
```

## Sprint I03 — Flow de validación

Objetivo:

* Recibir Excel.
* Extraer datos.
* Invocar backend.
* Devolver resultado estructurado.

Entregables esperados:

```text
Definición reproducible del Flow
Office Script, si procede
Contrato de entrada y salida
Guía de construcción
Pruebas
CHANGELOG
```

## Sprint I04 — UI de importación

Objetivo:

* Crear pantalla o modal.
* Seleccionar archivo.
* Lanzar validación.
* Mostrar resumen.
* Mostrar errores y conflictos.

Entregables esperados:

```text
Archivo YAML completo
Contratos Power Apps
Mapeos de colecciones
Guía de integración
Pruebas
CHANGELOG
```

## Sprint I05 — Commit y auditoría

Objetivo:

* Confirmar lote.
* Revalidar.
* Aplicar cambios.
* Registrar auditoría.
* Refrescar Punch List.

Entregables esperados:

```text
SP de commit
Flow de commit
Contrato final
Integración Power Apps
Pruebas
CHANGELOG
```

## Sprint I06 — Endurecimiento

Objetivo:

* Limpieza.
* Reintentos.
* Expiración.
* Rendimiento.
* Casos límite.
* Pruebas integrales.

Entregables esperados:

```text
Scripts de mantenimiento
Mejoras de robustez
Pruebas E2E
Documentación operativa
CHANGELOG
```

---

# 16. Estructura mínima de documentación por sprint

Cada sprint debe crear o actualizar un documento equivalente a:

```text
README_SPRINT_IXX.md
```

Debe contener:

```text
Objetivo
Alcance implementado
Archivos creados
Archivos modificados
Dependencias
Instrucciones de instalación
Instrucciones de prueba
Resultados de validación
Limitaciones conocidas
Siguiente paso
```

---

# 17. CHANGELOG

Actualizar el `CHANGELOG.md` existente.

Si no existe, crear uno siguiendo la convención del repositorio.

No crear múltiples changelogs incompatibles.

Cada entrada debe distinguir:

```text
Added
Changed
Fixed
Removed
Known Issues
```

---

# 18. Prohibiciones

No debes:

* Implementar todos los sprints de una vez.
* Inventar que una validación fue ejecutada.
* Declarar que Power Apps compiló si no se comprobó.
* Declarar que un Flow funciona si solo está documentado.
* Crear tablas duplicadas.
* Cambiar contratos sin versionarlos.
* Actualizar producción durante la fase de validación.
* Confiar en la protección visual de Excel.
* Aplicar columnas no autorizadas.
* Ignorar cambios concurrentes.
* Introducir valores secretos, conexiones o credenciales.
* Sobrescribir archivos ajenos al sprint sin justificación.
* Refactorizar áreas no relacionadas salvo que sea necesario para compilar o integrar.
* Eliminar funcionalidad existente para simplificar el desarrollo.

---

# 19. Validaciones mínimas antes de cerrar un sprint

Ejecuta todas las validaciones disponibles en el repositorio.

Como mínimo:

```text
Revisión de sintaxis
Búsqueda de referencias rotas
Validación SQL
Validación JSON
Validación YAML
Revisión de nombres y rutas
Revisión de contratos
Revisión de dependencias
```

Cuando una prueba no pueda ejecutarse, indicar:

```text
Prueba no ejecutada
Motivo exacto
Riesgo asociado
Procedimiento manual recomendado
```

No presentar una prueba no ejecutada como superada.

---

# 20. Respuesta final obligatoria de Codex

Al finalizar el sprint responde con esta estructura:

```text
SPRINT COMPLETADO: IXX — Nombre

Resumen
- ...

Archivos creados
- ruta/archivo

Archivos modificados
- ruta/archivo

Archivos eliminados
- Ninguno

Validaciones ejecutadas
- Validación: resultado

Pruebas no ejecutadas
- Prueba: motivo

Decisiones técnicas
- ...

Incidencias abiertas
- ...

Preparado para handoff
- Sí / No
```

Si el sprint no está realmente completo, utiliza:

```text
SPRINT PARCIALMENTE IMPLEMENTADO
```

y especifica con precisión lo pendiente.

---

# 21. Primera acción

Comienza por el Sprint I01.

Antes de realizar cambios:

1. Inspecciona el repositorio.
2. Localiza el export actual de Punches.
3. Identifica:

   * Flow de exportación.
   * Stored Procedures.
   * Contratos.
   * Pantallas Power Apps relacionadas.
   * Mapeo de columnas editables.
4. Presenta un diagnóstico breve basado en archivos reales.
5. Implementa el Sprint I01.
6. No avances al Sprint I02.
