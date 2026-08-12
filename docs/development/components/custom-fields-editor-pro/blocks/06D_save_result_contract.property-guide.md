# DF-06D — Contrato de resultado de guardado

**Tipo:** `I — Integration`  
**Propósito único:** permitir que `cmp_CustomFieldsEditorPro` sepa si el guardado host terminó correctamente y cuál es el `FieldDefId` autoritativo devuelto tras la recarga.

## Dependencias

- DF-06A/B/C integrados sin errores pendientes.
- DF-05B/DF-05D integrados.
- `varPunchReviewFieldDefsLastMutationSucceeded` existente.
- `varPunchReviewFieldDefsRefreshWarning` existente.
- `btnPR_SaveCustomFieldDef` existente.
- `colPunchReviewFieldDefsAdmin` existente.

## No modificar

- geometría del componente;
- catálogo;
- formulario;
- Live Preview;
- Comments;
- Review Progress;
- Dirty Guard;
- color / Design System.

---

# 1. Estado host nuevo en `scr_PunchReview.OnVisible`

Añade al final de la inicialización:

```powerfx
// =====================================================
// DF-06D — LAST SAVED CUSTOM FIELD DEFINITION ID
// =====================================================
Set(varPunchReviewFieldDefsLastSavedId, 0);
```

La asignación numérica explícita es obligatoria para mantener el tipo estable en Studio.

---

# 2. Nuevas propiedades de entrada en `cmp_CustomFieldsEditorPro`

Añade exactamente estas dos propiedades.

## 2.1 `SaveSucceeded`

- Tipo de propiedad: **Input**
- Tipo de dato: **Boolean**
- Descripción: `True when the last host save completed and the authoritative definition was reconciled`
- Valor por defecto: `false`

## 2.2 `SavedFieldDefId`

- Tipo de propiedad: **Input**
- Tipo de dato: **Number**
- Descripción: `Authoritative FieldDefId of the definition saved by the host`
- Valor por defecto: `0`

Estas propiedades no llaman a backend. Solo reciben resultado del host.

---

# 3. Wiring en la instancia `cmpPR_CustomFieldsEditor`

Target:

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

## `SaveSucceeded`

```powerfx
=Coalesce(varPunchReviewFieldDefsLastMutationSucceeded, false) &&
IsBlank(Coalesce(varPunchReviewFieldDefsRefreshWarning, "")) &&
Coalesce(varPunchReviewFieldDefsLastSavedId, 0) > 0
```

## `SavedFieldDefId`

```powerfx
=Coalesce(varPunchReviewFieldDefsLastSavedId, 0)
```

---

# Validación

1. Studio reconoce `varPunchReviewFieldDefsLastSavedId` como Number.
2. La instancia reconoce `SaveSucceeded` y `SavedFieldDefId`.
3. Con valores iniciales, `SaveSucceeded=false` y `SavedFieldDefId=0`.
4. No cambia ninguna geometría.

## Estado esperado

`SAVE RESULT CONTRACT = FUNCTIONAL_FROZEN`
