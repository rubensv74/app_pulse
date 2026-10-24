# PULSE Hero Object V3 · Branding and Media Gate

Estado: `CANDIDATE / SOURCE_PACK_GENERATED / NOT_IMPORTED / NOT_STUDIO_VALIDATED`

## Cambio respecto a V2

El usuario descartó las escenas industriales genéricas y eligió la dirección `Objeto protagonista`. La última tanda aprobada era un collage con P estilizada falsa en todos los banners y monogramas TR deformados.

El paquete V3 aporta 9 JPG independientes de 1600×224 a partir de la composición aceptada, con banda izquierda azul noche reservada para controles reales, sin títulos ni símbolos PULSE embebidos, y con reelaboración de los emblemas del casco de Tasks y Briefing usando el logo raster de un PDF corporativo facilitado anteriormente.

**No hay nueve fondos JPG en GitHub todavía.** Están en el ZIP `PULSE_HERO_OBJECT_V3_BRAND_REVIEW.zip` entregado en la conversación. El manifiesto versionado `manifest.json` permite validar después la correspondencia exacta de Media.

### Fuentes de identidad

1. TR: imagen incrustada en `Control Asistencia 1475 - 2 - HCS Training.pdf`, marca «tr» entrelazada y texto TÉCNICAS REUNIDAS, extraída literalmente como raster. No es un rediseño generativo.
2. PULSE: captura del runtime `Interfaz de control de PULSE.png`, marca de onda cian sobre «PULSE», recuperada como raster transparente de baja resolución. **No es el SVG maestro aprobado; debe recuperarse del Media original antes de producción**.
3. Los JPG incluyen únicamente escenas y objetos funcionalmente reconocibles. Donde existan hologramas generativos, son decoración y no sustituyen métricas reales de la aplicación.

## Contrato del componente

`cmp_PageHeaderHeroPro` conserva las **32 propiedades** que tenía `cmp_PageHeaderPro` y añade entradas optativas:

| Input | DataType | Default | Contrato |
|---|---|---|---|
| `HeroEnabled` | Boolean | false | 80 px → 112 px |
| `HeroMedia` | Image | Blank() | Fondo importado en Power Apps Media |
| `BrandVisible` | Boolean | false | Activa logo independiente solo en hero |
| `BrandMedia` | Image | Blank() | Media del logotipo **real** de PULSE, no un logo generado |

**Responsable de navegación:** pantalla host. **Responsable de ejecución:** flows y `App.OnStart` existentes; componente sin conexiones. Los cinco eventos existentes deben seguir apuntando a los callbacks de la pantalla.

Un host de laboratorio con imagen importada usaría:

```powerfx
cmp_PageHeaderHeroPro.HeroEnabled = true
cmp_PageHeaderHeroPro.HeroMedia = pulse_hero_punch_list_v3
cmp_PageHeaderHeroPro.BrandVisible = true
cmp_PageHeaderHeroPro.BrandMedia = pulse_logo_master
cmp_PageHeaderHeroPro.Height = 112
cmp_PageHeaderHeroPro.Width = Parent.Width
```

**Importante:** `pulse_logo_master` es nombre de Media **propuesto**, no activo creado; asignarlo solo después de importar el recurso original.

## Gate a ejecutar en Power Apps Studio

1. Obtener SVG/PNG maestro de PULSE del Media actual y comprobar con la captura de referencia.
2. Comprobar la fuente TR y el realismo de cada decal al mostrarla a 112 px; si la geometría no se distingue de forma segura, casco sin marca en vez de marca falsa.
3. Importar solo la imagen piloto `pulse_hero_punch_list_v3`; verificar `Media` y `Image` binding.
4. Crear componente `cmp_PageHeaderHeroPro` en laboratorio y confirmar que `BrandMedia` y `HeroMedia` son compatibles con la versión Studio; comprobar la instancia, guardado y reapertura.
5. Ejercitar los cinco eventos; comprobar que no se ejecutan flows de forma duplicada.
6. Comprobar 112 px y 80 px a 1366, 1600 y 1920 px (zoom 125 %). Verificar slot de proyecto y tres contextos, title/subtitle, utility/help, overflow y wrapping.
7. Integrar una primera pantalla —Punch List— solo tras gate del laboratorio, conservando rollback. Extender a Home/Overview y resto por ciclos.
8. Incorporar los JPG a GitHub en ruta `power-apps/assets/heroes/pulse/v3/` tras aprobación visual. Mientras solo existe el manifiesto, **NO** aprobar la PR ni `main`.
9. Ejecutar regresión de navegación / selecciones / filtros / carga y pantalla Boot existente.

## Riesgos pendientes

- En el collage generado inicialmente aparecen pequeños textos o hologramas con valores sintéticos: en V3 se difuminan las cifras más evidentes, pero debe verificarse uno por uno su ausencia de implicación funcional.
- El logo PULSE recuperado de captura no es el master. No declararlo validado ni distribuirlo como marca canónica.
- Los renders de 1600×224 se obtienen de una composición previa de ocho banners (no fotografías fuente independientes), por lo que podrían tener limitaciones de nitidez a escala superior.
- El contexto a derecha del header PULSE y `BrandVisible` pueden competir por ancho. No instalar globalmente hasta que Studio confirme.
- Los recursos TR provienen de marca corporativa; verificar política interna de distribución/publicación antes de subirlos a un repositorio público.

## Fix PA2231 — eventos del componente (2026-10-24)

**Incidencia real reportada por Studio:** `Custom input property of kind 'Event' requires a non-empty 'Default' formula`, cinco líneas del componente `cmp_PageHeaderHeroPro`.

**Corrección aplicada en la fuente íntegra versionada** `power-apps/components/cmp_PageHeaderHeroPro.pa.yaml`: `Default: =false` para `OnContext1Select`, `OnContext2Select`, `OnContext3Select`, `OnUtility` y `OnHelp` (las cinco propiedades `PropertyKind: Event`). Sin alteración de sus llamadas `OnSelect` ni del contrato de 32 propiedades heredadas.

**Validación estática:** 5/5 defaults no vacíos; 0 defaults vacíos en el fichero; 36/36 propiedades públicas presentes; sin nombres de control duplicados; no se introducen llamadas SQL/Power Automate.

**Gate sin cerrar:** debe importarse esta versión (no la anterior) y verificar en Power Apps Studio que **PA2231 desaparece**. No afirmar `STUDIO_PASS` ni fusionar PR hasta ejecutar esa validación, los cinco eventos y el diseño responsive.
