# C17-E2B-FIX1 — Punch Review template display context

**Estado:** READY FOR POWER APPS STUDIO  
**Target:** `scr_PunchReview → conPR_TemplateContext → cmbPR_Template`  
**Tipo:** property-guide / read-only context display  
**No tocar:** `varPunchReviewTemplateId`, loaders, Home template selector, Punch List template selector, flows.

## Hallazgo

En Home el template se muestra como un nombre completo (por ejemplo `70200 - Master Punch List`), mientras que en Punch Review el mismo contexto aparece reducido a `MPL`.

El control de Punch Review es `ModernCombobox@1.1.1` en `DisplayMode.View`. Aunque `Items` y `DefaultSelectedItems` construyen `TemplateDisplayText`, el render read-only no está mostrando de forma fiable el texto compuesto que usa Home.

Como el control es solo informativo y no permite selección en Punch Review, no necesita recibir todo el catálogo. Proyectaremos únicamente el template activo a un contrato de una fila cuyo campo visual canónico sea `Value`.

## Cambio 1 — `cmbPR_Template.Items`

Sustituir completamente por:

```powerfx
=If(
    IsBlank(varPunchReviewTemplateId),
    [],
    ForAll(
        Filter(
            colPunchTemplates_Filter,
            Value(TemplateId) = Value(varPunchReviewTemplateId)
        ),
        {
            Value:
                Coalesce(
                    TemplateDisplayName,
                    TemplateName,
                    TemplateCode,
                    Text(TemplateId)
                ),
            TemplateId: TemplateId
        }
    )
)
```

## Cambio 2 — `cmbPR_Template.DefaultSelectedItems`

Sustituir completamente por:

```powerfx
=Self.Items
```

Si Studio no acepta `Self.Items` en `DefaultSelectedItems`, usar exactamente la misma fórmula de `Items`.

## Cambio 3 — `cmbPR_Template.ItemDisplayText`

Sustituir por:

```powerfx
=ThisItem.Value
```

Mantener:

```powerfx
DisplayMode = DisplayMode.View
SelectMultiple = false
IsSearchable = false
```

## Validación

1. Entrar en Home con proyecto 70200 y confirmar el template visible completo.
2. Abrir Punch Review desde Home.
3. El header de Punch Review debe mostrar el mismo texto completo que Home, no solo `MPL`.
4. `varPunchReviewTemplateId` debe seguir correspondiendo al mismo template.
5. Navegar Punch Review → Punch List → Back y confirmar que el texto completo permanece.

## Criterio de cierre

`C17-E2B-FIX1 = VALIDATED` cuando Home y Punch Review muestran el mismo nombre de template para el mismo `TemplateId` y no se modifica ningún contrato funcional de carga.
