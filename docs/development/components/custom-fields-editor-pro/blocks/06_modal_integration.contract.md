# DF-06 — Integración modal de `cmp_CustomFieldsEditorPro` en Punch Review

**Tipo:** `I — Integration`  
**Estado:** IN PROGRESS — DF-06A publicado, pendiente de validación en Studio.

## Gate de entrada

DF-05A/B/C/D ha quedado sin errores pendientes reportados en Power Apps Studio. El error duplicado por `btnPR_RefreshCustomFieldDefinitionContext` fue corregido antes de iniciar DF-06.

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

### DF-06B — S/I · Modal shell + instancia

- crea overlay modal en `scr_PunchReview`;
- inserta `cmp_CustomFieldsEditorPro`;
- conecta ProjectId / EntityType / Definitions / Loading / Saving / Error;
- no conecta aún Save.

### DF-06C — I · Manage open / Close / Refresh

- `cmpPR_CustomFieldValues.OnManageFieldsRequested` abre modal;
- carga definiciones antes de mostrar contenido;
- Close cierra modal;
- Refresh ejecuta `btnPR_LoadCustomFieldDefs`.

### DF-06D — I · Save real

- copia `DraftDefinition` a `varPunchReviewDef_*`;
- ejecuta `btnPR_SaveCustomFieldDef`;
- conserva servidor como fuente autoritativa;
- mantiene modal abierto y refleja el catálogo recargado.

### DF-06E — I · Active/Inactive

- conecta la intención de cambio de disponibilidad al servicio host DF-05C cuando proceda;
- no duplica lógica de persistencia.

## Congelado durante DF-06

- Review Queue;
- Punch Overview;
- Session Activity;
- Comments;
- Custom Field Values panel;
- Review Progress;
- geometría de `conPR_RightColumn`;
- capa cromática global.

## Regla de avance

Cada incremento debe validarse en Studio antes del siguiente.
