# Punch Import — Power Apps Source Code compatibility and lessons learned

**Estado:** activo  
**Ámbito:** `scr_PunchImport` y sus bloques incrementales.

## Gate obligatorio pre-YAML

Antes de crear, corregir o publicar cualquier `.pa.yaml` de Punch Import deben consultarse:

1. `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` como registro maestro de compatibilidad PULSE;
2. este archivo como registro local de Punch Import.

Las reglas del registro maestro se heredan íntegramente. Entre ellas: no `Radius*` en `Label@2.5.1`, no `AccessibleLabel` en `Classic/Button@2.2.0`, no `Reset()` sobre controles no confirmados, tipado inequívoco de variables nuevas, CanvasComponent solo si está instalado, no SVG inline improvisado, JSON mediante `JSON()` cuando corresponda y raíz Source Code válida.

---

## PR-IMP-SC-001 — `PA1001` por propiedad raíz `Details`

**Fecha:** 2026-08-17  
**Bloque:** `PR-IMP-C04A_scr_PunchImport_shell.pa.yaml`  
**Session ID:** `39c81a9f-7ef6-48b0-b4a3-ea42d9d50f89`

### Error

```text
error PA1001 : An error occurred while parsing PaYaml.
Error code: YamlInvalidSyntax;
Reason: Property 'Details' not found on type 'Microsoft.PowerPlatform.PowerApps.Persistence.PaYaml.Models.SchemaV3.PaModule'.
```

### Diagnóstico

El artefacto fuente verificado en GitHub comienza con `Screens:` y no contiene `Details:`. El parser, sin embargo, informó que recibió `Details` como propiedad raíz. Esto sitúa el fallo en el límite de copy/paste: se introdujo texto distinto o adicional al módulo Source Code antes de que Studio pudiera evaluar los controles internos.

### Corrección

- el bloque C04A incorpora una cabecera de comentarios que identifica la primera clave válida `Screens:`;
- la guía entrega un enlace Raw directo;
- antes de pegar se verifica que no existan `Details:`, `Note:` ni `Session ID:` en el clipboard;
- no se modifica la arquitectura interna por un fallo que ocurre antes de interpretar `Screens:`;
- C04B permanece bloqueado hasta revalidar C04A.

### Regla preventiva

Para todo bloque completo pegable de Punch Import:

1. entregar enlace GitHub normal y enlace Raw;
2. indicar explícitamente la primera clave real esperada del esquema;
3. copiar únicamente el archivo Raw completo;
4. nunca copiar junto al YAML mensajes de error, documentación o texto del chat;
5. si `PA1001` denuncia una propiedad raíz que no existe en el archivo fuente, verificar primero el límite de copia antes de alterar controles o Power Fx.

### Estado

```text
RESUELTO — C04A/C04B aceptados por Power Apps Studio el 2026-08-17.
```

---

## PR-IMP-UX-001 — Contexto del header oculto por altura insuficiente en breakpoint apilado

**Fecha:** 2026-08-17  
**Bloque:** `PR-IMP-C04B_scr_PunchImport_header.pa.yaml`

### Síntoma

Power Apps Studio aceptó el YAML y renderizó el header, pero en un ancho inferior a 1400 px solo se veía la identidad de la pantalla y el banner `COMMENTS ONLY · V1`. Las tarjetas de Project, Punch template, Batch status y el botón Back quedaban ocultos.

### Causa

`conPI_HeaderMain` cambia a `LayoutDirection.Vertical` cuando `App.Width < 1400`. Sus hijos necesitan aproximadamente:

```text
68 px  HeaderIdentity
58 px  HeaderContext
10 px  LayoutGap
= 136 px mínimos
```

La primera versión asignaba `Height = 128`, de modo que el segundo hijo quedaba recortado. El contenedor padre `conPI_HeaderCard` también quedaba demasiado justo para sumar header apilado, banner, gap y paddings.

### Corrección

```powerfx
conPI_HeaderMain.Height = If(App.Width < 1400, 142, 78)
conPI_HeaderCard.Height = If(App.Width < 1400, 206, 136)
```

### Regla preventiva

Cuando un AutoLayout cambie de horizontal a vertical por breakpoint, calcular explícitamente la altura mínima como suma de las alturas de sus hijos + gaps + paddings. No reutilizar una altura pensada para layout horizontal.

### Estado

```text
CORREGIDO EN REPOSITORIO — pendiente de revalidación visual en Studio.
```

---

## Checklist Punch Import antes de cada YAML

- [ ] Registro maestro consultado inmediatamente antes de redactar/corregir.
- [ ] Registro local consultado inmediatamente antes de redactar/corregir.
- [ ] Raíz Source Code verificada para el contexto real de Studio.
- [ ] Enlace Raw preparado si el artefacto se entrega por copy/paste.
- [ ] No hay propiedades incompatibles heredadas del registro maestro.
- [ ] Si un AutoLayout cambia de dirección por breakpoint, su altura cubre hijos + gaps + paddings.
- [ ] No se avanza sobre un bloque con error abierto.
