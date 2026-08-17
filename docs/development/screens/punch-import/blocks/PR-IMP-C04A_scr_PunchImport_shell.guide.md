# PR-IMP-C04A — scr_PunchImport screen shell

**Responsabilidad única:** crear la nueva pantalla y validar únicamente su shell base.  
**Estado:** publicado; pendiente de validación en Power Apps Studio.  
**Idioma de operación:** español.  
**UI de PULSE:** inglés.

## 1. Artefacto

Usar el módulo completo:

`docs/development/screens/punch-import/blocks/PR-IMP-C04A_scr_PunchImport_shell.pa.yaml`

No insertar fragmentos parciales de este archivo.

## 2. Qué contiene

Solo contiene:

- pantalla `scr_PunchImport`;
- tema mínimo seguro en `OnVisible`;
- identidad de página;
- `conPI_ScreenRoot`;
- `cmpPI_Sidebar` usando `cmp_SidebarNav`;
- `conPI_ContentShell`;
- una card temporal `conPI_ShellMarker` para comprobar el render.

No contiene:

- Flow;
- SQL;
- importación de ficheros;
- variables de batch;
- stepper;
- preview;
- commit;
- escritura de comentarios.

## 3. Aplicación en Studio

1. Abre PULSE en Power Apps Studio.
2. Crea una pantalla nueva vacía.
3. Nómbrala `scr_PunchImport`.
4. Abre el editor **Source Code** de esa pantalla.
5. Sustituye el contenido por el módulo completo de C04A conforme al flujo de Source Code que estés utilizando para los bloques actuales.
6. Guarda.
7. Espera a que Studio termine de validar.
8. Ejecuta App Checker.
9. Navega temporalmente a `scr_PunchImport` para validar el render.

Si Studio espera únicamente el cuerpo de la pantalla en lugar de la raíz `Screens:`, no adaptes el archivo a mano: detente y devuelve el mensaje exacto. El artefacto se corregirá en el repositorio según el esquema real aceptado por Studio.

## 4. Gate esperado

Debe verse:

- sidebar PULSE a la izquierda;
- fondo general PULSE;
- una única card blanca premium ocupando el workspace;
- eyebrow `PUNCH REVIEW / DATA EXCHANGE`;
- título `Import comment updates`;
- texto indicando que el shell está preparado.

## 5. Criterios PASS

- no error `PA1001` / `YamlInvalidSyntax`;
- no error `PA2108`;
- no error `PA2301` para `cmp_SidebarNav`;
- `scr_PunchImport` guarda correctamente;
- App Checker no introduce un error nuevo provocado por C04A;
- sidebar y card se renderizan correctamente.

## 6. Criterio de parada

Ante cualquier error, no implementar C04B.

Enviar:

- captura;
- texto exacto del error;
- Session ID si Studio lo muestra.

La corrección se hará primero sobre el archivo fuente del repositorio.

## 7. Siguiente bloque tras PASS

`PR-IMP-C04B — Premium header + project/template/batch context + back action + Comments-only banner`.