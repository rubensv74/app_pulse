# cmp_CustomFieldEditorPro — Especificación funcional y de arquitectura

**Estado:** diseño aprobado — Opción A  
**Primera integración:** Punch Review Workspace  
**Objetivo:** componente premium reutilizable para edición de valores de Custom Fields, diseñado primero contra el caso real de Punch Review y generalizable después a otros contextos PULSE.

## 1. Decisión de arquitectura

Se adopta la **Opción A: reusable core + first implementation focused on Punch Review**.

El componente debe ser reutilizable, pero su primer contrato se valida exclusivamente con los datos, estados y servicios que ya existen en Punch Review. No se ampliará el alcance para resolver casos hipotéticos hasta que el primer consumidor esté validado en Power Apps Studio.

## 2. Problema que resuelve

El bloque actual de Custom Fields de Punch Review es funcional, pero mezcla en la propia pantalla:

- estructura visual;
- renderizado de seis tipos de campo;
- estado de carga/guardado;
- estado Saved/Unsaved;
- acciones Refresh/Reset/Save;
- tracking de cambios;
- integración con el dirty guard.

El resultado es correcto funcionalmente, pero el panel tiene poca jerarquía visual, alta densidad de controles de pantalla y menor reutilización.

`cmp_CustomFieldEditorPro` debe convertir esa zona en una experiencia premium, compacta y reutilizable sin mover los contratos backend dentro del componente.

## 3. Regla principal de separación de responsabilidades

### El componente SÍ es responsable de

- renderizar la cabecera premium;
- mostrar el contexto del registro;
- representar Loading / Empty / Ready / Unsaved / Saving / Error;
- renderizar los tipos de campo admitidos;
- mantener un working buffer interno de valores editados;
- identificar cambios por `FieldKey`;
- exponer el conjunto editado y el subconjunto dirty al host;
- emitir eventos de Refresh, Change, Reset y Save requested;
- representar permisos de edición;
- aplicar la apariencia visual PULSE.

### El componente NO es responsable de

- ejecutar Power Automate flows;
- conocer `WarRoom_GetCustomBundle`;
- conocer `WarRoom_SaveCustomBulk`;
- navegar entre pantallas;
- decidir el dirty guard de Punch Review;
- registrar Session Activity;
- administrar definiciones de campos;
- crear, activar o desactivar Custom Field definitions;
- persistir Reviewed state.

El host de pantalla conserva esas responsabilidades.

## 4. Restricción de plataforma relevante

La arquitectura no utilizará un componente individual dentro de cada fila de una Gallery. Canvas Components no pueden insertarse dentro de una Gallery o Form según las limitaciones actuales de Power Apps.

Por ello `cmp_CustomFieldEditorPro` contiene su propia Gallery y sus propios editores.

Para estado local del componente se usará `Set()` únicamente cuando sea necesario. No se usará `UpdateContext()` dentro del componente.

## 5. Contrato de datos de entrada

La propiedad `Items` debe aceptar el mismo contrato normalizado que ya utiliza Punch Review:

- `FieldKey` — Text
- `FieldLabel` — Text
- `FieldType` — Text
- `HelpText` — Text
- `IsRequired` — Boolean
- `IsPinned` — Boolean
- `IsEditable` — Boolean
- `SortOrder` — Number
- `OptionsJson` — Text
- `ValueText` — Text
- `ValueNumber` — Number
- `ValueDate` — Date
- `ValueBool` — Boolean
- `ValueJson` — Text
- `LastUpdatedOn` — Date/DateTime
- `LastUpdatedByEmail` — Text

El backend y el host siguen siendo la fuente de verdad. Tras un Save exitoso, el host debe proporcionar de nuevo al componente el `bundle.merged` devuelto por servidor.

## 6. Tipos de campo soportados en v1

La primera versión soportará exactamente los tipos que ya existen en Punch Review y en el contrato actual:

1. `Text`
2. `Number`
3. `Date`
4. `YesNo`
5. `Choice`
6. `MultiChoice`

No se introduce un nuevo tipo `MultilineText` porque el backend actual no lo declara. `Text` seguirá utilizando un editor capaz de admitir contenido de varias líneas dentro del espacio disponible.

## 7. Contrato de estado propuesto

### Inputs

- `Items`
- `Title`
- `Subtitle`
- `RecordLabel`
- `CanEdit`
- `IsLoading`
- `IsSaving`
- `ErrorText`
- `ShowTechnicalKey`
- `ShowHelpText`
- `AccentColor`
- `BackgroundColor`
- `SurfaceAltColor`
- `BorderColor`
- `TextColor`
- `MutedTextColor`
- `SuccessColor`
- `WarningColor`
- `DangerColor`

### Outputs previstos

- `HasFields`
- `FieldCount`
- `EditedItems`
- `DirtyItems`
- `IsDirty`
- `DirtyCount`
- `LastChangedFieldKey`

### Events previstos

- `OnRefresh`
- `OnChange`
- `OnResetRequested`
- `OnSaveRequested`

La primera entrega solo declara las propiedades necesarias para validar el shell. Los outputs y eventos que dependan del working buffer se incorporarán de forma incremental para evitar introducir un contrato complejo antes de validar la base del componente.

## 8. Diseño visual

### Cabecera

Altura objetivo: 56–60 px.

Contenido:

- `Custom Fields`;
- código o etiqueta del registro debajo del título;
- status pill a la derecha;
- Refresh;
- Reset;
- Save.

Estados visuales:

- `Saved` — success;
- `Unsaved` — warning;
- `Saving...` — accent;
- `Loading...` — accent/muted;
- `Error` — danger;
- `Empty` — neutral.

### Cuerpo

- Gallery vertical estándar, no flexible-height;
- scroll interno;
- separación visual entre campos;
- label del campo como primer nivel;
- metadata secundaria opcional;
- editor debajo;
- `Required` visible sin sobrecargar la fila;
- cambio local visible mediante indicador `Modified`;
- bordes suaves y superficies alternas PULSE.

### Editor por tipo

- Text: `ModernTextInput@1.1.1`;
- Number: `ModernNumberInput@1.1.1`;
- Date: `ModernDatePicker@1.0.1`;
- YesNo: `Toggle@1.1.5`;
- Choice/MultiChoice: `Classic/ComboBox@2.4.0` mientras no exista un reemplazo ya validado con el mismo contrato.

Estos tipos y versiones ya están presentes en el código actual de Punch Review y/o en el drawer existente.

## 9. Responsive

Primer rango de diseño: aproximadamente 300–700 px de ancho.

El primer consumidor real es la columna derecha de Punch Review. El componente debe funcionar correctamente en el ancho actual mostrado por esa pantalla antes de optimizar otros hosts.

Reglas:

- ancho = `Parent.Width` en la instancia host;
- header sin solapamientos a partir de 300 px;
- body siempre scrollable cuando no exista altura suficiente;
- controles de edición no deben depender de anchos absolutos grandes;
- acciones se compactan antes de reducir legibilidad del contenido.

## 10. Integración prevista con Punch Review

El host seguirá conservando:

- `btnPR_LoadCustomFields`;
- `btnPR_SaveCustomFields`;
- `colPunchReviewFieldsUI`;
- `colPunchReviewFieldsBase`;
- `colPunchReviewFieldsDirty`;
- `varPunchReviewDirty`;
- `varPunchReviewFieldsLoading`;
- `varPunchReviewFieldsSaving`;
- `varPunchReviewFieldsError`.

Durante la integración, el componente recibirá `colPunchReviewFieldsUI` como `Items`.

Cuando el componente emita `OnChange`, Punch Review sincronizará sus outputs editados/dirty con las colecciones host y actualizará `varPunchReviewDirty` y `colPunchReviewQueue.IsDirty`.

Cuando emita `OnSaveRequested`, el host seguirá utilizando el servicio ya validado `btnPR_SaveCustomFields`.

Cuando emita `OnRefresh`, el host seguirá utilizando `btnPR_LoadCustomFields`.

El dirty guard de Block 13 sigue perteneciendo a la pantalla.

## 11. Fuera de alcance de esta refactorización

- Manage Fields;
- administración de definiciones;
- cambios de esquema SQL;
- nuevos flows;
- nuevos tipos de campo;
- persistencia del estado Reviewed;
- cambios en Comments;
- Block 16 de hardening general.

## 12. Criterios de aceptación del componente final

1. Importa en Studio sin errores Source Code.
2. Se puede añadir a la biblioteca de componentes de la app.
3. Renderiza los seis tipos actuales.
4. Un manager puede editar; roles no editables quedan en modo lectura.
5. El componente identifica cambios por `FieldKey` sin duplicar dirty rows.
6. Reset recupera el estado de entrada vigente.
7. Save requested no ejecuta flows dentro del componente.
8. Tras save real, el bundle de servidor vuelve a ser la fuente autoritativa.
9. Punch Review mantiene su dirty guard sin regresiones.
10. La apariencia es coherente con el resto del Workspace y mejora claramente la jerarquía visual del bloque actual.
11. El componente funciona en el ancho real de la columna derecha de Punch Review.
12. No se utilizan SVG inline.

## 13. Fuente de referencia funcional

La implementación actual de `cmp_DetailDrawer_old` y Block 10 se usan como fuentes de verdad para contratos y comportamientos ya probados, pero no como arquitectura visual a copiar literalmente.

El nuevo componente debe conservar compatibilidad funcional y reducir el acoplamiento con la pantalla.