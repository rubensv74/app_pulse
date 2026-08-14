# APP-START-02 — Limpieza de ownership entre `App.OnStart` y `Screen.OnVisible`

**Estado:** HOME VALIDATED · PUNCH REVIEW PENDING  
**Tipo:** property/formula guide  
**Ámbito:** `App.OnStart`, `scr_Home.OnVisible`, `scr_PunchReview.OnVisible`.

## Objetivo

Reducir `OnVisible` a responsabilidades de pantalla y evitar resets cruzados. Este bloque no cambia flows, backend, layout ni contratos funcionales ya validados.

Artefactos:

- `APP-START-02_STATE_OWNERSHIP_MATRIX.md`
- `APP-START-02_scr_Home.OnVisible.powerfx`
- `APP-START-02_scr_PunchReview.OnVisible.powerfx`

---

## Estado de validación

### Home — VALIDATED IN STUDIO

Validado el 2026-08-14 después de aplicar `APP-START-02-FIX1_overview_navigation_guard.property-guide.md`.

Resultado:

- Home mantiene su estado propio sin volver a inicializar subsistemas ajenos.
- Home → Overview funciona.
- Home → Skyline y retorno funcionan.
- El guard circular de Overview quedó eliminado: la navegación solo exige un proyecto activo y la pantalla destino resuelve su propio estado/configuración.

### Punch Review — PENDING

Siguiente gate: reemplazo completo de `scr_PunchReview.OnVisible` y validación aislada de persistencia de sesión.

---

## Orden obligatorio

### PASO 1 — Completar `App.OnStart`

En la sección **01) Runtime / responsive layout**, después de los breakpoints existentes, añadir:

```powerfx
Set(varIsMobile, App.Width < 900);
Set(varIsTablet, App.Width >= 900 && App.Width < 1400);
Set(varIsDesktop, App.Width >= 1400);
```

En la sección **05) Navigation / page defaults**, después de:

```powerfx
Set(varHomeViewMode, "DASHBOARD");
```

añadir:

```powerfx
Set(varHomeDashboard, "PUNCHES");
```

No añadir aquí colecciones Home ni Punch Review session state.

> Si `APP-START-01-FIX1` ya está aplicado en Studio, conservarlo exactamente. APP-START-02 no lo sustituye.

Ejecutar **Run OnStart** y comprobar que no aparecen errores de fórmula antes de continuar.

---

## PASO 2 — Sustituir `scr_Home.OnVisible` completo

Target:

`Screens → scr_Home → OnVisible`

Operación:

**REPLACE FORMULA COMPLETELY** usando:

`docs/development/app/APP-START-02_scr_Home.OnVisible.powerfx`

### Qué se elimina expresamente

- todos los `varTheme_*`;
- user/email bootstrap;
- responsive bootstrap;
- `varProjectLoaded` derivado en OnVisible;
- resets de `varGlobal*`;
- resets de `varOps_*`, `varPHR_*`, `varCfg_*`;
- defaults de Skyline;
- `varBriefingEmailVisible`;
- selected Overview cell reset;
- PHR dimensions.

### Qué se conserva

- identidad Home;
- palette de disciplinas;
- typed collections Home;
- Search / Quick filter / Density / Sort / columns;
- Executive grid runtime;
- Hive-specific tokens y UI defaults;
- selected Hive node/subsystem;
- estado Executive Dashboard propio de Home.

---

## PASO 3 — Validación aislada de Home — VALIDATED

1. Entrar en Home con proyecto activo.
2. Confirmar KPIs, heatmap, discipline distribution y grid.
3. Cambiar algún filtro/selección Home.
4. Navegar a Overview y volver a Home.
5. Confirmar que Home conserva su estado válido.
6. Confirmar que volver a Home no fuerza a cero PHR/Overview.
7. Navegar a Skyline y volver a Home; volver a Skyline.
8. Confirmar que Home no resetea Skyline.

Incidencia detectada y corregida durante este gate:

`APP-START-02-FIX1 — Overview navigation guard`.

El sidebar no debe consultar `varProjectHasPHRData` como prerrequisito para navegar a Overview, porque ese estado se determina en la propia pantalla destino.

---

## PASO 4 — Sustituir `scr_PunchReview.OnVisible` completo

Target:

`Screens → scr_PunchReview → OnVisible`

Operación:

**REPLACE FORMULA COMPLETELY** usando:

`docs/development/app/APP-START-02_scr_PunchReview.OnVisible.powerfx`

### Qué se elimina expresamente

- dos bloques duplicados de fallback `varTheme_*`;
- segunda copia de identidad `PunchReview`;
- segunda copia de `Source/ReturnScreen` defaults.

### Qué se conserva

- host state DF-05/DF-06;
- modal editor cerrado al reentrar;
- caller-owned `Source/Return/Template` con fallback solo si están en blanco;
- typed collections de review inicializadas una sola vez;
- queue y Session Activity persistentes;
- current Punch/current index persistentes;
- Comments y Custom Fields runtime;
- Dirty Guard state;
- queue projection y resolución de current record.

### Ajuste deliberado

`varPunchReviewHelpLanguage` pasa de:

`Set(..., "ES")` en cada entrada

a inicialización guarded. Si el usuario cambia a English, el idioma se conserva durante la sesión.

---

## PASO 5 — Validación aislada de Punch Review

Validar en este orden:

1. Home → Punch Review con queue contextual.
2. Confirmar template heredado correcto.
3. Mark Reviewed en Punch A.
4. Ir a Punch B y realizar otra acción.
5. Confirmar Session Activity con múltiples eventos.
6. Punch Review → Open Punch List.
7. Confirmar Focus Mode con una sola fila.
8. Back → Punch Review.
9. Confirmar mismo current Punch, misma queue, reviewed marks y Session Activity.
10. Abrir Manage Custom Fields, cerrar y volver a abrir.
11. Validar Active/Inactive.
12. Modificar un Custom Field value y validar Dirty Guard.
13. Abrir Help, cambiar a English, cerrar, navegar fuera y volver; el idioma debe seguir EN durante la sesión.

---

## PASO 6 — Smoke test de aplicación

Después de ambos PASS:

1. Home.
2. Overview.
3. Punch List normal.
4. Punch Review.
5. Punch Review → Punch List focus → Punch Review.
6. Briefing.
7. Skyline.
8. Config.
9. Admin si el usuario es Super Admin.

No hace falta recargar flows salvo los que cada pantalla ejecuta normalmente.

---

## Regla de rollback

Si Home falla, restaurar solo su `OnVisible` anterior.  
Si Punch Review falla, restaurar solo su `OnVisible` anterior.  
No revertir `APP-START-01` completo ni los FIX C17/DF ya validados.

## Criterio de cierre

Confirmación esperada:

`APP-START-02 integrado y smoke test sin regresiones.`

Solo entonces actualizar los candidatos del repositorio a `VALIDATED` y continuar con `C17-E2B — 1600×900`.
