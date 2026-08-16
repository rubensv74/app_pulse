# PULSE Briefing — Especificación funcional y visual

**Estado:** propuesta de arquitectura congelable  
**Pantalla objetivo:** `scr_Briefing_PDS`  
**Área:** PULSE / Punch Review / Handover Meetings  
**Idioma de guía:** español  
**Fecha:** 2026-08-16

---

## 1. Propósito

`Briefing` es el workspace de cierre de una `Review Session` de Punch Review.

Su misión no es actuar como un asistente de reuniones genérico ni como un editor de documentos. Debe transformar la actividad estructurada ocurrida durante una Punch Review en información de reunión revisable y trazable, y convertir esa información aprobada en salidas operativas: Meeting Notes y correo de seguimiento.

Definición funcional:

> PULSE Briefing convierte la actividad estructurada generada durante una Punch Review en información de reunión revisable y trazable, y la transforma en actas, acciones y comunicaciones listas para su aprobación y distribución.

El Punch sigue siendo la fuente de verdad. La narrativa generada nunca sustituye a los datos de origen.

---

## 2. Arquitectura de interfaz SaaS

```text
PRIMARY_ARCHETYPE: Object 360
PRIMARY_OBJECT: Review Session
SECONDARY_PATTERNS:
- KPI Strip
- Audit Timeline
- Contextual Tabs
- Evidence Drawer
- Activity Stream
- Inline Review
- Empty / Loading / Error state surfaces

PRIMARY_USER_TASK:
Convertir una Punch Review terminada en información de reunión aprobada y lista para distribuir.

SUCCESS_CRITERION:
El Handover Manager puede pasar de una Review Session terminada a Meeting Notes y email aprobados sin reconstruir manualmente lo ocurrido durante la reunión.
```

`Briefing` no debe copiar la arquitectura de `scr_PunchReview`. Ambas pantallas comparten PULSE Design System, navegación, lenguaje visual y selección, pero responden a tareas distintas.

---

## 3. Relación con Punch Review

La pantalla actual `scr_PunchReview` ya contiene dos conceptos que anticipan Briefing:

- `IsReviewedInSession` dentro de la cola de revisión;
- `colPunchReviewSessionEvents` para representar eventos de sesión.

En el estado actual estos conceptos son locales y no constituyen una sesión persistente. Briefing debe diseñarse para evolucionar desde esa base sin introducir acoplamiento prematuro en BRF-C01.

Frontera funcional:

- **Punch Review** = revisar punches, comentar, editar campos y marcar revisados.
- **Briefing** = interpretar el resultado de una sesión terminada, revisar la interpretación, aprobarla y producir outputs.

Briefing no debe editar el Punch como fuente. Si la fuente es incorrecta, la corrección se realiza en Punch Review o en la pantalla operativa propietaria del dato.

---

## 4. Flujo de usuario objetivo

```text
Punch Review
    ↓
Review Session completed
    ↓
Generate Briefing
    ↓
Review summary / decisions / actions / blockers / evidence
    ↓
Approve Briefing
    ├──→ Generate Meeting Notes
    └──→ Prepare Email
              ↓
             Send
              ↓
            Archive
```

Flujo de madurez futuro:

```text
Previous Briefing
    ↓
Carry Forward open actions
    ↓
Next Punch Review
    ↓
New Briefing
```

---

## 5. Anatomía general de `scr_Briefing_PDS`

La pantalla queda dividida en seis superficies funcionales.

### A. Session Context

Mantiene visible:

- Project;
- Review Session;
- Meeting Date / Start-End;
- estado del Briefing;
- acción Refresh cuando proceda;
- acción primaria contextual.

### B. Session Snapshot

KPI strip de la sesión:

- `Reviewed`;
- `Changed`;
- `Comments`;
- `Actions`;
- `Blockers`.

Los KPIs deben ser navegables cuando exista detalle asociado. No usar colores de warning para representar simplemente trabajo abierto.

### C. Briefing Intelligence

Superficies principales:

- Executive Summary;
- Key Decisions;
- Progress & Changes;
- Blockers & Risks;
- Open Items.

### D. Action Register

Tabla operativa de acciones detectadas/propuestas:

- Action;
- Owner;
- Due Date;
- Source Punches;
- Status;
- Confidence / review state cuando aplique.

### E. Evidence & Quality

Columna/rail de control:

- Review Quality;
- Source Activity;
- Evidence Drawer;
- missing owner / due date;
- unsupported statements;
- source events processed.

### F. Outputs

Tabs subordinadas al mismo objeto `Review Session`:

1. `Briefing`
2. `Meeting Notes`
3. `Email`

No son procesos independientes: deben derivar del mismo contenido aprobado.

---

## 6. Header premium

Título recomendado:

`Briefing`

Subtítulo recomendado:

`Turn Punch Review activity into approved meeting outputs`

El header debe mantener el lenguaje visual PULSE y reutilizar `cmp_SidebarNav`.

Context cards siempre visibles en desktop:

- Project
- Review Session
- Meeting Date
- Briefing Status

Acciones de header:

- `Refresh`
- `Approve Briefing` cuando el estado permita aprobación

La acción primaria cambia según el estado. No deben coexistir varias acciones visualmente dominantes.

---

## 7. Estados funcionales de la pantalla

### `NO_SESSION`

No existe sesión seleccionada.

Mensaje:

> No review session selected
> Select a completed Punch Review session to prepare its briefing.

### `READY`

Existe una sesión válida y datos de origen disponibles, pero todavía no se ha generado el Briefing.

Mensaje:

> Ready to prepare briefing
> Reviewed punches and session events are available.

Acción primaria: `Generate briefing`.

### `GENERATING`

Generación en curso.

Usar skeletons/spinners localizados. Evitar bloquear innecesariamente toda la aplicación.

### `DRAFT`

Briefing generado y editable, pendiente de revisión.

### `NEEDS_REVIEW`

Existen elementos sin resolver que impiden considerar el contenido listo:

- decisiones pendientes de aceptar/excluir;
- acciones sin owner;
- acciones sin due date cuando sea requerido;
- afirmaciones sin soporte suficiente;
- validaciones incompletas.

### `APPROVED`

El contenido ha sido revisado y aprobado por el Handover Manager. Meeting Notes y Email deben derivar de esta versión aprobada.

### `STALE`

Las fuentes relevantes han cambiado después de generar o aprobar el Briefing.

Mensaje recomendado:

> Briefing out of date
> Source changes occurred after this draft was generated.

Acción: `Refresh from session`.

El sistema no debe presentar silenciosamente una versión antigua como actual.

### `SENT`

La comunicación ha sido enviada y existe snapshot archivado de lo aprobado/enviado.

### `ERROR`

Error recuperable con mensaje útil y acción `Retry` cuando sea seguro.

---

## 8. Executive Summary

Es la superficie narrativa dominante del tab Briefing.

Debe mostrar:

- texto generado/asistido;
- estado `AI-assisted draft` cuando aplique;
- indicador de evidencia disponible;
- número de punches y eventos fuente;
- acción `Edit`.

Regla de producto:

La IA no debe presentarse como protagonista. El valor principal es la trazabilidad de la Review Session.

La narrativa puede editarse, pero debe mantenerse el vínculo con la evidencia que la soporta.

---

## 9. Key Decisions

Cada decisión detectada debe presentarse como unidad revisable.

Campos mínimos:

- statement;
- Punch IDs fuente;
- número de sources;
- estado de revisión.

Acciones locales:

- `Accept`
- `Edit`
- `Exclude`
- `View evidence`

Una decisión excluida no debe aparecer en Meeting Notes ni Email salvo que se reincorpore explícitamente.

---

## 10. Progress & Changes

Debe condensar el `Session Delta`, no resumir todo el proyecto.

Agrupaciones posibles:

- Discipline;
- Subcontractor;
- System / Subsystem;
- Category;
- Responsible Party;
- otra dimensión estable del template.

Ejemplo:

```text
Mechanical
18 reviewed · 7 updated · 3 status changes
```

Debe existir drill-through contextual a las punches fuente cuando sea útil.

---

## 11. Blockers & Risks

Agrupa problemas equivalentes surgidos de la sesión.

Ejemplo:

```text
Vendor documentation
5 punches remain dependent on updated vendor documentation.
P-3812 · P-4104 · P-4120 · +2
5 sources
```

No todo trabajo abierto es un blocker. Mantener separadas las superficies `Blockers & Risks` y `Open Items`.

---

## 12. Open Items

Representa trabajo todavía abierto que no necesariamente constituye un riesgo.

Ejemplo:

- Documentation to be received;
- Site verification pending;
- Engineering response pending;
- Ready for follow-up.

La clasificación debe provenir de reglas/datos verificables o de una propuesta que el usuario pueda revisar.

---

## 13. Action Register

Es una de las superficies críticas del producto.

Columnas mínimas:

```text
Action | Owner | Due Date | Source Punches | Status
```

Regla absoluta:

> Briefing puede proponer una acción, pero no debe inventar Owner ni Due Date.

Cuando falten:

- `Owner missing`
- `Due date missing`

El usuario debe poder completar/corregir la información antes de aprobar.

Estados orientativos:

- Proposed
- Needs info
- Confirmed
- Excluded
- Carried forward
- Completed

La semántica definitiva se cerrará en BRF-C05.

---

## 14. Review Quality

Debe responder a la pregunta:

> ¿Puedo confiar en este Briefing y aprobarlo?

Indicadores mínimos:

- items needing review;
- actions missing owner;
- actions missing due date;
- unsupported statements;
- source events processed / expected.

Todos los indicadores accionables deberían permitir navegar al elemento correspondiente.

---

## 15. Evidence Drawer

Toda afirmación material debe poder rastrearse a sus fuentes.

El drawer debe mostrar, según proceda:

- Punch ID;
- Event Type;
- timestamp;
- actor;
- comment text;
- previous/new values;
- source context;
- acción `Open selected punch`.

No es necesario llenar la superficie principal de referencias; la trazabilidad debe estar disponible bajo demanda.

Regla:

> El texto generado no es la evidencia. La evidencia son los punches y eventos estructurados de la sesión.

---

## 16. Source Activity

Patrón secundario `Audit Timeline` compacto.

Ejemplos de eventos:

- Review session started;
- Punch reviewed;
- Comment added;
- Field updated;
- Status changed;
- Responsible changed;
- Review session ended.

Evento mínimo futuro:

```text
Timestamp
Actor
Event type
Punch / object
Previous value
New value
Session context
```

---

## 17. Meeting Notes tab

Se genera desde el Briefing aprobado, no desde una fuente paralela.

Estructura inicial:

1. Meeting Information
2. Attendance
3. Executive Summary
4. Key Decisions
5. Progress and Changes
6. Actions
7. Outstanding Items
8. Next Review

Debe permitir edición humana controlada.

Acciones de sección futuras:

- `Regenerate section`
- `Reset to approved briefing`

Evitar regenerar todo el documento destruyendo modificaciones humanas sin advertencia.

---

## 18. Email tab

Debe generarse desde el mismo Briefing aprobado.

Campos:

- To
- Cc
- Subject
- Body

Acciones:

- Preview
- Copy
- Send

`Send` solo será acción primaria cuando:

- el Briefing esté aprobado;
- los requisitos de distribución estén completos;
- no exista estado `STALE` sin resolver.

La integración Outlook pertenece a una capacidad posterior, no a BRF-C01.

---

## 19. Control de versión y estado STALE

El sistema deberá poder determinar si la fuente cambió después de generar una versión.

Conceptualmente, una versión de Briefing debe estar ligada a un snapshot o marcador de los eventos fuente usados.

Si cambia una punch relevante o aparece un nuevo evento posterior al corte:

- marcar `STALE`;
- mostrar cantidad/resumen de cambios;
- ofrecer refresh;
- conservar la versión anterior para auditoría cuando ya haya sido aprobada/enviada.

La semántica técnica de versionado se resolverá en BRF-C02/BRF-C03.

---

## 20. Carry Forward — extensión prevista

Desde la primera arquitectura debe reservarse espacio conceptual para:

- previous review;
- open actions from previous review;
- comparación `since last review`.

No se implementa en BRF-C01.

Capacidad prevista: `BRF-C08 — Carry Forward`.

---

## 21. Exclusiones expresas de la primera arquitectura

No incluir inicialmente:

- chat de IA;
- transcript de Teams como fuente primaria;
- sentiment analysis;
- word clouds;
- gráficos decorativos;
- envío automático sin aprobación;
- edición del Punch desde Briefing;
- duplicación de la cola de Punch Review;
- generación directa de Meeting Notes/Email desde una transcripción.

Una integración futura con Teams/transcript podrá enriquecer la sesión, pero no sustituirá al Punch como fuente de verdad.

---

## 22. Reglas PULSE Design System

Aplicar los tokens y reglas vigentes de `docs/design-system/PULSE_DESIGN_SYSTEM.md`.

Baseline visual:

- PageBg `#F6F8FB`
- Surface `#FFFFFF`
- BrandDark `#07111F`
- ActionPrimary `#1677FF`
- BrandAccent `#00C8FF`
- Border `#E2E8F0`
- SelectedBg `#EFF6FF`
- RadiusControl `8`
- RadiusPanel `12`
- RadiusModal `16`
- Segoe UI

Reglas:

- borders before shadows;
- una acción primaria por contexto;
- color semántico, no decorativo;
- estados loading/empty/error localizados cuando sea posible;
- selección consistente con PDS;
- densidad enterprise sin perder jerarquía.

---

## 23. Roadmap de capacidades

| Capacidad | Resultado |
|---|---|
| `BRF-C01 — Premium shell and visual states` | Pantalla independiente `scr_Briefing_PDS`, layout premium y estados sintéticos |
| `BRF-C02 — Review Session foundation` | Sesión persistente y contrato básico |
| `BRF-C03 — Session Delta and evidence` | Eventos, cambios y trazabilidad de fuentes |
| `BRF-C04 — Briefing generation and review` | Summary, decisions, progress, blockers y review |
| `BRF-C05 — Action Register` | Actions, owner, due date, validación y estados |
| `BRF-C06 — Meeting Notes output` | Documento derivado del Briefing aprobado |
| `BRF-C07 — Email approval and distribution` | Email, Outlook, envío y archivado |
| `BRF-C08 — Carry Forward` | Continuidad entre sesiones |

---

## 24. Alcance exacto de BRF-C01

BRF-C01 es exclusivamente visual y de interacción local.

Debe construir desde una pantalla vacía:

- `scr_Briefing_PDS`;
- `cmp_SidebarNav`;
- header premium;
- Session Context;
- KPI Strip;
- tabs Briefing / Meeting Notes / Email;
- Executive Summary;
- Key Decisions;
- Progress & Changes;
- Blockers & Risks;
- Open Items cuando la densidad lo permita;
- Action Register;
- Review Quality;
- Source Activity;
- Evidence Drawer;
- estados visuales sintéticos.

Estados mínimos:

`NO_SESSION · READY · GENERATING · DRAFT · NEEDS_REVIEW · APPROVED · STALE · SENT · ERROR`

En BRF-C01:

- no SQL;
- no nuevos stored procedures;
- no Power Automate;
- no Outlook;
- no IA real;
- no persistencia de Review Session;
- no modificar `scr_PunchReview`;
- no modificar navegación operativa actual;
- no presentar datos sintéticos como evidencia funcional.

---

## 25. Gate de BRF-C01

La capacidad no se considerará cerrada por existir YAML.

Requiere validación conjunta en Power Apps Studio de:

- composición general;
- jerarquía visual;
- densidad;
- scroll;
- alturas y anchuras;
- responsive;
- tabs;
- Evidence Drawer;
- Action Register;
- estados sintéticos;
- consistencia PDS;
- legibilidad a resolución objetivo.

Hasta superar ese gate no debe iniciarse BRF-C02 salvo trabajo documental independiente.

---

## 26. Fuentes normativas del repositorio

Antes de implementar consultar siempre:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`
- `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- `docs/development/ARTIFACT_DELIVERY_POLICY.md`
- `AGENTS.md`

Para BRF-C01, `scr_PunchReview` puede consultarse como referencia de identidad y contexto funcional, pero no debe copiarse como layout ni modificarse.
