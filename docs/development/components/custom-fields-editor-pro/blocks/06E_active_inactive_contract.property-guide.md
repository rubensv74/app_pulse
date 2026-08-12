# DF-06E — Active / Inactive real desde el editor

**Tipo:** `I — Integration`  
**Artefacto:** guía de propiedades  
**Propósito único:** conectar el cambio de disponibilidad de una definición existente en `cmp_CustomFieldsEditorPro` con el servicio host `btnPR_SetCustomFieldActive`, sin introducir Flows dentro del componente y sin modificar geometría.

## Decisión de comportamiento

DF-06E distingue dos escenarios:

- **Definición existente (`EDIT`)**: cambiar `Active / Inactive` ejecuta inmediatamente el servicio host DF-05C.
- **Definición nueva (`ADD`)**: el estado queda únicamente en el draft y se persiste mediante el Save normal de DF-06D.

Esto evita intentar activar/desactivar en backend una definición que todavía no existe.

Si la definición existente tenía otros cambios locales antes de cambiar su disponibilidad, esos cambios continúan marcados como `DraftDirty=true`. Solo el estado Active/Inactive se persiste inmediatamente. El Save posterior persiste el resto del draft.

## Dependencias

Deben existir y estar libres de errores de nombres en Studio:

- `cmp_CustomFieldsEditorPro` con el contrato DF-06A/DF-06D;
- `cmpPR_CustomFieldsEditor` en la capa modal;
- `btnPR_SetCustomFieldActive`;
- `varPunchReviewFieldDefToggleKey`;
- `varPunchReviewFieldDefToggleActive`;
- `varPunchReviewFieldDefToggleLoading`;
- `varPunchReviewFieldDefToggleError`;
- `varPunchReviewFieldDefsLastMutationSucceeded`;
- `colPunchReviewFieldDefsAdmin`.

## No modificar

- geometría de `cmp_CustomFieldsEditorPro`;
- Field Catalog;
- General / Filtering / Options;
- Live Preview;
- Save de DF-06D;
- Comments;
- Custom Field Values;
- Review Progress;
- Dirty Guard;
- Design System / color.

---

# 1. Añadir propiedades al componente

En `cmp_CustomFieldsEditorPro`, crea exactamente estas cuatro propiedades.

## 1.1 `ActiveChangeFieldKey`

- Tipo: **Output**
- Data type: **Text**
- Descripción: `FieldKey requested for immediate Active/Inactive mutation`

Fórmula:

```powerfx
Coalesce(varCFDEPro_ActiveChangeFieldKey, "")
```

## 1.2 `ActiveChangeTarget`

- Tipo: **Output**
- Data type: **Boolean**
- Descripción: `Target availability requested by the editor`

Fórmula:

```powerfx
Coalesce(varCFDEPro_ActiveChangeTarget, false)
```

## 1.3 `ActiveMutationSucceeded`

- Tipo: **Input**
- Data type: **Boolean**
- Descripción: `True when the host Active/Inactive mutation completed successfully`
- Default: `false`

## 1.4 `OnActiveChangeRequested`

- Tipo: **Event**
- Return type: **None**
- Descripción: `Raised for an existing definition when availability must be persisted immediately`

El evento no debe contener backend dentro del componente.

---

# 2. Wiring de la instancia modal

Target:

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

## `ActiveMutationSucceeded`

```powerfx
=Coalesce(varPunchReviewFieldDefsLastMutationSucceeded, false) &&
IsBlank(Coalesce(varPunchReviewFieldDefToggleError, ""))
```

## `OnActiveChangeRequested`

Usa la fórmula publicada en:

`06E_cmpPR_CustomFieldsEditor.OnActiveChangeRequested.powerfx`

La fórmula copia al host:

- `ActiveChangeFieldKey` → `varPunchReviewFieldDefToggleKey`
- `ActiveChangeTarget` → `varPunchReviewFieldDefToggleActive`

Después ejecuta:

`Select(btnPR_SetCustomFieldActive)`

---

# 3. Cambio dentro del componente

Target:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → conCFDEPro_BehaviorPanel → conCFDEPro_Availability → tglCFDEPro_Active → OnChange`

Sustituye únicamente `OnChange` por la fórmula publicada en:

`06E_tglCFDEPro_Active.OnChange.powerfx`

## Comportamiento resultante

### EDIT + draft limpio

1. El usuario cambia Active/Inactive.
2. El componente registra FieldKey + target.
3. Eleva `OnActiveChangeRequested`.
4. El host ejecuta DF-05C.
5. Si la mutación tiene éxito, el draft vuelve a limpio porque el único cambio ya está persistido.

### EDIT + otros cambios locales pendientes

1. El usuario ha modificado, por ejemplo, Label o HelpText.
2. Cambia Active/Inactive.
3. El estado se persiste inmediatamente mediante DF-05C.
4. Los demás cambios siguen pendientes.
5. `DraftDirty` permanece `true`.
6. Save de DF-06D persiste después el resto del draft.

### ADD

1. El usuario define un campo nuevo.
2. Puede elegir Active o Inactive.
3. No se ejecuta DF-05C porque todavía no existe una definición backend.
4. Save DF-06D crea la definición con el valor seleccionado.

### Error backend

Si DF-05C falla:

- `varPunchReviewFieldDefToggleError` se muestra mediante `ErrorText` ya conectado en DF-06B;
- `DraftDirty` permanece `true`;
- no se considera el estado sincronizado;
- Cancel puede recuperar la definición desde el catálogo servidor actualmente cargado.

---

# Estado esperado tras validación

```text
ACTIVE / INACTIVE — EXISTING DEF   FUNCTIONAL_FROZEN
ACTIVE / INACTIVE — NEW DEF        SAVE-OWNED / FUNCTIONAL_FROZEN
HOST FLOW OWNERSHIP                 FUNCTIONAL_FROZEN
GEOMETRY                            UNCHANGED
COLOR                               PENDING
```
