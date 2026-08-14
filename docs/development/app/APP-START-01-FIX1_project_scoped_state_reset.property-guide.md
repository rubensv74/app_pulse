# APP-START-01-FIX1 — Reset coherente de estado dependiente del proyecto

**Estado:** PENDIENTE DE VALIDACIÓN EN POWER APPS STUDIO  
**Target:** `App` → `OnStart`  
**Tipo:** FIX de consistencia / idempotencia  
**No tocar:** carga de proyectos habilitados, seguridad, navegación, flows de dashboard.

## Hallazgo

Tras ejecutar `Run OnStart`, `varProjectId` queda correctamente en `Blank()`, pero Home puede seguir mostrando KPIs, heatmap, distribución, grid y `Last Refresh` del proyecto anterior porque esos caches y variables no se invalidan al mismo tiempo.

En una sesión nueva real esto puede no reproducirse porque la memoria de la app parte vacía, pero `App.OnStart` debe ser coherente e idempotente también cuando se vuelve a ejecutar en Studio o cuando se reinicia el contexto de aplicación.

Regla: **si se invalida el Project Context, deben invalidarse también todos los artefactos visuales derivados de ese Project Context.**

## Ubicación

En el candidato `APP-START-01_App.OnStart.organized.powerfx`, localizar la sección:

`06) Project context`

Inmediatamente después de:

```powerfx
Set(varProjectId, Blank());
Set(varProjectCode, "");
Set(varProjectName, "");
Set(varProjectDescription, "");
Set(varSelectedProject, Blank());
Set(varProjectLoaded, false);
Set(varApplySubsystemDefault, false);
```

agregar el bloque siguiente.

## Bloque completo a agregar

```powerfx
// Project-scoped dashboard context must not survive a cleared project.
Set(varPunchDashboardTemplateId, Blank());
Set(varPunchDashboardLoaded, false);
Set(varPunchDashboardHasSnapshot, false);
Set(varPunchDashboardSnapshotId, Blank());
Set(varPunchDashboardLastRefresh, Blank());
Set(varPunchDashboardForceRefresh, false);
Set(varPunchDashboardError, "");
Set(varPunchDashboardMessage, "");

Set(varHomePunchKpiTotal, 0);
Set(varHomePunchKpiOpen, 0);
Set(varHomePunchKpiClosed, 0);
Set(varHomePunchKpiCompletion, 0);
Set(varHomePunchKpiHasPreviousSnapshot, false);

Set(varPunchExecutiveGridPage, 1);
Set(varPunchExecutiveGridTotalRows, 0);
Set(varPunchExecutiveGridTotalPages, 0);
Set(varPunchExecutiveGridHasPreviousPage, false);
Set(varPunchExecutiveGridHasNextPage, false);
Set(varPunchExecutiveGridSelectedId, Blank());
Set(varHomePunchGridSelectedKey, "");
Set(varHomePunchSelectedDisciplineCode, "");

Set(varPunchDrillSubsystemCode, "");
Set(varPunchDrillCategoryCode, "");
Set(varPunchDrillSubcontractorId, -1);
Set(varPunchDrillSubcontractorName, "");
Set(varPunchDrillStatusCode, "");
Set(varPunchDrillDisciplineCode, "");

Clear(colPunchDashboardSnapshotInfo);
Clear(colPunchDashboardSummary);
Clear(colPunchDashboardMatrix);
Clear(colPunchDashboardTimeline);
Clear(colPunchDashboardInsights);
Clear(colPunchDashboardSubsystems);
Clear(colPunchDashboardSubcontractors);
Clear(colPunchDashboardPunches);
Clear(colPunchExecutiveHeatmapRows);
Clear(colPunchExecutiveHeatmapColumns);
Clear(colPunchExecutiveHeatmapCells);
Clear(colPunchExecutiveDistribution);
Clear(colPunchExecutiveSelection);
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Clear(colPunchExecutiveDisciplineDistribution);
Clear(colPunchExecutiveDonutItems);
```

## Por qué no se eliminan filtros de Punch List aquí

Los filtros de `scr_Punches` tienen su propio contrato de inicialización y navegación. Este FIX se limita al dashboard Home y a sus datos derivados del proyecto. No mezclar ambos contextos.

## Validación

1. Seleccionar un proyecto y cargar Home.
2. Confirmar KPIs, heatmap, distribución, grid y Last Refresh con datos.
3. Ejecutar `Run OnStart`.
4. Home debe mostrar `Select Project`.
5. No deben permanecer cifras, heatmap, distribución, grid ni Last Refresh del proyecto anterior como si siguieran vigentes.
6. Seleccionar de nuevo el proyecto.
7. Cargar/Refresh Home y confirmar reconstrucción correcta del dashboard.

## Criterio de cierre

`APP-START-01-FIX1 = VALIDATED` cuando `Run OnStart` deja simultáneamente vacío el contexto de proyecto y todos los datos visuales que dependen de él, y el dashboard vuelve a reconstruirse al seleccionar un proyecto.
