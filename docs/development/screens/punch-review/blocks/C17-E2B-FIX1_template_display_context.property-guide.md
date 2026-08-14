# C17-E2B-FIX1 — Punch Review template display context

**Estado:** READY FOR POWER APPS STUDIO — REVISION 2  
**Target:** `scr_PunchReview → conPR_TemplateContext → cmbPR_Template`  
**Tipo:** property-guide / read-only context display  
**No tocar:** `varPunchReviewTemplateId`, loaders, Home template selector, Punch List template selector, flows.

## Corrección de la primera propuesta

La primera revisión de este FIX introducía un contrato artificial `{Value: ...}` y proponía `Self.Items` para `DefaultSelectedItems`. Power Apps Studio ha demostrado que esa combinación no es compatible con el `ModernCombobox@1.1.1` instalado en PULSE:

- `ThisItem.Value` no queda reconocido para ese `Items`.
- `Self.Items` no queda reconocido desde `DefaultSelectedItems`.

Por tanto, **esa primera propuesta queda SUPERCEDIDA y no debe utilizarse**.

La solución correcta es reutilizar exactamente el patrón que ya funciona en el selector de template de Home: `AddColumns(..., TemplateDisplayText, ...)`, `ItemDisplayText = ThisItem.TemplateDisplayText` y un `DefaultSelectedItems` que filtra la misma proyección tipada.

## Cambio 1 — `cmbPR_Template.Items`

Sustituir completamente por:

```powerfx
=AddColumns(
    colPunchTemplates_Filter,
    TemplateDisplayText,
    Coalesce(
        TemplateDisplayName,
        TemplateName,
        TemplateCode,
        Text(TemplateId)
    )
)
```

## Cambio 2 — `cmbPR_Template.ItemDisplayText`

Sustituir completamente por:

```powerfx
=ThisItem.TemplateDisplayText
```

## Cambio 3 — `cmbPR_Template.DefaultSelectedItems`

Sustituir completamente por:

```powerfx
=If(
    IsBlank(varPunchReviewTemplateId),
    [],
    Filter(
        AddColumns(
            colPunchTemplates_Filter,
            TemplateDisplayText,
            Coalesce(
                TemplateDisplayName,
                TemplateName,
                TemplateCode,
                Text(TemplateId)
            )
        ),
        Value(TemplateId) = Value(varPunchReviewTemplateId)
    )
)
```

## Mantener

```powerfx
DisplayMode = DisplayMode.View
SelectMultiple = false
IsSearchable = false
```

No usar:

```powerfx
ThisItem.Value
Self.Items
```

para este control en PULSE.

## Por qué este patrón

Home ya utiliza la misma colección `colPunchTemplates_Filter` y crea una columna calculada `TemplateDisplayText` a partir de `TemplateDisplayName`, `TemplateName`, `TemplateCode` y finalmente `TemplateId`. Esta implementación ya está funcionando en Studio y evita introducir otro contrato visual distinto para el mismo catálogo.

## Validación

1. Quitar primero los dos errores actuales de `ItemDisplayText` y `DefaultSelectedItems` aplicando las fórmulas anteriores.
2. Confirmar que Studio no muestra errores en `cmbPR_Template`.
3. Entrar en Home con proyecto 70200 y confirmar el template visible completo.
4. Abrir Punch Review desde Home.
5. El header de Punch Review debe mostrar el mismo texto completo que Home, no solo `MPL`.
6. Navegar Punch Review → Punch List → Back y confirmar que el texto completo permanece.

## Criterio de cierre

`C17-E2B-FIX1 = VALIDATED` cuando `cmbPR_Template` queda sin errores y Home/Punch Review muestran el mismo `TemplateDisplayText` para el mismo `TemplateId`.
