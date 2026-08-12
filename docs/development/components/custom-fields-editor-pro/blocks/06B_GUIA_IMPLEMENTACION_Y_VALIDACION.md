# DF-06B — Guía de implementación y validación del modal

## Objetivo

Insertar en `scr_PunchReview` la capa modal que alojará `cmp_CustomFieldsEditorPro`, manteniendo congelada la geometría de la pantalla.

DF-06B crea únicamente el shell y conecta inputs. Todavía no conecta el botón **Manage**, ni Close, Refresh o Save.

---

## 1. Aplicar primero el estado de visibilidad

Abre:

`scr_PunchReview`

Propiedad:

`OnVisible`

Añade al final el contenido indicado en:

`06B_modal_visibility_state.property-guide.md`

Guarda la pantalla y confirma que no existen errores.

---

## 2. Insertar la capa modal

En el árbol selecciona directamente:

`scr_PunchReview`

No selecciones `conPR_ScreenRoot`, `conPR_RightColumn` ni otro contenedor interno.

Añade como **nuevo hijo directo de la pantalla** el contenido de:

`06B_modal_shell.add-child.pa.yaml`

El nuevo árbol debe quedar conceptualmente así:

```text
scr_PunchReview
├── conPR_ScreenRoot
├── ...
├── conPR_HelpModalLayer
├── ...
└── conPR_CustomFieldsEditorModalLayer
    ├── rectPR_CustomFieldsEditorBackdrop
    └── cmpPR_CustomFieldsEditor
```

El orden exacto respecto a otras capas puede depender del árbol actual de Studio, pero debe permanecer como hijo de nivel pantalla y por encima del workspace normal.

---

## 3. Qué queda conectado en DF-06B

La instancia `cmpPR_CustomFieldsEditor` recibe:

- `Definitions = colPunchReviewFieldDefsAdmin`
- `ProjectId = varProjectId`
- `EntityType = "PUNCH"`
- `CanManage` según `varUserRole`
- `IsLoading = varPunchReviewFieldDefsLoading`
- `IsSaving` desde los estados host DF-05
- `ErrorText` desde los errores host de definición
- roles visuales ya existentes de PULSE: Surface, SurfaceAlt, Border, Text, Muted y Accent

No se llama a ningún Flow desde el componente.

---

## 4. Prueba visual aislada

Como todavía no existe el wiring de Manage, para validar DF-06B establece temporalmente:

```powerfx
Set(varPunchReviewFieldDefsModalVisible, true)
```

Puedes hacerlo mediante un control temporal o desde una fórmula de prueba.

### Resultado esperado

- backdrop oscuro cubriendo Punch Review;
- `cmp_CustomFieldsEditorPro` centrado;
- tamaño máximo aproximado 1180 × 700;
- margen mínimo alrededor del componente;
- catálogo / configuración / preview conservan su geometría aprobada;
- Punch Review permanece intacto debajo;
- al poner `varPunchReviewFieldDefsModalVisible=false`, desaparece completamente la capa.

---

## 5. Validación funcional mínima

Con un proyecto real y `colPunchReviewFieldDefsAdmin` cargada:

1. el catálogo del modal muestra las definiciones recibidas;
2. `CanManage=false` deja el editor en modo no gestionable;
3. `IsLoading=true` refleja el estado Loading del componente;
4. `varPunchReviewFieldDefsError` se refleja en el componente;
5. no se ejecuta Save al pulsar Save todavía;
6. Close y Refresh todavía no tienen comportamiento host en DF-06B;
7. no aparecen errores de nombres o propiedades en Studio.

---

## 6. Qué no hacer todavía

No modifiques en DF-06B:

- `cmpPR_CustomFieldValues.OnManageFieldsRequested`;
- `cmpPR_CustomFieldsEditor.OnClose`;
- `cmpPR_CustomFieldsEditor.OnRefresh`;
- `cmpPR_CustomFieldsEditor.OnSaveRequested`;
- `cmpPR_CustomFieldsEditor.OnCancelRequested`;
- servicios `btnPR_SaveCustomFieldDef` / `btnPR_SetCustomFieldActive`.

Esos contratos se conectarán incrementalmente en DF-06C, DF-06D y DF-06E.

## Estado esperado tras validación

```text
MODAL SHELL          FUNCTIONAL_FROZEN
COMPONENT INSTANCE   FUNCTIONAL_FROZEN
HOST INPUT WIRING    FUNCTIONAL_FROZEN
OPEN/CLOSE/REFRESH   PENDING — DF-06C
SAVE                 PENDING — DF-06D
ACTIVE/INACTIVE      PENDING — DF-06E
COLOR                PENDING
```
