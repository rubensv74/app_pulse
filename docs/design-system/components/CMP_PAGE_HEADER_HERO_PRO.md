# PULSE-HERO-01 — Page Header Hero Pro

**Estado:** `REVIEW_REQUIRED / SOURCE_PREPARED / NOT_STUDIO_VALIDATED`  
**Fuente candidata:** `power-apps/components/cmp_PageHeaderHeroPro.pa.yaml`  
**Referencia:** `cmp_AP_PageHeaderPro` de AssetPlan y `cmp_PageHeaderPro` de PULSE.

## Decisión de arquitectura

**Extender por variante aislada**, no sustituir inmediatamente un componente activo.

La fuente canónica de AssetPlan `cmp_AP_PageHeaderPro` (main) actualmente tiene altura 80 px, icono/título/subtítulo y dependencias de multimedia `ap-*`. No contiene el hero fotográfico aprobado en un contrato reutilizable. Copiarla literalmente a PULSE perdería:

- los tres slots de contexto PULSE (Project, Template, Last Refresh);
- las acciones Utility/Help;
- cinco eventos públicos (tres contextos, Utility y Help; y sus reglas de interacción);
- el PDS PULSE de colores, selección y navegación.

PULSE ya tiene `cmp_PageHeaderPro` con estas entradas y eventos. Su historial incluye un fallo anterior de inserción en Studio; la fuente no garantiza seguridad de instanciación. Por eso se ha clonado **en un candidato nuevo aislado** con el mismo contrato, añadiendo solo modalidad hero.

No instalar automáticamente en ninguna pantalla actual ni eliminar el componente existente antes del gate real.

## Contrato público de la variante

| Propiedad | Tipo | Valor por defecto | Responsabilidad |
|---|---|---|---|
| `HeroEnabled` | Boolean | false | false → render original 80px; true → modo panorámico 112px |
| `HeroMedia` | Image | Blank() | Imagen importada en Media de Power Apps, suministrada por la pantalla |
| `Title` / `Subtitle` | Text | Valores de componente PULSE original | Identidad de pantalla |
| `Context1..3Label/Value/Visible/Interactive` | Text/Boolean | Original | Contextos funcionales |
| `OnContext1..3Select` | Event | Original | La pantalla decide acciones de contexto |
| `UtilityText/Enabled/ShowUtility` | Text/Boolean | Original | Acción secundaria |
| `ShowHelp/OnHelp/OnUtility` | Boolean/Event | Original | Help, Refresh etc |
| `SurfaceColor/SurfaceAltColor/BorderColor/TextColor/MutedTextColor/Accent*` | Color | Original | Estilo de modo clásico |

**No se agregan llamadas SQL, flows, navegación, datos ficticios ni actualización de estado dentro del componente.**

En modo hero:

- La capa `imgPHH_HeroMedia` cubre 100 % del ancho y alto, sin alterar los slots.
- Overlay `RGBA(3,13,29,0.38)` para legibilidad.
- Título blanco 24/semibold; subtítulo azul hielo 11.
- Controles de contexto quedan con la superficie clara del componente original, conservando legibilidad.
- Altura 112 px; en modo anterior 80 px.
- Botones, label y contextos permanecen activos y con sus eventos originales.

## Imágenes — fuente visual PULSE

Primera familia candidata de 8 hero JPG optimizados, generada usando como referencia la escena industrial azul/cian aprobada para el Boot. **En la carpeta local de entrega están en `PULSE_HEROES_V1.zip`; los binarios aún deben incorporarse a `power-apps/assets/heroes/pulse/v1/` para que GitHub conserve la fuente multimedia.** No afirmar que estén instalados en Power Apps.

| Pantalla | Recurso de importación Media propuesto | Archivo |
|---|---|---|
| Home | `pulse_hero_home_v1` | `pulse-hero-home-v1.jpg` |
| Overview | `pulse_hero_overview_v1` | `pulse-hero-overview-v1.jpg` |
| Tasks | `pulse_hero_tasks_v1` | `pulse-hero-tasks-v1.jpg` |
| Punch List | `pulse_hero_punch_list_v1` | `pulse-hero-punch-list-v1.jpg` |
| Punch Review | `pulse_hero_punch_review_v1` | `pulse-hero-punch-review-v1.jpg` |
| Briefing | `pulse_hero_briefing_v1` | `pulse-hero-briefing-v1.jpg` |
| Skyline | `pulse_hero_skyline_v1` | `pulse-hero-skyline-v1.jpg` |
| Config | `pulse_hero_config_v1` | `pulse-hero-config-v1.jpg` |

Pixel dimensions: **1600 × 224**, intended to display at **112 px** height (2× density). Banner aspect ratio `~7.14:1`. All candidate JPG resources are under 85 KB each.

## Instanciación de prueba — no publicar automáticamente

1. En Power Apps Studio, importar una sola imagen piloto `pulse_hero_home_v1`.
2. En una **pantalla de laboratorio independiente**, crear la definición `cmp_PageHeaderHeroPro` desde `power-apps/components/cmp_PageHeaderHeroPro.pa.yaml`.
3. Validar firma de la propiedad `HeroMedia` como Image en Studio; si Studio no acepta ese tipo/default, ajustar la definición **antes** de promoverla como canónica (mantener la interfaz por media / Image, no reemplazar por una cadena URL improvisada).
4. Instanciar en una pantalla vacía en **modo heredado** `HeroEnabled=false`, `Height=80`. Ejercitar cada contexto y evento.
5. Activar `HeroEnabled=true`, `HeroMedia=pulse_hero_home_v1`, `Height=112`, `Width=Parent.Width`; comprobar texto, derecha, contraste.
6. Confirmar propiedad `ImagePosition.Fill` y el comportamiento real de recorte/estiramiento a 1366, 1600 y 1920 px.
7. Conectar una **primera pantalla**; preferencia: Home. Mantener rollback al componente previo.
8. Solo tras aceptación de Home continuar Overview, Tasks, Punch List, Punch Review, Briefing, Skyline y Config.

## Gates

- [ ] `PASS_STATIC` y parse YAML (estructura, propiedades, nombres, referencias).
- [ ] `COMPONENT_DEFINITION_ACCEPTED` en Studio sin introducir errores.
- [ ] `INSTANCE_SAFE` (importar, insertar, guardar, cerrar, reabrir, App Checker).
- [ ] `PUBLIC_CONTRACT_VALIDATED` (todos los eventos anteriores siguen funcionando).
- [ ] `VISUAL_QA` 1366×768 / 1600×900 / 1920×1080; zoom 125%.
- [ ] `RESPONSIVE`: título sin solapar 3 slots + utilities en anchos útiles de workspace; definir reducción de contextos en host si el ancho no lo permite.
- [ ] `ASSET_QA`: importación multimedia y mapping a las 8 pantallas sin textos embebidos.
- [ ] `SCREEN_CUTOVER`: instalación por pantalla, mantener contratos y volver al componente anterior si falla.
- [ ] `CANONICAL_PROMOTION`: actualizar documentación visual, componente PDS y estado de catálogo solo tras PASS real.

## Riesgos explícitos

- La imagen gráfica de AssetPlan aprobada en la aplicación Studio podría estar fuera del repositorio; por ello el nuevo hero se basa en la **referencia visual conocida y validada en este hilo**, no en la falsa afirmación de que hemos trasladado exactamente una definición productiva de 112px.
- El componente existente PULSE tiene historial de cierre de Studio al instanciar versiones anteriores: una nueva variante no evita ese riesgo hasta demostrar el PASS.
- El diseño PULSE actual sitúa contextos a la derecha y puede saturar la cabecera cuando el workspace es estrecho: validar el host por pantalla antes de desplegar.
- `Pulse Boot` es otra pantalla: no debe depender del nuevo Page Header.


## Actualización de dirección visual V2 — 2026-10-24

**Decisión aprobada por el usuario:** conservar el estilo de la última ilustración Punch List con tuberías, pines de incidencia, personal de obra con identidad TR, fotografía industrial crepuscular y cian eléctrico. El set abstracto V1 queda descartado para instalaciones nuevas.

**Recursos preparados externamente:** nueve fondos JPG 1600 × 224, nombres `pulse-hero-{home,overview,tasks,punch-list,punch-review,briefing,config,skyline,superadmin}-v2.jpg` según `power-apps/assets/heroes/pulse/v2/manifest.json`. Los archivos JPG se entregan en un ZIP local; NO están en GitHub ni en Media de Power Apps hasta que se incorporen expresamente.

**Diferenciación semántica:** Home = control central; Overview = avance/entrega; Tasks = trabajador/tablet/lista; Punch List = pines de incidencias y trabajadores TR; Punch Review = evidencia/verificación; Briefing = equipo/relevo; Config = engranajes/parámetros; Skyline = vista aérea/indicadores; SuperAdmin = administración/accesos. Boot mantiene su recurso independiente.

**Regla de diseño:** títulos, subtítulos, filtros, métricas reales y acciones se mantienen como controles dinámicos de Power Apps. No tomar los pequeños paneles holográficos ilustrativos como fuentes de métricas. Revisar y, si procede, limpiar microtextos residuales en el gate visual a altura 112 px antes de promoción.

**Prueba adicional:** confirmar que el logotipo TR en ropa es suficientemente fiel a la identidad corporativa autorizada; si requiere precisión exacta, sustituir por el recurso oficial aprobado antes de producción.


## Actualización V3 — Objeto protagonista y brand overlay

La referencia visual V3 sustituye V1 y V2 para nuevas pantallas. Ver `docs/design-system/components/PULSE_HERO_OBJECT_V3_STUDIO_GATE.md` y `power-apps/assets/heroes/pulse/v3/manifest.json`.

**Nuevos inputs de la variante candidata**:

- `BrandVisible : Boolean` (default `false`)
- `BrandMedia : Image` (default `Blank()`)

El logotipo PULSE **no debe estar incorporado a los JPG**: se suministra desde Media a `BrandMedia`, con `BrandVisible=true` únicamente después de obtener el maestro correcto. Así se evita perpetuar interpretaciones incorrectas de la marca en nueve imágenes distintas.

Todos los contextos y eventos anteriores permanecen intactos. No promover a `ACTIVE` sin confirmar inserción en Studio, `DataType: Image`, responsive 80/112px y el comportamiento de cinco eventos. Los 9 JPG están entregados en un ZIP fuera del repositorio; el repositorio solo guarda el manifiesto.
