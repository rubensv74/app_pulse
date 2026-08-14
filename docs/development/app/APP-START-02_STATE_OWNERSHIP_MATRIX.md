# APP-START-02 — State ownership matrix

**Estado:** READY FOR STUDIO VALIDATION  
**Fecha:** 2026-08-14  
**Ámbito:** `App.OnStart`, `scr_Home.OnVisible`, `scr_PunchReview.OnVisible`.

## Objetivo

Eliminar inicializaciones duplicadas y, sobre todo, impedir que la mera navegación a una pantalla modifique estado perteneciente a otra pantalla o a otro dominio funcional.

La regla de arquitectura es:

> **Bootstrap global en `App.OnStart`; identidad de pantalla en `Screen.OnVisible`; estado de dominio en su pantalla/servicio propietario; estado de navegación contextual en el caller; mutaciones de proyecto en el commit de cambio de proyecto.**

`OnVisible` no debe convertirse en un segundo `OnStart`.

---

## Hallazgos actuales

### `scr_Home.OnVisible`

El bloque actual mezcla cinco responsabilidades distintas:

1. bootstrap propio de Home;
2. theme y usuario globales;
3. estado responsive global;
4. resets de Overview/PHR/Skyline/Briefing;
5. estado de proyecto y loading global.

Esto provoca side effects al volver a Home. Ejemplos a retirar de `scr_Home.OnVisible`:

- `varTheme_*`;
- `varCurrentUserEmail` / `varCurrentUserName`;
- `varOps_*`, `varPHR_*`, `varCfg_*` y `varSkyline*` ajenos a Home;
- `varBriefingEmailVisible`;
- `varProjectLoaded` derivado implícitamente de `varProjectId`;
- resets globales de loading/error.

`btnHome_ProjectChange_Commit_2` ya es el propietario correcto de `varProjectId`, `varSelectedProject`, `varProjectCode`, `varProjectName`, `varProjectDescription` y `varProjectLoaded`.

### `scr_PunchReview.OnVisible`

El bloque actual contiene dos veces:

- fallback de theme;
- identidad `PunchReview`;
- defaults de `varPunchReviewSource` / `varPunchReviewReturnScreen`.

Además, conviven correctamente dos clases de estado que no deben mezclarse:

- **session state**: queue, reviewed marks, Session Activity, current Punch;
- **transient modal state**: editor visible, last saved id, host scratch.

La session state debe sobrevivir a `Punch Review → Punch List → Punch Review`.

---

## Matriz de propiedad

| Estado | Owner | Inicialización | Regla |
|---|---|---|---|
| `varTheme_*`, `gblAppColors` | `App.OnStart` | una vez por sesión | Nunca redefinir en una pantalla |
| usuario / email / role / seguridad | `App.OnStart` | una vez por sesión | Nunca redefinir en Home |
| breakpoints / responsive aliases | `App.OnStart` o fórmulas directas `App.Width` | bootstrap | No depender de haber visitado Home |
| sidebar items | `App.OnStart` | bootstrap | Shared app state |
| proyecto seleccionado | `btnHome_ProjectChange_Commit_2` | al cambiar proyecto | `OnVisible` no deduce ni reescribe `varProjectLoaded` |
| invalidación de datos dependientes de proyecto | project-change commit / `APP-START-01-FIX1` | al cambiar/resetear proyecto | Reset transaccional con el proyecto |
| identidad de pantalla `varAppView`, `varPage*` | pantalla visible | cada entrada | Es correcto asignarlo en `OnVisible` |
| `varHomeDashboard` | `App.OnStart` como default + acciones Home | bootstrap + interacción | Home no debe devolverlo a PUNCHES al volver |
| Home grid/heatmap/donut collections | Home | primera entrada / load actions | Bootstrap tipado con guardas |
| Home search/sort/density/columns | Home | primera entrada | Preservar al navegar fuera y volver |
| Home Hive selected node/subsystem | Home | primera entrada / acciones | No resetear si ya existe selección válida |
| `varOps_*`, `varPHR_*` | Overview/PHR | sus propias pantallas/servicios | Home no los toca |
| `varSkyline*` | Skyline | `App.OnStart` bootstrap + Skyline runtime | Home no los toca |
| `varBriefingEmailVisible` | Briefing | `App.OnStart`/Briefing | Home no lo toca |
| Punch Review source/return/template | caller + PunchReview fallback | antes de `Navigate`; fallback si blank | `OnVisible` no debe sobrescribir un caller válido |
| Punch Review queue | caller / session | al iniciar review context | `OnVisible` no la vacía si ya contiene filas |
| reviewed marks | Punch Review session | acciones Mark/Undo | persisten durante la sesión |
| `colPunchReviewSessionEvents` | Punch Review session | bootstrap una vez | persiste entre Punches y drill-through |
| Punch Review current index/record | Punch Review | primera entrada + queue actions | preservar al volver de Punch List |
| Comments / Custom Field values | Punch Review current Punch | load/save services | no reset global |
| Custom Fields definition modal visibility | Punch Review screen | cada entrada | puede cerrarse al reentrar |
| Custom Fields host scratch | Punch Review editor host | init local / eventos | no pertenece a App global |
| Help language | Punch Review user preference | primera entrada | no volver siempre a ES |
| Help visibility | Punch Review screen | cada entrada | cerrar al reentrar es correcto |

---

## Cambios APP-START-02

### A. `App.OnStart`

Añadir explícitamente el default de dashboard Home y los aliases responsive existentes antes de retirarlos de Home:

- `varHomeDashboard = "PUNCHES"`;
- `varIsMobile`;
- `varIsTablet`;
- `varIsDesktop`.

No mover a `App.OnStart` las colecciones específicas de Home ni la session state de Punch Review.

### B. `scr_Home.OnVisible`

Conservar únicamente:

- identidad de pantalla;
- palette y bootstrap tipado de Home;
- defaults Home guarded;
- columnas del grid;
- estado Executive Dashboard propio de Home;
- Hive UI state;
- selected Hive node/subsystem.

Eliminar theme, user, project derivation, global loading/error resets, PHR, Overview, Briefing y Skyline.

### C. `scr_PunchReview.OnVisible`

Conservar:

- identidad de pantalla una sola vez;
- contrato source/return/template sin sobrescribir caller válido;
- estado host de Custom Fields;
- typed collections guardadas;
- runtime/session variables guardadas;
- proyección de queue y current record.

Eliminar los dos bloques duplicados de theme y la segunda copia de identidad/source/return.

Cambiar `varPunchReviewHelpLanguage` a inicialización guarded para conservar el idioma durante la sesión.

---

## Invariantes de validación

Después de APP-START-02:

1. `Run OnStart` sigue dejando Home operativo y sin proyecto/datos heredados.
2. Seleccionar proyecto reconstruye Home normalmente.
3. Home → Overview → Home no resetea estado PHR/Overview por el simple hecho de volver a Home.
4. Home → Skyline → Home → Skyline no reinicia Skyline desde Home.
5. Home → Punch Review conserva template/contexto.
6. Mark/Undo en Punch Review sigue acumulando Session Activity.
7. Punch Review → Punch List focus → Back conserva queue, current Punch y Session Activity.
8. Abrir/cerrar editor Custom Fields continúa funcionando.
9. Dirty Guard continúa funcionando.
10. Ningún cambio requiere nuevos flows ni backend.

## Criterio de cierre

`APP-START-02 = VALIDATED` únicamente después de validar en Power Apps Studio los dos `OnVisible` candidatos y el pequeño ajuste de `App.OnStart`.