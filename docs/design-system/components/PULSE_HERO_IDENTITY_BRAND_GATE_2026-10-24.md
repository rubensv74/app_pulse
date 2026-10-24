# PULSE-HERO — Gate de identidad gráfica (2026-10-24)

**Estado:** `VISUAL_IDENTITY_FIX_REQUIRED`. No promover ningún hero con logotipos generados a Studio ni fusionarlo a `main`.

## Verificación: PULSE

Evidencia de referencia: captura anterior de la aplicación PULSE (`Interfaz de control de PULSE.png`), en el sidebar, y decisiones del usuario del 26/06/2026:
- **sí**: onda de pulso eléctrico en cian, aislada, sobre la palabra espaciada `PULSE`, con extremo de línea ascendente;
- **no**: letra P integrada en el símbolo, doble P, símbolo hexagonal previo ni variante orbital anterior.
- La pantalla de la tanda *Objeto protagonista* había generado incorrectamente la P de marca mezclada con un latido. La corrección del concepto visual ahora propone onda aislada, pero no se certifica igualdad bit a bit con el logo original.

**Contrato de producción:** preferir un logotipo de marca importado en Media y renderizado como `Image` por la pantalla/componente; **nunca regenerar el logotipo con IA** en cada hero. Debe recuperarse el asset original de Power Apps Studio / biblioteca de diseño y versionarse una vez con su fuente permitida.

## Verificación: Técnicas Reunidas

Referencias: documentación corporativa de TR y logotipo incrustado en `Control Asistencia 1475 - 2 - HCS Training.pdf` (fuente facilitada previamente por el usuario). El emblema real contiene las letras `tr` entrelazadas según contornos geométricos definidos, con firma `TECNICAS REUNIDAS` debajo cuando se reproduce completo.

Los logotipos improvisados por los modelos gráficos en los cascos de las ilustraciones no cumplen: las formas de la r/t y la tipografía se deforman, y el texto resulta impreciso a pocos píxeles. **El resultado generado no es un recurso corporativo fiel.** Se inspeccionó además `app-tms/main/assets/heroes/tms-hero-trainees.jpg` recuperado de archivos anteriores: esa imagen concreta muestra cascos neutros, por lo que NO acredita una versión maestra de la marca TR. No afirmar lo contrario.

**Contrato de producción:** aplicar el logo TR verdadero como decal/superposición desde el asset corporativo autorizado con perspectiva adecuada. La mera aproximación generativa queda prohibida en los hero que muestren la marca. Si la geometría a 112 px es demasiado pequeña, usar casco sin marca en vez de una marca falsa.

## Estado de propuestas

- Dirección **Objeto protagonista** aceptada por el usuario como nuevo punto de partida: Home, Overview, Tasks, Punch List, Punch Review, Briefing, Config y Skyline.
- La imagen candidata `PULSE` corregida en el hilo de 24/10 sigue siendo visual preliminar, no prueba de marca fiel en casco.
- El manifiesto V2 anterior es de estilo industrial narrativo y se mantiene como **superseded**; no instalar ni mapear por defecto a las pantallas.
- El componente `cmp_PageHeaderHeroPro` es independiente de la ilustración y debe superar sus gates de Studio antes de cualquier adopción.

## Orden del próximo gate

1. Recuperar asset maestro de PULSE del entorno donde se diseñó y registrar URI/MediaName.
2. Utilizar el monograma TR auténtico, no una recreación del generador, y verificar autorización de uso.
3. Editar la nueva serie de heroes para eliminar marcas generadas; incorporar TR cuando proceda, mediante composición exacta.
4. Mantener títulos, filtros, cifras y PULSE como controles/activos separados, no como arte en el JPG.
5. Ensayar 112px en Power Apps, comprobar branding y transiciones/responsive antes de elevar a `PASS`.

**La PR queda en draft.**
