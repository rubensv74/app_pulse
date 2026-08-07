# Protocolo de Implementación Incremental Asistida por IA

## Contrato operativo reutilizable para desarrollo, validación y documentación

**Versión:** 2.0  
**Estado:** Activo  
**Idioma:** Español  
**Ámbito:** desarrollo de software asistido por IA, con especial aplicación a Power Apps, Power Automate, SQL, componentes reutilizables, integraciones, documentación técnica y manuales de usuario.  
**Documento relacionado:** `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md` para la construcción de pantallas Canvas Power Apps desde cero.

---

# 1. Finalidad

Este protocolo define una forma de trabajo para transformar un encargo técnico amplio en una secuencia de **incrementos pequeños, verificables, trazables y reversibles**.

El objetivo principal no es generar código rápidamente. El objetivo es reducir incertidumbre, contener errores, evitar regresiones y conseguir que cada avance quede:

- implementado;
- guardado en el repositorio;
- versionado;
- documentado;
- validado en la herramienta real;
- preparado para que otro desarrollador o agente de IA pueda continuar el trabajo.

La metodología se basa en una regla central:

> **Analizar → diseñar → dividir → implementar una pieza → guardar → validar → corregir → documentar → continuar.**

Nunca se considera suficiente una respuesta de chat, un archivo descargable o un fragmento de código aislado si el desarrollo forma parte de un repositorio. El resultado definitivo debe quedar archivado en la estructura acordada del repositorio.

---

# 2. Denominación y naturaleza del protocolo

La metodología se denomina:

> **Protocolo de Implementación Incremental Asistida por IA**

El encargo concreto que se entrega a un modelo o agente se denomina:

> **Encargo Técnico Incremental**

Este documento no debe interpretarse como un simple prompt. Es un **contrato operativo** entre:

- el responsable funcional o técnico;
- el repositorio;
- las herramientas de desarrollo;
- los entornos de validación;
- el agente o modelo de IA.

Define fuentes de verdad, límites, reglas de publicación, criterios de validación, formato de los entregables y condiciones de parada.

---

# 3. Cuándo utilizarlo

Este protocolo es especialmente adecuado cuando el trabajo incluye uno o varios de estos elementos:

- nuevas funcionalidades;
- rediseño o creación de pantallas;
- componentes reutilizables;
- fórmulas Power Fx;
- Power Automate flows;
- procedimientos almacenados, tablas, vistas o funciones SQL;
- APIs o contratos JSON;
- integraciones entre módulos;
- migraciones de datos;
- refactorizaciones con riesgo de regresión;
- archivos extensos o frágiles;
- validación manual obligatoria;
- dependencias que no pueden probarse completamente desde el agente;
- necesidad de documentación funcional y técnica continua.

Puede utilizarse también fuera de Power Platform siempre que exista un repositorio y una forma objetiva de validar los incrementos.

---

# 4. Principios no negociables

## 4.1. El repositorio es la fuente de verdad técnica

Antes de implementar, el agente debe inspeccionar el estado real del repositorio y trabajar sobre la rama y commit acordados.

No debe:

- inventar rutas;
- asumir nombres de archivos, controles, funciones o variables;
- asumir columnas SQL;
- asumir parámetros de flows o APIs;
- reutilizar contratos antiguos sin comprobar el código actual;
- sustituir la inspección del repositorio por memoria de conversaciones anteriores;
- afirmar que un archivo existe o está publicado sin verificarlo.

Cuando exista contradicción entre una explicación anterior y el código actual, prevalece el código actual salvo que el responsable indique expresamente que debe cambiarse.

---

## 4.2. Todo desarrollo debe quedar guardado en el repositorio

Esta regla es obligatoria.

Cualquier código, documento, script, configuración, SQL, YAML, Power Fx, contrato, manual o artefacto textual creado como parte del desarrollo debe guardarse en la ruta correcta del repositorio.

Una descarga ofrecida al usuario puede ser útil como comodidad adicional, pero:

> **una descarga nunca sustituye al archivo versionado en el repositorio.**

El agente no debe considerar finalizado un entregable mientras solo exista en el chat o como archivo temporal.

---

## 4.3. Un incremento, una responsabilidad principal

Cada bloque o incremento debe resolver una responsabilidad concreta y validable.

Ejemplos:

- crear el shell de una pantalla;
- añadir el encabezado;
- definir el estado runtime;
- implementar un listado;
- conectar una lectura remota;
- habilitar un guardado;
- añadir un modal;
- introducir un procedimiento SQL;
- integrar una pantalla origen con una pantalla destino.

No deben mezclarse cambios visuales, persistencia, navegación, SQL e integración remota en un único bloque salvo que técnicamente sean inseparables.

---

## 4.4. No avanzar sobre errores conocidos

Si el incremento actual produce un error nuevo o no supera la prueba mínima, el trabajo se detiene en ese punto.

El siguiente bloque no debe considerarse listo hasta que:

1. se haya localizado la causa;
2. se haya corregido el archivo fuente;
3. se haya guardado la corrección en el repositorio;
4. se haya registrado el aprendizaje cuando sea reutilizable;
5. el responsable confirme la validación.

---

## 4.5. Los errores se convierten en conocimiento reutilizable

Un error resuelto no debe quedar únicamente como una conversación pasada.

Cuando sea reutilizable debe producir:

- una corrección de código;
- una entrada en el registro de compatibilidad o incidencias;
- una regla preventiva;
- cuando proceda, documentación en el repositorio de conocimiento compartido.

La finalidad es evitar que otro agente vuelva a cometer el mismo error meses después.

---

## 4.6. La documentación se escribe durante el desarrollo

No se espera al final.

La documentación mínima debe evolucionar junto con el código:

- README de la funcionalidad;
- decisiones de arquitectura;
- contratos de datos;
- registro de errores y compatibilidad;
- manual de usuario;
- limitaciones conocidas;
- estado de los incrementos;
- pruebas realizadas.

---

## 4.7. La herramienta real de ejecución tiene la última palabra

La revisión estática del agente es necesaria, pero no sustituye la ejecución real.

Ejemplos:

- Power Apps Studio y App Checker prevalecen sobre una validación teórica del YAML;
- SQL Server prevalece sobre una inspección textual del script;
- una compilación Android real prevalece sobre la apariencia correcta del código;
- una ejecución de flow prevalece sobre una inferencia del contrato.

El agente debe distinguir siempre entre:

- **validación estática realizada por el agente**;
- **validación real realizada en la herramienta o entorno objetivo**.

---

# 5. Ficha de configuración del encargo

Antes de iniciar un nuevo trabajo deben completarse los siguientes placeholders. Los campos no aplicables se indicarán expresamente como `NO APLICA`.

## 5.1. Identificación

| Campo | Valor |
|---|---|
| Proyecto | `[NOMBRE_PROYECTO]` |
| Aplicación / solución | `[NOMBRE_APLICACION]` |
| Funcionalidad | `[NOMBRE_FUNCIONALIDAD]` |
| Repositorio | `[OWNER/REPOSITORY]` |
| URL | `[URL_REPOSITORIO]` |
| Rama base | `[RAMA_BASE]` |
| Política de publicación | `[DIRECTO_MAIN / RAMA_Y_PR]` |
| Ruta local | `[RUTA_LOCAL]` |
| Entorno de ejecución | `[ENTORNO]` |
| Responsable de validación | `[RESPONSABLE]` |

## 5.2. Rutas del repositorio

| Información | Ruta |
|---|---|
| Código fuente principal | `[RUTA_CODIGO]` |
| Pantallas | `[RUTA_PANTALLAS]` |
| Componentes | `[RUTA_COMPONENTES]` |
| Flows / automatizaciones | `[RUTA_FLOWS]` |
| SQL | `[RUTA_SQL]` |
| Contratos / schemas | `[RUTA_CONTRATOS]` |
| Configuración | `[RUTA_CONFIG]` |
| Tests | `[RUTA_TESTS]` |
| Bloques incrementales | `[RUTA_BLOQUES]` |
| Análisis / auditorías | `[RUTA_ANALISIS]` |
| Documentación técnica | `[RUTA_DOC_TECNICA]` |
| Documentación funcional | `[RUTA_DOC_FUNCIONAL]` |
| Manual de usuario | `[RUTA_MANUAL]` |
| Registro de errores | `[RUTA_ERRORES]` |
| Decisiones de arquitectura | `[RUTA_DECISIONES]` |

## 5.3. Repositorio de conocimiento reutilizable

Cuando exista un repositorio separado para conocimiento transversal:

| Campo | Valor |
|---|---|
| Repositorio de conocimiento | `[OWNER/KNOWLEDGE_REPOSITORY]` |
| Ruta de conocimiento técnico | `[RUTA_KNOWLEDGE_TECNICO]` |
| Ruta de patrones | `[RUTA_KNOWLEDGE_PATRONES]` |
| Ruta de errores conocidos | `[RUTA_KNOWLEDGE_ERRORES]` |

Solo debe duplicarse allí conocimiento **generalizable**. La documentación específica de la aplicación permanece en su repositorio de origen.

---

# 6. Orden de prioridad de las fuentes de verdad

Cuando exista discrepancia, se utilizará este orden:

1. comportamiento real confirmado en producción o entorno objetivo, cuando sea seguro observarlo;
2. código actual del repositorio en la rama acordada;
3. contratos reales de base de datos, APIs, flows y componentes;
4. resultados de compilación, pruebas y herramientas de validación;
5. documentación técnica actualizada;
6. decisiones funcionales expresas del responsable;
7. prototipos, capturas o documentación histórica;
8. hipótesis del agente.

Las hipótesis deben declararse y nunca presentarse como contratos confirmados.

---

# 7. Fase 0 — Auditoría obligatoria

Antes de crear código el agente debe realizar una auditoría suficiente para comprender el entorno.

## 7.1. Comprobaciones Git

Cuando el agente tenga acceso al repositorio debe verificar, según las herramientas disponibles:

```text
rama actual
commit actual
estado de trabajo
últimos commits relevantes
```

Si el HEAD real ha avanzado respecto del esperado, debe trabajar sobre el estado real y documentarlo.

## 7.2. Inspección técnica mínima

Debe inspeccionar:

- estructura del repositorio;
- archivos relacionados con la funcionalidad;
- implementaciones equivalentes existentes;
- convenciones de nombres;
- componentes reutilizables;
- temas o design system;
- modelos y contratos de datos;
- flows o servicios;
- SQL relacionado;
- permisos y roles;
- navegación origen/destino;
- documentación previa;
- errores conocidos.

## 7.3. Entregable de auditoría

Antes del primer incremento debe quedar claro:

- qué archivos se han inspeccionado;
- qué contratos están confirmados;
- qué elementos se reutilizarán;
- qué huecos existen;
- qué riesgos se han identificado;
- qué no puede inventarse;
- qué decisiones necesitan validación humana;
- cómo se dividirá el trabajo.

---

# 8. Decisión de arquitectura antes de implementar

El agente no debe empezar a generar código complejo hasta haber definido la arquitectura del cambio.

Según el tipo de encargo puede incluir:

- árbol de controles;
- flujo de navegación;
- responsabilidades por componente;
- variables y colecciones;
- contratos de entrada/salida;
- llamadas remotas;
- persistencia;
- tablas y procedimientos SQL;
- estados de loading/error/empty;
- protección frente a cambios sin guardar;
- permisos.

La arquitectura puede refinarse posteriormente, pero debe existir un mapa suficientemente estable para evitar improvisación bloque a bloque.

---

# 9. División en incrementos

El trabajo se divide en una secuencia numerada.

Cada incremento debe ser suficientemente pequeño para:

- integrarse sin afectar demasiadas áreas;
- probarse de manera aislada;
- revertirse con facilidad;
- permitir identificar el origen de un error.

## 9.1. Tipos de operación

Se utilizarán etiquetas claras, por ejemplo:

```text
CREATE FILE
ADD CONTROL
ADD AS CHILD
ADD AS SIBLING
REPLACE CONTROL
REPLACE PROPERTY
PATCH FILE
ADD FLOW CONTRACT
ADD SQL OBJECT
TEST SEED
DOCUMENTATION
CANONICAL CONSOLIDATION
```

## 9.2. Orden recomendado

Un orden típico es:

1. estructura o foundation;
2. estado y contratos internos;
3. funcionalidad local;
4. lectura remota;
5. edición;
6. persistencia;
7. validaciones y errores;
8. integración con otros módulos;
9. hardening;
10. documentación y consolidación.

Para pantallas Power Apps desde cero debe utilizarse además `PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`.

---

# 10. Contrato obligatorio de cada incremento

Cada bloque o archivo incremental debe indicar como mínimo:

```text
BLOCK / INCREMENT [N]
Name: [NOMBRE]
Operation: [OPERACION]
Target file: [ARCHIVO]
Target element: [ELEMENTO]
Parent / anchor: [PADRE_O_ANCLA]
Exact location: [POSICION]
Dependencies: [DEPENDENCIAS]
Scope: [QUE_HACE]
Out of scope: [QUE_NO_HACE]
Compatibility constraints: [REGLAS]
Validation: [PRUEBA_MINIMA]
Expected result: [RESULTADO]
```

Si el incremento modifica una fórmula o función existente, debe indicar expresamente si el usuario debe:

- sustituirla completa;
- añadir contenido al principio;
- añadir contenido al final;
- insertar un fragmento en un punto concreto.

No se aceptan instrucciones ambiguas como “añade esto al control” cuando pueda existir más de una ubicación razonable.

---

# 11. Publicación y trazabilidad Git

## 11.1. Política de rama

La modalidad debe acordarse al inicio.

### Modalidad A — Rama + Pull Request

Preferida cuando:

- se modifica código canónico crítico;
- existe más de un colaborador;
- se requiere revisión;
- el cambio afecta a producción de forma directa.

### Modalidad B — Publicación directa en `main`

Puede utilizarse cuando:

- el responsable lo haya solicitado expresamente;
- se publican bloques auxiliares o documentación;
- existe una única línea de trabajo controlada.

## 11.2. Reglas obligatorias

- Un propósito principal por commit.
- No mezclar correcciones no relacionadas.
- Utilizar mensajes descriptivos.
- Verificar la rama después de publicar.
- Verificar la existencia del archivo antes de afirmar que está disponible.
- No sobrescribir archivos canónicos prematuramente cuando todavía se está validando un bloque experimental.

Ejemplos:

```text
feat(module): add review queue
fix(module): correct flow parameter order
docs(module): update user manual
test(module): add optional seed
refactor(module): consolidate validated blocks
```

---

# 12. Regla de artefactos y descargas

Cuando el agente genere un archivo descargable, ZIP, documento o script:

1. debe indicar si es un artefacto auxiliar o la fuente definitiva;
2. si forma parte del proyecto, debe existir también en el repositorio;
3. el repositorio mantiene la versión canónica;
4. cualquier archivo temporal debe identificarse como tal;
5. nunca se debe afirmar que algo está guardado si solo existe como enlace de descarga temporal.

---

# 13. Datos de prueba

Los test seeds y fixtures deben estar separados del código productivo.

Convención recomendada:

```text
[N]A_[descripcion].optional.powerfx
[N]A_[descripcion].test.sql
[N]A_[descripcion].fixture.json
[N]A_[descripcion].mock.yaml
```

Cada archivo debe especificar:

- finalidad;
- prerrequisitos;
- cómo ejecutarlo;
- qué modifica;
- resultado esperado;
- acciones prohibidas con datos ficticios;
- momento en que debe eliminarse.

Nunca deben quedar registros, botones, mocks o credenciales de prueba en la versión final sin una justificación explícita.

---

# 14. Validación incremental

La validación se realiza por capas.

## 14.1. Validación estática

El agente comprueba:

- estructura;
- sintaxis razonable;
- referencias;
- contratos;
- propiedades conocidas;
- compatibilidad con ejemplos reales del repositorio;
- posibles regresiones.

## 14.2. Validación en herramienta objetivo

El responsable valida en la herramienta real.

Ejemplos:

### Power Apps

- guardar;
- Source Code validation;
- App Checker;
- navegación;
- comportamiento funcional.

### SQL

- parseo/compilación;
- ejecución controlada;
- esquema de salida;
- rendimiento cuando proceda.

### Aplicaciones compiladas

- build;
- unit tests;
- instrumented/integration tests;
- lint;
- ejecución manual.

## 14.3. Confirmación estándar

Cuando un incremento está correcto, el responsable puede responder:

```text
Bloque [N] integrado sin errores.
```

o una confirmación equivalente e inequívoca.

Solo entonces se continúa.

---

# 15. Protocolo de tratamiento de errores

Cuando aparece un error, se detiene la secuencia.

El responsable debe aportar, siempre que exista:

- mensaje completo;
- línea o ubicación;
- captura;
- control / función / SP afectado;
- versión del control o runtime;
- Session ID;
- pasos para reproducirlo.

El agente debe:

1. localizar la causa real;
2. evitar parches basados únicamente en síntomas;
3. corregir el archivo fuente del repositorio;
4. buscar el mismo patrón en bloques pendientes;
5. registrar el incidente cuando sea reutilizable;
6. publicar un commit de corrección;
7. proporcionar una prueba mínima;
8. esperar una nueva validación.

---

# 16. Registro de compatibilidad y lecciones aprendidas

Cuando la tecnología tenga restricciones particulares debe existir un documento de compatibilidad, por ejemplo:

```text
[RUTA_ERRORES]/COMPATIBILITY.md
```

Debe contener:

- identificador del incidente;
- fecha;
- mensaje de error;
- tecnología/control/versión;
- causa;
- corrección;
- patrón seguro alternativo;
- regla preventiva;
- bloques o archivos afectados.

Una regla confirmada debe añadirse también al checklist de bloques futuros.

---

# 17. Estados funcionales obligatorios

Cualquier funcionalidad que dependa de datos o servicios debe diseñar explícitamente sus estados.

Como mínimo, cuando proceda:

```text
No context / no selection
Loading
Loaded with data
Loaded empty
Error
Retry
```

Si existe edición:

```text
Saved
Dirty / Unsaved
Saving
Save success
Save error
Discard / Reset
```

No debe diseñarse exclusivamente el “happy path”.

---

# 18. Integraciones remotas

Antes de utilizar un flow, API, SP o servicio deben confirmarse:

- nombre real;
- orden de parámetros;
- tipos;
- valores opcionales;
- entidad o contexto;
- respuesta;
- errores;
- paginación;
- permisos.

No deben copiarse contratos de otro módulo sin comprobar que coinciden.

Cuando un contrato no esté disponible, se documentará como **bloqueador** o **suposición pendiente**, nunca como hecho.

---

# 19. Escritura y persistencia

Cuando exista guardado:

- distinguir claramente estado local y estado persistido;
- no declarar éxito antes de recibir confirmación del servicio;
- cuando el backend devuelva una versión autoritativa, reconstruir el estado desde esa respuesta;
- mantener protección ante navegación con cambios sin guardar;
- documentar roles y permisos;
- contemplar error y reintento.

Una actualización local de una colección no debe describirse como persistencia si no se ha ejecutado un servicio real.

---

# 20. Documentación viva

## 20.1. README de funcionalidad

Debe incluir:

- propósito;
- arquitectura;
- orden de bloques;
- estado de cada bloque;
- contratos relevantes;
- rutas importantes;
- restricciones.

## 20.2. Manual de usuario

Debe redactarse en lenguaje sencillo y describir el comportamiento real, no el previsto.

Debe incluir cuando aplique:

- finalidad;
- partes de la pantalla o módulo;
- flujos de uso;
- estados;
- permisos;
- limitaciones;
- resolución de problemas;
- historial de cambios.

## 20.3. Decisiones de arquitectura

Las decisiones que condicionen el futuro deben documentarse, especialmente:

- alternativas descartadas;
- decisiones de persistencia;
- razones para reutilizar o no un componente;
- contratos temporales;
- deuda técnica aceptada.

---

# 21. Captura de conocimiento transversal

Cuando durante el desarrollo aparezca conocimiento reutilizable para otros proyectos, debe evaluarse si debe archivarse también en el repositorio de conocimiento.

Ejemplos:

- patrones Power Apps seguros;
- incompatibilidades de controles;
- patrones de paginación;
- diseños de SP reutilizables;
- reglas de integración con Power Automate;
- checklists de auditoría;
- patrones de documentación.

No debe copiarse allí información específica que dependa de nombres internos, secretos, datos de negocio o contratos exclusivos del proyecto salvo que sea necesario y apropiado.

---

# 22. Handoff entre agentes o sesiones

El desarrollo debe poder retomarse sin depender del historial completo del chat.

Antes de una pausa relevante debe existir suficiente información en el repositorio para conocer:

- último bloque validado;
- siguiente bloque previsto;
- estado del código;
- problemas abiertos;
- contratos confirmados;
- datos de prueba disponibles;
- archivos que no deben modificarse todavía.

Cuando sea necesario puede mantenerse un documento:

```text
CURRENT_STATE.md
HANDOFF.md
IMPLEMENTATION_STATUS.md
```

---

# 23. Consolidación canónica

Durante el desarrollo incremental puede ser conveniente mantener bloques separados de los archivos canónicos.

Al finalizar la validación:

1. integrar únicamente los bloques validados;
2. consolidarlos en la estructura canónica;
3. eliminar placeholders y test scaffolding;
4. comprobar referencias rotas;
5. actualizar documentación;
6. validar la versión consolidada de nuevo.

La existencia de bloques auxiliares no sustituye la consolidación final cuando el producto necesita un archivo fuente canónico.

---

# 24. Definition of Done

Una funcionalidad no está terminada solo porque “funciona”.

Debe cumplirse, según aplique:

- código implementado;
- código guardado en el repositorio;
- rama correcta;
- commits trazables;
- pruebas pasadas;
- validación real realizada;
- flujos de error comprobados;
- permisos comprobados;
- datos de prueba retirados;
- documentación actualizada;
- manual actualizado;
- errores conocidos registrados;
- integración completa;
- estado canónico consolidado;
- repositorio limpio o con cambios pendientes explícitamente documentados.

---

# 25. Formato esperado de las respuestas del agente

Después de cada incremento la respuesta debe ser operativa y contener, en este orden cuando aplique:

1. **Incremento publicado**.
2. **Ruta exacta y commit**.
3. **Qué problema resuelve**.
4. **Operación exacta de integración**.
5. **Archivo/control/función afectado**.
6. **Estructura antes y después**.
7. **Prueba mínima**.
8. **Resultado esperado**.
9. **Limitaciones o riesgos**.
10. **Condición para continuar**.

Debe evitar formulaciones ambiguas como:

```text
“pega esto por ahí”
“debería funcionar”
“he guardado el archivo” sin indicar dónde
“usa el flow habitual” sin confirmar su contrato
```

---

# 26. Plantilla maestra de Encargo Técnico Incremental

El siguiente bloque puede entregarse a ChatGPT, Codex u otro agente. Todos los placeholders deben resolverse antes de comenzar o mediante la auditoría inicial.

```markdown
# ENCARGO TÉCNICO INCREMENTAL — [NOMBRE_FUNCIONALIDAD]

Debes trabajar siguiendo el documento:

`[RUTA_PROTOCOLO]/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`

Si el trabajo consiste en crear una pantalla Canvas Power Apps desde cero, debes aplicar además:

`[RUTA_PROTOCOLO]/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`

## 1. Contexto

- Proyecto: `[PROYECTO]`
- Aplicación: `[APLICACION]`
- Repositorio: `[OWNER/REPOSITORY]`
- Rama base: `[RAMA]`
- Política de publicación: `[DIRECTO_MAIN / RAMA_Y_PR]`
- Ruta local: `[RUTA_LOCAL]`
- Funcionalidad: `[FUNCIONALIDAD]`

## 2. Objetivo

`[DESCRIPCION_OBJETIVO]`

Resultados esperados:

- `[RESULTADO_1]`
- `[RESULTADO_2]`
- `[RESULTADO_3]`

Fuera de alcance:

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`

## 3. Fuentes de verdad

Debes inspeccionar antes de implementar:

- código: `[RUTA_CODIGO]`
- pantallas: `[RUTA_PANTALLAS]`
- componentes: `[RUTA_COMPONENTES]`
- flows: `[RUTA_FLOWS]`
- SQL: `[RUTA_SQL]`
- contratos: `[RUTA_CONTRATOS]`
- tests: `[RUTA_TESTS]`
- documentación: `[RUTA_DOC]`
- registro de errores: `[RUTA_ERRORES]`

El repositorio actual es la fuente de verdad. No inventes contratos, nombres, columnas, parámetros ni propiedades.

## 4. Regla de repositorio

Todo desarrollo creado durante este encargo debe quedar guardado y versionado en el repositorio correspondiente.

Una descarga o contenido mostrado en el chat es únicamente una ayuda adicional y no sustituye al archivo guardado en Git.

## 5. Metodología

1. Audita primero el estado actual.
2. Confirma contratos y dependencias.
3. Propón la arquitectura.
4. Divide el trabajo en incrementos pequeños.
5. Implementa un único incremento cada vez.
6. Guarda el incremento en el repositorio y proporciona ruta + commit.
7. Indica exactamente cómo validarlo.
8. Detente hasta recibir confirmación cuando la validación dependa del usuario.
9. Ante cualquier error, corrige primero el archivo fuente y registra el aprendizaje.
10. Mantén la documentación viva.

## 6. Documentación obligatoria

Mantén actualizados cuando apliquen:

- `[RUTA_README]`
- `[RUTA_MANUAL]`
- `[RUTA_ERRORES]`
- `[RUTA_DECISIONES]`
- `[RUTA_STATUS]`

Si surge conocimiento reutilizable para otros proyectos, archívalo también en:

`[RUTA_REPOSITORIO_CONOCIMIENTO]`

## 7. Validación

Después de cada incremento indicarás:

- qué validar;
- dónde;
- pasos exactos;
- resultado esperado;
- errores que deben impedir continuar.

Yo confirmaré mediante:

`Bloque [N] integrado sin errores.`

o proporcionaré el error completo.

No avances sobre un error no resuelto.

## 8. Primera entrega

No empieces generando toda la solución.

Tu primera entrega debe contener:

1. estado del repositorio y fuentes inspeccionadas;
2. contratos confirmados;
3. riesgos y huecos;
4. arquitectura propuesta;
5. secuencia numerada de incrementos;
6. estructura documental que debe crearse o mantenerse;
7. únicamente el primer incremento pequeño y validable.
```

---

# 27. Checklist de inicio

Antes de comenzar:

- [ ] Repositorio confirmado.
- [ ] Rama confirmada.
- [ ] Política de publicación confirmada.
- [ ] Commit de partida conocido.
- [ ] Fuentes de verdad localizadas.
- [ ] Objetivo y exclusiones entendidos.
- [ ] Contratos inspeccionados.
- [ ] Arquitectura propuesta.
- [ ] Secuencia incremental definida.
- [ ] Carpeta de bloques definida si aplica.
- [ ] Documentación viva localizada o creada.
- [ ] Registro de errores localizado o creado.
- [ ] Estrategia de pruebas definida.

---

# 28. Checklist de cierre

Antes de declarar terminado el encargo:

- [ ] Todos los incrementos previstos están resueltos o las exclusiones están documentadas.
- [ ] Todo el código está en el repositorio.
- [ ] No depende de archivos temporales o descargas externas.
- [ ] Tests y validaciones están documentados.
- [ ] No quedan datos de prueba involuntarios.
- [ ] No quedan placeholders no aceptados.
- [ ] README actualizado.
- [ ] Manual actualizado.
- [ ] Registro de errores actualizado.
- [ ] Decisiones relevantes documentadas.
- [ ] Código canónico consolidado cuando corresponda.
- [ ] Estado Git y rama final verificados.
- [ ] Handoff suficiente para que otro agente pueda continuar.

---

# 29. Resumen operativo

La metodología puede resumirse en diez reglas:

1. **Inspeccionar antes de escribir.**
2. **Trabajar contra el repositorio real.**
3. **Diseñar antes de implementar.**
4. **Dividir el trabajo en piezas pequeñas.**
5. **Guardar cada avance en Git.**
6. **Validar cada pieza en la herramienta real.**
7. **No avanzar sobre errores.**
8. **Convertir los errores en conocimiento.**
9. **Documentar mientras se desarrolla.**
10. **Consolidar y dejar un handoff reproducible.**

> **El valor del protocolo no está en producir más código, sino en hacer que cada cambio sea comprensible, verificable, recuperable y reutilizable.**
