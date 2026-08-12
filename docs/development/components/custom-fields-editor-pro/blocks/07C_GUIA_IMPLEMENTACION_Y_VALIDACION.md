# DF-07C — Guía de implementación y validación en Power Apps Studio

## Objetivo

Validar que `cmp_CustomFieldsEditorPro` puede utilizarse de forma razonable solo con teclado y que los controles interactivos muestran un foco visible, sin reabrir el backend ni el layout.

## Orden de implementación

### Paso 1 — Botones clásicos

En `cmp_CustomFieldsEditorPro`, selecciona uno por uno:

- `btnCFDEPro_Refresh`
- `btnCFDEPro_Close`
- `btnCFDEPro_AddField`
- `btnCFDEPro_CancelDraft`
- `btnCFDEPro_SaveDraft`

Aplica las propiedades indicadas en `07C_accessibility_keyboard_focus.property-guide.md`.

No añadas `AccessibleLabel` a `Classic/Button@2.2.0`; el registro PULSE ha confirmado incompatibilidad de esa propiedad en Source Code.

### Paso 2 — Toggles clásicos

Aplica `TabIndex`, `FocusedBorderColor` y `FocusedBorderThickness` a los seis toggles del componente.

Después comprueba en Studio si `Classic/Toggle@2.1.0` expone `AccessibleLabel`. Si lo expone, aplica los valores de la guía. Si no lo expone, no fuerces la propiedad desde Source Code.

### Paso 3 — Controles modernos

Comprueba `AcceptsFocus` en:

- Search;
- Field label;
- Field type;
- Sort order;
- Help text;
- Filter mode;
- Filter order;
- Options.

El Internal Key debe quedar fuera del recorrido si Studio permite configurar `AcceptsFocus=false`.

### Paso 4 — Smoke test solo teclado

Con el modal abierto:

1. deja el ratón sin usar;
2. pulsa `Tab` repetidamente;
3. confirma que el foco visible avanza por acciones e inputs en un orden comprensible;
4. usa `Shift+Tab` para recorrer el orden inverso;
5. activa/desactiva toggles mediante teclado;
6. ejecuta botones mediante teclado;
7. comprueba que no existe un control interactivo sin indicador visible de foco.

### Paso 5 — Casos condicionales

Repite la prueba con:

- `ADD / Text`;
- `ADD / Choice`;
- `EDIT`;
- `Filterable=false`;
- `Filterable=true`;
- `Quick filter=true`;
- `CanManage=false`;
- `IsLoading=true`;
- `IsSaving=true`.

## Matriz PASS / FAIL

| Caso | PASS |
|---|---|
| Refresh / Close reciben foco visible | [ ] |
| Add field recibe foco visible | [ ] |
| Search entra en la secuencia | [ ] |
| Internal Key no crea parada inútil | [ ] |
| FieldType en EDIT no crea interacción falsa | [ ] |
| Required / Pinned / Active operan por teclado | [ ] |
| Filterable / Quick Filter operan por teclado | [ ] |
| FilterMode / FilterOrder respetan su estado | [ ] |
| Options aparece en la secuencia para Choice/MultiChoice | [ ] |
| Cancel / Save reciben foco visible | [ ] |
| Shift+Tab recorre el orden inverso coherentemente | [ ] |
| Loading / Saving eliminan controles no disponibles del recorrido | [ ] |
| Reader no puede modificar definiciones | [ ] |
| No aparecen nuevos errores de Studio | [ ] |

## Limitación que NO debe convertirse en retrabajo

No intentar construir un focus trap manual dentro de `conPR_CustomFieldsEditorModalLayer`. Power Apps Canvas tiene limitaciones conocidas para overlays estándar. DF-07C solo asegura un recorrido de teclado razonable y foco visible dentro del componente actual.

Si la aplicación necesitara en el futuro un diálogo con semántica y focus management estrictos, eso debe tratarse como una decisión arquitectónica separada, no como un parche de DF-07.

## Gate de salida

Si la matriz queda limpia:

```text
DF-07C ACCESSIBILITY / KEYBOARD = FUNCTIONAL_FROZEN
```

El siguiente incremento es:

```text
DF-07D — Help + documentación de usuario + documentación reutilizable
```
