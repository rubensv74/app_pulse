# PR-EXP-C03C2B-FIX1 — corregir tipo `rowCount` en la respuesta del Flow

## Síntoma

El export se genera correctamente y el Excel contiene exactamente los Punches esperados, pero Power Apps muestra:

```text
JSON parsing error, expected 'number' but got 'string'.
```

## Diagnóstico

La definición histórica validada de `Warroom_ExportPunchesToExcel_Codex` demuestra que el output `rowcount` está declarado en el schema de respuesta como `number`, pero el body lo devuelve mediante interpolación de texto:

```json
"rowcount": "@{outputs('Compose_RowCount')}"
```

Eso serializa el valor como string, por ejemplo `"3"`, mientras Power Apps espera un número `3`.

La creación del fichero, Office Script y snapshot ya han terminado antes de esta respuesta; por eso el Excel sí se genera aunque Power Apps falle al parsear el response.

## Corrección en `Warroom_ExportPunchReviewToExcel`

### Acción: `Respond to a Power App or flow`

Mantén el output `rowCount` con tipo **Number**.

En el valor de `rowCount`, elimina el token dinámico actual y usa la expresión:

```text
int(outputs('Compose_RowCount'))
```

No uses:

```text
outputs('Compose_RowCount')
```

ni una interpolación textual del tipo:

```text
@{outputs('Compose_RowCount')}
```

porque puede volver a serializarse como texto.

### Acción: `Respond ExportFailure`

Mantén:

```text
rowCount = 0
```

como valor numérico literal.

## Power Apps

No es necesario cambiar el `OnSelect` por este incidente. Esta línea sigue siendo válida:

```powerfx
Set(
    varPRExportRowCount,
    Coalesce(Value(flowResponse.rowcount), 0)
)
```

La conversión `Value(...)` es inocua si `flowResponse.rowcount` ya llega tipado como Number. El fallo actual ocurre antes, durante el parseo del response del Flow.

## Gate de validación

1. Guardar el Flow.
2. Si Power Apps mantiene el contrato anterior en caché, eliminar solo la referencia `Warroom_ExportPunchReviewToExcel` de la app y volver a añadirla.
3. Repetir el export CLIENT con la Review Queue actual.
4. Esperado:
   - Flow = Succeeded;
   - no aparece `JSON parsing error`;
   - `varPRExportRowCount` coincide con la cola;
   - el pie del modal pasa a `Export ready`;
   - el Excel se abre con exactamente los Punches de la Review Queue.

## Observación UX separada

El nombre actual del fichero usa el `ProjectId` interno (`4049`) porque `Init_FileName` construye el nombre a partir de `varProjectId`. Esto no afecta a C03C2B-FIX1, pero debe corregirse en un incremento posterior para que el usuario vea el código de proyecto funcional (`70200`) y no la clave interna de base de datos.
