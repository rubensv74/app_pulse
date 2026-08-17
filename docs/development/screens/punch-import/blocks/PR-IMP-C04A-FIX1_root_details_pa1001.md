# PR-IMP-C04A-FIX1 — PA1001 root `Details`

**Fecha:** 2026-08-17  
**Bloque:** `PR-IMP-C04A_scr_PunchImport_shell.pa.yaml`  
**Session ID:** `39c81a9f-7ef6-48b0-b4a3-ea42d9d50f89`  
**Estado:** corregido el procedimiento de entrega; pendiente de revalidación en Power Apps Studio.

## Error recibido

```text
Details:
error PA1001 : An error occurred while parsing PaYaml. Error code: YamlInvalidSyntax; Reason: Property 'Details' not found on type 'Microsoft.PowerPlatform.PowerApps.Persistence.PaYaml.Models.SchemaV3.PaModule'.

Note:
Make sure to use the Source Code schema, which is the only supported format.

Session ID: 39c81a9f-7ef6-48b0-b4a3-ea42d9d50f89
```

## Diagnóstico

El parser indica que recibió una propiedad raíz llamada `Details`.

El artefacto fuente verificado en GitHub comienza con la raíz válida `Screens:` y no contiene ninguna clave `Details:`. Por tanto, el fallo confirmado en este incidente está en el límite de copia/pegado: Studio recibió texto adicional o distinto del módulo Source Code publicado.

No se atribuye el fallo a propiedades internas del shell porque el parser se detuvo antes de interpretar `Screens:`.

## Corrección aplicada

1. Se revalidó la versión vigente de `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` antes de tocar el YAML.
2. El YAML C04A incorpora ahora una cabecera de comentarios que marca explícitamente el límite de copia.
3. La guía de implementación obliga a usar el enlace Raw y comprobar que la primera clave real sea `Screens:`.
4. Se prohíbe copiar al editor Source Code cualquier salida de error que contenga `Details:`, `Note:` o `Session ID:`.
5. No se avanza a C04B hasta que Studio acepte C04A.

## Regla preventiva

Para todo módulo `.pa.yaml` entregado mediante copy/paste:

- facilitar un enlace Raw directo;
- indicar la primera clave real esperada del esquema;
- comprobar antes de pegar que el clipboard no contiene cabeceras de chat, documentación o errores de Studio;
- si el parser denuncia una propiedad raíz ajena al archivo fuente, verificar primero el límite de copia antes de modificar controles internos.

## Gate de revalidación

Abrir el Raw de C04A, copiar todo, sustituir completamente el Source Code de `scr_PunchImport` y guardar.

PASS:

```text
No PA1001
No YamlInvalidSyntax
scr_PunchImport accepted by Studio
```