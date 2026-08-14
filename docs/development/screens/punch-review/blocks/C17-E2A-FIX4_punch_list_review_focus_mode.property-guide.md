# C17-E2A-FIX4 — Punch List / Review Focus Mode

**Estado:** PENDIENTE DE VALIDACIÓN EN POWER APPS STUDIO  
**Tipo:** FIX UX / coherencia de contexto  
**Ámbito:** `scr_Punches` únicamente  
**No tocar:** backend de paginación, `colPunches`, filtros normales fuera del modo PunchReview, cola de Punch Review, Session Activity.

## Problema observado

El drill-through desde Punch Review ya puede mostrar una sola fila mediante `colPunchesReviewFocus`, pero la barra de filtros de Punch List conserva visualmente los filtros del contexto anterior. Esto puede mostrar, por ejemplo, una fila Category A0 mientras el combo Category sigue mostrando D. La vista funciona, pero comunica un contexto falso.

## Regla de diseño

Cuando `Upper(Coalesce(varPunches_FilterSource,"")) = "PUNCHREVIEW"`, Punch List debe comportarse como una **vista de foco de revisión**, no como una página de filtrado normal.

Se conserva `colPunches` y su estado. Los filtros normales no se borran: simplemente dejan de mostrarse durante el drill-through. Al volver a la navegación normal, reaparecen exactamente como estaban.

## Cambios de propiedades

Usar esta expresión base:

```powerfx
Upper(Coalesce(varPunches_FilterSource, "")) <> "PUNCHREVIEW"
```

### Ocultar controles de filtrado durante Review Focus

Aplicar a `Visible` de los siguientes controles:

- `btnOpenDynamicFilters_2`
- `btnPunchApplyFilters_2`
- `btnPunchClearFilters_2`
- `btnOpenSubsystemMVF_2`
- `ddPunchTemplate_2`
- `ddPunchDiscipline_2`
- `ddPunchSubcontractor_2`
- `ddPunchCategory_2`
- `ddPunchStatus_2`
- `btnPunches_OpenPunchReview_2`

Si alguno ya tiene una fórmula `Visible`, conservarla y añadir la condición anterior con `&&`.

Ejemplo para `btnOpenDynamicFilters_2`:

```powerfx
CountRows(colPunchDynamicFilters) > 0 &&
Upper(Coalesce(varPunches_FilterSource, "")) <> "PUNCHREVIEW"
```

### Mantener visible el botón Back

`backPunchesBackToOperations_2.Visible` debe permanecer `true`.

Su rama `PunchReview` debe seguir limpiando únicamente el contexto temporal:

```powerfx
"PunchReview",
    Set(varPunches_FilterSource, "Manual");
    Set(varPunches_FocusPunchId, Blank());
    Clear(colPunchesReviewFocus);
    Set(varAppView, "PunchReview");
    Navigate(scr_PunchReview, ScreenTransition.None),
```

## Opcional recomendado — descripción contextual

Target: `lblPunches_ProjectDescription_3.Text`

```powerfx
If(
    Upper(Coalesce(varPunches_FilterSource, "")) = "PUNCHREVIEW",
    "Review focus · " & Coalesce(Text(First(colPunchesReviewFocus).PunchCode), "Selected Punch"),
    If(
        !IsBlank(varProjectId),
        Coalesce(varSelectedProject.ProjectDescription, "Project context loaded"),
        "Select a project from Home"
    )
)
```

Esto hace explícito que la pantalla está mostrando un único Punch por contexto de revisión.

## Validación mínima

1. Desde Punch Review seleccionar un Punch.
2. Abrir Punch List.
3. Confirmar una sola fila.
4. Confirmar que los filtros normales no se muestran durante el foco.
5. Confirmar que la descripción indica `Review focus` si se aplica el cambio opcional.
6. Pulsar Back y confirmar regreso a Punch Review.
7. Entrar después a Punch List por navegación normal y confirmar que los filtros vuelven a mostrarse y conservan su estado previo.

## Criterio de cierre

`C17-E2A-FIX4 = VALIDATED` cuando la vista de foco no muestra controles que contradigan el Punch mostrado y el retorno a Punch Review conserva la sesión.
