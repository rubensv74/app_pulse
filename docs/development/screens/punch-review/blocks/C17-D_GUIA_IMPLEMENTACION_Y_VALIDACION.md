# C17-D — Guía de implementación y validación

**Pantalla:** `scr_PunchReview`  
**Componente:** `cmp_CustomFieldValuesPro`  
**Objetivo:** validar la modernización de renderers sin tocar backend ni dirty state.

## Orden de implementación

1. Abrir `cmp_CustomFieldValuesPro`.
2. Corregir primero `numCFVPro_Number`:
   - `Appearance = Appearance.Outline`;
   - `Default` numérico sin `Text()`.
3. Guardar y confirmar que Studio no muestra errores.
4. Sustituir únicamente `cmbCFVPro_Choice` por un Modern Combo box con el mismo nombre.
5. Aplicar exactamente las propiedades descritas en `C17-D_modern_custom_field_renderers.property-guide.md`.
6. Conservar la fórmula `OnChange` existente de VF-03.
7. Guardar el componente.
8. Volver a `scr_PunchReview` y probar con un Punch que tenga al menos:
   - Number;
   - YesNo;
   - Choice;
   - MultiChoice;
   - Text;
   - Date.

## Validación visual

### Number

Debe:

- usar fondo blanco/superficie Outline;
- dejar de parecer disabled cuando sea editable;
- mantener stepper/incremento si la versión lo muestra;
- tener la misma altura visual que Text y Date.

### Choice

Al abrir el control:

- deben aparecer los textos reales de las opciones;
- no debe abrirse una lista visualmente vacía;
- el flyout debe usar el estilo moderno Fluent;
- la opción seleccionada debe mostrarse en el campo.

### MultiChoice

- deben mostrarse todas las opciones;
- deben poder seleccionarse varias;
- las selecciones visibles deben corresponder a `ValueJson`;
- no debe construirse JSON mediante escape manual de comillas.

### YesNo

- el switch sigue siendo moderno;
- el texto Yes/No permanece visible;
- cambiarlo actualiza el dirty state.

## Validación funcional

Ejecutar esta secuencia sobre un Punch real:

1. Cambiar un Choice.
2. Confirmar `Unsaved` y que Save se habilita.
3. Volver al valor original y confirmar que el dirty row desaparece.
4. Cambiar un MultiChoice seleccionando dos opciones.
5. Guardar.
6. Recargar Custom Fields.
7. Confirmar que ambas opciones se restauran correctamente.
8. Cambiar un Number y guardar.
9. Cambiar YesNo y guardar.
10. Usar Cancel sobre cambios no guardados y confirmar restauración del baseline.

## Test crítico de Gallery

El renderer vive dentro de `galCFVPro_Values`, por lo que debe probarse reciclaje de filas:

1. crear/usar suficientes Custom Fields para que exista scroll;
2. cambiar un Choice o MultiChoice sin guardar;
3. desplazarse hasta sacar la fila completamente de la vista;
4. volver a la fila;
5. confirmar que la selección visual coincide con `colCFVPro_Working`;
6. confirmar que `DirtyCount` no aumenta artificialmente;
7. guardar y recargar.

Si la selección visual se pierde aunque `colCFVPro_Working` conserve el dato, C17-D no pasa y se abrirá un FIX específico de renderer/gallery. No compensar el problema tocando el backend.

## Test de opciones vacías

Probar también una definición Choice sin opciones válidas si puede existir por datos históricos:

- el control no debe romper Studio;
- debe mostrarse vacío;
- no debe inventar opciones;
- no debe guardar un valor inexistente.

## Gate C17-D

```text
STUDIO ERRORS           0
NUMBER OUTLINE          PASS
CHOICE OPTIONS          VISIBLE
MULTICHOICE OPTIONS     VISIBLE
MODERN FLYOUT           PASS
INITIAL SELECTION       PASS
DIRTY ADD               PASS
DIRTY REVERT            PASS
SAVE                     PASS
CANCEL                   PASS
RELOAD                   PASS
GALLERY SCROLL           PASS
NO CLIPPING              PASS
```

Solo después de este gate se inicia C17-E — Cleanup + responsive + Visual QA.