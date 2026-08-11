# DF-04D-FIX — Consolidación limpia de `cmp_CustomFieldsEditorPro`

## Clasificación

`C — Component / FIX`

## Propósito único

Eliminar la duplicación estructural del editor central introducida durante DF-04B y dejar una única implementación consolidada del componente, sin cambiar su contrato funcional ni iniciar integración backend.

## TARGET

`ComponentDefinitions > cmp_CustomFieldsEditorPro`

## OPERATION

`REPLACE COMPONENT DEFINITION`

Se reemplaza la definición completa del componente por una versión consolidada derivada directamente del baseline funcional suministrado por el usuario y aceptado por Power Apps Studio el 2026-08-11.

## DEPENDS ON

- baseline funcional actual suministrado por el usuario;
- `30-playbooks/power-platform/modular-power-apps-screen-construction.md` vigente;
- `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` vigente;
- estado local DF-03/DF-04 ya presente en el baseline.

## TOUCHES

Solo la estructura interna duplicada del editor central:

- elimina el editor antiguo que contenía al editor refinado como hijo;
- promueve el editor refinado DF-04B al nivel correcto dentro de `conCFDEPro_Body`;
- normaliza sus nombres eliminando el sufijo temporal `_1`;
- conserva un único `conCFDEPro_Editor`;
- conserva un único `conCFDEPro_EditorEmpty`.

## DO NOT MODIFY

Quedan congelados y no se rediseñan en este FIX:

- CustomProperties del componente;
- header;
- catálogo y búsqueda;
- geometría general de las tres columnas;
- live preview;
- reglas de selección de definiciones;
- draft local;
- editor Choice/MultiChoice y serialización con `JSON(..., JSONFormat.Compact)`;
- permisos `CanManage`;
- contratos de color/tokens existentes;
- backend/flows;
- Punch Review.

## Arquitectura esperada tras el FIX

```text
cmp_CustomFieldsEditorPro
└── conCFDEPro_Root
    ├── conCFDEPro_Header
    ├── rectCFDEPro_HeaderDivider
    └── conCFDEPro_Body
        ├── conCFDEPro_Catalog
        ├── conCFDEPro_Preview
        └── conCFDEPro_Editor
            ├── header/status del editor
            ├── conCFDEPro_Form
            │   ├── General
            │   ├── Behavior
            │   ├── Filtering
            │   └── Options
            └── conCFDEPro_EditorEmpty
```

## Compatibilidad aplicada

- raíz `ComponentDefinitions` válida;
- se mantienen tipos/versiones de controles ya aceptados por Studio en el baseline;
- no se añaden `Radius*` a `Label@2.5.1`;
- no se añade `AccessibleLabel` a `Classic/Button@2.2.0`;
- no se introduce `Reset()`;
- no se introduce SVG;
- no se modifica la serialización JSON existente;
- no se introduce ningún `CanvasComponent` anidado;
- no se cambian paletas ni geometría global durante este FIX.

## VALIDATION EN POWER APPS STUDIO

1. Reemplazar la definición completa de `cmp_CustomFieldsEditorPro` con `04D-FIX_consolidated_component.pa.yaml`.
2. Confirmar que Studio acepta el Source Code sin error PA1001/PA2108/PA2301 ni errores de fórmula.
3. Insertar una nueva instancia del componente en una pantalla de prueba.
4. Confirmar que solo existe un panel `Field configuration` en la columna central.
5. Seleccionar `Walkdown Area`: debe mostrarse un único formulario con `General → Behavior → Filtering → Options`.
6. Confirmar que `Live preview` sigue reaccionando a la definición seleccionada.
7. Confirmar que el catálogo, búsqueda y Active only siguen funcionando.
8. Confirmar que Choice/MultiChoice conserva las opciones y que editar una línea marca `Modified`.
9. Confirmar que no se ha realizado ninguna llamada backend.
10. Confirmar que una segunda instancia nueva del componente también se inserta sin errores.

## EXPECTED STATUS AFTER VALIDATION

```text
STRUCTURE      FROZEN
BEHAVIOR       FUNCTIONAL_FROZEN
DATA CONTRACT  FROZEN
COLOR          PENDING / unchanged
COMPONENT      FUNCTIONAL_FROZEN
```

Tras esta validación puede comenzar DF-05 como bloque `I — Integration`, sin reabrir la geometría del componente salvo error explícito.