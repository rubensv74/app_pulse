# DF-06E-FIX4 — Active/Inactive usando `DraftDefinition` estable

**Pantalla host:** `scr_PunchReview`  
**Componente:** `cmp_CustomFieldsEditorPro`  
**Estado:** READY FOR STUDIO VALIDATION  
**Tipo:** FIX funcional aislado · property-only

## Diagnóstico

DF-06E-FIX3 corrigió los outputs `ActiveChangeFieldKey` y `ActiveChangeTarget`, pero la captura posterior sigue mostrando el error:

> The selected Custom Field definition is not present in the loaded catalog after refresh.

El componente ya dispone de un output estable y autoritativo para la definición que el usuario está editando: `DraftDefinition`.

Ese output contiene exactamente:

- `FieldKey = varCFDEPro_Draft_FieldKey`
- `IsActive = varCFDEPro_Draft_IsActive`

Y esos mismos valores son los que se muestran en el formulario (`Internal key`) y en el toggle `Availability`.

Para evitar cualquier divergencia o timing entre outputs transitorios y el host, la mutación Active/Inactive debe tomar su contexto directamente de `DraftDefinition`.

---

# A. `cmpPR_CustomFieldsEditor.OnActiveChangeRequested` — REEMPLAZAR COMPLETAMENTE

Target:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnActiveChangeRequested`

```powerfx
=Set(varPunchReviewFieldDefsLastMutationSucceeded, false);
Set(varPunchReviewFieldDefToggleError, "");

With(
    {
        draft:
            First(cmpPR_CustomFieldsEditor.DraftDefinition)
    },

    Set(
        varPunchReviewFieldDefToggleKey,
        Trim(Coalesce(draft.FieldKey, ""))
    );

    Set(
        varPunchReviewFieldDefToggleActive,
        Coalesce(draft.IsActive, false)
    )
);

Select(btnPR_SetCustomFieldActive)
```

## Por qué

El host deja de depender de:

- `ActiveChangeFieldKey`
- `ActiveChangeTarget`

para ejecutar la mutación inmediata.

La fuente pasa a ser el mismo draft que alimenta el formulario visible y el Save contract.

Los dos outputs ActiveChange pueden mantenerse por compatibilidad, pero dejan de ser críticos para la persistencia.

---

# B. `cmpPR_CustomFieldsEditor.OnRefresh` — limpiar error de mutación obsoleto

Target:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnRefresh`

Reemplazar completamente por:

```powerfx
=If(
    Coalesce(cmpPR_CustomFieldsEditor.DraftDirty, false),

    Notify(
        "Guarda o cancela los cambios antes de actualizar las definiciones.",
        NotificationType.Warning
    ),

    Set(varPunchReviewFieldDefToggleError, "");
    Set(varPunchReviewFieldDefsError, "");
    Select(btnPR_LoadCustomFieldDefs)
)
```

Esto impide que un error Active/Inactive anterior siga visible después de un Refresh correcto.

---

# No tocar

En este FIX no cambiar:

- `tglCFDEPro_Active.OnChange`;
- `DraftDefinition` del componente;
- `btnPR_SetCustomFieldActive.OnSelect` de DF-06E-FIX2;
- `btnPR_LoadCustomFieldDefs.OnSelect` de DF-06E-FIX2;
- flows;
- stored procedures;
- definición `impact_score`;
- catálogo.

---

# Validación

1. Aplicar A y B.
2. Cerrar y volver a abrir Manage, o pulsar Refresh con draft limpio.
3. Seleccionar `Impact Score`.
4. Confirmar que `Internal key` muestra `impact_score`.
5. Active → Inactive.
6. Confirmar ausencia del error `not present in loaded catalog`.
7. Confirmar que tras refresh automático `Impact Score` queda inactivo.
8. Activar `Show inactive`.
9. Seleccionar de nuevo `Impact Score`.
10. Inactive → Active.
11. Confirmar persistencia y ausencia de error.

## PASS

```text
HOST MUTATION KEY        impact_score
HOST MUTATION TARGET     false / true según draft
FALSE NOT-PRESENT ERROR  0
STALE ERROR AFTER REFRESH 0
DEACTIVATE               PASS
REACTIVATE               PASS
PERSIST AFTER REFRESH    PASS
```

Si este gate falla, capturar el valor visible de `Internal key` y el mensaje de error exacto; no modificar backend hasta tener esa evidencia.