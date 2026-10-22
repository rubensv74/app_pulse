# `scr_Home` — correcciones locales candidatas

Fuente: export de Power Apps Studio recibido el 2026-10-22. Son reemplazos de propiedades, no cambios aplicados al runtime.

## 1. Evitar recargar el proyecto ya activo

Control: `cmbHome_ProjectSelector_2`  
Propiedad: `OnChange`

Reemplazar la fórmula completa por:

```powerfx
If(
    !IsBlank(Self.Selected.ProjectId) &&
    Value(Self.Selected.ProjectId) <> Value(Coalesce(varProjectId, 0)),

    Set(varPendingProjectId, Value(Self.Selected.ProjectId));

    Set(varGlobalLoading, true);
    Set(varGlobalLoadingMsg, "Changing project...");
    Set(varGlobalLoadingSubMsg, "Preparing project dashboard");
    Set(varGlobalLoadingScope, "HOME");

    Set(varProjectSwitching, true);
    Set(varHomeLoading, false);

    Set(varGlobalLoadAction, "PROJECT_CHANGE");
    Set(varGlobalLoadPending, true)
)
```

Efecto: seleccionar de nuevo el proyecto actual no activa el overlay, no pone el cambio pendiente y no inicia el ciclo de carga. Los valores de `ProjectId` se comparan como números para tolerar representación numérica en texto.

## 2. Evitar dos `AddColumns` por evaluación del selector de plantilla

Control: `cmbHomePunchTemplateHeader_1`

Reemplazar solo estas propiedades:

```powerfx
Items = colPunchTemplates_Filter
```

```powerfx
ItemDisplayText = Coalesce(
    ThisItem.TemplateDisplayName,
    ThisItem.TemplateName,
    ThisItem.TemplateCode,
    Text(ThisItem.TemplateId)
)
```

```powerfx
DefaultSelectedItems =
If(
    IsBlank(varPunchDashboardTemplateId),
    [],
    Filter(
        colPunchTemplates_Filter,
        Value(TemplateId) = Value(varPunchDashboardTemplateId)
    )
)
```

Efecto: elimina la reconstrucción de `TemplateDisplayText` tanto en `Items` como en `DefaultSelectedItems`, sin modificar la colección compartida ni su esquema. Se conserva el mismo criterio de texto visible y de selección por `TemplateId`.

## Validación pendiente

- Comprobación estática contra el export: las referencias usadas existen y no se modifican argumentos de Flow ni datos persistidos.
- No se ejecutó Power Fx en Studio. Confirmar compilación del control al pegar el cambio.
- La actualización repetida del mismo proyecto debe comprobarse una vez en Studio; no requiere volver a repetir el recorrido completo de Home.
