# DF-06E-FIX3 — Corregir outputs ActiveChange del componente

**Componente:** `cmp_CustomFieldsEditorPro`  
**Pantalla host:** `scr_PunchReview`  
**Estado:** READY FOR STUDIO VALIDATION  
**Tipo:** FIX funcional aislado · property-only

## Diagnóstico confirmado

El Source Code real entregado desde Power Apps Studio muestra que `tglCFDEPro_Active.OnChange` prepara correctamente el estado antes de disparar el evento:

- `varCFDEPro_ActiveChangeFieldKey` recibe `varCFDEPro_Draft_FieldKey`.
- `varCFDEPro_ActiveChangeTarget` recibe el nuevo valor del toggle.
- después se ejecuta `cmp_CustomFieldsEditorPro.OnActiveChangeRequested()`.

Sin embargo, los dos **Output custom properties** del componente no exponen esas variables. Actualmente están definidos como valores constantes:

- `ActiveChangeFieldKey = "Text"`
- `ActiveChangeTarget = true`

Por tanto, el host recibe siempre el literal `Text` como `FieldKey`, aunque el campo seleccionado sea por ejemplo `impact_score`. El `LookUp` preventivo del host no puede encontrar esa clave en `colPunchReviewFieldDefsAdmin` y devuelve el error:

> The selected Custom Field definition is not present in the loaded catalog after refresh.

El catálogo, el loader y el Flow `WarRoom_SetCustomFieldActive` no son la causa de este fallo.

---

## Cambio 1 — Output `ActiveChangeFieldKey`

### Ubicación

Seleccionar el componente **`cmp_CustomFieldsEditorPro`** y editar su propiedad personalizada **`ActiveChangeFieldKey`**.

### Sustituir completamente por

```powerfx
=Coalesce(varCFDEPro_ActiveChangeFieldKey, "")
```

---

## Cambio 2 — Output `ActiveChangeTarget`

### Ubicación

En el mismo componente editar la propiedad personalizada **`ActiveChangeTarget`**.

### Sustituir completamente por

```powerfx
=Coalesce(varCFDEPro_ActiveChangeTarget, false)
```

---

## No modificar

En este FIX no cambiar:

- `tglCFDEPro_Active.OnChange`;
- `OnActiveChangeRequested` del componente;
- `btnPR_SetCustomFieldActive.OnSelect`;
- `btnPR_LoadCustomFieldDefs.OnSelect`;
- `WarRoom_SetCustomFieldActive`;
- `WarRoom_ListCustomFieldDefs`.

El `OnChange` actual ya genera la clave y el target correctos. El defecto está exclusivamente en el enlace de los Output properties.

---

## Validación mínima en Studio

1. Aplicar únicamente los dos cambios anteriores.
2. Guardar el componente y confirmar **0 errores de fórmula**.
3. Abrir `Custom Fields` desde Punch Review.
4. Pulsar `Refresh` y confirmar que el catálogo carga.
5. Seleccionar `Impact Score` (`impact_score`).
6. Cambiar `Active → Inactive`.
7. Confirmar que desaparece el error `definition is not present...`.
8. Confirmar que `Impact Score` queda inactivo después del refresh automático.
9. Activar `Show inactive`, seleccionar de nuevo `Impact Score` y cambiar `Inactive → Active`.
10. Confirmar persistencia después del refresh.

## PASS esperado

```text
ACTIVE OUTPUT FIELD KEY      impact_score
ACTIVE OUTPUT TARGET         false / true según toggle
FALSE NOT-PRESENT ERROR      0
DEACTIVATE                   PASS
REACTIVATE                   PASS
PERSIST AFTER REFRESH        PASS
STUDIO FORMULA ERRORS        0
```

## Siguiente gate

No mezclar todavía el ajuste tipográfico con este FIX. Una vez validado DF-06E-FIX3, realizar un bloque visual independiente para elevar los textos de `Size = 5/6/7` que resultan demasiado pequeños en el modal.