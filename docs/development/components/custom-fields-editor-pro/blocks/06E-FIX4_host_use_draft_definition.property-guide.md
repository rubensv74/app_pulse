# DF-06E-FIX4 — Active/Inactive usando `DraftDefinition` estable

**Pantalla host:** `scr_PunchReview`  
**Componente:** `cmp_CustomFieldsEditorPro`  
**Estado:** STUDIO VALIDATED · 2026-08-13  
**Tipo:** FIX funcional aislado · property-only

## Resultado validado

Power Apps Studio confirmó que la mutación Active/Inactive funciona correctamente cuando el host toma el contexto directamente de `DraftDefinition`.

Validado por el usuario:

- Active → Inactive funciona;
- Inactive → Active funciona;
- desaparece el falso error `definition is not present in the loaded catalog after refresh`;
- la mutación usa el `FieldKey` visible/estable del draft;
- el enfoque basado en outputs transitorios deja de ser crítico para persistencia.

## Diagnóstico final

El componente dispone de un output estable y autoritativo para la definición que el usuario está editando: `DraftDefinition`.

Ese output contiene:

- `FieldKey = varCFDEPro_Draft_FieldKey`
- `IsActive = varCFDEPro_Draft_IsActive`

Y esos mismos valores son los que se muestran en el formulario (`Internal key`) y en el toggle `Availability`.

Para evitar divergencias o timing entre outputs transitorios y el host, la mutación Active/Inactive toma su contexto directamente de `DraftDefinition`.

---

# A. `cmpPR_CustomFieldsEditor.OnActiveChangeRequested`

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

# B. `cmpPR_CustomFieldsEditor.OnRefresh`

Target:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnRefresh`

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

- `tglCFDEPro_Active.OnChange`;
- `DraftDefinition` del componente;
- `btnPR_SetCustomFieldActive.OnSelect` de DF-06E-FIX2;
- `btnPR_LoadCustomFieldDefs.OnSelect` de DF-06E-FIX2;
- flows;
- stored procedures;
- definición `impact_score`;
- catálogo.

## Gate cerrado

```text
HOST MUTATION KEY          PASS
HOST MUTATION TARGET       PASS
FALSE NOT-PRESENT ERROR    0
STALE ERROR AFTER REFRESH  0
DEACTIVATE                 PASS
REACTIVATE                 PASS
PERSIST AFTER REFRESH      PASS
```

## Lección preventiva

Para eventos inmediatos de componentes, cuando ya existe un output agregado y estable como `DraftDefinition`, el host debe preferir ese contrato autoritativo frente a varios outputs transitorios independientes que puedan divergir por timing o sincronización.