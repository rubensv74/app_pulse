# OPDS-C01-FIX — encabezado nativo y configuración del Sidebar

## Por qué existe este FIX

La primera validación en Studio demostró tres hechos útiles:

- Studio acepta el Source Code completo de la pantalla;
- las superficies visuales `Loading` y `Ready` se presentan correctamente;
- los dos componentes reutilizables insertados manualmente no cargaron sus
  propiedades como se necesitaba.

`cmp_SidebarNav` mostró los valores predeterminados `Text` y únicamente el elemento
Home. `cmp_PageHeaderPro` permaneció vacío y su instancia solo expuso un contrato
genérico mínimo. Esto reproduce el límite de integración ya observado en Home PDS.

El FIX detiene únicamente la vía de reutilización que ha fallado. Conserva
`cmp_SidebarNav`, cuyo cuerpo y propiedades públicas están disponibles, y sustituye
el Page Header vacío por un encabezado premium nativo dentro del alojamiento ya
validado.

## Una única intervención conjunta en Studio

### 1. Sustituir el código completo de la pantalla

1. Selecciona `scr_Overview_PDS`.
2. Abre **Source code** para la pantalla completa.
3. Sustituye todo su contenido por la versión vigente de:
   `power-apps/screens/OverviewPDS/scr_Overview_PDS.pa.yaml`.
4. Guarda y espera a que Studio termine de validar el código.

Esta sustitución limpia elimina las dos instancias que fallaron e instala el
encabezado premium nativo. El alojamiento del Sidebar queda vacío intencionadamente.

### 2. Insertar y configurar únicamente el Sidebar

1. Usa **Insert > Custom** e inserta `cmp_SidebarNav`.
2. Muévelo dentro de `conOPDS_SidebarHost`.
3. Renómbralo como `cmpOPDS_Sidebar`.
4. Configura todas estas propiedades en la misma operación:

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

Si Studio no muestra alguna de estas propiedades, devuelve su nombre exacto y detén
solo la integración del Sidebar. No aceptes los valores literales `Text` / `Text`.

### 3. Validar la capacidad visual completa

Guarda, vuelve a abrir la pantalla y comprueba:

| Comprobación | Resultado esperado |
|---|---|
| Encabezado premium nativo | Se muestran título, subtítulo, proyecto, estado visual, evidencia y acciones Loading y Help. |
| Interacción del encabezado | Loading cambia únicamente el estado local de prueba; Help muestra un mensaje informativo. |
| Sidebar | Overview está activo, no quedan valores `Text` y seleccionar un elemento no navega. |
| Seis superficies | Loading, No project, No config, No data, Error y Ready aparecen individualmente. |
| Calidad visual | No hay solapamientos, recortes ni barras de desplazamiento accidentales a 1600×900. |
| App Checker | No aparece ningún error bloqueante nuevo bajo `scr_Overview_PDS`. Los errores existentes en otros artefactos no se atribuyen a C01. |
| Guardar y reabrir | El encabezado, las propiedades del Sidebar y los seis estados continúan disponibles. |
| Aislamiento | No se ejecuta ningún flujo de Overview y `scr_Overview` permanece intacta. |

Devuelve una captura del estado Ready, una captura de cualquier defecto y el resultado
de cada fila. Esta es la segunda y última validación de Studio prevista para OPDS-C01.
