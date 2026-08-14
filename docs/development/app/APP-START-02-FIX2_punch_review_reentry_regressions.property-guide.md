# APP-START-02-FIX2 — Punch Review re-entry regressions

**Estado:** READY FOR POWER APPS STUDIO  
**Tipo:** property / tree-structure guide  
**Ámbito:** `scr_PunchReview`  
**Objetivo:** corregir dos regresiones detectadas tras aplicar `APP-START-02_scr_PunchReview.OnVisible.powerfx` sin reabrir la arquitectura funcional de Punch Review.

## Hallazgos

### 1. El template del caller se sobrescribe en `OnVisible`

El contrato de APP-START-02 dice que **el caller gana**, pero la fórmula candidata actual ejecuta siempre:

```powerfx
Set(
    varPunchReviewTemplateId,
    Switch(...)
)
```

Esto puede sustituir un `varPunchReviewTemplateId` ya preparado por Home o Punch List por un fallback distinto (`varFilter_PunchTemplateId` / `varPunchDashboardTemplateId`). El síntoma observado fue que Punch Review mostró `MPL` en lugar del contexto de template esperado desde Home.

### 2. `lblPR_HelpCommentsBody` está anidado en el contenedor equivocado

En el Source Code actual, `lblPR_HelpCommentsBody` aparece como hijo de `conPR_HelpPurposeCard` junto a:

- `lblPR_HelpPurposeTitle`
- `lblPR_HelpPurposeBody`

Como el control no tiene posición manual explícita en ese contenedor, cae en la esquina superior y se superpone al título `¿Para qué sirve este espacio?`.

El control pertenece semánticamente a la sección **4. Comments** y debe ser hermano de `lblPR_HelpCommentsTitle` dentro de `conPR_HelpContent`.

---

## FIX 1 — Preservar `varPunchReviewTemplateId` preparado por el caller

Target:

`Screens → scr_PunchReview → OnVisible`

Localizar la sección:

`02) Entry contract — caller wins; screen only supplies fallbacks`

Mantener:

```powerfx
If(IsBlank(varPunchReviewSource), Set(varPunchReviewSource, "NAVIGATION"));
If(IsBlank(varPunchReviewReturnScreen), Set(varPunchReviewReturnScreen, "HOME"));
```

Sustituir **completamente** el bloque que asigna `varPunchReviewTemplateId` por:

```powerfx
If(
    IsBlank(varPunchReviewTemplateId),
    Set(
        varPunchReviewTemplateId,
        Switch(
            Upper(Coalesce(varPunchReviewSource, "NAVIGATION")),
            "HOME", Coalesce(varPunchDashboardTemplateId, varFilter_PunchTemplateId),
            "PUNCHES", Coalesce(varFilter_PunchTemplateId, varPunchDashboardTemplateId),
            Coalesce(varFilter_PunchTemplateId, varPunchDashboardTemplateId)
        )
    )
);
```

### Regla

`Home/Punch List → set context → Navigate()` es la transacción autoritativa. `scr_PunchReview.OnVisible` solo proporciona fallback cuando el caller no ha preparado `varPunchReviewTemplateId`.

No modificar `cmbPR_Template` todavía. Su `DefaultSelectedItems` ya resuelve la fila del catálogo por `TemplateId`.

---

## FIX 2 — Corregir la estructura del Help modal

Target actual:

`scr_PunchReview → conPR_HelpContent → conPR_HelpPurposeCard → lblPR_HelpCommentsBody`

### Operación

Mover/reubicar `lblPR_HelpCommentsBody` fuera de `conPR_HelpPurposeCard` y convertirlo en hijo directo de:

`scr_PunchReview → conPR_HelpContent`

Debe quedar **inmediatamente después de**:

`lblPR_HelpCommentsTitle`

Orden lógico esperado dentro de `conPR_HelpContent`:

1. `conPR_HelpPurposeCard`
2. `lblPR_HelpQueueTitle`
3. `lblPR_HelpQueueBody`
4. `lblPR_HelpOverviewTitle`
5. `lblPR_HelpOverviewBody`
6. `lblPR_HelpActionsTitle`
7. `lblPR_HelpActionsBody`
8. `lblPR_HelpCommentsTitle`
9. `lblPR_HelpCommentsBody`
10. `conPR_HelpWarningCard`
11. `lblPR_HelpActivityTitle`
12. `lblPR_HelpActivityBody`
13. resto de contenido/footer existente

No crear un control nuevo y no duplicar el texto. Reutilizar el control existente.

### Propiedades del control después de moverlo

Conservar:

```powerfx
AutoHeight = true
Height = 78
Size = 9
Width = Parent.Width
```

No necesita `X` ni `Y` al quedar bajo `conPR_HelpContent`, porque el padre es `AutoLayout` vertical.

No cambiar `conPR_HelpPurposeCard.Height`, `lblPR_HelpPurposeTitle` ni `lblPR_HelpPurposeBody`: el solape no procede de su geometría sino del hijo intruso.

---

## FIX 3 — Persistencia del idioma

No cambiar la fórmula guardada en APP-START-02:

```powerfx
If(IsBlank(varPunchReviewHelpLanguage), Set(varPunchReviewHelpLanguage, "ES"));
Set(varPunchReviewHelpVisible, false);
```

`tabPR_HelpLanguage.OnChange` ya actualiza `varPunchReviewHelpLanguage`. Esta parte debe validarse, no reimplementarse.

---

## Validación obligatoria

### Template

1. En Home seleccionar el template real esperado.
2. Abrir Punch Review desde Home.
3. Confirmar que el header muestra el mismo template que Home, no un fallback alternativo.
4. Ir a Punch List y volver a Punch Review.
5. Confirmar que el template permanece estable durante la sesión.

### Help modal

1. Abrir Help en Español.
2. Confirmar que `¿Para qué sirve este espacio?` y su cuerpo no tienen texto superpuesto.
3. Confirmar que debajo de `4. Consulta y añade comentarios` aparece su cuerpo descriptivo.
4. Cambiar a English.
5. Cerrar Help.
6. Salir de Punch Review y volver.
7. Abrir Help otra vez: debe seguir seleccionado English.

### No regresión

Confirmar después del FIX:

- queue intacta;
- current Punch intacto;
- reviewed marks intactos;
- Session Activity intacta;
- Open Punch List Focus Mode sigue funcionando;
- Back regresa al origen correcto;
- Custom Fields Active/Inactive sigue funcionando.

## Criterio de cierre

`APP-START-02-FIX2 = VALIDATED` cuando template heredado, Help layout y persistencia EN/ES funcionan sin regresiones.

Solo después cerrar `APP-START-02` y avanzar a `C17-E2B — 1600×900`.
