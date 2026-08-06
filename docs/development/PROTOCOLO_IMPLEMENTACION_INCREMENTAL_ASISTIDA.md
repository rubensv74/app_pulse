# Protocolo de Implementación Incremental Asistida por IA

## Plantilla maestra de encargo técnico reutilizable

**Versión:** 1.0  
**Estado:** Activo  
**Idioma:** Español  
**Ámbito:** Power Apps, Power Automate, SQL, componentes reutilizables, documentación técnica y manuales de usuario  
**Finalidad:** convertir un encargo amplio en una secuencia de bloques pequeños, verificables, versionados y fáciles de corregir.

---

## 1. Denominación formal

La metodología se denomina:

> **Protocolo de Implementación Incremental Asistida por IA**

El documento que se entrega al modelo o agente para iniciar un trabajo concreto se denomina:

> **Plantilla maestra de encargo técnico incremental**

No es únicamente un prompt. Es un contrato operativo que define:

- fuentes de verdad;
- alcance;
- rutas del repositorio;
- reglas de implementación;
- formato de los entregables;
- orden de validación;
- gestión de errores;
- documentación viva;
- condiciones para avanzar o detenerse.

---

## 2. Cuándo utilizar este protocolo

Este protocolo debe utilizarse cuando el trabajo incluya una o varias de estas situaciones:

- creación o rediseño de una pantalla Power Apps;
- integración de componentes reutilizables;
- modificación de fórmulas Power Fx;
- incorporación de flows de Power Automate;
- creación o ajuste de tablas, vistas o procedimientos almacenados SQL;
- construcción de contratos de datos;
- trabajo sobre archivos extensos o frágiles;
- necesidad de probar cada incremento manualmente en Studio;
- desarrollo donde un error pequeño puede invalidar un bloque completo;
- necesidad de mantener manuales de usuario y registros técnicos durante el desarrollo.

No se recomienda entregar una pantalla monolítica o una implementación completa de una sola vez cuando existen dependencias de Studio, YAML, flows, SQL o componentes todavía no validados.

---

## 3. Principios obligatorios

### 3.1. El repositorio es la fuente de verdad

Antes de proponer código, el agente debe inspeccionar el estado real del repositorio.

No debe:

- inventar rutas;
- asumir nombres de controles;
- asumir contratos de flows;
- asumir columnas SQL;
- copiar patrones de otro proyecto sin verificar compatibilidad;
- utilizar recuerdos anteriores como sustituto del código actual.

### 3.2. Un bloque, una responsabilidad

Cada bloque debe resolver una responsabilidad concreta y comprobable.

Ejemplos:

- estructura de pantalla;
- encabezado;
- estado tipado;
- cola de registros;
- panel de detalle;
- barra de acciones;
- comentarios;
- campos personalizados;
- modal de ayuda;
- integración con una pantalla origen.

No se deben mezclar en un mismo bloque estructura visual, flows, persistencia SQL y navegación salvo que sean inseparables.

### 3.3. No avanzar sin validación

El siguiente bloque no debe publicarse como listo para integrar hasta que el usuario confirme que el bloque anterior:

1. se importa o pega correctamente;
2. guarda sin errores;
3. abre en Studio;
4. no añade errores nuevos en App Checker;
5. cumple la prueba mínima acordada.

### 3.4. Los errores se convierten en reglas

Todo error confirmado debe producir tres acciones:

1. corrección del archivo fuente;
2. registro del incidente;
3. nueva regla preventiva aplicable a bloques posteriores.

### 3.5. La documentación evoluciona con el producto

No se espera al final para redactar documentación.

Deben mantenerse desde el inicio:

- registro de compatibilidad y errores;
- README de la funcionalidad;
- manual de usuario;
- decisiones de arquitectura;
- limitaciones conocidas;
- estado de validación de cada bloque.

---

## 4. Ficha de configuración del encargo

Completar todos los placeholders antes de iniciar el trabajo.

### 4.1. Identificación general

| Campo | Valor |
|---|---|
| Proyecto | `[NOMBRE_PROYECTO]` |
| Repositorio | `[OWNER/REPOSITORY]` |
| URL del repositorio | `[URL_REPOSITORIO]` |
| Rama base | `[RAMA_BASE]` |
| Rama de trabajo | `[RAMA_TRABAJO_O_DIRECTO_MAIN]` |
| Ruta local | `[RUTA_LOCAL_REPOSITORIO]` |
| Entorno Power Platform | `[ENTORNO_POWER_PLATFORM]` |
| Solución | `[NOMBRE_SOLUCION]` |
| Funcionalidad | `[NOMBRE_FUNCIONALIDAD]` |
| Pantalla o módulo objetivo | `[PANTALLA_O_MODULO]` |
| Responsable de validación | `[RESPONSABLE_VALIDACION]` |

### 4.2. Rutas del repositorio

| Tipo de información | Ruta |
|---|---|
| Pantallas Power Apps | `[RUTA_PANTALLAS]` |
| Componentes Power Apps | `[RUTA_COMPONENTES]` |
| App / configuración global | `[RUTA_APP_CONFIG]` |
| Power Automate / flows | `[RUTA_FLOWS]` |
| SQL — tablas | `[RUTA_SQL_TABLAS]` |
| SQL — procedimientos almacenados | `[RUTA_SQL_SP]` |
| SQL — vistas y funciones | `[RUTA_SQL_OTROS]` |
| Contratos de datos | `[RUTA_CONTRATOS]` |
| Mapeos | `[RUTA_MAPEOS]` |
| Tests | `[RUTA_TESTS]` |
| Documentación funcional | `[RUTA_DOC_FUNCIONAL]` |
| Documentación técnica | `[RUTA_DOC_TECNICA]` |
| Manuales de usuario | `[RUTA_MANUALES]` |
| Registro de errores/compatibilidad | `[RUTA_REGISTRO_ERRORES]` |
| Carpeta de bloques incrementales | `[RUTA_BLOQUES]` |

Utilizar `NO APLICA` cuando una categoría no exista. No dejar rutas ambiguas.

### 4.3. Tecnologías y versiones

| Elemento | Valor |
|---|---|
| Power Apps | `[TIPO_APP_Y_VERSIONES_CONTROLES_RELEVANTES]` |
| Power Fx | `[CONFIGURACION_REGIONAL_O_SEPARADORES]` |
| Power Automate | `[TIPO_DE_FLOWS]` |
| Base de datos | `[MOTOR_Y_VERSION]` |
| CLI | `[PAC_CLI_VERSION_SI_APLICA]` |
| Formato fuente | `[SOURCE_CODE_SCHEMA_OTRO]` |
| Herramientas de desarrollo | `[VS_CODE_CODEX_OTRAS]` |

---

## 5. Definición del objetivo

### 5.1. Problema que debe resolverse

`[DESCRIBIR_PROBLEMA_ACTUAL]`

### 5.2. Resultado esperado

`[DESCRIBIR_RESULTADO_FUNCIONAL_Y_VISUAL]`

### 5.3. Usuarios y contexto de uso

`[TIPOS_DE_USUARIO_REUNIONES_FLUJO_OPERATIVO]`

### 5.4. Alcance incluido

- `[ALCANCE_1]`
- `[ALCANCE_2]`
- `[ALCANCE_3]`

### 5.5. Fuera de alcance

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`
- `[EXCLUSION_3]`

### 5.6. Restricciones no negociables

- `[RESTRICCION_TECNICA_1]`
- `[RESTRICCION_FUNCIONAL_2]`
- `[RESTRICCION_UX_3]`
- `[RESTRICCION_SEGURIDAD_4]`

---

## 6. Orden de prioridad de las fuentes de verdad

Cuando exista discrepancia, se aplicará este orden:

1. código actual del repositorio en la rama indicada;
2. contratos reales de flows, SQL y componentes;
3. comportamiento confirmado en Power Apps Studio;
4. documentación técnica actualizada;
5. decisiones expresas del responsable funcional;
6. prototipos o capturas;
7. hipótesis del agente.

Las hipótesis siempre deben identificarse como tales y no pueden sustituir un contrato real.

---

## 7. Fase 0 — Auditoría obligatoria antes de implementar

El agente debe realizar una auditoría breve pero suficiente.

### 7.1. Inspección mínima

- estructura del repositorio;
- rama y commit de partida;
- archivos de pantalla relacionados;
- componentes reutilizables disponibles;
- variables globales y colecciones existentes;
- contratos de flows;
- tablas y procedimientos SQL relacionados;
- navegación y pantallas origen/destino;
- documentación y decisiones previas;
- errores de compatibilidad conocidos.

### 7.2. Entregable de auditoría

Antes del primer bloque, debe indicar:

- archivos inspeccionados;
- contratos confirmados;
- huecos o riesgos;
- decisiones de arquitectura;
- elementos que no se deben inventar;
- propuesta de división en bloques.

### 7.3. Condiciones de parada

El agente debe detenerse y pedir aclaración cuando falte un dato que pueda cambiar la arquitectura, por ejemplo:

- identificador real de una entidad;
- contrato de un flow;
- origen de una colección;
- política de persistencia;
- pantalla de retorno;
- reglas de permisos;
- alcance clínico, legal o de seguridad.

No debe detenerse por detalles menores que puedan resolverse inspeccionando el repositorio.

---

## 8. Diseño de la secuencia incremental

La funcionalidad debe dividirse en una lista numerada de bloques.

### 8.1. Orden recomendado

1. esqueleto o contenedor raíz;
2. encabezado y navegación local;
3. layout global;
4. variables y colecciones tipadas;
5. listado o cola principal;
6. panel de detalle;
7. acciones locales;
8. actividad o historial de sesión;
9. lectura de datos remotos;
10. edición y guardado;
11. indicadores y gráficos;
12. tablas relacionadas;
13. modales y protección ante cambios;
14. integración desde pantallas origen;
15. limpieza de datos de prueba;
16. documentación y cierre.

El orden puede adaptarse, pero debe conservar la regla: primero estructura y estado; después funcionalidad; finalmente integración y persistencia.

### 8.2. Tipos de bloques

- `CREATE FILE`: crea un archivo completo.
- `ADD AS CHILD`: añade un control como hijo.
- `ADD AS SIBLING`: añade un control al mismo nivel.
- `REPLACE CONTROL`: sustituye un nodo completo.
- `REPLACE PROPERTY`: sustituye una propiedad completa, por ejemplo `OnVisible`.
- `PATCH EXISTING FILE`: modifica un archivo canónico.
- `TEST SEED`: añade datos temporales de prueba.
- `DOCUMENTATION`: actualiza manuales, README o registros.

---

## 9. Contrato obligatorio de cada bloque

Cada archivo de bloque debe comenzar con una cabecera que contenga:

```text
BLOCK [NUMERO] — [NOMBRE]
Operation: [TIPO_OPERACION]
Target file: [ARCHIVO]
Target control/property: [CONTROL_O_PROPIEDAD]
Parent: [PADRE]
Exact location: [POSICION]
Dependencies: [BLOQUES_PREVIOS]
Scope: [QUE_HACE]
Out of scope: [QUE_NO_HACE]
Compatibility: [REGLAS_RELEVANTES]
Validation: [PRUEBAS]
```

### 9.1. Información que debe acompañar al bloque en la respuesta

- ruta exacta del archivo creado;
- commit;
- operación que debe realizar el usuario;
- árbol antes y después;
- controles o propiedades afectados;
- pasos de prueba;
- resultado esperado;
- limitaciones actuales;
- instrucción explícita de no avanzar hasta validar.

### 9.2. Prohibiciones

Un bloque no debe:

- incluir fragmentos incompletos sin indicar dónde pegarlos;
- depender de controles todavía inexistentes sin declararlo;
- introducir propiedades no verificadas silenciosamente;
- mezclar datos de prueba con código de producción;
- reemplazar un archivo completo cuando basta con un control;
- modificar `main` o una rama distinta a la acordada;
- afirmar que una función persiste cuando solo modifica estado local.

---

## 10. Flujo operativo usuario–agente

Esta es la dinámica de trabajo estándar.

### Paso 1 — Preparación del agente

El agente:

1. inspecciona el repositorio;
2. confirma fuentes de verdad;
3. propone la arquitectura;
4. divide el trabajo en bloques;
5. crea el registro de compatibilidad y la carpeta de bloques si no existen.

### Paso 2 — Publicación de un bloque

El agente:

1. crea o actualiza el archivo en la rama acordada;
2. realiza un commit específico;
3. verifica que el archivo existe en la rama correcta;
4. entrega instrucciones exactas de integración.

### Paso 3 — Integración por el usuario

El usuario:

1. actualiza el repositorio local;
2. copia o integra el bloque;
3. guarda en Studio;
4. ejecuta App Checker;
5. realiza la prueba mínima;
6. informa de éxito o proporciona el error completo.

### Paso 4 — Tratamiento de errores

Cuando aparece un error, el usuario proporciona:

- mensaje completo;
- líneas;
- control y versión si aparecen;
- Session ID;
- captura cuando aporte contexto.

El agente:

1. localiza la causa en el archivo fuente;
2. corrige el bloque en el repositorio;
3. busca el mismo patrón en bloques futuros;
4. actualiza el registro de compatibilidad;
5. publica el commit de corrección;
6. no continúa hasta que el bloque corregido sea validado.

### Paso 5 — Confirmación

El usuario responde con una fórmula breve y inequívoca:

```text
Bloque [N] integrado sin errores.
```

Solo entonces se prepara el siguiente bloque.

---

## 11. Política de ramas y commits

La política debe definirse al inicio mediante el placeholder:

```text
[POLITICA_PUBLICACION]
```

Opciones habituales:

### Modalidad A — Rama de trabajo y Pull Request

Adecuada cuando:

- hay revisión de código;
- se modifican archivos canónicos;
- existen varios colaboradores;
- la funcionalidad debe agruparse antes de llegar a `main`.

### Modalidad B — Publicación directa en `main`

Adecuada cuando:

- los archivos son bloques auxiliares o documentación;
- el responsable ha pedido expresamente visibilidad inmediata;
- el repositorio tiene una única línea de trabajo controlada.

### Reglas de commit

- un propósito por commit;
- mensajes descriptivos;
- correcciones separadas de nuevas funcionalidades;
- documentación actualizada en commits propios cuando sea útil;
- nunca afirmar que algo está en `main` sin verificar la rama.

Ejemplos:

```text
feat([modulo]): add [bloque]
fix([modulo]): remove unsupported [property]
docs([modulo]): update user guide
test([modulo]): add optional test seed
```

---

## 12. Datos de prueba

Los datos de prueba deben estar separados del bloque productivo.

Formato recomendado:

```text
[N_BLOQUE]A_[descripcion].optional.powerfx
[N_BLOQUE]A_[descripcion].test.sql
[N_BLOQUE]A_[descripcion].fixture.json
```

El archivo debe indicar:

- que es opcional;
- dónde ejecutarlo;
- cómo eliminarlo;
- qué resultados deben aparecer;
- qué variables o colecciones modifica.

No se deben dejar botones, colecciones o registros de prueba en la versión final.

---

## 13. Registro de compatibilidad y errores

Debe existir un archivo específico:

```text
[RUTA_REGISTRO_ERRORES]
```

### 13.1. Contenido mínimo

- matriz de controles y propiedades incompatibles;
- incidentes numerados;
- mensaje de error;
- causa;
- corrección;
- regla preventiva;
- Session ID;
- bloques afectados;
- controles nuevos pendientes de validación.

### 13.2. Regla de expansión

Todo control o propiedad que aparezca por primera vez debe considerarse pendiente de validación hasta que Studio lo acepte.

### 13.3. Ejemplo de regla derivada

```text
Label@[VERSION] no admite Radius*.
```

La solución no consiste solo en borrar la propiedad: debe definirse un patrón alternativo seguro.

---

## 14. Manual de usuario vivo

Debe crearse desde los primeros bloques funcionales:

```text
[RUTA_MANUALES]/[MANUAL_FUNCIONALIDAD].md
```

### 14.1. Requisitos

- lenguaje sencillo;
- estructura orientada a tareas;
- explicación de cada panel;
- pasos numerados;
- diferencia entre estados similares;
- limitaciones actuales;
- resolución de problemas básicos;
- historial de versiones;
- futuras ampliaciones.

### 14.2. Regla de actualización

Cada bloque que cambie el comportamiento visible debe actualizar el manual.

### 14.3. Ayuda integrada

Cuando la pantalla lo justifique, debe existir una ayuda contextual dentro de la aplicación:

- modal o panel;
- acceso visible desde el encabezado;
- contenido coherente con el manual;
- pestañas reales cuando haya varios idiomas o secciones;
- limitaciones expresadas con claridad;
- no sustituye al manual completo del repositorio.

---

## 15. Validación por capas

### 15.1. Validación de sintaxis

- Source Code schema correcto;
- tipos y versiones de controles;
- propiedades soportadas;
- fórmulas Power Fx válidas;
- estructura YAML correcta.

### 15.2. Validación visual

- alineación;
- alturas y anchos;
- ausencia de solapamientos;
- comportamiento responsive;
- scroll;
- estados vacíos;
- estados de carga;
- jerarquía visual.

### 15.3. Validación funcional

- selección;
- filtros;
- búsqueda;
- navegación;
- acciones;
- persistencia local;
- carga remota;
- guardado;
- errores y reintentos.

### 15.4. Validación contractual

- parámetros de flows en orden correcto;
- tipos SQL correctos;
- identificadores numéricos/texto coherentes;
- JSON compatible;
- nombres reales de campos;
- paginación consistente.

### 15.5. Validación documental

- README actualizado;
- manual actualizado;
- registro de errores actualizado;
- estado de bloques actualizado;
- limitaciones explícitas.

---

## 16. Criterios para declarar un bloque validado

Un bloque solo puede marcarse como `validado` cuando:

- el usuario confirma importación correcta;
- no hay errores nuevos de App Checker atribuibles al bloque;
- la prueba mínima pasa;
- el archivo corregido está en la rama acordada;
- el README refleja su estado;
- los errores encontrados están registrados;
- el manual se actualiza cuando hay cambio funcional visible.

No basta con que el YAML parezca correcto en el repositorio.

---

## 17. Criterios de cierre de la funcionalidad

La funcionalidad se considera completada cuando:

- todos los bloques están validados;
- se han eliminado los datos de prueba;
- las integraciones origen/destino funcionan;
- la persistencia real está conectada o su ausencia está explícitamente aceptada;
- no quedan placeholders visuales;
- se han probado estados vacíos, carga y error;
- el manual coincide con el comportamiento real;
- el registro de compatibilidad está actualizado;
- el código canónico se ha incorporado a la solución o estructura final;
- existe un resumen de arquitectura y decisiones.

---

# 18. Plantilla maestra de encargo técnico incremental

Copiar el bloque siguiente en un nuevo chat, agente o sesión de desarrollo y sustituir todos los placeholders.

```markdown
# ENCARGO TÉCNICO INCREMENTAL — [NOMBRE_FUNCIONALIDAD]

Actúa como arquitecto funcional y desarrollador principal del repositorio `[OWNER/REPOSITORY]`.

## 1. Objetivo

Debemos implementar `[DESCRIPCION_OBJETIVO]` en `[PANTALLA_O_MODULO]`.

El resultado esperado es:

- `[RESULTADO_1]`
- `[RESULTADO_2]`
- `[RESULTADO_3]`

Queda fuera de alcance:

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`

## 2. Repositorio y publicación

- Repositorio: `[OWNER/REPOSITORY]`
- Rama base: `[RAMA_BASE]`
- Política de publicación: `[DIRECTO_MAIN / RAMA_Y_PR]`
- Ruta local: `[RUTA_LOCAL]`
- Carpeta de bloques: `[RUTA_BLOQUES]`

No publiques en una rama distinta a la indicada. Verifica siempre que cada archivo exista en la rama correcta antes de afirmar que está disponible.

## 3. Fuentes de verdad

Inspecciona antes de implementar:

- Pantallas: `[RUTA_PANTALLAS]`
- Componentes: `[RUTA_COMPONENTES]`
- App/configuración: `[RUTA_APP_CONFIG]`
- Flows: `[RUTA_FLOWS]`
- SQL tablas: `[RUTA_SQL_TABLAS]`
- SQL procedimientos: `[RUTA_SQL_SP]`
- Contratos: `[RUTA_CONTRATOS]`
- Mapeos: `[RUTA_MAPEOS]`
- Tests: `[RUTA_TESTS]`
- Documentación técnica: `[RUTA_DOC_TECNICA]`
- Manual de usuario: `[RUTA_MANUAL]`
- Registro de compatibilidad: `[RUTA_REGISTRO_ERRORES]`

El estado actual del repositorio es la fuente de verdad. No inventes nombres, rutas, controles, variables, contratos, columnas ni parámetros.

## 4. Restricciones

- `[RESTRICCION_1]`
- `[RESTRICCION_2]`
- `[RESTRICCION_3]`

Reglas generales:

1. Usa el esquema fuente real del proyecto.
2. Confirma el tipo y versión de cada control.
3. Reutiliza componentes existentes cuando sean compatibles.
4. No mezcles datos de prueba con producción.
5. No introduzcas persistencia ficticia.
6. No sustituyas archivos completos sin necesidad.
7. No avances al siguiente bloque hasta mi confirmación.

## 5. Auditoría inicial

Antes de crear código:

1. inspecciona los archivos relacionados;
2. identifica contratos reales de datos;
3. describe riesgos y huecos;
4. propón el árbol de controles o arquitectura;
5. divide la implementación en bloques numerados;
6. indica qué documentos vivos deben crearse o actualizarse.

## 6. Metodología de bloques

Cada bloque debe tener una sola responsabilidad.

Para cada bloque entrega:

- ruta del archivo;
- commit;
- operación exacta;
- archivo, control y propiedad afectados;
- padre y posición exacta;
- YAML, Power Fx, SQL o contenido completo;
- dependencias;
- prueba mínima;
- resultado esperado;
- limitaciones.

Encabezado obligatorio de cada archivo:

`BLOCK [N] — [NOMBRE]`  
`Operation: [OPERACION]`  
`Target: [OBJETIVO]`  
`Parent: [PADRE]`  
`Exact location: [POSICION]`  
`Dependencies: [DEPENDENCIAS]`  
`Validation: [PRUEBAS]`

## 7. Flujo de validación

Después de cada bloque yo lo integraré en `[HERRAMIENTA_DE_VALIDACION]` y responderé con:

- `Bloque [N] integrado sin errores`, o
- el error completo, líneas y Session ID.

Cuando exista un error:

1. detén el siguiente bloque;
2. corrige el archivo fuente en el repositorio;
3. registra el incidente;
4. busca el mismo patrón en bloques futuros;
5. publica la corrección;
6. espera mi validación.

## 8. Documentación viva

Mantén actualizados:

- `[RUTA_README_FUNCIONALIDAD]`
- `[RUTA_REGISTRO_ERRORES]`
- `[RUTA_MANUAL_USUARIO]`
- `[RUTA_DECISIONES_ARQUITECTURA]`

El manual debe estar escrito en lenguaje sencillo y actualizarse con cada función visible.

## 9. Datos de prueba

Cuando sean necesarios, crea un archivo separado y opcional:

`[NUMERO]A_[NOMBRE].optional.[EXTENSION]`

Indica cómo ejecutarlo, qué resultado esperar y cuándo eliminarlo.

## 10. Inicio

Comienza únicamente con:

1. auditoría del estado actual;
2. propuesta de arquitectura;
3. secuencia de bloques;
4. creación de la estructura documental mínima;
5. primer bloque pequeño y validable.
```

---

## 19. Formato recomendado de respuesta del agente

Después de publicar un bloque, la respuesta debe seguir este orden:

1. **Bloque publicado**
2. **Ruta y commit**
3. **Operación exacta**
4. **Árbol de controles antes/después**
5. **Pasos de integración**
6. **Prueba mínima**
7. **Resultado esperado**
8. **Limitaciones**
9. **Condición para continuar**

Debe evitar respuestas ambiguas como:

- “pega esto en la pantalla”;
- “añádelo cerca del encabezado”;
- “debería funcionar”;
- “he actualizado el repositorio” sin indicar rama, ruta y commit.

---

## 20. Checklist de inicio rápido

Antes de comenzar un nuevo encargo:

- [ ] Repositorio y rama confirmados.
- [ ] Política de publicación confirmada.
- [ ] Rutas de pantallas, componentes, flows y SQL completadas.
- [ ] Objetivo y exclusiones documentados.
- [ ] Contratos reales inspeccionados.
- [ ] Registro de compatibilidad localizado o creado.
- [ ] Carpeta de bloques localizada o creada.
- [ ] Manual de usuario localizado o creado.
- [ ] Arquitectura dividida en bloques.
- [ ] Primer bloque limitado a una responsabilidad.

---

## 21. Resultado esperado de la metodología

La aplicación de este protocolo debe producir:

- menos errores repetidos;
- cambios más pequeños y recuperables;
- mayor precisión al indicar controles y propiedades;
- trazabilidad completa en GitHub;
- validación real en Studio antes de avanzar;
- documentación alineada con el producto;
- posibilidad de retomar el trabajo en otro chat o con otro agente;
- una dinámica estable entre análisis funcional, desarrollo, validación y documentación.
