# Protocolo de Implementación Incremental Asistida por IA

## Contrato operativo de desarrollo, documentación viva y captura de conocimiento reutilizable

**Versión:** 1.1  
**Estado:** Activo  
**Idioma:** Español  
**Ámbito:** Power Apps, Power Automate, SQL, componentes reutilizables, aplicaciones web, documentación técnica, manuales de usuario y desarrollo asistido por IA  
**Finalidad:** convertir un encargo amplio en una secuencia de bloques pequeños, verificables, versionados y fáciles de corregir, manteniendo sincronizados el producto, su documentación y el conocimiento reutilizable derivado del trabajo.

---

## 1. Denominación formal

La metodología se denomina:

> **Protocolo de Implementación Incremental Asistida por IA**

El documento que se entrega al modelo o agente para iniciar un trabajo concreto se denomina:

> **Encargo técnico incremental con documentación y captura de conocimiento**

No es únicamente un prompt. Es un contrato operativo que define:

- fuentes de verdad;
- alcance y exclusiones;
- repositorios y rutas;
- reglas de implementación;
- formato de los entregables;
- orden de validación;
- gestión de errores;
- documentación viva del producto;
- captura de conocimiento reutilizable;
- publicación multirrepositorio;
- condiciones para avanzar, detenerse o degradar el modo de publicación.

---

## 2. Modelo documental de dos repositorios

Este protocolo distingue dos destinos diferentes.

### 2.1. Repositorio de la aplicación

Contiene la verdad específica del producto:

- código y configuración;
- arquitectura real de la aplicación;
- pantallas, módulos y componentes;
- contratos de datos, flows y SQL;
- reglas de negocio;
- decisiones específicas;
- pruebas y resultados de validación;
- manuales de usuario;
- incidencias y limitaciones propias del producto.

Ejemplos:

- implementación del filtro por disciplina de PULSE;
- contrato real de un flow;
- nombres de controles y variables;
- manual del Punch Review Workspace;
- ciclo de vida concreto de una Work Order de CMMS.

### 2.2. Repositorio central de conocimiento

Contiene conocimiento transferible y sanitizado:

- capacidades profesionales;
- patrones y anti-patrones;
- playbooks;
- consultas, comandos y fragmentos reutilizables;
- lecciones aprendidas;
- criterios de arquitectura;
- técnicas de diagnóstico;
- procedimientos de pruebas;
- metodologías de análisis funcional;
- plantillas y checklists.

Ejemplos:

- patrón de filtrado contextual entre gráficos y grids;
- playbook para implementar una pantalla Power Apps;
- regla preventiva sobre propiedades incompatibles;
- procedimiento para documentar un esquema SQL;
- patrón de estados de carga, error y vacío.

### 2.3. Regla de separación

El repositorio de la aplicación explica **cómo funciona este producto**.

El repositorio central explica **qué conocimiento puede reutilizarse en otros productos**.

No se debe copiar el mismo documento completo en ambos repositorios. Cuando el cambio produzca ambos tipos de información:

1. se documenta la implementación concreta en el repositorio de la aplicación;
2. se extrae una versión general, sanitizada y reutilizable para el repositorio central;
3. ambos documentos se enlazan mediante referencias de origen y documentos relacionados.

---

## 3. Cuándo utilizar este protocolo

Debe utilizarse cuando el trabajo incluya una o varias de estas situaciones:

- creación o rediseño de una pantalla;
- integración de componentes reutilizables;
- modificación de fórmulas Power Fx;
- incorporación de flows de Power Automate;
- creación o ajuste de tablas, vistas o procedimientos almacenados SQL;
- construcción de contratos de datos;
- trabajo sobre archivos extensos o frágiles;
- necesidad de probar incrementos manualmente;
- desarrollo donde un error pequeño puede invalidar un bloque completo;
- necesidad de mantener manuales y registros técnicos;
- trabajo del que puedan derivarse patrones, playbooks o lecciones reutilizables.

No se recomienda entregar una implementación monolítica cuando existen dependencias todavía no validadas.

---

## 4. Principios obligatorios

### 4.1. El repositorio de la aplicación es la fuente de verdad del producto

Antes de proponer código, el agente debe inspeccionar el estado real del repositorio de la aplicación.

No debe:

- inventar rutas;
- asumir nombres de controles;
- asumir contratos de flows;
- asumir columnas SQL;
- copiar patrones de otro proyecto sin verificar compatibilidad;
- utilizar recuerdos anteriores como sustituto del código actual;
- utilizar el repositorio central como sustituto de la inspección del producto.

El repositorio central aporta orientación y conocimiento reutilizable, pero no prevalece sobre los contratos reales del producto.

### 4.2. Un bloque, una responsabilidad

Cada bloque debe resolver una responsabilidad concreta y comprobable.

No se deben mezclar estructura visual, flows, persistencia SQL y navegación salvo que sean inseparables.

### 4.3. No avanzar sin validación

El siguiente bloque no debe publicarse como listo para integrar hasta que el bloque anterior:

1. se importe o aplique correctamente;
2. guarde sin errores;
3. no añada errores nuevos atribuibles al cambio;
4. cumpla la prueba mínima acordada;
5. tenga actualizada la documentación afectada.

### 4.4. Los errores se convierten en reglas

Todo error confirmado debe producir:

1. corrección del archivo fuente;
2. registro del incidente en el repositorio de la aplicación;
3. regla preventiva para bloques posteriores;
4. evaluación de si la regla es reutilizable y debe publicarse en el repositorio central.

### 4.5. La documentación evoluciona con el producto

No se espera al final para redactar documentación. Deben mantenerse desde el inicio:

- registro de compatibilidad y errores;
- README de la funcionalidad;
- manual de usuario;
- decisiones de arquitectura;
- limitaciones conocidas;
- estado de validación de cada bloque;
- candidatos de conocimiento reutilizable.

### 4.6. La documentación forma parte del Definition of Done

Una tarea técnica no está terminada hasta que código, pruebas y documentación estén sincronizados.

El agente debe justificar expresamente los casos en los que no sea necesario crear o modificar documentación.

---

## 5. Ficha de configuración del encargo

Completar los placeholders aplicables antes de iniciar el trabajo. Utilizar `NO APLICA` o `NO CONFIGURADO` cuando corresponda.

### 5.1. Identificación general

| Campo | Valor |
|---|---|
| Proyecto | `[NOMBRE_PROYECTO]` |
| Funcionalidad | `[NOMBRE_FUNCIONALIDAD]` |
| Pantalla o módulo | `[PANTALLA_O_MODULO]` |
| Responsable de validación | `[RESPONSABLE_VALIDACION]` |
| Herramienta de validación | `[POWER_APPS_STUDIO / TESTS / NAVEGADOR / OTRA]` |

### 5.2. Repositorio de la aplicación

| Campo | Valor |
|---|---|
| Repositorio | `[OWNER/APP_REPOSITORY]` |
| URL | `[URL_APP_REPOSITORY]` |
| Rama base | `[APP_BASE_BRANCH]` |
| Rama de trabajo | `[APP_WORK_BRANCH]` |
| Ruta local | `[APP_LOCAL_PATH]` |
| Política de publicación | `[DIRECTO_MAIN / RAMA_Y_PR]` |

### 5.3. Repositorio central de conocimiento

| Campo | Valor |
|---|---|
| Repositorio | `[OWNER/KNOWLEDGE_REPOSITORY / NO CONFIGURADO]` |
| URL | `[URL_KNOWLEDGE_REPOSITORY / NO CONFIGURADO]` |
| Rama base | `[KNOWLEDGE_BASE_BRANCH]` |
| Rama de trabajo | `[KNOWLEDGE_WORK_BRANCH]` |
| Ruta local | `[KNOWLEDGE_LOCAL_PATH / NO DISPONIBLE]` |
| Política de publicación | `[DIRECTO_MAIN / RAMA_Y_PR / OUTBOX / DESACTIVADO]` |
| Protocolo del repositorio | `[RUTA_AGENTS_O_PROTOCOLO]` |
| Bandeja de salida local | `[RUTA_OUTBOX_CONOCIMIENTO]` |

Ruta recomendada para la bandeja de salida cuando no exista acceso multirrepositorio:

```text
docs/knowledge-outbox/
```

### 5.4. Rutas del repositorio de la aplicación

| Tipo de información | Ruta |
|---|---|
| Pantallas | `[RUTA_PANTALLAS]` |
| Componentes | `[RUTA_COMPONENTES]` |
| App o configuración global | `[RUTA_APP_CONFIG]` |
| Flows | `[RUTA_FLOWS]` |
| SQL — tablas | `[RUTA_SQL_TABLAS]` |
| SQL — procedimientos | `[RUTA_SQL_SP]` |
| SQL — vistas y funciones | `[RUTA_SQL_OTROS]` |
| Contratos de datos | `[RUTA_CONTRATOS]` |
| Mapeos | `[RUTA_MAPEOS]` |
| Tests | `[RUTA_TESTS]` |
| Documentación funcional | `[RUTA_DOC_FUNCIONAL]` |
| Documentación técnica | `[RUTA_DOC_TECNICA]` |
| Manuales de usuario | `[RUTA_MANUALES]` |
| Registro de errores | `[RUTA_REGISTRO_ERRORES]` |
| Decisiones | `[RUTA_DECISIONES]` |
| Bloques incrementales | `[RUTA_BLOQUES]` |

---

## 6. Comprobación de capacidades del agente

Antes de prometer una publicación multirrepositorio, el agente debe comprobar:

- acceso de lectura y escritura al repositorio de la aplicación;
- acceso de lectura y escritura al repositorio central;
- rama permitida en cada repositorio;
- posibilidad de crear commits o Pull Requests;
- disponibilidad local de ambos repositorios cuando trabaje desde un workspace;
- reglas `AGENTS.md`, `CONTRIBUTING.md` o equivalentes de cada repositorio.

### 6.1. Modos de publicación

#### Modo A — `MULTI_REPO_DIRECT`

Se utiliza cuando el agente puede modificar ambos repositorios.

El agente debe:

1. actualizar la aplicación y su documentación local;
2. crear o actualizar el conocimiento reutilizable en el repositorio central;
3. realizar commits independientes por repositorio;
4. informar de rama, commit y PR de cada repositorio.

#### Modo B — `KNOWLEDGE_PR`

Se utiliza cuando el agente puede abrir una rama o PR en el repositorio central, pero no publicar directamente en su rama principal.

#### Modo C — `OUTBOX`

Se utiliza cuando el agente no puede escribir en el repositorio central.

El agente debe:

1. completar la documentación específica en el repositorio de la aplicación;
2. generar un candidato de conocimiento en `[RUTA_OUTBOX_CONOCIMIENTO]`;
3. marcarlo como `status: candidate`;
4. incluir la ruta de destino propuesta en el repositorio central;
5. no afirmar que el conocimiento ha sido publicado fuera;
6. dejar instrucciones de traslado o sincronización.

#### Modo D — `DESACTIVADO`

Solo se utiliza cuando el encargo indica expresamente que no debe realizarse captura de conocimiento.

### 6.2. Prohibición de simulación

El agente nunca debe afirmar que ha actualizado el repositorio central si no puede aportar una ruta verificable y un commit o PR real.

---

## 7. Orden de prioridad de las fuentes de verdad

Cuando exista discrepancia, se aplicará este orden:

1. código actual del repositorio de la aplicación en la rama indicada;
2. contratos reales de flows, SQL, APIs y componentes;
3. comportamiento confirmado en la herramienta de validación;
4. documentación técnica actualizada del producto;
5. decisiones expresas del responsable funcional;
6. ADR vigentes;
7. conocimiento reutilizable validado del repositorio central;
8. prototipos o capturas;
9. hipótesis del agente.

Las hipótesis deben identificarse como tales.

---

## 8. Fase 0 — Auditoría obligatoria

Antes de implementar, el agente debe inspeccionar:

- estructura del repositorio;
- rama y commit de partida;
- archivos relacionados;
- componentes reutilizables;
- variables y colecciones;
- contratos de flows, SQL o APIs;
- navegación y dependencias;
- documentación y decisiones previas;
- errores conocidos;
- conocimiento relacionado existente en el repositorio central, cuando sea accesible.

### 8.1. Entregable de auditoría

Debe indicar:

- archivos inspeccionados;
- contratos confirmados;
- huecos y riesgos;
- elementos que no se deben inventar;
- propuesta de bloques;
- documentación del producto que deberá actualizarse;
- posibles candidatos de conocimiento reutilizable;
- modo de publicación multirrepositorio disponible.

### 8.2. Condiciones de parada

El agente debe detenerse cuando falte un dato que pueda cambiar la arquitectura, seguridad, permisos, persistencia o contrato real.

No debe detenerse por detalles menores que puedan resolverse inspeccionando los repositorios.

---

## 9. Clasificación documental obligatoria

### 9.1. Se guarda solo en el repositorio de la aplicación

- nombres reales de controles, variables y colecciones;
- contratos específicos;
- rutas internas;
- reglas de negocio particulares;
- manuales de usuario;
- inventarios de pantallas y componentes;
- decisiones exclusivas del producto;
- incidencias que no sean transferibles.

### 9.2. Se evalúa para el repositorio central

- solución aplicable a más de un producto;
- patrón técnico o funcional;
- anti-patrón confirmado;
- procedimiento repetible;
- regla preventiva derivada de un error;
- técnica de diagnóstico;
- consulta o comando reutilizable;
- checklist;
- aprendizaje que modifica el criterio profesional;
- plantilla reutilizable.

### 9.3. No se publica en el repositorio central

- secretos, credenciales o tokens;
- datos productivos;
- información personal;
- identificadores corporativos innecesarios;
- código propietario completo cuando no sea necesario;
- detalles sensibles de infraestructura;
- hipótesis no validadas presentadas como hechos;
- duplicados de documentación ya existente.

### 9.4. Prueba de reutilización

Antes de publicar conocimiento central, el agente debe responder:

1. ¿Podría aplicarse fuera de esta aplicación?
2. ¿Está validado por una implementación, prueba o incidente real?
3. ¿Puede explicarse sin datos sensibles?
4. ¿Aporta algo nuevo respecto al conocimiento existente?
5. ¿Tiene una ubicación clara en el mapa del repositorio central?

Si alguna respuesta crítica es negativa, el contenido permanece en el repositorio de la aplicación o en estado de candidato.

---

## 10. Diseño de la secuencia incremental

La funcionalidad debe dividirse en bloques numerados.

Orden orientativo:

1. auditoría y arquitectura;
2. esqueleto o contenedor raíz;
3. layout y navegación;
4. variables y estado;
5. listado o cola principal;
6. panel de detalle;
7. acciones locales;
8. datos remotos;
9. edición y guardado;
10. indicadores y gráficos;
11. modales y protección de cambios;
12. integración con pantallas origen;
13. limpieza de datos de prueba;
14. consolidación documental;
15. extracción de conocimiento reutilizable;
16. cierre.

Tipos de operación:

- `CREATE FILE`
- `ADD AS CHILD`
- `ADD AS SIBLING`
- `REPLACE CONTROL`
- `REPLACE PROPERTY`
- `PATCH EXISTING FILE`
- `TEST SEED`
- `APP DOCUMENTATION`
- `KNOWLEDGE CANDIDATE`
- `KNOWLEDGE PUBLICATION`

---

## 11. Contrato obligatorio de cada bloque

Cada bloque debe declarar:

```text
BLOCK [NUMERO] — [NOMBRE]
Operation: [TIPO_OPERACION]
Repository: [APP / KNOWLEDGE]
Target file: [ARCHIVO]
Target control/property: [CONTROL_O_PROPIEDAD]
Parent: [PADRE]
Exact location: [POSICION]
Dependencies: [BLOQUES_PREVIOS]
Scope: [QUE_HACE]
Out of scope: [QUE_NO_HACE]
Compatibility: [REGLAS_RELEVANTES]
Validation: [PRUEBAS]
Documentation impact: [DOCUMENTOS_APP]
Knowledge impact: [NONE / CANDIDATE / UPDATE / CREATE]
Proposed knowledge path: [RUTA_O_NO_APLICA]
```

Un bloque no debe:

- incluir fragmentos incompletos sin ubicación exacta;
- depender de controles inexistentes sin declararlo;
- introducir propiedades no verificadas silenciosamente;
- mezclar datos de prueba con producción;
- reemplazar archivos completos sin necesidad;
- modificar una rama distinta a la acordada;
- afirmar persistencia que no existe;
- publicar conocimiento no validado como definitivo.

---

## 12. Flujo operativo usuario–agente

### Paso 1 — Preparación

El agente:

1. inspecciona el repositorio de la aplicación;
2. inspecciona el repositorio central cuando tenga acceso;
3. confirma fuentes de verdad;
4. declara el modo de publicación;
5. divide el trabajo en bloques;
6. identifica documentos vivos y candidatos de conocimiento.

### Paso 2 — Publicación del bloque técnico

El agente:

1. crea o actualiza el archivo en la rama acordada;
2. realiza un commit específico;
3. verifica la ruta y rama;
4. entrega instrucciones exactas de integración.

### Paso 3 — Validación del usuario o del sistema

El bloque se prueba en la herramienta correspondiente.

### Paso 4 — Tratamiento de errores

Cuando aparece un error, el agente:

1. localiza la causa;
2. corrige el archivo fuente;
3. registra el incidente;
4. busca el mismo patrón en bloques futuros;
5. actualiza la documentación;
6. evalúa si existe una lección reutilizable;
7. no continúa hasta la validación.

### Paso 5 — Consolidación documental

Después de validar un bloque:

1. actualiza la documentación del producto;
2. actualiza manuales si cambia el comportamiento visible;
3. registra decisiones cuando tengan consecuencias futuras;
4. publica o prepara el conocimiento reutilizable;
5. enlaza origen y destino.

### Paso 6 — Confirmación

El usuario puede confirmar mediante:

```text
Bloque [N] integrado sin errores.
```

---

## 13. Formato del conocimiento reutilizable

Los documentos sustantivos del repositorio central deben incluir metadatos equivalentes a:

```yaml
---
title: Título descriptivo
type: pattern
status: validated
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_product: pulse
source_repository: OWNER/APP_REPOSITORY
source_commit: COMMIT_SHA
source_paths:
  - ruta/origen.md
tags:
  - power-apps
  - filtering
related: []
---
```

Tipos recomendados:

- `concept`
- `pattern`
- `anti-pattern`
- `playbook`
- `reference`
- `lesson`
- `incident-pattern`
- `checklist`
- `template`

### 13.1. Candidato de bandeja de salida

Cuando se utilice `OUTBOX`, el documento debe incluir además:

```yaml
status: candidate
proposed_destination: 30-patterns/power-apps/example.md
publication_blocked_by: knowledge-repository-not-accessible
```

---

## 14. Política de ramas, commits y Pull Requests

- un propósito por commit;
- commits independientes por repositorio;
- no mezclar implementación y sincronización central cuando dificulte la revisión;
- incluir la documentación local junto al cambio técnico cuando formen una unidad;
- publicar el conocimiento central solo después de validar el aprendizaje;
- enlazar PR relacionados cuando existan dos repositorios;
- no afirmar que algo está en `main` sin verificarlo.

Ejemplos:

```text
feat(punch-review): add interactive discipline filter
docs(punch-review): update workspace user guide
docs(patterns): add contextual cross-filtering pattern
fix(compatibility): remove unsupported control property
```

---

## 15. Datos de prueba

Los datos de prueba deben estar separados del código productivo e indicar:

- que son opcionales;
- dónde ejecutarlos;
- cómo eliminarlos;
- resultado esperado;
- variables, tablas o colecciones afectadas.

No deben permanecer en la versión final.

---

## 16. Registro de compatibilidad, incidentes y lecciones

Todo incidente relevante debe documentar:

- síntoma;
- mensaje de error;
- causa raíz;
- corrección;
- validación;
- regla preventiva;
- bloques afectados;
- evaluación de reutilización.

La solución no consiste únicamente en corregir el caso puntual. Debe determinarse si existe un patrón seguro reutilizable.

---

## 17. Manual de usuario vivo

Debe crearse desde los primeros bloques funcionales.

Cada cambio visible debe actualizar:

- objetivo de la función;
- pasos de uso;
- comportamiento de filtros y acciones;
- estados similares;
- limitaciones;
- resolución de problemas básicos;
- historial de cambios.

La ayuda integrada de la aplicación no sustituye al manual del repositorio.

---

## 18. Validación por capas

### 18.1. Sintaxis y compatibilidad

- formato fuente correcto;
- tipos y versiones;
- propiedades soportadas;
- fórmulas válidas;
- estructura correcta.

### 18.2. Visual

- alineación;
- dimensiones;
- ausencia de solapamientos;
- comportamiento responsive;
- scroll;
- estados de carga, error y vacío;
- jerarquía visual.

### 18.3. Funcional

- selección;
- filtros;
- búsqueda;
- navegación;
- acciones;
- carga remota;
- guardado;
- errores y reintentos.

### 18.4. Contractual

- parámetros en orden correcto;
- tipos coherentes;
- JSON compatible;
- nombres reales;
- paginación consistente;
- permisos y dependencias.

### 18.5. Documental

- README actualizado;
- manual actualizado;
- decisiones registradas;
- incidentes registrados;
- limitaciones explícitas;
- candidato o publicación central evaluados;
- enlaces de trazabilidad válidos.

---

## 19. Criterios de cierre

La funcionalidad se considera completada cuando:

- todos los bloques están validados;
- se han eliminado los datos de prueba;
- las integraciones funcionan;
- la persistencia real está conectada o su ausencia está aceptada;
- no quedan placeholders no justificados;
- se han probado estados vacíos, carga y error;
- el manual coincide con el comportamiento real;
- el registro de compatibilidad está actualizado;
- existe un resumen de arquitectura y decisiones;
- la documentación del producto está sincronizada;
- el conocimiento reutilizable ha sido publicado, preparado en `OUTBOX` o descartado con justificación.

---

# 20. Plantilla maestra de encargo técnico incremental

Copiar el bloque siguiente y sustituir los placeholders.

```markdown
# ENCARGO TÉCNICO INCREMENTAL — [NOMBRE_FUNCIONALIDAD]

Actúa como arquitecto funcional y desarrollador principal del repositorio `[OWNER/APP_REPOSITORY]`.

Aplica íntegramente el protocolo `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`.

## 1. Objetivo

Implementa `[DESCRIPCION_OBJETIVO]` en `[PANTALLA_O_MODULO]`.

Resultados esperados:

- `[RESULTADO_1]`
- `[RESULTADO_2]`
- `[RESULTADO_3]`

Fuera de alcance:

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`

## 2. Repositorio de la aplicación

- Repositorio: `[OWNER/APP_REPOSITORY]`
- Rama base: `[APP_BASE_BRANCH]`
- Política: `[DIRECTO_MAIN / RAMA_Y_PR]`
- Ruta local: `[APP_LOCAL_PATH]`
- Carpeta de bloques: `[RUTA_BLOQUES]`

## 3. Repositorio central de conocimiento

- Repositorio: `[OWNER/KNOWLEDGE_REPOSITORY / NO CONFIGURADO]`
- Rama base: `[KNOWLEDGE_BASE_BRANCH]`
- Política: `[DIRECTO_MAIN / RAMA_Y_PR / OUTBOX / DESACTIVADO]`
- Ruta local: `[KNOWLEDGE_LOCAL_PATH / NO DISPONIBLE]`
- Bandeja de salida: `[RUTA_OUTBOX_CONOCIMIENTO]`

Antes de prometer cambios en el repositorio central, comprueba que tienes acceso real. Si no lo tienes, utiliza `OUTBOX` y no afirmes que publicaste fuera.

## 4. Fuentes de verdad

Inspecciona antes de implementar:

- Pantallas: `[RUTA_PANTALLAS]`
- Componentes: `[RUTA_COMPONENTES]`
- App/configuración: `[RUTA_APP_CONFIG]`
- Flows: `[RUTA_FLOWS]`
- SQL: `[RUTA_SQL]`
- Contratos: `[RUTA_CONTRATOS]`
- Tests: `[RUTA_TESTS]`
- Documentación técnica: `[RUTA_DOC_TECNICA]`
- Manual: `[RUTA_MANUAL]`
- Registro de compatibilidad: `[RUTA_REGISTRO_ERRORES]`
- Conocimiento relacionado: `[RUTAS_KNOWLEDGE_RELACIONADAS / NO APLICA]`

El estado actual del repositorio de la aplicación es la fuente de verdad. No inventes nombres, rutas, controles, variables, contratos, columnas ni parámetros.

## 5. Reglas de ejecución

1. Audita antes de crear código.
2. Divide el trabajo en bloques de una responsabilidad.
3. No avances al siguiente bloque sin validación.
4. Mantén sincronizada la documentación del producto.
5. Evalúa después de cada aprendizaje si existe conocimiento reutilizable.
6. Publica conocimiento central solo cuando esté validado y sanitizado.
7. Registra decisiones con consecuencias futuras.
8. Registra errores no triviales y su regla preventiva.
9. Actualiza manuales cuando cambie el comportamiento visible.
10. No guardes secretos ni datos productivos.

## 6. Auditoría inicial

Antes del primer bloque entrega:

1. archivos inspeccionados;
2. contratos confirmados;
3. riesgos y huecos;
4. arquitectura propuesta;
5. secuencia de bloques;
6. documentos del producto afectados;
7. candidatos de conocimiento previstos;
8. modo de publicación multirrepositorio disponible.

## 7. Contrato de bloque

Para cada bloque indica:

- repositorio;
- ruta y commit;
- operación exacta;
- archivo, control o propiedad;
- dependencias;
- prueba mínima;
- resultado esperado;
- limitaciones;
- impacto documental;
- impacto de conocimiento;
- ruta central propuesta.

## 8. Cierre obligatorio

No consideres terminada la tarea mientras código y documentación no estén sincronizados.

La respuesta final debe enumerar:

1. archivos técnicos creados o modificados;
2. documentación de la aplicación creada o actualizada;
3. decisiones e incidentes registrados;
4. conocimiento central creado o actualizado;
5. candidatos dejados en `OUTBOX`;
6. repositorio, rama, commit y PR de cada publicación;
7. pruebas y validaciones;
8. riesgos, limitaciones y pendientes;
9. justificación cuando no haya conocimiento reutilizable.
```

---

## 21. Formato de respuesta del agente

Después de cada bloque:

1. **Bloque publicado**
2. **Repositorio, rama, ruta y commit**
3. **Operación exacta**
4. **Archivos o controles afectados**
5. **Pasos de integración**
6. **Prueba mínima**
7. **Resultado esperado**
8. **Documentación actualizada**
9. **Conocimiento reutilizable evaluado**
10. **Limitaciones**
11. **Condición para continuar**

Al cierre, debe existir una tabla por repositorio con rutas y commits verificables.

---

## 22. Checklist de inicio rápido

- [ ] Repositorio y rama de la aplicación confirmados.
- [ ] Política de publicación de la aplicación confirmada.
- [ ] Repositorio central configurado o modo `OUTBOX` seleccionado.
- [ ] Capacidades reales del agente verificadas.
- [ ] Rutas técnicas completadas.
- [ ] Objetivo y exclusiones documentados.
- [ ] Contratos reales inspeccionados.
- [ ] Registro de compatibilidad localizado o creado.
- [ ] Manual localizado o creado.
- [ ] Arquitectura dividida en bloques.
- [ ] Impacto documental identificado.
- [ ] Criterio de captura de conocimiento acordado.
- [ ] Primer bloque limitado a una responsabilidad.

---

## 23. Resultado esperado de la metodología

La aplicación de este protocolo debe producir:

- menos errores repetidos;
- cambios pequeños y recuperables;
- mayor precisión técnica;
- trazabilidad completa en GitHub;
- validación real antes de avanzar;
- documentación alineada con cada producto;
- conocimiento reutilizable fuera de los repositorios de aplicación;
- menor dependencia de chats o memoria informal;
- posibilidad de retomar el trabajo con otro agente;
- una base de conocimiento profesional que crece a partir de desarrollos reales y validados.
