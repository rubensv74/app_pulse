# PR-EXP-C03C2B-FIX3 — Simplificar `lblPRExport_GateHint.Text`

## Síntoma

Power Apps Studio marca toda la fórmula de `lblPRExport_GateHint.Text` como inválida. Para evitar que una inferencia de tipos dentro de `Switch` + `Coalesce` invalide toda la expresión, sustituimos la fórmula por una versión equivalente basada únicamente en `If` anidados y variables ya tipadas.

## Acción

Control:

`lblPRExport_GateHint`

Propiedad:

`Text`

**REEMPLAZA COMPLETAMENTE** la fórmula actual por:

```powerfx
=If(
    varPRExportState = "GENERATING",
    "Generating governed Excel package...",

    varPRExportState = "SUCCESS",
    "Export ready - " &
    Text(varPRExportRowCount) &
    " punches - " &
    varPRExportFileName,

    varPRExportState = "ERROR",
    "Export failed - " & varPRExportError,

    If(
        varPRExportScopeValid,
        "Exact Review Queue scope ready - " &
        Text(varPRExportScopeCount) &
        " WorkItems serialized.",

        If(
            IsBlank(varPRExportScopeError),
            "Preparing exact Review Queue scope...",
            "Scope blocked - " & varPRExportScopeError
        )
    )
)
```

## Motivo

Esta versión elimina del control visual:

- `Switch(...)`;
- `Upper(...)`;
- `Coalesce(...)` sobre variables booleanas y numéricas;
- caracteres decorativos que no aportan lógica.

El comportamiento funcional no cambia:

- `GENERATING` muestra progreso;
- `SUCCESS` muestra filas y fichero;
- `ERROR` muestra el mensaje;
- en estado normal muestra la disponibilidad del scope exacto.

## Importante

El banner superior `JSON parsing error, expected 'number' but got 'string'.` es un problema distinto. Procede de la respuesta tipada del Flow hacia Power Apps. Esta corrección resuelve únicamente la fórmula visual de `lblPRExport_GateHint.Text`.

En `Respond to a Power App or flow` (la respuesta de éxito), `rowCount` debe ser de tipo Number y su valor debe ser:

```text
int(outputs('Compose_RowCount'))
```

`Respond ExportFailure` puede devolver `0` como número.

## Gate

Después de sustituir la fórmula:

1. Studio deja de subrayar `lblPRExport_GateHint.Text` en rojo.
2. El modal abre normalmente.
3. Antes de generar muestra `Exact Review Queue scope ready...`.
4. Después de corregir también `rowCount` en la respuesta de éxito del Flow, el export debe completar sin el banner JSON.
