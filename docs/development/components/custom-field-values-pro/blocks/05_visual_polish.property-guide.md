# VF-05 — Visual polish — Guía de cambios de propiedades

**Estado:** corrección de PR-SC-007  
**Formato:** guía ejecutable, **NO pegar este archivo completo en Source Code**.

## Por qué existe esta guía

El primer artefacto VF-05 se publicó como un mapa de parches con nombres de controles en la raíz. Power Apps Studio lo interpretó como un `PaModule` y devolvió `PA1001 / YamlInvalidSyntax` porque `conCFVPro_Header` no es una propiedad válida del módulo.

Este documento sustituye ese artefacto. Los cambios siguientes deben aplicarse sobre los controles existentes desde Studio, propiedad por propiedad. No cambia datos, flows, Dirty Guard ni eventos.

## A. `cmp_CustomFieldValuesPro` — cabecera compacta

Abre el componente `cmp_CustomFieldValuesPro` y aplica únicamente estos cambios:

| Control | Propiedad | Nuevo valor |
|---|---|---|
| `conCFVPro_Header` | `Height` | `64` |
| `lblCFVPro_Title` | `Width` | `Max(120, Parent.Width - 110)` |
| `lblCFVPro_Title` | `X` | `14` |
| `lblCFVPro_Title` | `Y` | `5` |
| `lblCFVPro_Record` | `Width` | `Max(100, Parent.Width - 160)` |
| `lblCFVPro_Record` | `X` | `14` |
| `lblCFVPro_Record` | `Y` | `29` |
| `conCFVPro_StatusPill` | `X` | `Parent.Width - 82` |
| `conCFVPro_StatusPill` | `Y` | `7` |
| `btnCFVPro_Manage` | `Height` | `26` |
| `btnCFVPro_Manage` | `Width` | `72` |
| `btnCFVPro_Manage` | `X` | `Parent.Width - 122` |
| `btnCFVPro_Manage` | `Y` | `32` |
| `btnCFVPro_Refresh` | `Height` | `26` |
| `btnCFVPro_Refresh` | `Width` | `34` |
| `btnCFVPro_Refresh` | `X` | `Parent.Width - 42` |
| `btnCFVPro_Refresh` | `Y` | `32` |
| `rectCFVPro_HeaderDivider` | `Y` | `64` |
| `conCFVPro_Body` | `Height` | `Parent.Height - If(cmp_CustomFieldValuesPro.ShowFooter, 113, 65)` |
| `conCFVPro_Body` | `Y` | `65` |

Resultado esperado: la cabecera queda en dos líneas y mantiene separados título/contexto, status, Manage y Refresh incluso con un ancho cercano a 360–380 px.

## B. `scr_PunchReview` — altura del workspace derecho

En `scr_PunchReview`, aplica:

| Control | Propiedad | Nuevo valor |
|---|---|---|
| `conPR_UpperGrid` | `Height` | `If(App.Width < 1320, 1060, Max(660, Parent.Height - 200))` |
| `conPR_UpperGrid` | `LayoutMinHeight` | `If(App.Width < 1320, 1060, 660)` |
| `conPR_RightColumn` | `Height` | `If(App.Width < 1320, 660, Parent.Height)` |
| `conPR_RightColumn` | `LayoutMinHeight` | `660` |

La reserva vertical responde a esta geometría mínima:

- Comments: 220 px;
- Custom Field Values: 280 px;
- Review Progress: 140 px;
- dos gaps de 10 px;
- total mínimo: 660 px.

## C. Comprobación del host VF-04

No cambies estas propiedades si ya tienen estos valores. Solo corrige si tu integración VF-04 quedó diferente:

| Control | Propiedad | Valor esperado |
|---|---|---|
| `conPR_CustomFieldsHost` | `FillPortions` | `1` |
| `conPR_CustomFieldsHost` | `LayoutMinHeight` | `280` |
| `conPR_CustomFieldsHost` | `LayoutMinWidth` | `300` |
| `conPR_CustomFieldsHost` | `Width` | `Parent.Width` |
| `cmpPR_CustomFieldValues` | `Height` | `Parent.Height` |
| `cmpPR_CustomFieldValues` | `Width` | `Parent.Width` |

## Orden de integración

1. Aplica primero el grupo A dentro de `cmp_CustomFieldValuesPro`.
2. Guarda y verifica que el componente no presenta errores.
3. Abre `scr_PunchReview` y aplica el grupo B.
4. Revisa el grupo C únicamente como comprobación.
5. Ejecuta la matriz visual `05A_visual_validation_matrix.md`.

## Gate VF-05

- 1366×768: sin clipping de Comments / Custom Fields / Review Progress; puede existir scroll vertical del workspace.
- 1600×900: los tres paneles siguen utilizables.
- 1920×1080: no aparece un hueco vertical artificial grande.
- 360–380 px de ancho del componente: cabecera sin solapes.
- Comments composer visible.
- Custom Fields conserva al menos 280 px y su Gallery hace scroll.
- Review Progress conserva 140 px.
- Save, Cancel, Refresh, dirty state y Dirty Guard continúan funcionando.

## Regla de formato

Este archivo es deliberadamente `.md`. Un mapa `control -> Properties` no se volverá a presentar como `.pa.yaml` pegable en Source Code.