# DF-06C — Manage → Open / Close / Refresh

**Tipo:** `I — Integration`  
**Artefacto:** guía de propiedades  
**Propósito único:** conectar el modal ya creado en DF-06B con las acciones host de apertura, cierre y recarga, sin tocar Save ni Active/Inactive.

## Dependencias

Deben existir y estar libres de errores de nombres en Studio:

- `conPR_CustomFieldsEditorModalLayer`;
- `cmpPR_CustomFieldsEditor`;
- `cmpPR_CustomFieldValues`;
- `btnPR_LoadCustomFieldDefs`;
- `varPunchReviewFieldDefsModalVisible`;
- `varProjectId`;
- `varUserRole`.

## No modificar

- geometría de Punch Review;
- `conPR_RightColumn`;
- Comments;
- Custom Field Values;
- Review Progress;
- Help modal;
- Dirty Guard;
- servicios DF-05;
- geometría interna de `cmp_CustomFieldsEditorPro`;
- Save (`OnSaveRequested`);
- Active/Inactive;
- capa de color.

---

# A. Abrir el modal desde Manage

## Target

`conPR_RightColumn → conPR_CustomFieldsHost → cmpPR_CustomFieldValues → OnManageFieldsRequested`

## Sustituir la fórmula completa por

```powerfx
=If(
    IsBlank(varProjectId),
    Notify(
        "Selecciona un proyecto antes de administrar Custom Fields.",
        NotificationType.Error
    ),
    Lower(Coalesce(varUserRole, "reader")) <> "manager",
    Notify(
        "No tienes permisos para administrar las definiciones de Custom Fields.",
        NotificationType.Error
    ),
    Set(varPunchReviewFieldDefsModalVisible, true);
    Select(btnPR_LoadCustomFieldDefs)
)
```

### Comportamiento esperado

- sin proyecto: no abre el modal;
- sin rol manager: no abre el modal;
- con contexto válido: abre la capa modal y ejecuta el servicio host de carga;
- mientras carga, `cmpPR_CustomFieldsEditor.IsLoading` refleja `varPunchReviewFieldDefsLoading` gracias al wiring de DF-06B.

---

# B. Cerrar el modal

## Target

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnClose`

## Fórmula

```powerfx
=If(
    Coalesce(cmpPR_CustomFieldsEditor.DraftDirty, false),
    Notify(
        "Hay cambios sin guardar. Guarda o cancela el borrador antes de cerrar.",
        NotificationType.Warning
    ),
    Set(varPunchReviewFieldDefsModalVisible, false)
)
```

### Decisión UX

El botón **Close** no descarta silenciosamente un draft modificado. Si existe `DraftDirty=true`, el modal permanece abierto.

El usuario debe:

- usar **Save** cuando quiera persistir;
- usar **Cancel** cuando quiera restaurar el draft local;
- cerrar después cuando `DraftDirty=false`.

No se introduce un segundo dirty guard en este bloque.

---

# C. Refresh del catálogo

## Target

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnRefresh`

## Fórmula

```powerfx
=If(
    Coalesce(cmpPR_CustomFieldsEditor.DraftDirty, false),
    Notify(
        "Guarda o cancela los cambios antes de actualizar las definiciones.",
        NotificationType.Warning
    ),
    Select(btnPR_LoadCustomFieldDefs)
)
```

### Comportamiento esperado

- draft limpio: recarga definiciones desde backend mediante el servicio host existente;
- draft modificado: evita una recarga que pueda dejar catálogo y borrador en estados inconsistentes;
- no duplica ninguna llamada a Flow dentro del componente.

---

# D. `OnCancelRequested`

En DF-06C **no es obligatorio añadir lógica host** a `OnCancelRequested`.

El componente ya restaura/cancela su draft local antes de elevar el evento. Por tanto, puede dejarse vacío en esta fase. El cierre del modal sigue siendo responsabilidad explícita de **Close**.

---

# Validación mínima

1. Con proyecto válido y rol manager, pulsa **Manage**.
2. Debe abrirse el modal y cargar el catálogo real.
3. Pulsa **Refresh** con draft limpio: debe recargar sin cerrar el modal.
4. Modifica `Label` de una definición: `DraftDirty=true`.
5. Pulsa **Refresh**: debe mostrar warning y no recargar.
6. Pulsa **Close** con draft modificado: debe mostrar warning y mantener el modal abierto.
7. Usa **Cancel** dentro del formulario.
8. Confirma `DraftDirty=false`.
9. Pulsa **Close**: el modal debe desaparecer.
10. Sin proyecto, pulsa **Manage**: debe mostrar error y no abrir modal.
11. Confirma que Comments, Review Progress, Review Queue y Custom Field Values no cambian de geometría.

## Estado esperado tras validación

```text
MODAL OPEN / CLOSE / REFRESH = FUNCTIONAL_FROZEN
SAVE                         = PENDING DF-06D
ACTIVE / INACTIVE            = PENDING DF-06E
COLOR                         = PENDING
```
