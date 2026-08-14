# C17-E2A-FIX2 — Explicit return navigation

**Pantalla:** `scr_PunchReview`  
**Tipo:** FIX funcional aislado · property-only  
**Estado:** READY FOR STUDIO VALIDATION

## Diagnóstico confirmado

La navegación actual de `btnPR_Back` usa `Back()` tanto en estado limpio como desde el Dirty Guard. Sin embargo, Punch Review ya mantiene un contrato explícito de origen mediante:

- `varPunchReviewSource`
- `varPunchReviewReturnScreen`

Punch List establece antes de navegar a Punch Review:

```text
varPunchReviewSource = "PUNCHES"
varPunchReviewReturnScreen = "PUNCHES"
```

Aun así, `Back()` depende del historial de navegación de Power Apps y no de ese contrato. La validación real muestra que el resultado puede volver a Home incluso cuando el origen funcional fue Punch List.

La solución es dejar de usar `Back()` para esta ruta y resolver explícitamente el destino mediante `varPunchReviewReturnScreen`.

---

## 1. `btnPR_Back.Text`

Target:

`scr_PunchReview → btnPR_Back → Text`

Reemplazar completamente por:

```powerfx
=Switch(
    Upper(Coalesce(varPunchReviewReturnScreen, varPunchReviewSource, "HOME")),
    "PUNCHES", "Back to Punch List",
    "HOME", "Back to Home",
    "Back"
)
```

---

## 2. `btnPR_Back.OnSelect`

Target:

`scr_PunchReview → btnPR_Back → OnSelect`

Reemplazar completamente por:

```powerfx
=If(
    varPunchReviewDirty,

    Set(varPunchReviewPendingAction, "BACK");
    Set(varPunchReviewPendingIndex, 0);
    Set(varPunchReviewShowDirtyDialog, true),

    Switch(
        Upper(Coalesce(varPunchReviewReturnScreen, varPunchReviewSource, "HOME")),

        "PUNCHES",
            Set(varAppView, "Punches");
            Navigate(scr_Punches, ScreenTransition.None),

        "HOME",
            Set(varAppView, "Home");
            Set(varPageKey, "HOME");
            Set(varPageTitle, "Home");
            Set(varPageSubtitle, "Project command center");
            Set(varHomeViewMode, "DASHBOARD");
            Navigate(scr_Home, ScreenTransition.None),

        Set(varAppView, "Home");
        Navigate(scr_Home, ScreenTransition.None)
    )
)
```

No cambiar el Dirty Guard en este control: si existe dirty state se sigue posponiendo la salida mediante `varPunchReviewPendingAction = "BACK"`.

---

## 3. `btnPR_ContinuePendingAction.OnSelect` — rama `BACK`

Target:

`scr_PunchReview → conPR_DirtyGuardLayer → btnPR_ContinuePendingAction → OnSelect`

En el `Switch` existente, sustituir únicamente la rama `"BACK"` que actualmente termina en `Back()` por:

```powerfx
"BACK",
    Set(varPunchReviewPendingAction, "");
    Set(varPunchReviewPendingIndex, 0);

    Switch(
        Upper(Coalesce(varPunchReviewReturnScreen, varPunchReviewSource, "HOME")),

        "PUNCHES",
            Set(varAppView, "Punches");
            Navigate(scr_Punches, ScreenTransition.None),

        "HOME",
            Set(varAppView, "Home");
            Set(varPageKey, "HOME");
            Set(varPageTitle, "Home");
            Set(varPageSubtitle, "Project command center");
            Set(varHomeViewMode, "DASHBOARD");
            Navigate(scr_Home, ScreenTransition.None),

        Set(varAppView, "Home");
        Navigate(scr_Home, ScreenTransition.None)
    ),
```

Mantener sin cambios las ramas `CHANGE_CURRENT`, `OPEN_PUNCHES` y el fallback del `Switch` principal.

---

## 4. Contrato de entrada

Punch List ya establece explícitamente:

```text
varPunchReviewSource = "PUNCHES"
varPunchReviewReturnScreen = "PUNCHES"
```

No modificar esa entrada.

Para Home, el contrato esperado es `HOME`; si no se asigna explícitamente en el botón que abre Punch Review, `scr_PunchReview.OnVisible` ya conserva `HOME` como fallback. No cambiar `OnVisible` en este FIX.

---

## No tocar

- Queue;
- Session Activity;
- Review Progress;
- Comments;
- Custom Fields;
- template inheritance;
- layout C17;
- source-screen queue construction;
- Dirty Guard salvo la rama `BACK` indicada.

---

## Validación Studio

### Caso A — origen Home

1. Abrir Punch Review desde Home.
2. Confirmar botón `Back to Home`.
3. Pulsarlo en estado limpio.
4. Debe navegar a `scr_Home`.

### Caso B — origen Punch List

1. Abrir Punch List.
2. Entrar en Punch Review mediante `Review page` / acción equivalente.
3. Confirmar botón `Back to Punch List`.
4. Pulsarlo en estado limpio.
5. Debe navegar a `scr_Punches`, no a Home.

### Caso C — Dirty Guard desde Punch List

1. Entrar desde Punch List.
2. Modificar un Custom Field sin guardar.
3. Pulsar `Back to Punch List`.
4. Dirty Guard debe abrirse.
5. Continuar con la salida usando la acción que descarte/complete la navegación.
6. Debe terminar en `scr_Punches`, no en Home.

## PASS

```text
HOME LABEL                  Back to Home
HOME RETURN                 scr_Home
PUNCH LIST LABEL            Back to Punch List
PUNCH LIST RETURN           scr_Punches
DIRTY GUARD RETURN          same explicit destination
BACK() DEPENDENCY           removed from return path
STUDIO FORMULA ERRORS       0
```