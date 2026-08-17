# PR-IMP-C04E — Premium Upload Surface

**Responsabilidad única:** sustituir el workspace sintético de C04C por la superficie premium del paso Upload, manteniendo todavía sin conectar la ingestión real del fichero, Power Automate y SQL.

## Dependencias

- C04A Shell — PASS.
- C04B Header — PASS.
- C04C Stepper — PASS.
- C04D Runtime State — PASS.

## Por qué C04E todavía es sintético

Este gate valida primero la experiencia visual y los estados de fichero. La ingestión real del Excel se conecta en C05 junto con el contrato Power Automate/backend, para no mezclar UI con infraestructura.

El botón `Choose Excel file` de C04E carga un workbook sintético:

`PULSE_Punches_INTERNAL_sample.xlsx`

No abre el dispositivo y no sube ningún archivo todavía.

## Aplicación en Studio

1. Abre `scr_PunchImport` > **Source Code**.
2. Localiza el último control dentro de `conPI_ContentShell > Children`:

   `- conPI_WorkspaceMarker:`

3. Como es el último control del módulo, elimina desde esa línea hasta el final del archivo.
4. Copia **completo** el archivo `PR-IMP-C04E_upload_surface.replace-workspace.txt` y pega el bloque en ese mismo lugar.
5. Guarda y espera la validación de Studio.
6. Ejecuta App Checker.
7. Abre la pantalla.

No modifiques `OnVisible`: debe mantenerse el C04D ya validado.

## Gate visual inicial

Con `varPunchImportHasFile = false` debe verse:

- `STEP 1 / UPLOAD`;
- `Choose an import-ready Excel file`;
- card principal de selección;
- `Choose Excel file`;
- panel `Before you continue`;
- footer `No workbook selected`;
- botón `Validate file` deshabilitado.

## Gate sintético de fichero seleccionado

Pulsa `Choose Excel file`.

Debe ocurrir únicamente en cliente:

- aparece `PULSE_Punches_INTERNAL_sample.xlsx`;
- tamaño `184 KB`;
- estado `Workbook ready for validation`;
- `Validate file` queda habilitado;
- no cambia el stepper;
- no se llama a Flow ni SQL.

Al pulsar `Validate file` solo debe aparecer el mensaje:

`Stage/Validate backend connection arrives in PR-IMP-C05.`

## STOP

Ante cualquier error de Source Code o App Checker, no avanzar a C05. Enviar mensaje exacto y Session ID.

## Siguiente gate

`PR-IMP-C05 — Real file ingestion + Stage/Validate integration`.
