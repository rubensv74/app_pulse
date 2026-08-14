# C17-E3A — Initial Punch Hydration

Objetivo: cargar automáticamente Comments + Custom Fields del primer Punch al iniciar una **nueva** sesión de Punch Review, sin forzar recarga al volver desde Punch List.

## 1. `scr_PunchReview.OnVisible`

### Ubicación
Sección `05) Review-session runtime defaults`, después de:

```powerfx
If(IsBlank(varPunchReviewRequestedIndex), Set(varPunchReviewRequestedIndex, Blank()));
Set(varPunchReviewPendingIndex, 0);
If(IsBlank(varPunchReviewShowDirtyDialog), Set(varPunchReviewShowDirtyDialog, false));
```

### Añadir

```powerfx
// C17-E3A — Initial hydration flag
If(
    IsBlank(varPunchReviewInitialHydrationPending),
    Set(varPunchReviewInitialHydrationPending, false)
);
```

### Ubicación
Al final de `scr_PunchReview.OnVisible`, después de resolver `varPunchReviewCurrentId`.

### Añadir

```powerfx
// -----------------------------------------------------
// 08) Initial Punch hydration
// -----------------------------------------------------
If(
    Coalesce(varPunchReviewInitialHydrationPending, false),

    If(
        !IsBlank(varPunchReviewCurrentId) &&
        !Coalesce(varPunchReviewDirty, false),

        Set(varPunchReviewCommentsPage, 1);
        Select(btnPR_LoadComments);
        Select(btnPR_LoadCustomFields)
    );

    Set(varPunchReviewInitialHydrationPending, false)
)
```

---

## 2. Entrada desde Home

### Ubicación
`scr_Home` → acción que crea la nueva sesión de Punch Review.

### Añadir inmediatamente antes de `Set(varAppView, "PunchReview")`

```powerfx
Set(varPunchReviewInitialHydrationPending, true);
```

El final debe quedar:

```powerfx
Set(
    varPunchReviewCurrentId,
    varPunchReviewCurrent.PunchIdNumber
);

Set(varPunchReviewInitialHydrationPending, true);
Set(varAppView, "PunchReview");

Navigate(
    scr_PunchReview,
    ScreenTransition.None
)
```

---

## 3. Entrada desde Punch List

### Ubicación
`scr_Punches` → `btnPunches_OpenPunchReview_2` → `OnSelect`.

### Añadir inmediatamente antes de `Set(varAppView, "PunchReview")`

```powerfx
Set(varPunchReviewInitialHydrationPending, true);
```

El final debe quedar:

```powerfx
Set(
    varPunchReviewCurrentId,
    varPunchReviewCurrent.PunchIdNumber
);

Set(varPunchReviewInitialHydrationPending, true);
Set(varAppView, "PunchReview");

Navigate(
    scr_PunchReview,
    ScreenTransition.None
)
```

---

## Validación

- `Home → Punch Review`: el primer Punch carga Comments + Custom Fields sin interacción adicional.
- `Punch List → Review page`: mismo comportamiento.
- `Punch Review → Punch List → Back`: conserva sesión y no inicia una hidratación nueva.
