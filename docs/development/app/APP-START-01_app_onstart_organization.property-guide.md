# APP-START-01 — Organización de `App.OnStart`

**Estado:** PENDIENTE DE VALIDACIÓN EN POWER APPS STUDIO  
**Target:** `App` → `OnStart`  
**Operación:** sustitución completa de la fórmula actual por el candidato organizado.

## Artefactos

- Fórmula completa: `APP-START-01_App.OnStart.organized.powerfx`
- Auditoría: `APP_ONSTART_AUDIT_2026-08-14.md`

## Qué corrige

1. Elimina la segunda inicialización de Skyline.
2. Mueve los filtros `varFilter_Task*` a la sección Tasks.
3. Centraliza el contrato base de Punch List (`varPunches_FilterSource`, `varPunches_FocusPunchId`).
4. Añade `colPunchesReviewFocus` para el drill-through desde Punch Review.
5. Amplía el seed tipado de `colPunches` para que coincida con el esquema real observado en `btnPunches_LoadPage_Punches_2`.
6. Mantiene separados bootstrap global, estado de pantallas y colecciones tipadas.
7. Normaliza artefactos de Markdown presentes en el texto recibido (`*App*`, `\_`, `\*`) a sintaxis Power Fx real (`App`, `_`, `*`).
8. Conserva temporalmente los legacy view flags.
9. Conserva `varUserRole = "manager"` sin asumir todavía un backend de roles no validado; queda documentado como deuda de seguridad.

## Orden de implantación

No mezclar esta sustitución con la depuración de C17-E2A-FIX3 en una única validación.

### Gate 1 — navegación

Validar primero C17-E2A-FIX3 y confirmar:

- Punch Review → Open Punch List muestra solo el Punch actual.
- Back desde Punch List vuelve a Punch Review.
- La sesión de Review permanece intacta.

### Gate 2 — App.OnStart

Después:

1. Seleccionar `App` en Power Apps Studio.
2. Abrir propiedad `OnStart`.
3. Guardar una copia del bloque actual fuera de Studio si se desea rollback manual.
4. Sustituir el contenido completo por `APP-START-01_App.OnStart.organized.powerfx`.
5. Ejecutar **Run OnStart**.
6. Esperar a que finalicen `WarRoom_Security_IsSuperAdmin` y `WarRoom_EnabledProjects_GetActive`.
7. Comprobar que Studio no reporta errores de fórmula.

## Smoke test mínimo

Validar en este orden:

1. Home abre y muestra proyecto selector/sidebar.
2. Selección de proyecto sigue funcionando.
3. Overview abre y puede cargar PHR.
4. Punch List abre, filtros/paginación normal siguen funcionando.
5. Punch Review abre y conserva su flujo actual.
6. C17-E2A-FIX3 sigue funcionando después de ejecutar OnStart.
7. Config abre y conserva árbol/scope.
8. Skyline abre sin errores y parte de estado limpio.
9. Admin aparece únicamente cuando `varIsSuperAdmin = true`.

## No incluido en APP-START-01

No eliminar todavía duplicaciones de `scr_Home.OnVisible` ni `scr_PunchReview.OnVisible`. Esos bloques requieren una limpieza posterior e incremental (`APP-START-02`) porque modificar simultáneamente bootstrap y pantallas haría más difícil aislar regresiones.

## Confirmación esperada

`APP-START-01 integrado y Run OnStart sin errores.`
