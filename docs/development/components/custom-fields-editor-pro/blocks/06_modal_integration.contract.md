# DF-06 — Integración modal de `cmp_CustomFieldsEditorPro` en Punch Review

**Tipo:** `I — Integration`  
**Estado:** IN PROGRESS — DF-06A/B/C/D continuados sin error reportado; DF-06E publicado y pendiente de validación en Power Apps Studio.

## Gate de entrada

DF-05A/B/C/D ha quedado sin errores pendientes reportados en Power Apps Studio. El error duplicado por `btnPR_RefreshCustomFieldDefinitionContext` fue corregido antes de iniciar DF-06.

DF-06A ha preparado el contrato host del componente mediante `DraftDefinition`, `DraftDirty`, `EditMode`, `OnSaveRequested` y `OnCancelRequested`.

DF-06B ha creado la capa modal y la instancia real `cmpPR_CustomFieldsEditor`.

DF-06C conecta Manage, Close y Refresh.

DF-06D conecta Save real con `btnPR_SaveCustomFieldDef`, conserva el servidor como fuente autoritativa y reconcilia `FieldDefId` después del guardado.

El usuario ha solicitado avanzar a DF-06E sin reportar errores nuevos de DF-06D. Power Apps Studio continúa siendo la autoridad final de validación.

## Objetivo

Convertir el botón **Manage** de Custom Fields en Punch Review en una experiencia modal real basada en `cmp_CustomFieldsEditorPro`, manteniendo:

- backend y Flows en el host;
- componente reutilizable sin llamadas Power Automate;
- geometría actual de Punch Review congelada;
- Comments, Custom Field Values y Review Progress sin modificaciones incidentales.

## Incrementos

### DF-06A — C · Component — contrato host + Save/Cancel

- expone el draft local mediante `DraftDefinition`;
- expone `DraftDirty` y `EditMode`;
- añade eventos `OnSaveRequested` / `OnCancelRequested`;
- sustituye el texto local-only por acciones Save / Cancel.

**Estado:** continuado sin error reportado.

### DF-06B — S/I · Modal shell + instancia

Artefactos:

- `06B_modal_visibility_state.property-guide.md`
- `06B_modal_shell.add-child.pa.yaml`
- `06B_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- crea `conPR_CustomFieldsEditorModalLayer` como hijo directo de `scr_PunchReview`;
- inserta `cmpPR_CustomFieldsEditor` usando `cmp_CustomFieldsEditorPro`;
- conecta contexto, permisos, loading/saving/error y roles visuales existentes.

**Estado:** continuado sin error reportado.

### DF-06C — I · Manage open / Close / Refresh

Artefactos:

- `06C_open_close_refresh.property-guide.md`
- `06C_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- Manage valida contexto y abre modal;
- Close protege draft modificado;
- Refresh recarga solo con draft limpio.

**Estado:** continuado sin error reportado.

### DF-06D — I · Save real

Artefactos:

- `06D_save_result_contract.property-guide.md`
- `06D_cmpPR_CustomFieldsEditor.OnSaveRequested.powerfx`
- `06D_btnCFDEPro_SaveDraft.OnSelect.powerfx`
- `06D_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- copia `DraftDefinition` a `varPunchReviewDef_*`;
- ejecuta `btnPR_SaveCustomFieldDef`;
- reconcilia el `FieldDefId` autoritativo;
- mantiene dirty si backend/reconciliación falla;
- tras éxito convierte ADD en EDIT y conserva el modal abierto.

**Estado:** continuado por el usuario sin error nuevo reportado; validación final sigue siendo responsabilidad de Studio.

### DF-06E — I · Active / Inactive real

Artefactos:

- `06E_active_inactive_contract.property-guide.md`
- `06E_tglCFDEPro_Active.OnChange.powerfx`
- `06E_cmpPR_CustomFieldsEditor.OnActiveChangeRequested.powerfx`
- `06E_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- añade al componente el contrato `ActiveChangeFieldKey`, `ActiveChangeTarget`, `ActiveMutationSucceeded` y `OnActiveChangeRequested`;
- en `EDIT`, el toggle Availability ejecuta el servicio host DF-05C inmediatamente;
- en `ADD`, Availability permanece dentro del draft y se persiste mediante DF-06D;
- si Active/Inactive era el único cambio y la mutación host tiene éxito, `DraftDirty` vuelve a false;
- si existían otros cambios locales, esos cambios permanecen dirty;
- no duplica Flow dentro del componente.

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

## Congelado durante DF-06

- Review Queue;
- Punch Overview;
- Session Activity;
- Comments;
- Custom Field Values panel;
- Review Progress;
- geometría de `conPR_RightColumn`;
- Help modal;
- Dirty Guard;
- capa cromática global.

## Regla de avance

Cada incremento debe validarse en Studio antes del siguiente.

El componente `cmp_CustomFieldsEditorPro` está confirmado como componente real de la app activa; Power Apps Studio continúa siendo la autoridad final de validación.

## Estado esperado al cerrar DF-06

```text
MODAL SHELL                 FUNCTIONAL_FROZEN
OPEN / CLOSE / REFRESH      FUNCTIONAL_FROZEN
SAVE                        FUNCTIONAL_FROZEN
ACTIVE / INACTIVE           FUNCTIONAL_FROZEN
HOST FLOW OWNERSHIP         FUNCTIONAL_FROZEN
GEOMETRY                    FUNCTIONAL_FROZEN
COLOR                        PENDING
```
