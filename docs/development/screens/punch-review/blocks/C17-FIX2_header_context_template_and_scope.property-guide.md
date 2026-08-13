# C17-FIX2 — Header context: template heredado y Queue Scope simplificado

Pantalla: `scr_PunchReview`  
Tipo: `S/I-FIX`  
Objetivo: heredar correctamente el template de la pantalla de origen y retirar del header un selector de Queue Scope que no reconstruye la cola.

## Diagnóstico

Home usa `varPunchDashboardTemplateId`. Punch Review intenta resolver el valor inicial de `cmbPR_Template` con `varFilter_PunchTemplateId`, mientras `cmbPR_Template.OnChange` escribe `varPunchReviewTemplateId`. Esto deja tres estados parcialmente solapados.

Además, Home presenta plantillas con `TemplateDisplayText = Coalesce(TemplateDisplayName, TemplateName, TemplateCode, Text(TemplateId))`, mientras Punch Review usa `ThisItem.TemplateLabel`. Debe reutilizarse el mismo contrato de presentación que Home.

`cmbPR_QueueScope` solo actualiza `varPunchReviewQueueScope`; la pantalla no usa posteriormente esa variable para reconstruir `colPunchReviewQueue`. Por tanto, el selector no cambia la cola visible.

## A. `scr_PunchReview.OnVisible`

Después de inicializar `varPunchReviewSource` y `varPunchReviewReturnScreen`, establecer `varPunchReviewTemplateId` según el origen:

```powerfx
Set(
    varPunchReviewTemplateId,
    Switch(
        Upper(Coalesce(varPunchReviewSource, "NAVIGATION")),
        "HOME", Coalesce(varPunchDashboardTemplateId, varFilter_PunchTemplateId),
        "PUNCHES", Coalesce(varFilter_PunchTemplateId, varPunchDashboardTemplateId),
        Coalesce(varFilter_PunchTemplateId, varPunchDashboardTemplateId)
    )
);
```

No proteger esta asignación con `If(IsBlank(...))`: debe refrescarse en cada entrada para evitar un template residual de otra sesión/proyecto.

## B. `cmbPR_Template`

`Items`:

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

`ItemDisplayText`:

```powerfx
=ThisItem.TemplateDisplayText
```

`DefaultSelectedItems`:

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

`DisplayMode`:

```powerfx
=DisplayMode.View
```

`IsSearchable`:

```powerfx
=false
```

`InputTextPlaceholder`:

```powerfx
="No template context"
```

`OnChange`: dejar vacío. El template de Punch Review es contexto heredado; cambiarlo dentro de la sesión sería engañoso si no se reconstruye la cola.

## C. `conPR_QueueScopeContext`

`Visible`:

```powerfx
=false
```

No eliminarlo todavía; C17-E decidirá el cleanup físico. `varPunchReviewQueueScope` se conserva como metadata del origen de la sesión.

## Regla UX

Punch Review consume un snapshot de navegación: Project + Template + Queue source + Queue rows. Un selector del header solo debe cambiar ese snapshot si existe una operación explícita de rebuild de la cola con dirty guard.

## Validación

Desde Home: seleccionar proyecto/template, entrar en Punch Review y comprobar que el mismo template aparece automáticamente. Desde Punch List: confirmar que se hereda el template de Punches y no uno residual de Home. Cambiar de proyecto y repetir para descartar estado obsoleto. Queue Scope debe quedar oculto y la cola debe permanecer sin cambios.
