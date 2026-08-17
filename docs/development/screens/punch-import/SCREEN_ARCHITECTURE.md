# PULSE — scr_PunchImport architecture

**Pantalla:** `scr_PunchImport`  
**Objetivo:** importar comentarios desde un workbook INTERNAL gobernado, previsualizar cambios y aplicar únicamente comentarios autorizados.  
**Patrón:** pantalla independiente, construida desde cero por bloques pequeños.  
**Validación:** Power Apps Studio + App Checker.

## 1. Arquitectura objetivo

```text
scr_PunchImport
└── conPI_ScreenRoot
    ├── cmpPI_Sidebar              cmp_SidebarNav
    └── conPI_ContentShell
        ├── conPI_HeaderCard
        │   ├── identidad
        │   ├── Project context
        │   ├── Punch template context
        │   ├── Batch status
        │   └── Back to Punch Review
        ├── conPI_SafetyBanner
        ├── conPI_StepperCard
        │   ├── Upload
        │   ├── Preview
        │   ├── Confirm
        │   └── Result
        ├── conPI_Workspace
        │   ├── conPI_UploadSurface
        │   ├── conPI_PreviewSurface
        │   ├── conPI_ConfirmSurface
        │   └── conPI_ResultSurface
        └── modal/error layers cuando sean necesarios
```

## 2. Contratos congelados antes de UI

- Comments-only v1.
- `New Comment` no vacío = append de un comentario nuevo.
- blank = no change.
- no overwrite de historial.
- Custom Fields no se aplican en v1.
- upload nunca significa Apply.
- checksum del workbook se valida antes del preview.
- cambio concurrente en PULSE = `CONFLICT` y bloquea Commit.
- no existe force overwrite en v1.

## 3. Backend ya validado

### Stage / validate

`warroom.usp_StageValidatePunchCommentImport`

Validado:

- workbook válido → `READY`;
- checksum manipulado → `BLOCKED`;
- no escribe `PunchComment`.

### Preview

`warroom.usp_GetPunchCommentImportPreview`

Validado:

- preview paginado;
- filtro por estado;
- expone `OriginalValuesJson` y `CurrentValuesJson`;
- read-only.

### Concurrencia

`warroom.usp_RevalidatePunchCommentImportConflicts`

Validado:

- current state intacto → `READY`, `CanCommit=1`;
- current state modificado → `CONFLICT`, `BLOCKED`, `CanCommit=0`;
- no escribe producción.

## 4. Secuencia incremental de pantalla

### PR-IMP-C04A — Screen shell

Responsabilidad única:

- crear `scr_PunchImport`;
- raíz horizontal;
- `cmp_SidebarNav`;
- content shell;
- marcador visual temporal.

Sin Flow, SQL, stepper ni upload.

### PR-IMP-C04B — Premium header

Añadir:

- eyebrow;
- título/subtítulo;
- Project;
- Template;
- Batch status;
- Back to Punch Review;
- banner `COMMENTS ONLY · V1`.

### PR-IMP-C04C — Stepper

Añadir cuatro estados visuales:

`UPLOAD → PREVIEW → CONFIRM → RESULT`.

### PR-IMP-C04D — Runtime state

Inicializar variables tipadas y colecciones mínimas.

### PR-IMP-C04E — Upload surface

Crear exclusivamente la superficie de selección de workbook y estados sintéticos.

### PR-IMP-C05 — Stage/Validate integration

Conectar la carga real del workbook y el backend de staging.

### PR-IMP-C06 — Preview workspace

KPI strip, filtros, grid paginado, diff y blockers.

### PR-IMP-C07 — Confirm + Commit

Revalidación final, confirmación explícita, apply idempotente y auditoría.

### PR-IMP-C08 — Punch Review integration

Acción `Import comments`, navegación, retorno y refresh.

## 5. Reglas de Source Code aplicadas

Antes del primer YAML se consultó el registro vigente:

`docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

Reglas activas relevantes:

- no Radius en `Label@2.5.1`;
- no `AccessibleLabel` en `Classic/Button@2.2.0`;
- no SVG inline;
- no Reset sobre controles no confirmados;
- variables numéricas con primera asignación numérica inequívoca;
- CanvasComponent solo cuando está presente en la app activa;
- el artefacto pegable debe tener raíz `PaModule` válida.

`cmp_SidebarNav` está confirmado en la app activa porque ya se utiliza en `scr_PunchReview`.

## 6. Gate actual

Importar y validar exclusivamente **PR-IMP-C04A** en Power Apps Studio.

No se prepara el siguiente bloque funcional sobre un error abierto.