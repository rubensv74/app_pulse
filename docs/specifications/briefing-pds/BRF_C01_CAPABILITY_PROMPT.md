# Encargo — BRF-C01 · Premium shell and visual states

Usa `@build-power-platform-frameworks` para trabajar en PULSE.

Repositorio:
https://github.com/rubensv74/app_pulse

Rama de trabajo preparada para la especificación:
`briefing-pds-foundation`

Especificación funcional y visual:
`docs/specifications/briefing-pds/BRIEFING_PDS_SCREEN_SPECIFICATION.md`

Ejecuta la capacidad:

`BRF-C01 — Premium shell and visual states`

## Resultado que quiero conseguir

Construye una nueva pantalla independiente llamada `scr_Briefing_PDS` desde una pantalla vacía.

La pantalla debe representar el workspace premium de cierre de una Punch Review. Su objetivo visual es permitir que el Handover Manager comprenda qué ocurrió en una Review Session, revise la interpretación propuesta y disponga de las superficies que en capacidades posteriores producirán Meeting Notes y Email.

Esta capacidad es exclusivamente visual y de interacción local. No debe conectar todavía datos reales ni generar contenido mediante IA real.

La arquitectura de interfaz está congelada como:

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
El Handover Manager puede comprender y validar visualmente el flujo completo de Briefing mediante datos sintéticos antes de conectar persistencia, SQL, flows o IA.
```

## Superficies que debe contener BRF-C01

Incluye:

- shell general PULSE;
- `cmp_SidebarNav`;
- header premium;
- Project context;
- Review Session context;
- Meeting Date context;
- Briefing Status;
- acción Refresh visual;
- acción primaria contextual;
- KPI strip con `Reviewed`, `Changed`, `Comments`, `Actions`, `Blockers`;
- tabs `Briefing`, `Meeting Notes`, `Email`;
- Executive Summary;
- Key Decisions;
- Progress & Changes;
- Blockers & Risks;
- Open Items cuando la composición lo permita sin degradar densidad;
- Action Register;
- Review Quality;
- Source Activity;
- Evidence Drawer;
- indicador compacto del lifecycle de la sesión/briefing si aporta claridad sin sobrecargar el header.

Utiliza datos sintéticos coherentes entre sí para que la pantalla pueda evaluarse como una experiencia completa.

## Estados visuales obligatorios

Construye superficies mutuamente excluyentes para:

- `NO_SESSION`
- `READY`
- `GENERATING`
- `DRAFT`
- `NEEDS_REVIEW`
- `APPROVED`
- `STALE`
- `SENT`
- `ERROR`

Deben poder activarse mediante un selector o variable local de prueba claramente identificable.

Los datos sintéticos y los estados de prueba no deben presentarse como evidencia de funcionamiento real.

## Reglas funcionales que la interfaz debe expresar visualmente

Aunque todavía no haya lógica real, el diseño debe dejar claras estas reglas:

1. El Punch es la fuente de verdad.
2. Briefing representa una `Review Session`, no el proyecto completo.
3. Executive Summary, Decisions, Blockers y Actions deben disponer de acceso visual a evidencia.
4. Una acción puede mostrar `Owner missing` o `Due date missing`; nunca simular que esos datos han sido inferidos con certeza cuando no existen.
5. `STALE` debe comunicar que las fuentes cambiaron después de generar el draft.
6. Meeting Notes y Email son outputs derivados de un Briefing aprobado.
7. `Send` no debe mostrarse como disponible cuando el Briefing no está aprobado o está stale.
8. El usuario debe distinguir claramente `DRAFT`, `NEEDS_REVIEW`, `APPROVED`, `STALE` y `SENT`.

## Referencia visual y PDS

La pantalla debe tener el mismo nivel premium que el resto de PULSE, pero no copiar el layout de Punch Review.

Consulta y respeta obligatoriamente:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`
- `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`
- `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- `docs/development/ARTIFACT_DELIVERY_POLICY.md`
- `AGENTS.md`

Usa como baseline visual PDS:

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

Aplica `borders before shadows`, una única acción primaria por contexto, color semántico y densidad enterprise controlada.

## Límites estrictos

No modifiques:

- `scr_PunchReview`;
- `scr_Overview`;
- `scr_Overview_PDS` si existe en la baseline;
- `scr_Home`;
- `scr_Punches`;
- SQL;
- stored procedures;
- esquemas de base de datos;
- Power Automate;
- Outlook;
- navegación operativa actual;
- contratos backend existentes.

No implementes todavía:

- persistencia real de Review Session;
- Session Delta real;
- generación IA;
- integración Teams/transcript;
- Meeting Notes funcional;
- envío de Email;
- Carry Forward;
- escritura en punches desde Briefing.

No agregues componentes nuevos si la misma superficie puede construirse de forma segura con controles y componentes ya compatibles. Si propones un componente reutilizable nuevo, justifica antes por qué evita duplicación real y verifica su compatibilidad con Source Code schema.

## Baseline y preflight

Consulta primero el repositorio, la rama canónica, el estado actual y el procedimiento vigente.

Reconstruye la baseline y comprueba al menos:

- disponibilidad y propiedades reales de `cmp_SidebarNav`;
- tokens PDS actuales;
- controles modernos/clásicos compatibles ya usados por el proyecto;
- restricciones conocidas de Source Code schema;
- lecciones aprendidas relevantes antes de redactar YAML;
- estructura actual de `power-apps/screens`;
- compatibilidad de cualquier patrón reutilizado desde `scr_PunchReview`.

`colPunchReviewSessionEvents` e `IsReviewedInSession` pueden consultarse únicamente como contexto de diseño futuro. BRF-C01 no debe convertirlos en un contrato funcional ni modificar su comportamiento.

## Método de construcción

Trabaja por bloques pequeños acumulativos según el protocolo vigente.

El resultado final de BRF-C01 debe ser un único paquete acumulativo y pegable en Power Apps Studio, pero su construcción debe conservar trazabilidad de bloques y gates.

Reduce la intervención manual al mínimo razonable.

Continúa autónomamente hasta completar BRF-C01 o encontrar un gate real. Si un gate afecta solo a una superficie, continúa con las partes independientes cuando sea seguro.

No solicites confirmaciones ceremoniales.

## Validación

No afirmes que algo compila, funciona o está validado si no existe evidencia ejecutada.

La capacidad requiere finalmente validación en Power Apps Studio de:

- composición general;
- jerarquía visual;
- densidad;
- scroll;
- alturas/anchuras;
- responsive;
- tabs;
- KPI strip;
- Action Register;
- Review Quality;
- Source Activity;
- Evidence Drawer;
- los nueve estados sintéticos;
- consistencia PDS.

La ausencia de validación Studio debe clasificarse explícitamente como no probada, no como PASS.

## Entrega

Entrega:

- los artefactos completos y acumulativos;
- el archivo `.pa.yaml` final correspondiente a `scr_Briefing_PDS`;
- las guías manuales necesarias en español;
- las comprobaciones realmente ejecutadas;
- aquello que todavía no se ha probado;
- estado de cada criterio relevante;
- gates pendientes y su alcance;
- siguiente acción concreta;
- enlaces directos a archivos y documentación utilizados;
- PR de implementación cuando corresponda al flujo vigente.

Explícame el resultado con lenguaje natural y humano. Coloca el detalle técnico al final y solo cuando sea útil.

## Gate final de BRF-C01

BRF-C01 no autoriza BRF-C02 automáticamente.

Después de integrar el YAML en Studio debe existir un gate visual conjunto. Solo si la composición, densidad, estados y flujo de Briefing quedan aceptados debe congelarse la arquitectura visual y avanzar a:

`BRF-C02 — Review Session foundation`.
