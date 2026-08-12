# DF-06D — Guía de implementación y validación del Save real

**Tipo:** `I — Integration`  
**Propósito único:** conectar el botón Save de `cmp_CustomFieldsEditorPro` con el servicio host `btnPR_SaveCustomFieldDef` y reconciliar el draft local con el resultado autoritativo del backend.

## Qué modifica

- estado host mínimo para recordar el `FieldDefId` guardado;
- dos inputs del componente: `SaveSucceeded` y `SavedFieldDefId`;
- dos propiedades de la instancia modal;
- `cmpPR_CustomFieldsEditor.OnSaveRequested`;
- `btnCFDEPro_SaveDraft.OnSelect` dentro del componente.

## Qué NO modifica

- geometría de Punch Review;
- geometría interna del editor;
- catálogo, formulario o Live Preview;
- Comments;
- Custom Field Values;
- Review Progress;
- Active/Inactive host service;
- color / Design System.

---

# Orden obligatorio de implementación

## Paso 1 — Estado host + nuevas propiedades del componente

Aplica primero:

`06D_save_result_contract.property-guide.md`

Comprueba que existen:

- `varPunchReviewFieldDefsLastSavedId`;
- `cmp_CustomFieldsEditorPro.SaveSucceeded`;
- `cmp_CustomFieldsEditorPro.SavedFieldDefId`.

No continúes si Studio marca alguno de esos nombres como desconocido.

---

## Paso 2 — Wiring de la instancia modal

En:

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

configura las propiedades `SaveSucceeded` y `SavedFieldDefId` exactamente como indica la guía del Paso 1.

---

## Paso 3 — Conectar el evento `OnSaveRequested`

Target:

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → OnSaveRequested`

Copia la fórmula completa de:

`06D_cmpPR_CustomFieldsEditor.OnSaveRequested.powerfx`

Responsabilidad:

1. copiar `First(cmpPR_CustomFieldsEditor.DraftDefinition)` al contrato host `varPunchReviewDef_*`;
2. ejecutar `btnPR_SaveCustomFieldDef`;
3. respetar `varPunchReviewFieldDefsLastMutationSucceeded` y `varPunchReviewFieldDefsRefreshWarning` de DF-05D;
4. reconciliar el `FieldDefId` real contra `colPunchReviewFieldDefsAdmin` después de la recarga;
5. no cerrar el modal.

---

## Paso 4 — Sincronizar el draft interno después de Save

Target dentro de la definición del componente:

`cmp_CustomFieldsEditorPro → conCFDEPro_FormActions → btnCFDEPro_SaveDraft → OnSelect`

Sustituye solo la propiedad `OnSelect` por el contenido de:

`06D_btnCFDEPro_SaveDraft.OnSelect.powerfx`

El componente sigue sin llamar a ningún Flow. Primero eleva `OnSaveRequested`; después, solo cuando el host devuelve `SaveSucceeded=true`, realiza estas tres acciones locales:

- adopta el `SavedFieldDefId` autoritativo;
- pasa a `EDIT`;
- deja `DraftDirty=false`.

Si el backend falla o la reconciliación posterior queda incompleta, `DraftDirty` permanece `true` y el usuario no pierde el borrador local.

---

# Matriz de validación

## A. Editar una definición existente

1. Abre Manage con proyecto real y rol manager.
2. Selecciona una definición existente.
3. Cambia `Label` o `HelpText`.
4. Confirma `DraftDirty=true`.
5. Pulsa Save.
6. Debe aparecer la notificación de éxito del servicio host.
7. El catálogo debe reflejar la recarga servidor.
8. `SaveSucceeded=true`.
9. `SavedFieldDefId > 0`.
10. `DraftDirty=false`.
11. `EditMode="EDIT"`.
12. El modal permanece abierto.

## B. Crear una definición nueva

1. Pulsa `+ Add field`.
2. Introduce Label, FieldKey y el resto de propiedades requeridas.
3. Pulsa Save.
4. El backend debe crear la definición.
5. El catálogo recargado debe contener el nuevo `FieldKey`.
6. `SavedFieldDefId` debe recibir el identificador real del servidor.
7. El componente debe cambiar de `ADD` a `EDIT`.
8. `DraftDirty=false`.
9. Modifica de nuevo el mismo campo y guarda una segunda vez.
10. Debe actualizar la misma definición, no intentar crear un duplicado.

Este último punto es el gate crítico de DF-06D.

## C. Error backend

1. Provoca una validación fallida o prueba sin contexto válido.
2. Save no debe limpiar el draft local.
3. `SaveSucceeded=false`.
4. `DraftDirty=true`.
5. El usuario debe poder corregir y volver a intentar.

## D. Guardado correcto con refresh incompleto

Si la mutación backend termina pero DF-05D deja `varPunchReviewFieldDefsRefreshWarning`:

- `SaveSucceeded=false` para el componente;
- el borrador no se considera reconciliado;
- `DraftDirty` permanece `true`;
- se muestra la advertencia correspondiente;
- no se inventa un `FieldDefId` local.

---

# Criterio de aceptación

DF-06D se considera validado únicamente si funcionan los cuatro casos:

```text
EDIT EXISTENTE        PASS
ALTA NUEVA             PASS
SEGUNDO SAVE DEL ALTA  PASS
ERROR SIN PERDER DRAFT PASS
```

## Estado esperado

```text
MODAL SHELL             FUNCTIONAL_FROZEN
OPEN / CLOSE / REFRESH  FUNCTIONAL_FROZEN
REAL SAVE               FUNCTIONAL_FROZEN
ACTIVE / INACTIVE       PENDING DF-06E
COLOR                    PENDING
```
