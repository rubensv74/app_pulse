# PR-EXP-C03C2B-FIX2 — Template label + rowCount de respuesta correcta

## Motivo

Durante la validación end-to-end del export de Punch Review se han confirmado dos ajustes:

1. el modal muestra `20` en la tarjeta **TEMPLATE**, cuando el usuario debe ver el mismo texto amigable que ya aparece en el selector de cabecera, por ejemplo `70200 - Master Punch List`;
2. el banner `JSON parsing error, expected 'number' but got 'string'` sigue apareciendo porque la conversión `int(...)` se aplicó en `Respond ExportFailure`, pero la ejecución correcta termina por la acción superior `Respond to a Power App or flow`.

El Flow sí está generando el Excel y el scope exacto está funcionando. Estos cambios corrigen la presentación y el contrato de respuesta hacia Power Apps.

---

## FIX2-A — Tarjeta TEMPLATE del Premium Export Modal

### Control

`scr_PunchReview > conPRExport_Layer > conPRExport_Dialog > conPRExport_TemplateCard > lblPRExport_TemplateValue`

### Propiedad

`Text`

### Acción

**REEMPLAZAR COMPLETAMENTE** la fórmula actual por:

```powerfx
=Coalesce(
    cmbPR_Template.Selected.TemplateLabel,
    LookUp(
        colPunchTemplates_Filter,
        TemplateId = varPunchReviewTemplateId,
        TemplateLabel
    ),
    Text(varPunchReviewTemplateId)
)
```

### Resultado esperado

Para el contexto validado:

```text
70200 - Master Punch List
```

La fórmula reutiliza el mismo `TemplateLabel` que gobierna el combobox de cabecera de Punch Review, evitando mostrar al usuario el identificador técnico `20`.

---

## FIX2-B — `rowCount` debe corregirse en la respuesta SUCCESS

En el Flow `Warroom_ExportPunchReviewToExcel` hay dos acciones de respuesta:

1. `Respond to a Power App or flow` — ruta **SUCCESS**;
2. `Respond ExportFailure` — ruta de error.

La captura de validación muestra que `int(...)` fue introducido en `Respond ExportFailure`. Esa acción aparece `Skipped` en una ejecución correcta, por lo que no corrige el contrato que recibe Power Apps.

### Acción correcta

Abre la acción superior:

`Respond to a Power App or flow`

En el output:

`rowCount`

mantén el tipo **Number** y sustituye su valor por la expresión:

```text
int(outputs('Compose_RowCount'))
```

### Ruta de error

En `Respond ExportFailure`, `rowCount` puede permanecer simplemente como:

```text
0
```

numérico.

### Resultado esperado

En una ejecución correcta:

- `Respond to a Power App or flow` = Succeeded;
- `Respond ExportFailure` = Skipped; esto es normal;
- Power Apps deja de mostrar `JSON parsing error, expected 'number' but got 'string'`;
- `flowResponse.rowcount` llega como número;
- `varPRExportRowCount` adopta el número real de filas exportadas.

---

## Gate de validación

Usar la cola actual de 3 Punches:

1. guardar el Flow después de corregir **la respuesta SUCCESS**;
2. en Power Apps abrir Punch Review > Export;
3. confirmar que la tarjeta TEMPLATE muestra `70200 - Master Punch List`;
4. seleccionar `Client / external`;
5. pulsar `Generate Excel` una sola vez;
6. comprobar que no aparece el banner JSON;
7. comprobar que el Excel contiene exactamente 3 Punches;
8. comprobar que `varPRExportRowCount = 3`;
9. comprobar que el pie del modal puede mostrar el estado `SUCCESS` sin errores de fórmula.

No avanzar al perfil INTERNAL hasta pasar este gate.