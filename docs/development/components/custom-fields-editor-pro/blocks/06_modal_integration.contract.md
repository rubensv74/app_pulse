# DF-06 — Integración modal de `cmp_CustomFieldsEditorPro` en Punch Review

**Tipo:** `I — Integration`  
**Estado:** IN PROGRESS — DF-06A integrado; DF-06B publicado y pendiente de validación en Power Apps Studio.

## Gate de entrada

DF-05A/B/C/D ha quedado sin errores pendientes reportados en Power Apps Studio. El error duplicado por `btnPR_RefreshCustomFieldDefinitionContext` fue corregido antes de iniciar DF-06.

DF-06A ha preparado el contrato host del componente mediante `DraftDefinition`, `DraftDirty`, `EditMode`, `OnSaveRequested` y `OnCancelRequested`.

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
- sustituye el texto local-only por acciones Save / Cancel;
- no toca Punch Review.

**Estado:** integrado / gate superado para continuar.

### DF-06B — S/I · Modal shell + instancia

Artefactos:

- `06B_modal_visibility_state.property-guide.md`
- `06B_modal_shell.add-child.pa.yaml`
- `06B_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- crea `conPR_CustomFieldsEditorModalLayer` como hijo directo de `scr_PunchReview`;
- inserta `cmpPR_CustomFieldsEditor` usando `cmp_CustomFieldsEditorPro`;
- conecta `ProjectId`, `EntityType`, `Definitions`, `CanManage`, `Loading`, `Saving`, `Error` y roles visuales existentes;
- mantiene el modal cerrado por defecto;
- no conecta todavía Manage, Close, Refresh ni Save.

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

### DF-06C — I · Manage open / Close / Refresh

- `cmpPR_CustomFieldValues.OnManageFieldsRequested` carga definiciones y abre modal;
- Close cierra modal;
- Refresh ejecuta `btnPR_LoadCustomFieldDefs`;
- no conecta Save.

**Estado:** bloqueado hasta validar DF-06B.

### DF-06D — I · Save real

- copia `DraftDefinition` a `varPunchReviewDef_*`;
- ejecuta `btnPR_SaveCustomFieldDef`;
- conserva servidor como fuente autoritativa;
- mantiene modal abierto y refleja el catálogo recargado.

**Estado:** bloqueado.

### DF-06E — I · Active/Inactive

- conecta la intención de cambio de disponibilidad al servicio host DF-05C cuando proceda;
- no duplica lógica de persistencia.

**Estado:** bloqueado.

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

El componente `cmp_CustomFieldsEditorPro` está confirmado como componente real de la app activa antes de DF-06B; por tanto puede utilizarse como `CanvasComponent` en la capa modal. Power Apps Studio continúa siendo la autoridad final de validación.
