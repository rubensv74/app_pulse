# DF-07B — Guía de implementación y validación

## Objetivo

Cerrar el acabado visual de `cmp_CustomFieldsEditorPro` sin reabrir backend, contratos ni geometría macro.

## Dependencias

Antes de aplicar DF-07B:

1. DF-07A aplicado.
2. DF-07A-FIX1 aplicado.
3. `Filtering` sin clipping de `Not filterable / Filterable` ni `More filters / Quick filter`.
4. `Save / Cancel` visibles.
5. `Internal key` generado/bloqueado.
6. Contexto real del proyecto visible.

Power Apps Studio sigue siendo la autoridad final.

---

# Orden exacto

## Paso 1 — Read-only legible en Filtering

Aplicar primero las fórmulas `DisplayMode` de:

- `ddCFDEPro_FilterMode`
- `numCFDEPro_FilterOrder`

Resultado esperado:

- `Filterable=false`: aparecen en modo View, no editables pero legibles.
- loading/saving/no manager: Disabled.
- `Filterable=true`: Edit.

Validar antes de continuar.

## Paso 2 — Live Preview

Aplicar únicamente las propiedades indicadas en `07B_visual_finish.property-guide.md` a:

- `lblCFDEPro_PreviewSubtitle`
- `lblCFDEPro_PreviewFlags`
- `conCFDEPro_PreviewMetadata`
- labels de metadata
- spacing interno de `conCFDEPro_PreviewCard`

No cambiar fórmulas de preview ni añadir controles.

Validar con `Text`, `Number`, `Choice` y `MultiChoice`.

## Paso 3 — Empty states

Hacer responsive únicamente `Y` de los títulos/body de:

- `conCFDEPro_PreviewEmpty`
- `conCFDEPro_EditorEmpty`

Comprobar:

- modal recién abierto sin selección;
- catálogo cargado pero ningún campo seleccionado;
- cambio de altura del host si Studio permite redimensionar la instancia.

## Paso 4 — Matriz de estados

Probar sin modificar lógica:

### Loading

- status pill muestra Loading;
- inputs no editables;
- no clipping.

### Saving

- status pill muestra Saving;
- Save no permite otra escritura;
- footer permanece visible.

### Error

- status pill muestra Error;
- layout no cambia;
- el mensaje/feedback host sigue funcionando.

### Reader / no manager

- editor sigue siendo legible;
- controles de edición no permiten cambios;
- no se degrada la geometría.

---

# Matriz visual mínima

| Caso | Qué comprobar |
|---|---|
| ADD + Text | key automático, footer visible, preview legible |
| EDIT + Text | key bloqueado, Save solo con dirty |
| Number | preview muestra valor numérico simulado |
| Date | preview correcto |
| YesNo | preview correcto |
| Choice | Options visible sin tocar footer |
| MultiChoice | muchas opciones sin invadir footer |
| Filterable OFF | Mode/Order read-only y legibles |
| Filterable ON | Mode/Order editables |
| Quick filter OFF/ON | texto completo y sin clipping |
| Help largo | no invade Availability |
| Label largo | no rompe Preview |
| Loading | estado bloqueado y legible |
| Saving | doble save imposible |
| Error | status visible sin deformación |

---

# Criterio de cierre

DF-07B puede considerarse validado cuando:

- no existe clipping visible;
- no existe solapamiento;
- footer permanece visible en el host real;
- `Filtering` mantiene jerarquía clara OFF/ON;
- Preview y empty states están equilibrados;
- los estados Loading/Saving/Error no rompen geometría;
- no aparecen nombres ni fórmulas en rojo;
- backend y contratos permanecen sin cambios.

## Estado después de PASS

```text
STRUCTURE      FROZEN
BEHAVIOR       FROZEN
DATA CONTRACT  FROZEN
VISUAL QA      APPROVED
COLOR          PENDING
```

Si la única diferencia restante es cromática, no reabrir estructura ni comportamiento. Tratar color como bloque independiente del Design System.
