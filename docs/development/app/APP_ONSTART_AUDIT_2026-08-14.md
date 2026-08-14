# Auditoría de `App.OnStart` — 2026-08-14

**Aplicación:** PULSE  
**Fuente auditada:** bloque `App.OnStart` facilitado desde Power Apps Studio el 14/08/2026.  
**Estado:** REVISADO — refactor preparado, pendiente de validación en Studio.

## Resumen

El `App.OnStart` actual funciona como un bootstrap global, pero ha crecido hasta mezclar cuatro responsabilidades diferentes:

1. configuración global estable de la aplicación;
2. identidad, seguridad y catálogo de proyectos;
3. inicialización tipada necesaria para Power Fx;
4. estado de ejecución específico de pantallas.

No es necesario convertir `App.OnStart` en un cargador de toda la aplicación. La dirección correcta es mantener en él únicamente el **bootstrap de sesión** y las estructuras tipadas que necesitan existir desde el arranque, dejando las cargas y el comportamiento de cada pantalla en sus respectivos `OnVisible`/servicios ocultos.

## Hallazgos

### A. Duplicidad real: Skyline

Skyline se inicializa en la sección `19) Briefing / Skyline defaults` y vuelve a inicializarse después de `22) Initialization completed`. El segundo bloque también añade `varSelectedSkylineWeek` y limpia las colecciones Skyline.

**Corrección:** una única sección Skyline antes de las colecciones tipadas y antes de marcar la inicialización como completada.

### B. Variables Tasks huérfanas al final

Después del bloque Skyline duplicado aparecen:

- `varFilter_TaskSubsystem`
- `varFilter_TaskDiscipline`
- `varFilter_TaskSubcontractor`
- `varFilter_TaskStatusId`

Son estado de Tasks y deben vivir en la sección Tasks.

### C. Contrato de navegación incompleto para Punch Review → Punch List

`varPunches_ReturnView` tiene un default válido (`Overview`), pero no existía estado inicial explícito para el drill-through desde Punch Review.

El refactor añade:

- `varPunches_FilterSource = "Manual"`
- `varPunches_FocusPunchId = Blank()`
- colección tipada `colPunchesReviewFocus`

Esto soporta C17-E2A-FIX3 sin contaminar `colPunches`.

### D. `colPunches` estaba tipada con un esquema demasiado pequeño

El loader real de Punch List trabaja con muchas más columnas que las declaradas en el seed de `App.OnStart`: WBS, TemplateId, categorías, Inspection, Subcontractor, Custom Fields metadata, comentarios, etc.

**Corrección:** el candidato organizado declara el esquema completo observado en `btnPunches_LoadPage_Punches_2`. Esto reduce inferencias ambiguas y permite que `colPunchesReviewFocus` reutilice el mismo contrato.

### E. Seguridad: `varUserRole = "manager"`

El rol funcional continúa hardcodeado como `manager`.

Esto **no se modifica en este refactor** porque no se ha validado todavía una fuente autoritativa de roles equivalente a `WarRoom_Security_IsSuperAdmin`. Sin embargo, debe considerarse deuda de seguridad: una capacidad de edición no debería depender de un rol cliente fijo si el backend dispone o va a disponer de autorización real.

### F. Flows en `App.OnStart`

Hay dos llamadas globales:

- `WarRoom_Security_IsSuperAdmin`
- `WarRoom_EnabledProjects_GetActive`

Son aceptables en el bootstrap porque determinan identidad/autorización global y el catálogo básico de proyectos. No se añaden otras cargas de negocio al `OnStart`.

### G. `Legacy view flags`

`varView_Home`, `varView_Overview`, etc. siguen inicializándose por compatibilidad, aunque la arquitectura actual utiliza `varAppView`.

**Decisión:** conservarlos por ahora y marcarlos explícitamente como LEGACY. Eliminarlos requiere una búsqueda completa de referencias y constituye otro cambio independiente.

### H. Duplicación fuera de `App.OnStart`

La revisión del código actual muestra que `scr_Home.OnVisible` vuelve a definir tokens de tema, usuario y numerosos defaults que deberían pertenecer al bootstrap global. `scr_PunchReview.OnVisible` también contiene inicializaciones de tema/página repetidas entre bloques históricos.

**No se corrige aquí.** Mezclar la limpieza de `App.OnStart`, Home y Punch Review en una misma entrega aumentaría innecesariamente el riesgo. Debe abordarse después de validar `APP-START-01`.

## Arquitectura resultante de `App.OnStart`

El candidato se reorganiza en este orden:

1. Bootstrap / responsive runtime.
2. Drawer responsive.
3. Theme tokens globales.
4. Usuario / sesión.
5. Navegación global y page identity.
6. Contexto de proyecto.
7. Seguridad global.
8. Proyectos habilitados.
9. Sidebar.
10. Loading/error/loaded flags globales.
11. PHR.
12. Tasks.
13. Punches + contrato Punch Review drill-through.
14. Drawer/comments.
15. Config.
16. Super Admin.
17. Briefing.
18. Skyline.
19. Colecciones tipadas.
20. Legacy flags.
21. Initialization completed.

## Qué se ha preservado deliberadamente

- mismos tokens visuales;
- mismos breakpoints y geometría;
- misma seguridad Super Admin;
- misma carga de proyectos;
- mismos defaults funcionales conocidos;
- mismos nombres de variables existentes;
- mismo default `varPunches_ReturnView = "Overview"`;
- mismos legacy flags;
- sin nuevos Flows.

## Qué cambia funcionalmente

Solo se introduce el estado base necesario para el nuevo contrato de navegación Punch Review → Punch List:

- `varPunches_FilterSource`;
- `varPunches_FocusPunchId`;
- `colPunchesReviewFocus`.

El resto es una reorganización/consolidación y una mejora de tipado de `colPunches`.

## Riesgo y estrategia de implantación

No sustituir `App.OnStart` al mismo tiempo que se depura C17-E2A-FIX3 sin una validación intermedia.

Orden recomendado:

1. validar C17-E2A-FIX3;
2. guardar/publicar una versión estable;
3. sustituir `App.OnStart` por el candidato `APP-START-01_App.OnStart.organized.powerfx`;
4. ejecutar **Run OnStart**;
5. comprobar errores de fórmula;
6. validar Home, Overview, Punch List, Punch Review, Config y Skyline;
7. solo después considerar `APP-START-01` integrado.

## Siguiente limpieza recomendada, fuera de alcance

`APP-START-02` debería auditar qué inicializaciones de `scr_Home.OnVisible` y `scr_PunchReview.OnVisible` ya están cubiertas por `App.OnStart`, eliminando duplicados pantalla por pantalla sin alterar comportamiento.
