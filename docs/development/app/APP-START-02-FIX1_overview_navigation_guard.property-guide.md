# APP-START-02-FIX1 — Overview navigation guard

**Estado:** PENDIENTE DE VALIDACIÓN EN POWER APPS STUDIO  
**Targets:**
- `scr_Home` → `cmp_NavApp_2` → `OnSelectItem`
- `scr_PunchReview` → `cmpPR_Sidebar` → `OnSelectItem`

## Hallazgo

Tras limpiar `scr_Home.OnVisible` en APP-START-02, la navegación `Home → Overview` queda bloqueada con el mensaje:

`This project has no published report configuration yet.`

El problema no es la ausencia real de proyecto ni necesariamente la ausencia de configuración. El guard actual calcula:

`varProjectHasReportConfig || varHomeHiveLoaded || varProjectHasPHRData`

pero `varProjectHasPHRData` se determina precisamente cuando `scr_Overview` carga su snapshot. Por tanto, exigir ese valor **antes de navegar a Overview** crea una dependencia circular.

Además, `varProjectHasReportConfig` pertenece al contexto del dashboard Home/Tasks y no es una fuente autoritativa para decidir si `scr_Overview` puede abrirse.

## Regla

La navegación debe validar únicamente los prerrequisitos conocidos antes de entrar en una pantalla.

Para `Overview`, el único prerrequisito global es disponer de `varProjectId`.

La disponibilidad de configuración/datos PHR debe validarse **dentro de `scr_Overview`**, que ya dispone de estados como:

- `varProjectHasPHRData`
- `varOverviewNoConfig`
- `varOverviewNoData`
- `varPHR_OverviewLoaded`

No se debe impedir la navegación basándose en un estado que la propia pantalla destino es responsable de determinar.

---

## Cambio 1 — `scr_Home → cmp_NavApp_2 → OnSelectItem`

Sustituir completamente `OnSelectItem` por:

```powerfx
=With(
    {
        _key: Lower(Trim(Self.SelectedItemKey)),
        _hasProject: !IsBlank(varProjectId)
    },
    If(
        _key = "superadmin",
        Set(varAppView, "SuperAdmin");
        Set(varPageKey, "SUPERADMIN");
        Set(varPageTitle, "Administration");
        Set(varPageSubtitle, "Platform configuration and governance");
        Navigate(scr_SuperAdmin, ScreenTransition.None),

        If(
            _key <> "home" && !_hasProject,
            Notify("Please select a project first.", NotificationType.Warning),

            Switch(
                _key,

                "home",
                    Set(varAppView, "Home");
                    Set(varPageKey, "HOME");
                    Set(varPageTitle, "Home");
                    Set(varPageSubtitle, "Project command center");
                    Set(varHomeViewMode, "DASHBOARD");
                    Navigate(scr_Home, ScreenTransition.None),

                "overview",
                    Set(varAppView, "Overview");
                    Set(varPageKey, "OVERVIEW");
                    Set(varPageTitle, "Overview");
                    Set(varOps_ViewMode, "OVERVIEW");
                    Navigate(scr_Overview, ScreenTransition.None),

                "punchreview",
                    Set(varAppView, "Punch Review");
                    Navigate(scr_PunchReview, ScreenTransition.None),

                "punches",
                    Set(varAppView, "Punches");
                    Navigate(scr_Punches, ScreenTransition.None),

                "briefing",
                    Set(varAppView, "Briefing");
                    Navigate(scr_Briefing, ScreenTransition.None),

                "config",
                    Set(varAppView, "Config");
                    Navigate(scr_Config, ScreenTransition.None),

                "skyline",
                    Set(varAppView, "Skyline");
                    Navigate(scr_Skyline, ScreenTransition.None),

                Notify("Key not mapped: [" & _key & "]", NotificationType.Error)
            )
        )
    )
)
```

---

## Cambio 2 — `scr_PunchReview → cmpPR_Sidebar → OnSelectItem`

Aplicar el mismo contrato: retirar `_hasReportConfig` y permitir `Overview` siempre que exista proyecto.

Sustituir completamente `OnSelectItem` por:

```powerfx
=With(
    {
        _key: Lower(Trim(Self.SelectedItemKey)),
        _hasProject: !IsBlank(varProjectId)
    },
    If(
        _key = "superadmin",
        Set(varAppView, "SuperAdmin");
        Set(varPageKey, "SUPERADMIN");
        Set(varPageTitle, "Administration");
        Set(varPageSubtitle, "Platform configuration and governance");
        Navigate(scr_SuperAdmin, ScreenTransition.None),

        If(
            _key <> "home" && !_hasProject,
            Notify("Please select a project first.", NotificationType.Warning),

            Switch(
                _key,

                "home",
                    Set(varAppView, "Home");
                    Set(varPageKey, "HOME");
                    Set(varPageTitle, "Home");
                    Set(varPageSubtitle, "Project command center");
                    Set(varHomeViewMode, "DASHBOARD");
                    Navigate(scr_Home, ScreenTransition.None),

                "overview",
                    Set(varAppView, "Overview");
                    Set(varPageKey, "OVERVIEW");
                    Set(varPageTitle, "Overview");
                    Set(varOps_ViewMode, "OVERVIEW");
                    Navigate(scr_Overview, ScreenTransition.None),

                "punchreview",
                    Set(varAppView, "Punch Review");
                    Navigate(scr_PunchReview, ScreenTransition.None),

                "punches",
                    Set(varAppView, "Punches");
                    Navigate(scr_Punches, ScreenTransition.None),

                "briefing",
                    Set(varAppView, "Briefing");
                    Navigate(scr_Briefing, ScreenTransition.None),

                "config",
                    Set(varAppView, "Config");
                    Navigate(scr_Config, ScreenTransition.None),

                "skyline",
                    Set(varAppView, "Skyline");
                    Navigate(scr_Skyline, ScreenTransition.None),

                Notify("Key not mapped: [" & _key & "]", NotificationType.Error)
            )
        )
    )
)
```

## No tocar

- `scr_Home.OnVisible` depurado por APP-START-02.
- `scr_Overview.OnVisible`.
- `varProjectHasReportConfig` donde siga teniendo significado dentro de Home/Tasks.
- `varProjectHasPHRData`, `varOverviewNoConfig`, `varOverviewNoData`.
- Flows de Overview/PHR.

## Validación

1. Seleccionar un proyecto válido en Home.
2. Pulsar `Overview` desde el sidebar de Home.
3. Debe navegar a `scr_Overview` sin el warning de configuración previa.
4. `scr_Overview` debe decidir por sí misma si hay datos, no hay datos o no existe configuración.
5. Volver a Home.
6. Abrir Punch Review y desde su sidebar navegar a Overview.
7. Debe comportarse igual.
8. Sin proyecto seleccionado, Overview debe seguir bloqueado con `Please select a project first.`

## Criterio de cierre

`APP-START-02-FIX1 = VALIDATED` cuando Overview es accesible con un proyecto activo y la evaluación de configuración/datos queda exclusivamente en la pantalla Overview.
