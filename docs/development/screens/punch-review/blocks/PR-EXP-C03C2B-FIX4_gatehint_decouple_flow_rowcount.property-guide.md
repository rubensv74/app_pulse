# PR-EXP-C03C2B-FIX4 — Desacoplar el GateHint del `rowCount` del Flow

## Hallazgo

`lblPRExport_GateHint.Text` queda marcado con:

```text
JSON parsing error, expected 'number' but got 'string'.
```

La fórmula del label es sintácticamente válida. El problema aparece porque el estado de export está consumiendo `varPRExportRowCount`, una variable alimentada por la respuesta del Flow mientras el contrato de `rowCount` todavía está siendo corregido.

El GateHint no necesita depender del contador devuelto por Power Automate: ya existe `varPRExportScopeCount`, calculado localmente desde la Review Queue exacta y validado antes de ejecutar el Flow.

## Cambio

Control:

`lblPRExport_GateHint`

Propiedad:

`Text`

**REEMPLAZAR COMPLETAMENTE** por:

```powerfx
=If(
    varPRExportState = "GENERATING",
    "Generating governed Excel package...",

    varPRExportState = "SUCCESS",
    "Export ready - " &
    Text(varPRExportScopeCount) &
    " punches - " &
    If(
        IsBlank(varPRExportFileName),
        "Excel generated",
        varPRExportFileName
    ),

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

- `varPRExportScopeCount` es local, numérico y deriva directamente de `colPunchReviewQueue`.
- El texto de éxito debe representar el scope que el usuario decidió exportar.
- El `rowCount` retornado por el Flow sigue siendo útil para validación técnica, logging y comparación end-to-end, pero no debe ser una dependencia de renderizado del modal mientras se corrige su schema de respuesta.

## Gate de Studio

1. La fórmula deja de aparecer en rojo.
2. Con estado `CONFIGURE`, muestra `Exact Review Queue scope ready - X WorkItems serialized.`.
3. Con estado `GENERATING`, muestra `Generating governed Excel package...`.
4. Con estado `SUCCESS`, muestra `Export ready - X punches - <filename>`.
5. El runtime error de `rowCount` del Flow, si aún existe, debe resolverse aparte en la acción de respuesta de éxito de Power Automate.
