# PULSE-BOOT-01 — Pantalla Boot premium

**Estado:** `CANDIDATE / PENDING STUDIO GATE`  
**Rama:** `feature/pulse-boot-splash-v1-20261023`  
**Pantalla nueva:** `scr_Boot`  
**Origen visual:** `scr_AP_Boot` de AssetPlan (baseline W03 Studio validated, 2026-08-18).  
**Fuente candidata:** `blocks/01_scr_Boot.candidate.pa.yaml`

## Resultado preparado

Boot es una **pantalla Power Apps completa** con el lenguaje de bienvenida de AssetPlan adaptado a PULSE:

- Superficie oscura `#07111F`, firma PULSE y acento `#00C8FF`.
- Centro de carga, mensaje de inicialización y spinner.
- `ERROR`: detalle amigable y reintento protegido con single-flight.
- `EMPTY`: no hay proyectos habilitados; acceso explícito a Home sin inventar un proyecto.
- `READY`: transición `Fade` a `scr_Home`, delegada a un Timer.
- `imgPulseBoot_Background`: capa de imagen oculta y sin dependencia multimedia, reservada para el arte final de PULSE.

La pantalla Boot es **arquetipo global de arranque** y por eso no utiliza sidebar, Page Header ni componentes operacionales de otras pantallas.

## Contrato técnico

| Emisor | Acción / estado | Consumidor |
|---|---|---|
| `App.StartScreen` | `scr_Boot` | Pantalla Boot |
| `App.OnStart` existente | `WarRoom_Security_IsSuperAdmin.Run(varCurrentUserEmail)` | `colSecurity`, `varIsSuperAdmin` |
| `App.OnStart` existente | `WarRoom_EnabledProjects_GetActive.Run().result` | `colEnabledProjects`, `colEnabledProjectsUI`, `varEnabledProjectsError` |
| `App.OnStart` existente | `varScrApp_Initialized = true` **al terminar** | `tmrPulseBoot_Observe` |
| `tmrPulseBoot_Observe` | `LOADING → ERROR / EMPTY / READY` | Feedback y temporizador de salida |
| `tmrPulseBoot_Ready` | `READY → Navigate(scr_Home)` | Home / selección de proyecto |
| `btnPulseBoot_Retry` | Reintenta **solo** `WarRoom_EnabledProjects_GetActive` | Las mismas colecciones del OnStart |

**No se elige proyecto durante Boot.** La elección permanece en Home, como en la arquitectura actual de PULSE. No se llama a SQL directamente ni se añaden flujos nuevos.

### Dependencias y límites verificados en repositorio

1. El candidato de `App.OnStart` versionado en `docs/development/app/APP-START-01_App.OnStart.organized.powerfx` **sí** inicializa seguridad/proyectos y termina con `Set(varScrApp_Initialized, true)`.
2. Ese candidato se encuentra marcado **pendiente de validación Studio**. No hay garantía de que la versión real abierta actualmente en Power Apps Studio coincida con él.
3. PULSE no tiene exportación canónica instalada de `App.StartScreen` en este repositorio. La activación es una operación explícita en Studio.
4. El fallo de `WarRoom_Security_IsSuperAdmin` queda degradado a no-superadmin por el `OnStart` actual, y Boot **no** modifica ese contrato; su estado de error cubre el catálogo de proyectos.
5. El estado `READY` certifica **solo bootstrap de sesión**, no que los datos específicos de Home, Overview, Punches ni Tasks ya estén cargados.
6. No se ha importado ni probado aún esta pantalla en la aplicación real. El source es candidato; **no afirmar runtime PASS**.

## Gate de instalación en Power Apps Studio

1. Guardar copia del `App.OnStart`, del `App.StartScreen` y del source de la pantalla inicial actualmente instalados.
2. Revisar el **OnStart real de Studio**. Verificar los nombres de `WarRoom_EnabledProjects_GetActive`, `colEnabledProjects`, `colEnabledProjectsUI`, `varEnabledProjectsError`, y que **al final** asigna `Set(varScrApp_Initialized, true)`.
3. Como medida de idempotencia para `Run OnStart`, garantizar `Set(varScrApp_Initialized, false)` **antes de las cargas asíncronas** y `true` exclusivamente al final de la inicialización. Sin este contrato, **no activar** `App.StartScreen`.
4. Crear la nueva pantalla `scr_Boot` e introducir su Source Code completo desde `blocks/01_scr_Boot.candidate.pa.yaml` sin modificar el resto de pantallas.
5. Verificar App Checker (incluidas conexiones, tipos, Timer Start/OnTimerEnd y control `ModernButton`).
6. En `App.StartScreen` establecer exactamente **`scr_Boot`**. No invocar `Navigate` desde `OnVisible` ni desde `App.OnStart`.
7. Ejecutar **Run OnStart** y después abrir la aplicación desde una sesión nueva, no solo desde la vista previa con valores de variable persistidos.
8. Ejecutar las pruebas de la sección siguiente. Solo después trasladar el source validado a `power-apps/screens/Boot/scr_Boot.pa.yaml` y actualizar el mapa de navegación y documentación de runtime.

## Pruebas de aceptación

| ID | Escenario | Resultado exigido |
|---|---|---|
| B01 | Sesión nueva, catálogo válido con proyectos | Boot → READY → Home. Sin selección automática de proyecto |
| B02 | Observación de ejecuciones en Power Automate | **Solo una** ejecución inicial de `WarRoom_EnabledProjects_GetActive` por arranque, sin duplicados desde Boot |
| B03 | Fallo del catálogo | ERROR con `Try again`; no navegación automática |
| B04 | Reintento después de restablecer servicio | Una ejecución, botones bloqueados durante la petición, READY → Home |
| B05 | Catálogo válido vacío | EMPTY y botón `Open Home`; no pantalla cautiva |
| B06 | OnStart demora más de 30 s | Mensaje de demora, interfaz responde; transición cuando termina, sin reconsultas |
| B07 | Variable `varScrApp_Initialized` inexistente o no reseteada | **Gate fail**; corregir OnStart antes de habilitar StartScreen |
| B08 | Pruebas visuales 1366×768 / 1600×900 y 125 % zoom | Sin recortes, scrollbars internos, superposiciones ni textos ilegibles |
| B09 | Primer arranque y navegación posterior | Home, Overview, Punches y Tasks mantienen sus cargas y navegación existentes |
| B10 | Proyecto no seleccionado y rol restringido | Boot no selecciona contexto ni concede privilegios por su cuenta |

## Siguiente incremento: imagen de fondo

El diseño admite incorporar una imagen específica de PULSE **sin tocar los contratos funcionales**:

- sustituir solo `imgPulseBoot_Background.Image = Blank()` por un recurso multimedia de Power Apps después de importarlo;
- activar `imgPulseBoot_Background.Visible = true`;
- conservar el contraste del wordmark, spinner, textos y acciones, y comprobar recorte en las resoluciones pactadas.

**No se reutiliza la imagen AssetPlan** ni se importa una imagen temporal. La ilustración final se diseñará aparte.

## Exclusiones

- Sin cambios en los SP, SQL, flujos de producción o Power Apps de ejecución.
- Sin refactor de `App.OnStart` de 600+ líneas ni de `scr_Home.OnVisible`.
- Sin intervención en módulos Punch Review, Punch List, Tasks, Overview ni Config.
- Sin nueva librería de componentes; los controles de marca y mensaje pertenecen solo a este arquetipo de arranque.
