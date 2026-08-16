# Bloque 18A — Entrada Export y estado del modal

## Objetivo

Preparar `scr_PunchReview` para abrir el nuevo modal premium de exportación sin conectar todavía el flow.

Este bloque tiene una única responsabilidad: **añadir la acción Export a `cmpPR_Actions` e inicializar el estado del modal**.

No modifica SQL, Power Automate ni el contrato de exportación.

---

## Dependencias

- `cmpPR_Actions` existe en `scr_PunchReview`.
- `cmp_ActionToolbarPro` está instalado en la app activa.
- El bloque `18B_export_modal.add-screen-child.pa.yaml` se añadirá como hijo de `scr_PunchReview` después de aplicar esta guía.
- Se ha consultado `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` antes de redactar el bloque YAML asociado.

---

## 1. Inicialización en `scr_PunchReview.OnVisible`

Añadir estas asignaciones al bloque de inicialización de la pantalla, sin eliminar las existentes:

```powerfx
Set(varPRExportOpen, false);
Set(varPRExportProfile, "CLIENT");
Set(varPRExportState, "CONFIGURE");
Set(varPRExportError, "");
Set(varPRExportFileUrl, "");
Set(varPRExportLoading, false)
```

### Semántica

- `varPRExportOpen`: muestra/oculta la capa modal.
- `varPRExportProfile`: `CLIENT` o `INTERNAL`.
- `varPRExportState`: `CONFIGURE`, `GENERATING`, `SUCCESS` o `ERROR`.
- `varPRExportError`: error funcional/técnico mostrado por el modal.
- `varPRExportFileUrl`: URL devuelta por el flow cuando se conecte en un bloque posterior.
- `varPRExportLoading`: bloqueo de acciones mientras se genera el Excel.

No utilizar `FILTERED` como valor de `varPRExportProfile`. El scope se gestionará por separado.

---

## 2. Añadir la acción `EXPORT` a `cmpPR_Actions.Actions`

Dentro del `Table(...)` de `cmpPR_Actions.Actions`, añadir este registro después de `OPEN_PUNCHES`:

```powerfx
{
    Key: "EXPORT",
    Label: "Export",
    IconText: "⇩",
    Tone: "neutral",
    IsVisible: true,
    IsEnabled:
        !varPunchReviewIsLoading &&
        !IsBlank(varProjectId),
    Order: 3
}
```

Si ya existen acciones posteriores con `Order: 3`, desplazar sus órdenes para mantener una secuencia única.

---

## 3. Añadir el caso `EXPORT` a `cmpPR_Actions.OnAction`

Dentro del `Switch(cmpPR_Actions.SelectedActionKey, ...)`, añadir:

```powerfx
"EXPORT",
    If(
        IsBlank(varProjectId),
        Notify(
            "No active project is available for export.",
            NotificationType.Information
        ),
        Set(varPRExportProfile, "CLIENT");
        Set(varPRExportState, "CONFIGURE");
        Set(varPRExportError, "");
        Set(varPRExportFileUrl, "");
        Set(varPRExportLoading, false);
        Set(varPRExportOpen, true)
    ),
```

Mantener intactos los casos existentes `MARK_REVIEWED`, `UNMARK_REVIEWED`, `OPEN_PUNCHES` y cualquier otro que exista en el código actual.

---

## 4. Regla de dirty state

En este bloque la apertura del modal **no descarta ni guarda cambios**.

El modal 18B mostrará una advertencia cuando existan cambios locales. La conexión real del flow se bloqueará en PR-EXP-C04 hasta que esos cambios hayan sido guardados o descartados.

Motivo: el Excel se genera desde SQL y no puede representar cambios locales todavía no persistidos.

---

## 5. Validación en Power Apps Studio

1. Abrir `scr_PunchReview`.
2. Confirmar que la pantalla carga sin errores nuevos.
3. Confirmar que la Action Toolbar muestra `Export`.
4. Pulsar `Export` con proyecto activo.
5. Confirmar que `varPRExportOpen` pasa a `true`.
6. Confirmar que no se modifica la review queue, el Punch actual ni el dirty state.
7. Confirmar que las acciones existentes siguen funcionando.

Después aplicar el bloque `18B_export_modal.add-screen-child.pa.yaml` y realizar su gate visual.