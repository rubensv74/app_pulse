# DF-05 — Backend host integration

**Type:** `I — Integration`  
**Status:** IN PROGRESS — DF-05A/B/C/D publicados; DF-05D pendiente de validación final en Power Apps Studio.

## Gate

La línea visual de Punch Review y `cmp_ReviewProgressPro` está congelada para este incremento. DF-05 trabaja únicamente sobre servicios host y consistencia backend bajo la regla:

`entregar -> validar en Studio -> congelar -> siguiente bloque`.

## Purpose

Conectar `cmp_CustomFieldsEditorPro` al backend existente de Custom Field Definitions manteniendo todas las llamadas Power Automate en la pantalla host, nunca dentro del componente reutilizable.

## Existing backend contracts

### List definitions

`WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`

Contrato normalizado:

- FieldDefId
- ProjectId
- EntityType
- FieldKey
- Label
- FieldType
- HelpText
- IsRequired
- IsPinned
- IsActive
- SortOrder
- OptionsJson
- IsFilterable
- ShowInQuickFilters
- FilterOrder
- FilterMode

### Upsert definition

`WarRoom_UpsertCustomFieldDef(...)`

DF-05 transmite únicamente propiedades soportadas por el contrato actual. No introduce grupos, regex, límites de longitud, defaults ni reglas de automatización inexistentes en backend.

### Activate / deactivate definition

`WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`

## Host responsibilities

El host es responsable de:

- cargar definiciones;
- guardar/upsert del draft actual;
- mutación Active/Inactive;
- estados loading/saving/error;
- refresh autoritativo posterior a mutación;
- marcar `varPunchDynamicFilters_NeedRefresh=true` tras una mutación real;
- refrescar los Custom Fields del Punch actual;
- notificaciones;
- permisos.

El componente reutilizable mantiene únicamente presentación, edición local del draft, validación local y eventos/outputs para el host.

## Frozen during DF-05

DF-05 no debe rediseñar:

- geometría de tres columnas de `cmp_CustomFieldsEditorPro`;
- Field Catalog;
- Field Configuration;
- Live Preview;
- editor Choice/MultiChoice;
- capa de color;
- Comments de Punch Review;
- Review Progress.

## Increment plan

- `DF-05A` — host definition load — **PUBLISHED**;
- `DF-05B` — host upsert/save — **PUBLISHED**;
- `DF-05C` — host active/inactive mutation — **PUBLISHED**;
- `DF-05D` — post-mutation refresh + dynamic-filter invalidation + final backend validation — **PUBLISHED / PENDING STUDIO VALIDATION**.

## DF-05A artifacts

- `05A_definition_load.add-child.pa.yaml`
- `05A_manage_load_trigger.property-guide.md`
- `05A_orden_implementacion.guia.md`

DF-05A carga activas e inactivas (`IncludeInactive = 1`) porque el componente gobierna localmente la vista Active only / Show inactive.

Colección normalizada:

`colPunchReviewFieldDefsAdmin`

Estado:

- `varPunchReviewFieldDefsLoading`
- `varPunchReviewFieldDefsError`

## DF-05B artifacts

- `05B_host_save_runtime.property-guide.md`
- `05B_definition_upsert.add-child.pa.yaml`
- `05B_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Servicio host:

`btnPR_SaveCustomFieldDef`

Responsabilidad: validación host + `WarRoom_UpsertCustomFieldDef`.

## DF-05C artifacts

- `05C_host_active_state.property-guide.md`
- `05C_definition_active_toggle.add-child.pa.yaml`
- `05C_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Servicio host:

`btnPR_SetCustomFieldActive`

Responsabilidad: `WarRoom_SetCustomFieldActive` con protección de no-op y permisos.

## DF-05D artifacts

- `05D_post_mutation_refresh_state.property-guide.md`
- `05D_post_mutation_refresh.add-child.pa.yaml`
- `05D_existing_services_wiring.property-guide.md`
- `05D_VALIDACION_INTEGRAL_BACKEND.md`

Servicio host:

`btnPR_RefreshCustomFieldDefinitionContext`

Responsabilidad:

1. marcar `varPunchDynamicFilters_NeedRefresh=true`;
2. recargar definiciones desde servidor;
3. recargar Custom Fields del Punch actual;
4. distinguir escritura correcta de posibles advertencias de refresh;
5. evitar duplicación de sincronización entre DF-05B y DF-05C.

Punch List no se modifica en DF-05D: su implementación actual ya consume `varPunchDynamicFilters_NeedRefresh` al abrir `Project filters`, ejecuta `btnPunches_LoadDynamicFilters_2` y vuelve a poner la bandera en `false`.

## Final validation

Con proyecto real y `EntityType="PUNCH"`:

1. List devuelve activas e inactivas;
2. Upsert existente persiste y recarga valor servidor;
3. alta nueva persiste;
4. Choice/MultiChoice conserva `OptionsJson`;
5. Active -> Inactive persiste;
6. Inactive -> Active persiste;
7. no-op no ejecuta mutación innecesaria;
8. errores sin proyecto y sin permiso son accionables;
9. tras mutación, el Punch actual se refresca;
10. `varPunchDynamicFilters_NeedRefresh=true` tras mutación;
11. Punch List consume la bandera al abrir Project filters;
12. no existen regresiones visuales.

## Expected status after successful DF-05 validation

```text
COMPONENT STRUCTURE       FUNCTIONAL_FROZEN
LOCAL BEHAVIOR            FUNCTIONAL_FROZEN
BACKEND READ              FUNCTIONAL_FROZEN
BACKEND UPSERT            FUNCTIONAL_FROZEN
ACTIVE / INACTIVE         FUNCTIONAL_FROZEN
POST-MUTATION REFRESH     FUNCTIONAL_FROZEN
DYNAMIC FILTER INVALID.   FUNCTIONAL_FROZEN
COLOR                      PENDING
```

Tras validar esta matriz en Studio, DF-05 puede cerrarse y el siguiente incremento es `DF-06 — Punch Review modal integration`.
