# PULSE-BOOT-03 — Premium Project Gallery · Paquete de instalación

**Estado: CANDIDATO COMPLETO / QA ESTÁTICO / PENDIENTE DE POWER APPS STUDIO.**

## Resultado funcional

Pantalla `scr_Boot` con estética de la referencia aprobada: refinería al atardecer, logo PULSE separado, tarjeta acristalada, buscador, selector visual por tarjetas, ordenación A-Z/Z-A, selección explícita, estados de carga/error/catálogo vacío, botón de reintento y entrada protegida contra doble ejecución.

La lista **NO tiene cuatro proyectos simulados hardcodeados**. Su `Items` es una consulta de `colEnabledProjectsUI`, colección existente en `App.OnStart` cuya fuente es `WarRoom_EnabledProjects_GetActive.Run().result`. Cada proyecto muestra su `ProjectCode`, `ProjectName`, `ProjectDescription` reales. Las cuatro miniaturas especiales son ilustraciones del mockup y **no son fotografías verificadas de esos proyectos**; para otros códigos se usa un placeholder industrial neutro. Si no se permite una imagen ilustrativa de un proyecto concreto, usar placeholder único para todos, sustituyendo `Image` de `imgPulseBoot_RowThumb` por `pulse_boot_project_placeholder_v3`.

## Recursos Media a importar ANTES del Source Code

| Archivo del paquete | Nombre EXACTO de Media en Studio |
|---|---|
| `PULSE_Boot_Background_Clean_Quality92.jpg` | `pulse_boot_background_v3` |
| `PULSE_Boot_Wave_Reference_Raster.png` | `pulse_boot_wave_v3` |
| `PULSE_Boot_Project_Placeholder.jpg` | `pulse_boot_project_placeholder_v3` |
| `PULSE_Boot_Thumb_02200_Illustrative.jpg` | `pulse_boot_thumb_02200_v3` |
| `PULSE_Boot_Thumb_03010_Illustrative.jpg` | `pulse_boot_thumb_03010_v3` |
| `PULSE_Boot_Thumb_05000_Illustrative.jpg` | `pulse_boot_thumb_05000_v3` |
| `PULSE_Boot_Thumb_06010_Illustrative.jpg` | `pulse_boot_thumb_06010_v3` |

El fondo es una **reconstrucción/limpieza de la referencia visual aprobada**, no una fotografía fuente original sin modificaciones. La composición lateral, la tablet y el atardecer proceden del mockup; el centro se recompone porque la referencia original ya traía el selector incrustado. El fondo está pensado para verse detrás de un panel oscuro opaco. Los logos/textos/botones funcionales son controles separados.

El PNG de onda es una **copia rasterizada de la referencia visual, no un SVG maestro oficial**. Reemplazarlo por el logo maestro de PULSE si se dispone de este; **no** incrustar logos en el JPG de fondo.

## Instalación y contrato de flujo

1. Guardar el Source Code ACTUAL de `scr_Boot` (reemplazaremos la pantalla existente, no crearemos `scr_Boot` duplicada).
2. Verificar en la aplicación LIVE que el `App.OnStart` actual llama `WarRoom_EnabledProjects_GetActive.Run().result`, normaliza `colEnabledProjects`, calcula `colEnabledProjectsUI` y finaliza con `Set(varScrApp_Initialized,true)`.
3. Si `App.OnStart` no pone `Set(varScrApp_Initialized,false)` al PRINCIPIO, agregar esa sentencia **antes de** iniciar los flows; conservar true solo al final. No reemplazar el resto del `App.OnStart` con fragmentos.
4. Importar los siete Media; respetar sus nombres EXACTOS en Studio.
5. Abrir `scr_Boot_PremiumProjectGallery.pa.yaml`, validar en vista Source Code para pantalla y aplicar siguiendo el flujo compatible con la app (Source Code/Git Integration). El formato `.pa.yaml` NO equivale a un botón universal de importar archivos en la app publicada.
6. Mantener `App.StartScreen = scr_Boot`.
7. Revisar App Checker, guardar, reabrir y lanzar sesión de arranque nueva; no confundir editor con prueba runtime.
8. Al pulsar `Abrir proyecto`, Boot solo establece `varPendingProjectId`, `varGlobalLoadAction="PROJECT_CHANGE"`, `varGlobalLoadPending=true` y navega a **`scr_Home`**, nombre técnico REAL. No existe aún un `scr_Tower` operativo publicado.
9. El `tmrGlobalLoader_2` ya existente en `scr_Home` consume esa acción y llama `btnHome_ProjectChange_Commit_2`. El commit resuelve `varSelectedProject`, establece `varProjectId`, `varProjectCode`, `varProjectName`, `varProjectDescription` y agenda carga del dashboard activo. **No duplicar este proceso en Boot.**
10. Conservar selector de proyecto de `scr_Home` para cambios posteriores sin regresar obligatoriamente a Boot.

## Gates de aceptación

- B01 `LOADING` -> `SELECT_PROJECT`: un solo bootstrap inicial del catálogo en Monitor, no dos.
- B02 Sin selección: botón deshabilitado; primera tarjeta NO autoseleccionada.
- B03 Búsqueda por código/nombre/descripcion: lista filtrada sin tocar `colEnabledProjectsUI`.
- B04 Ordenación asc/desc y filtro: estado de selección por `ProjectId` preservado, botón protegido.
- B05 Pulsación de tarjeta seguida de `Abrir proyecto`: **una** solicitud `PROJECT_CHANGE`, Home recibe un ProjectId numérico válido.
- B06 Verificar timer/commit real en Home y filtros/datos dashboard de ese mismo proyecto.
- B07 Error de flow: mensaje, retry único, recupera listado sin navegación automática.
- B08 Catálogo vacío: EMPTY; no permite entrar a Home sin proyecto.
- B09 Proyecto B tras Proyecto A: se invalidan snapshots, caches, filtros heredados según `btnHome_ProjectChange_Commit_2`.
- B10 QA de diseño en 1366×768, 1600×900 y zoom 125%. Cuatro filas caben o la galería muestra scroll sin cortar footer.
- B11 Comprobar que las imágenes opcionales son ilustrativas, no sustituyen evidencia de proyecto.
- B12 Guardar/reabrir la app tras importar el Source Code sin fallos del componente galería.

## Riesgos pendientes / no afirmar PASS Studio

La estructura YAML y el contrato cruzado se revisaron estáticamente. No se dispone de ejecución real en Power Apps Studio, ni se confirma que la versión LIVE de Home sea idéntica a la versionada en GitHub. El repositorio `app_pulse` figuraba **público** en la última consulta: los PNG/JPG del paquete no se han subido allí.