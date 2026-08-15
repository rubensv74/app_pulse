# OPDS-C01 — paquete inicial de Studio en una sola intervención

> Guía histórica de la primera prueba. La validación se ejecutó el 15 de agosto de
> 2026 y descubrió fallos de integración de los componentes dentro de la pantalla.
> No repitas esta guía. Continúa con `OPDS-C01-FIX_STUDIO_GUIDE.md`.

Esta guía instalaba el candidato visual completo y permitía validar conjuntamente
los seis estados sintéticos.

## Antes de comenzar

Confirma que la biblioteca de componentes de la aplicación contiene:

- `cmp_SidebarNav`;
- `cmp_PageHeaderPro`.

No edites la definición de ninguno de los componentes. No abras ni modifiques
`scr_Overview`.

## Parte 1 — crear y pegar la pantalla

1. Abre la aplicación PULSE en Power Apps Studio.
2. Añade una pantalla **vacía**.
3. Renómbrala exactamente como `scr_Overview_PDS`.
4. Selecciona la pantalla completa y abre **Source code**.
5. Sustituye todo el código por el contenido de
   `power-apps/screens/OverviewPDS/scr_Overview_PDS.pa.yaml`.
6. Guarda y espera a que Studio termine de comprobar el código.

En esta versión, los alojamientos oscuros del Sidebar y blanco del encabezado estaban
vacíos intencionadamente. No se trataba de bloques ausentes, sino de una precaución
frente a un problema de integración ya observado en PULSE.

## Parte 2 — insertar el Sidebar de forma segura

1. Usa **Insert > Custom** e inserta `cmp_SidebarNav`.
2. Mueve la instancia dentro de `conOPDS_SidebarHost`.
3. Renómbrala como `cmpOPDS_Sidebar`.
4. Configura estas propiedades desde el selector de propiedades y la barra de fórmulas:

| Propiedad | Fórmula |
|---|---|
| `Width` | `Parent.Width` |
| `Height` | `Parent.Height` |
| `Fill` | `varTheme_NavBg` |
| `ActiveKey` | `"overview"` |
| `AppVersion` | `"PULSE"` |
| `EnvironmentLabel` | `"VISUAL CANDIDATE"` |
| `IsCollapsed` | `true` |
| `Items` | `colSidebarNavItems` |
| `NavItems` | `colSidebarNavItems` |
| `ProjectCode` | `Coalesce(varSelectedProject.ProjectCode, "")` |
| `ProjectName` | `Coalesce(varSelectedProject.ProjectName, "")` |
| `UserRole` | `Coalesce(varUserRole, "reader")` |
| `OnSelectItem` | `Notify("Overview PDS está en modo de prueba visual.", NotificationType.Information)` |

La navegación operativa debía permanecer intacta. Al seleccionar una opción del
Sidebar en esta pantalla de prueba solo debía mostrarse el mensaje informativo.

## Parte 3 — insertar el Page Header

1. Usa **Insert > Custom** e inserta `cmp_PageHeaderPro`.
2. Mueve la instancia dentro de `conOPDS_PageHeaderHost`.
3. Renómbrala como `cmpOPDS_PageHeader`.
4. Configura estas propiedades:

| Propiedad | Fórmula |
|---|---|
| `Width` | `Parent.Width` |
| `Height` | `Parent.Height` |
| `Title` | `"Overview"` |
| `Subtitle` | `"Project Handover Report · premium visual candidate"` |
| `Context1Label` | `"Project"` |
| `Context1Value` | `If(IsBlank(varProjectId), "No project selected", Coalesce(varSelectedProject.ProjectCode, Text(varProjectId)) & " · " & Coalesce(varSelectedProject.ProjectName, "Project"))` |
| `Context1Visible` | `true` |
| `Context1Interactive` | `false` |
| `Context2Label` | `"Visual state"` |
| `Context2Value` | `Switch(varOPDS_VisualTestState, "LOADING", "Loading", "NO_PROJECT", "No project", "NO_CONFIGURATION", "No configuration", "NO_DATA", "No data", "ERROR", "Error", "READY", "Ready", "Visual test")` |
| `Context2Visible` | `true` |
| `Context2Interactive` | `false` |
| `Context3Label` | `"Evidence"` |
| `Context3Value` | `"Visual only"` |
| `Context3Visible` | `true` |
| `Context3Interactive` | `false` |
| `UtilityText` | `"Preview loading"` |
| `ShowUtility` | `true` |
| `UtilityEnabled` | `true` |
| `OnUtility` | `UpdateContext({varOPDS_VisualTestState: "LOADING"})` |
| `ShowHelp` | `true` |
| `OnHelp` | `Notify("OPDS-C01 solo valida la presentación. No hay ningún flujo de Overview conectado.", NotificationType.Information)` |
| `SurfaceColor` | `varTheme_Surface` |
| `SurfaceAltColor` | `varTheme_SurfaceAlt` |
| `BorderColor` | `varTheme_Border` |
| `TextColor` | `varTheme_Text` |
| `MutedTextColor` | `varTheme_TextMuted` |
| `AccentColor` | `varTheme_PulseBlueDark` |
| `AccentSoftColor` | `varTheme_PulseSoft` |

Si alguno de los componentes insertados manualmente quedaba vacío o no mostraba sus
propiedades públicas, debía detenerse únicamente esa integración. Las superficies
nativas podían seguir revisándose sin reescribir el componente ni probar instancias
equivalentes mediante Source Code.

## Parte 4 — validación conjunta

Había que guardar la aplicación, cerrar y volver a abrir la pantalla si era necesario,
y utilizar los seis botones de la barra `Visual test state`.

Cada criterio obligatorio debía clasificarse como `PASS`, `FAIL`, `NOT_RUN` o `GATED`.

| Comprobación | Observación esperada |
|---|---|
| Pantalla independiente | `scr_Overview_PDS` se abre y `scr_Overview` permanece intacta. |
| Shell | Sidebar, encabezado premium y superficie principal se muestran a 1600×900. |
| Loading | El mensaje de carga y el esqueleto de la matriz aparecen solos. |
| No project | Aparece únicamente la superficie de selección de proyecto y su botón solo muestra un mensaje. |
| No configuration | Aparece únicamente la ayuda de configuración e indica que es un candidato visual. |
| No data | Aparece la superficie vacía y Preview refresh cambia únicamente a Loading. |
| Error | Aparece la superficie de error y Preview retry cambia únicamente a Loading. |
| Ready | Aparecen el contexto, las pestañas visuales, la acción de subsistema y la matriz preparada. |
| Exclusividad | No se solapan dos superficies durante el recorrido por los seis estados. |
| App Checker | No aparece ningún error bloqueante nuevo atribuible a `scr_Overview_PDS`. |
| Guardar y reabrir | La pantalla y las dos instancias permanecen visibles y configuradas. |
| Aislamiento | No se ejecuta ningún flujo de Overview y la navegación operativa permanece intacta. |

Las comprobaciones de ausencia de configuración, ausencia de datos y error solo
demostraban su presentación. No podían registrarse como situaciones funcionales
reales de un proyecto.

## Resultado que debía devolverse

La respuesta debía incluir:

1. `OPDS-C01 STUDIO RESULT`;
2. un resultado para cada fila de la tabla;
3. el primer error completo de Studio o App Checker, si existía;
4. una captura del estado Ready y de cualquier defecto visual;
5. confirmación de si guardar y reabrir conservaba las dos instancias.

No debían ejecutarse los flujos de Overview durante esta validación.
