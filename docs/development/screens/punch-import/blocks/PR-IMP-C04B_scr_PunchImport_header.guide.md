# PR-IMP-C04B — Premium header + context

**Responsabilidad única:** sustituir el marker visual de C04A por el encabezado premium de `scr_PunchImport`, manteniendo todavía sin conectar Flow, SQL, upload, preview ni commit.

## Qué añade

- identidad `PUNCH REVIEW / DATA EXCHANGE`;
- título `Import comment updates`;
- contexto de Project;
- contexto de Punch template;
- contexto `Batch status`;
- botón `Back to Punch Review`;
- banner de política `COMMENTS ONLY · V1`;
- workspace inferior aún sintético.

## Estado sintético de este bloque

`varPunchImportBatchStatus` se inicializa deliberadamente a `NOT_STARTED`.

`varPunchImportTemplateLabel` se resuelve desde `colPunchTemplates_Filter` usando `varPunchReviewTemplateId`, para mostrar al usuario la etiqueta funcional del template y no el ID técnico.

## Revisión FIX2 — contexto siempre visible

La primera versión compilaba, pero el bloque de Project / Template / Batch / Back podía quedar fuera del área visible del header en el viewport efectivo de Studio. Aumentar únicamente la altura no resolvió el problema.

La versión actual usa tres filas explícitas dentro del header:

1. `conPI_HeaderIdentityRow` — identidad y título;
2. `conPI_HeaderContextRow` — Project, Punch template, Batch status y Back;
3. `conPI_SafetyBanner` — política `COMMENTS ONLY · V1`.

`conPI_HeaderContextRow` tiene altura propia y scroll horizontal de seguridad, de modo que el contexto obligatorio no depende de una conmutación responsive del mismo contenedor que la identidad.

## Aplicación en Power Apps Studio

1. Abre `scr_PunchImport`.
2. Abre **Source Code** de la pantalla.
3. Sustituye TODO el módulo actual por el archivo completo `PR-IMP-C04B_scr_PunchImport_header.pa.yaml`.
4. La primera clave de esquema real debe ser `Screens:`.
5. Guarda.
6. Espera la validación de Studio.
7. Ejecuta App Checker.
8. Navega a `scr_PunchImport` y valida visualmente.

No pegues texto del chat ni mensajes de error dentro de Source Code.

## Gate visual esperado

Debe verse el sidebar PULSE, header blanco premium, eyebrow, Project funcional, Punch template funcional, Batch status `NOT STARTED`, botón Back y banner `COMMENTS ONLY · V1`.

## PASS

- No `PA1001`.
- No `PA2108`.
- No `PA2301` para `cmp_SidebarNav`.
- App Checker no introduce un error nuevo por C04B.
- Project y template muestran contexto funcional.
- `Project`, `Punch template`, `Batch status` y `Back to Punch Review` son visibles simultáneamente en la fila de contexto.
- Back vuelve correctamente a Punch Review.

## STOP

Ante cualquier error o si falta alguna de las cuatro superficies de contexto, no avanzar a C04C.

## Siguiente bloque tras PASS

`PR-IMP-C04C — 4-step progress header (Upload / Preview / Confirm / Result) + synthetic step state`.
