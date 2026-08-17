# PR-IMP-C04A — scr_PunchImport screen shell

**Responsabilidad única:** crear la nueva pantalla y validar únicamente su shell base.  
**Estado:** corregido tras incidente `PA1001`; pendiente de revalidación en Power Apps Studio.  
**Idioma de operación:** español.  
**UI de PULSE:** inglés.

## 1. Artefacto

Usar exclusivamente el módulo completo:

`docs/development/screens/punch-import/blocks/PR-IMP-C04A_scr_PunchImport_shell.pa.yaml`

Raw copy:

`https://raw.githubusercontent.com/rubensv74/app_pulse/feature/pr-exp-c03-exact-review-queue/docs/development/screens/punch-import/blocks/PR-IMP-C04A_scr_PunchImport_shell.pa.yaml`

No insertar fragmentos parciales y no copiar el texto de esta guía ni un mensaje de error de Power Apps.

## 2. Gate de copia antes de pegar

Antes de sustituir el Source Code, verifica visualmente el contenido copiado:

- puede comenzar por comentarios YAML que empiezan por `#`;
- la primera clave real del esquema debe ser exactamente `Screens:`;
- inmediatamente debajo debe aparecer `scr_PunchImport:`;
- no debe existir una clave raíz `Details:`;
- tampoco deben aparecer `Note:` o `Session ID:` procedentes de una salida de error de Studio.

El incidente `PA1001` con Session ID `39c81a9f-7ef6-48b0-b4a3-ea42d9d50f89` indicó expresamente que Studio recibió `Details` como propiedad raíz de `PaModule`. El archivo fuente verificado del repositorio no contiene esa propiedad; por tanto, este gate protege el límite de copia/pegado.

## 3. Qué contiene

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

## 4. Aplicación en Studio

1. Abre PULSE en Power Apps Studio.
2. Crea una pantalla nueva vacía.
3. Nómbrala `scr_PunchImport`.
4. Abre el editor **Source Code** de esa pantalla.
5. Abre el enlace Raw del artefacto C04A.
6. Copia todo el contenido del Raw.
7. Comprueba que la primera clave real es `Screens:` y que no existe `Details:`.
8. Sustituye completamente el contenido del editor Source Code por ese texto.
9. Guarda.
10. Espera a que Studio termine de validar.
11. Ejecuta App Checker.
12. Navega temporalmente a `scr_PunchImport` para validar el render.

Si Studio devuelve otro error, no adaptes el YAML a mano. Detente y devuelve el mensaje exacto y Session ID.

## 5. Gate esperado

Debe verse:

- sidebar PULSE a la izquierda;
- fondo general PULSE;
- una única card blanca premium ocupando el workspace;
- eyebrow `PUNCH REVIEW / DATA EXCHANGE`;
- título `Import comment updates`;
- texto indicando que el shell está preparado.

## 6. Criterios PASS

- no error `PA1001` / `YamlInvalidSyntax`;
- no error `PA2108`;
- no error `PA2301` para `cmp_SidebarNav`;
- `scr_PunchImport` guarda correctamente;
- App Checker no introduce un error nuevo provocado por C04A;
- sidebar y card se renderizan correctamente.

## 7. Criterio de parada

Ante cualquier error, no implementar C04B.

Enviar:

- captura;
- texto exacto del error;
- Session ID si Studio lo muestra.

La corrección se hará primero sobre el archivo fuente o el procedimiento de entrega del bloque, según la causa confirmada.

## 8. Siguiente bloque tras PASS

`PR-IMP-C04B — Premium header + project/template/batch context + back action + Comments-only banner`.