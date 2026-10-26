# PULSE BOOT V4 · Corrección de scroll en textos (26 octubre 2026)

Estado: **STATIC_PASS / STUDIO_PENDING**

## Fuente autoritativa

Este candidato se basa en el código íntegro facilitado por el usuario, **Pasted text(20261026-110652).txt**, exportado de Power Apps Studio. No se basa en la copia V3 de la rama.

**Instalar:** `power-apps/screens/Boot/v4/scr_Boot_PremiumProjectGallery_V4_SCROLLFIX.candidate.pa.yaml` como Source Code completo de `scr_Boot`. Guardar copia del runtime antes de sustituirlo.

## Hallazgos y ajustes

1. Los `ModernText` mostraban marcas verticales por alturas demasiado pequeñas para su texto y el padding por defecto (controles de fila a 16/22/18 px). En **los diez** controles de texto se fija `AutoHeight=true`, `PaddingTop=PaddingBottom=PaddingLeft=PaddingRight=0`, `VerticalAlign.Middle`. En filas: alturas 22/26/22 y posiciones 1/22/45, con `Wrap=false`.
2. La galería conserva desplazamiento mediante rueda táctil/ratón, pero oculta el indicador (`ShowScrollbar=false`, `ShowNavigation=false`). **No** se ha bloqueado scroll útil para listas largas.
3. La tarjeta principal deja de ocupar casi toda la pantalla con un solo proyecto; altura limitada por pantalla y por número de proyectos.
4. Búsqueda de una sola línea; al modificar el texto se invalida la selección anterior y se deshabilita «Abrir proyecto» hasta elegir otra fila. Reset de búsqueda al entrar y tras reintento satisfactorio.
5. Descripción larga se acorta solo para presentación; valor real de `ProjectDescription` no se modifica. Se utiliza código como fallback visual para nombre vacío.
6. El temporizador de observación solo repite durante `LOADING`. Se incluye etiqueta accesible en el botón invisible de cada fila.
7. El icono de lupa se oculta durante carga/error, acompañando correctamente al campo.

## Elementos que se conservan sin sustitución

- 31 controles y sus nombres.
- Fondo: `pulse_boot_background_v3`.
- Logotipo: `PULSE_logo_boot`.
- Miniatura genérica: `'pulse_boot_project_generic_v1'`.
- Catálogo: `colEnabledProjectsUI`; flujo `WarRoom_EnabledProjects_GetActive` solo en retry (bootstrap en `App.OnStart`).
- Carga: `varPendingProjectId` → `PROJECT_CHANGE` → `Navigate(scr_Home)` → rutina actual de Home. Sin duplicación de flujos.
- Ordenación por `ProjectDisplayName`, filtrado por código/nombre/descripción.

## Validaciones estáticas

- Parse YAML: OK.
- Cantidad y nombres de controles: 31/31 conservados.
- Fórmulas de Items de galería, Enter, Timer y RowSelect: contratos heredados preservados.
- Imágenes referenciadas: exactamente las tres importadas en Media por el usuario.
- ZIP de conversación contiene la fuente completa, documentación y QA.

## Gate Power Apps Studio obligatorio

- [ ] Studio acepta la nueva fuente sin errores de esquema.
- [ ] No aparecen barras en los textos del encabezado ni del proyecto a zoom 100% y 125%.
- [ ] Un solo proyecto: la tarjeta se contrae, sin zonas excesivamente vacías ni solapamientos.
- [ ] Seis o más proyectos: lista desplazable y pie siempre visible.
- [ ] Nombre y descripción largos: ni scroll interno ni solapamiento con iconos.
- [ ] Cambiar búsqueda después de seleccionar impide abrir selección obsoleta.
- [ ] Retry con catálogo vacío/error no duplica llamadas.
- [ ] Abrir un proyecto dispara solo una vez `PROJECT_CHANGE`; comprobar con Monitor.
- [ ] Adaptación visual 1366×768, 1600×900, 1920×1080.

**La PR es candidata; no está validada en Studio y no debe fusionarse a main todavía.**
