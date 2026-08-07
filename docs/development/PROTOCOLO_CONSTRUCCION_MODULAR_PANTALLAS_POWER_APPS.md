# Protocolo de Construcción Modular de Pantallas Power Apps Asistida por IA

**Versión:** 1.0  
**Estado:** Activo  
**Ámbito:** Creación de pantallas Canvas Power Apps desde cero mediante Source Code YAML + Power Fx  
**Uso previsto:** humanos, ChatGPT, Codex y otros agentes de IA con acceso al repositorio  
**Relación:** protocolo especializado que complementa `PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`

---

# 1. Finalidad

Este protocolo define cómo construir **una pantalla Power Apps nueva desde cero, por piezas pequeñas, verificables y reversibles**, evitando entregar una pantalla monolítica difícil de importar, depurar o corregir.

La metodología parte de una regla central:

> **La pantalla no se considera un único artefacto. Se considera una secuencia ordenada de bloques independientes que van materializando estructura, estado, comportamiento, integraciones y documentación.**

Cada bloque debe poder:

- entenderse de forma aislada;
- copiarse o integrarse en una ubicación exacta;
- validarse en Power Apps Studio;
- corregirse sin reconstruir la pantalla completa;
- dejar trazabilidad en GitHub;
- convertirse en referencia para el siguiente bloque.

El objetivo no es escribir YAML rápidamente. El objetivo es **reducir incertidumbre, contener errores y construir una pantalla estable mediante validación progresiva**.

---

# 2. Cuándo utilizar este protocolo

Debe utilizarse cuando se cree una nueva pantalla Canvas Power Apps que incluya una o varias de estas características:

- diseño premium o layout complejo;
- varios paneles funcionales;
- galerías, grids, filtros o navegación interna;
- componentes reutilizables;
- variables y colecciones locales/globales;
- Power Automate flows;
- SQL o APIs;
- comentarios, historial, custom fields u otros submódulos;
- estados de carga, error y vacío;
- edición y persistencia;
- modales;
- integración con pantallas existentes;
- necesidad de mantener manual de usuario durante el desarrollo.

Es especialmente recomendable cuando Power Apps Studio es la autoridad final de validación y el agente de IA no puede ejecutar App Checker directamente.

---

# 3. Principios no negociables

## 3.1. El repositorio actual es la fuente de verdad

Antes de crear el primer bloque, el agente debe inspeccionar el código real de la aplicación.

Debe confirmar, como mínimo:

- formato Source Code utilizado;
- versiones reales de controles;
- convenciones de nombres;
- variables de tema;
- estructura de pantallas existentes;
- navegación lateral o global;
- componentes reutilizables disponibles;
- contratos reales de flows;
- contratos SQL o de datos;
- errores de compatibilidad ya conocidos.

El agente no puede inventar propiedades, nombres de controles, parámetros de flows ni estructuras JSON cuando exista una implementación real que pueda inspeccionarse.

---

## 3.2. La construcción se hace sobre una arquitectura congelada

Antes de programar, debe definirse el árbol objetivo de controles.

Ejemplo genérico:

```text
scr_[Screen]
└── con[Screen]_Root
    ├── cmp[Screen]_Sidebar
    └── con[Screen]_Content
        ├── con[Screen]_Header
        ├── con[Screen]_Body
        │   ├── con[Screen]_Left
        │   ├── con[Screen]_Center
        │   └── con[Screen]_Right
        └── con[Screen]_ModalLayer
```

El árbol puede evolucionar, pero cualquier cambio estructural importante debe documentarse antes de afectar bloques posteriores.

---

## 3.3. Un bloque = una responsabilidad principal

Cada bloque debe resolver un objetivo concreto.

Ejemplos correctos:

- crear el shell de pantalla;
- añadir el header;
- crear el layout central;
- inicializar estado tipado;
- implementar una cola;
- implementar un panel Overview;
- implementar Comments;
- implementar Custom Fields;
- añadir un modal Dirty Guard.

Ejemplo incorrecto:

> “Bloque 4: crear filtros, llamar a tres flows, editar registros, abrir modal, guardar SQL y añadir documentación.”

Si una pieza falla, debe poder corregirse sin desmontar otras funciones ya validadas.

---

## 3.4. No avanzar sobre un error abierto

Un bloque debe quedar en uno de estos estados:

```text
planned
published
integrating
failed
corrected
validated
```

El agente no debe preparar el siguiente bloque funcional mientras el anterior permanezca en `failed`.

Primero se corrige, se vuelve a probar y se valida.

---

## 3.5. Power Apps Studio es la autoridad de compilación

El agente puede realizar validación estática contra el repositorio, pero no debe afirmar que un bloque “compila” si no ha sido guardado y aceptado en Studio.

La validación real incluye:

- pegar/importar el bloque;
- guardar;
- esperar validación de fórmulas;
- revisar App Checker;
- ejecutar la interacción mínima acordada.

---

# 4. Configuración inicial obligatoria

Antes de iniciar una pantalla, debe completarse esta ficha.

```text
PROJECT: [NOMBRE_PROYECTO]
REPOSITORY: [OWNER/REPO]
BASE_BRANCH: [main]
PUBLICATION_MODE: [DIRECT_MAIN | FEATURE_BRANCH]
SCREEN_NAME: [scr_NuevaPantalla]
SCREEN_SLUG: [nueva-pantalla]
CANONICAL_SCREEN_PATH: [ruta final del YAML de pantalla]
COMPONENTS_PATH: [ruta de componentes]
FLOWS_PATH: [ruta flows]
SQL_PATH: [ruta SQL]
BLOCKS_PATH: [ruta de bloques incrementales]
USER_GUIDE_PATH: [ruta manual]
COMPATIBILITY_PATH: [registro compatibilidad]
VALIDATION_TOOL: Power Apps Studio + App Checker
SOURCE_CODE_SCHEMA: [schema real utilizado]
```

No se comienza a producir YAML hasta completar o verificar los campos críticos.

---

# 5. Estructura de trabajo recomendada en el repositorio

Para cada pantalla nueva debe existir una carpeta de construcción independiente.

```text
[SCREEN_WORK_PATH]/
├── README.md
├── SCREEN_ARCHITECTURE.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
│   ├── 01_screen_shell.pa.yaml
│   ├── 02_header.children.pa.yaml
│   ├── 03_workspace_layout.children.pa.yaml
│   ├── 04_runtime_state.onvisible.pa.yaml
│   ├── 05_first_module.replace-control.pa.yaml
│   └── ...
└── user-guide/
    └── MANUAL_USUARIO_[SCREEN].md
```

Los bloques son **artefactos de construcción**. No sustituyen automáticamente el archivo canónico de la pantalla.

La consolidación canónica se realiza al final o cuando exista una política expresa para hacerlo antes.

---

# 6. Fase 0 — Auditoría del entorno antes de crear la pantalla

La IA debe inspeccionar primero pantallas y componentes existentes para aprender el “dialecto” real de la aplicación.

## 6.1. Debe revisar

- una pantalla sencilla existente;
- una pantalla compleja existente;
- sidebar/navigation actual;
- un contenedor AutoLayout;
- un contenedor ManualLayout;
- botones Classic y Modern utilizados realmente;
- galerías utilizadas realmente;
- TextInput, ComboBox, Toggle, DatePicker y Spinner si van a usarse;
- patrones actuales de `OnVisible`;
- variables de tema;
- flows equivalentes;
- patrones de error/loading/empty state.

## 6.2. Resultado obligatorio de la auditoría

El agente debe redactar:

```text
Confirmed patterns
Known incompatibilities
Reusable components
Data contracts
Navigation contracts
Open risks
Do-not-invent list
```

No se inicia el Bloque 01 sin esta auditoría.

---

# 7. Fase 1 — Definir arquitectura y secuencia de bloques

Antes del primer YAML deben quedar cerrados dos elementos:

1. **árbol de controles objetivo**;
2. **plan numerado de bloques**.

## 7.1. Secuencia base recomendada

Para una pantalla compleja desde cero:

```text
01  Screen shell
02  Header
03  Workspace/layout
04  Runtime state
05  Primary list / queue / grid
06  Main overview/detail
07  Primary actions
08  Session activity / local history
09  First real remote service
10  Editable remote data
11  KPI / progress / visualization
12  Related records
13  Dirty guard / confirmation modal
14  Integration from source screen A
15  Integration from source screen B
16  Empty/loading/error hardening
17  Accessibility/responsive pass
18  Remove test scaffolding
19  Canonical consolidation
20  Final documentation and acceptance
```

La secuencia debe adaptarse al caso real. No se fuerza un bloque inexistente si la pantalla no lo necesita.

---

# 8. Contrato de un bloque

Cada bloque debe tener cabecera documental dentro del propio archivo.

Formato obligatorio:

```text
BLOCK [NN] — [NAME]
Operation: [CREATE | ADD CHILD | REPLACE CONTROL | REPLACE FORMULA | PATCH]
Target control: [CONTROL]
Target property: [PROPERTY if applicable]
Parent: [PARENT]
Exact location: [ANCHOR]
Dependencies: [BLOCKS]
Scope: [WHAT IT DOES]
Out of scope: [WHAT IT DOES NOT DO]
Compatibility: [KNOWN RULES]
Validation: [MINIMUM TEST]
```

## 8.1. La respuesta del agente debe indicar además

- ruta exacta del archivo;
- commit exacto;
- qué debe copiar el usuario;
- qué debe reemplazar;
- qué no debe conservar;
- árbol de controles resultante;
- prueba mínima;
- resultado esperado;
- condición para considerar validado el bloque.

---

# 9. Tipos de operación permitidos

## CREATE

Para crear el shell o un artefacto nuevo completo.

## ADD CHILD

Para insertar un control dentro de un padre existente.

## ADD SIBLING

Para insertar al mismo nivel que un control existente.

## REPLACE CONTROL

Para sustituir completamente un placeholder o módulo.

Regla:

> Cuando se indique `REPLACE CONTROL`, el placeholder anterior debe eliminarse por completo salvo instrucción contraria.

## REPLACE FORMULA

Para propiedades como:

```text
OnVisible
OnSelect
Items
Visible
DisplayMode
```

No debe “añadirse al final” una fórmula si el archivo indica reemplazo completo.

## INCREMENTAL PATCH

Para cambios pequeños y expresos, por ejemplo añadir una única propiedad validada.

---

# 10. Estrategia de construcción por capas

La pantalla se construye en seis capas.

## Capa A — Estructura

Primero se crean:

- pantalla;
- root container;
- sidebar;
- header;
- body;
- columnas/filas principales;
- slots/placeholders.

No se conectan flows en esta fase.

## Capa B — Estado

Después se crean variables y colecciones con tipos inequívocos.

Ejemplo:

```powerfx
Set(varScreenLoading, false);
Set(varScreenError, "");
Set(varCurrentIndex, 1);
Set(varCurrentRecordId, Blank());
Clear(colScreenRows);
```

Regla importante:

> Una variable nueva debe inicializarse con un tipo compatible con su uso posterior. No debe depender de inferencias ambiguas de Power Fx.

## Capa C — Interacción local

Después se validan sin servicios externos:

- selección;
- navegación next/previous;
- filtros;
- búsqueda;
- tabs;
- modales;
- estado Reviewed/Selected/Dirty local.

## Capa D — Lectura remota

Cuando la interacción local es estable se conectan los servicios de lectura.

Cada integración debe incluir:

- loading state;
- error state;
- empty state;
- retry cuando tenga sentido.

## Capa E — Escritura/persistencia

Solo después se implementan:

- Save;
- Add;
- Update;
- Delete si aplica;
- confirmaciones;
- dirty state.

La UI nunca debe afirmar “Saved” antes de recibir confirmación válida del backend.

## Capa F — Integración externa

Finalmente se conecta la nueva pantalla con:

- Home;
- listados origen;
- deep links;
- filtros heredados;
- contexto de retorno.

---

# 11. Placeholders como mecanismo deliberado

Durante las primeras fases es correcto construir módulos vacíos explícitos:

```text
Overview — Block 06
Comments — Block 09
Custom Fields — Block 10
Progress — Block 11
```

El placeholder sirve para:

- reservar layout;
- validar proporciones;
- evitar construir demasiadas cosas a la vez;
- permitir que el usuario evalúe visualmente la arquitectura antes de invertir en lógica.

Cada placeholder debe desaparecer cuando llegue su bloque funcional.

No debe quedar ninguno al cierre.

---

# 12. Hidden service controls

En pantallas complejas puede utilizarse un patrón de **controles internos de servicio invisibles** para encapsular acciones Power Fx reutilizables.

Ejemplo:

```text
btnScreen_LoadCurrent
btnScreen_RebuildQueue
btnScreen_LoadComments
btnScreen_SaveCustomFields
```

Propiedades típicas:

```text
Visible = false
Width = 1
Height = 1
```

Y otros controles pueden invocarlos mediante:

```powerfx
Select(btnScreen_LoadCurrent)
```

Este patrón es válido cuando mejora la separación de responsabilidades, pero no debe utilizarse indiscriminadamente.

No sustituye componentes ni funciones reales cuando exista un mecanismo más adecuado.

---

# 13. Datos de prueba separados

Cuando un bloque necesita datos antes de disponer del backend real, se crea un seed independiente.

Convención:

```text
05A_queue_test_seed.optional.powerfx
09B_comments_test_seed.optional.powerfx
10B_custom_fields_test_seed.optional.powerfx
```

Debe indicar expresamente:

- que es opcional;
- dónde pegarlo;
- si utiliza IDs ficticios;
- qué controles permite validar;
- qué acciones reales NO deben ejecutarse con esos datos;
- cuándo eliminarlo.

Los datos de prueba nunca se incrustan de forma permanente en el bloque productivo.

---

# 14. Integraciones reales: reutilizar contratos existentes

Antes de llamar a un flow o SP, el agente debe buscar una llamada real existente en la aplicación.

Debe confirmar:

```text
FlowName.Run(
    Param1,
    Param2,
    Param3
)
```

incluyendo:

- nombre exacto;
- orden exacto;
- tipo esperado;
- nombre del resultado;
- estructura JSON;
- comportamiento de error.

No se debe reconstruir un contrato “por intuición”.

Si no existe ejemplo utilizable, se documenta el contrato nuevo antes de escribir la llamada.

---

# 15. Estados UX obligatorios para módulos remotos

Todo panel conectado a datos remotos debe contemplar al menos:

```text
No record selected
Loading
Loaded with data
Loaded empty
Error
Retry
```

Para módulos editables se añaden:

```text
Saved
Unsaved
Saving
Save error
```

Un panel que solo funciona en el “happy path” no se considera terminado.

---

# 16. Dirty state y prevención de pérdida de cambios

Cuando exista edición:

```powerfx
Set(varScreenDirty, true)
```

Debe existir una política explícita antes de permitir:

- cambiar de registro;
- cambiar filtro que elimine el registro actual;
- abandonar la pantalla;
- recargar datos;
- cerrar un modal editable.

La solución final recomendada es:

```text
Unsaved changes

[Save and continue]
[Discard and continue]
[Cancel]
```

Si el modal se implementa en un bloque posterior, debe existir temporalmente una protección conservadora que bloquee la navegación antes que perder datos silenciosamente.

---

# 17. Reglas de compatibilidad Power Apps

Debe existir un registro vivo de compatibilidad.

Cada error confirmado genera una regla reutilizable.

Ejemplos:

```text
Label@[version] does not support Radius*.
Classic/Button@[version] does not support AccessibleLabel in this Source Code schema.
TabList@[version] cannot be reset with Reset().
Toggle@[version] uses Checked for its Boolean state.
```

Antes de utilizar por primera vez una propiedad poco habitual, el agente debe:

1. buscar ejemplos reales en el repositorio;
2. confirmar control y versión;
3. considerarla “pendiente de validación” hasta que Studio la acepte.

---

# 18. Ciclo de validación después de cada bloque

El usuario integra un bloque y ejecuta este gate:

```text
1. Paste / integrate
2. Save in Studio
3. Wait for formula validation
4. Open App Checker
5. Navigate to screen
6. Execute minimum test
7. Capture screenshot if visual review is relevant
```

## Resultado A — correcto

El usuario confirma:

```text
Bloque NN integrado sin errores.
```

El agente:

- marca el bloque validado en README;
- actualiza manual si aplica;
- inicia el siguiente bloque.

## Resultado B — error

El usuario aporta:

```text
error code
message
line/column
control type/version
Session ID
screenshot if useful
```

El agente debe:

1. detener el siguiente bloque;
2. revisar el archivo exacto;
3. localizar la causa;
4. corregir en repositorio;
5. crear commit `fix` separado;
6. actualizar registro de compatibilidad si es una regla nueva;
7. entregar únicamente la corrección necesaria;
8. esperar nueva validación.

---

# 19. Revisión visual incremental

La pantalla debe revisarse visualmente varias veces, no solo al final.

Gates recomendados:

```text
Gate V1 — shell + header + layout
Gate V2 — primer módulo funcional
Gate V3 — todos los paneles principales
Gate V4 — loading/error/empty states
Gate V5 — pantalla completa integrada
```

En cada gate se evalúan:

- jerarquía visual;
- proporciones;
- densidad;
- alineación;
- scroll;
- espacios muertos;
- consistencia con otras pantallas;
- claridad de acciones;
- legibilidad en datos reales.

Los ajustes visuales deben realizarse antes de seguir acumulando lógica cuando afecten a la arquitectura del layout.

---

# 20. Manual de usuario vivo

Cuando la primera funcionalidad visible esté validada debe crearse un manual.

Ruta genérica:

```text
[SCREEN_WORK_PATH]/user-guide/MANUAL_USUARIO_[SCREEN].md
```

Cada nuevo bloque funcional debe revisar si cambia:

- qué puede hacer el usuario;
- cómo lo hace;
- limitaciones;
- permisos;
- estados temporales vs persistidos;
- resolución de problemas.

El manual debe incluir historial de versiones por bloques.

---

# 21. Ayuda contextual dentro de la pantalla

Para pantallas de uso operativo complejo se recomienda un modal de ayuda.

Patrón recomendado:

```text
Header
└── Info icon
    └── Help modal
        └── TabList
            ├── Español
            └── English
```

Las pestañas deben ser pestañas reales, no dos botones que simulan navegación.

La ayuda no debe describir “el prototipo”. Debe explicar:

- finalidad;
- flujo de trabajo;
- decisiones del usuario;
- significado de acciones;
- limitaciones activas.

Debe evolucionar con los bloques igual que el manual.

---

# 22. Política Git

Todo desarrollo debe quedar guardado en el repositorio aunque el agente también entregue texto, archivos descargables o contenido copiable en el chat.

Reglas:

- un bloque productivo = commit identificable;
- una corrección = commit `fix` separado;
- test seed = commit `test` cuando sea útil;
- documentación = commit `docs` cuando sea útil;
- verificar rama antes de comunicar disponibilidad;
- no depender de archivos temporales externos al repositorio;
- no sobrescribir el YAML canónico prematuramente.

Mensajes recomendados:

```text
feat([screen]): add review queue
fix([screen]): remove unsupported property
test([screen]): add optional field seed
docs([screen]): update user guide
```

---

# 23. Consolidación canónica

Los bloques incrementales son la fuente de construcción durante el desarrollo, pero no deben convertirse en una segunda aplicación divergente.

Cuando todos los módulos principales estén validados:

1. obtener el estado real actualizado de la pantalla desde la solución/repositorio;
2. consolidar el código validado en la ruta canónica;
3. comprobar que el árbol completo coincide con la arquitectura aprobada;
4. eliminar placeholders;
5. eliminar botones/seeds de prueba;
6. ejecutar revisión de referencias;
7. validar la pantalla completa en Studio;
8. mantener los bloques como trazabilidad histórica si la política del repositorio así lo establece.

Nunca se debe construir manualmente una “versión final” desde memoria si puede obtenerse el estado real de la solución.

---

# 24. Definition of Done de una pantalla

Una pantalla creada con este protocolo solo está terminada si:

- todos los bloques productivos están validados;
- no quedan placeholders;
- no quedan test seeds activos;
- loading/error/empty states funcionan;
- permisos están comprobados;
- flows reales funcionan;
- save/update se verifican con datos reales;
- dirty guard está resuelto;
- navegación origen y retorno funciona;
- App Checker no contiene errores nuevos atribuibles a la pantalla;
- responsive/layout está revisado;
- manual de usuario coincide con el comportamiento;
- ayuda integrada coincide con el comportamiento si existe;
- README muestra el estado final;
- código canónico está consolidado;
- Git está limpio y todo el trabajo está versionado.

---

# 25. Antipatrones prohibidos

El agente no debe:

- entregar una pantalla compleja completa de miles de líneas como primer incremento;
- avanzar cinco bloques sin validación del usuario;
- introducir controles en galerías que la aplicación ya sabe que son problemáticos;
- inventar propiedades porque “suelen existir”;
- asumir que un flow tiene el mismo orden de parámetros que otro;
- ocultar que una función es temporal;
- marcar como persistido un estado solo local;
- mezclar test data con producción;
- reconstruir el archivo canónico desde fragmentos no verificados;
- ignorar un error de Studio y continuar con el siguiente bloque;
- modificar varias zonas no relacionadas de la pantalla en la misma corrección;
- prometer un resultado que no se ha validado en el entorno real.

---

# 26. Formato de encargo para un modelo de IA

El siguiente bloque puede entregarse directamente a otro modelo o agente para iniciar una pantalla nueva.

```markdown
# ENCARGO — CONSTRUCCIÓN MODULAR DE UNA NUEVA PANTALLA POWER APPS

Debes crear desde cero la pantalla `[SCREEN_NAME]` del repositorio `[OWNER/REPO]` utilizando el **Protocolo de Construcción Modular de Pantallas Power Apps Asistida por IA**.

Documento de referencia obligatorio:
`docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`

También debes respetar:
`docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`

## Objetivo funcional

`[DESCRIBIR_OBJETIVO]`

## Usuarios

`[DESCRIBIR_USUARIOS_Y_CONTEXTO]`

## Alcance inicial

- `[FUNCION_1]`
- `[FUNCION_2]`
- `[FUNCION_3]`

## Fuera de alcance

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`

## Rutas

- Pantallas: `[RUTA_PANTALLAS]`
- Componentes: `[RUTA_COMPONENTES]`
- Flows: `[RUTA_FLOWS]`
- SQL: `[RUTA_SQL]`
- Documentación: `[RUTA_DOCUMENTACION]`
- Carpeta de construcción de la pantalla: `[SCREEN_WORK_PATH]`

## Reglas obligatorias

1. Audita primero el repositorio actual.
2. No inventes controles, propiedades, contratos ni datos.
3. Define el árbol completo de controles antes del Bloque 01.
4. Divide la pantalla en bloques pequeños numerados.
5. Publica únicamente un bloque funcional cada vez.
6. Cada bloque debe indicar operación, target, parent, posición, dependencias y prueba mínima.
7. Guarda todos los bloques y documentación en el repositorio.
8. No sobrescribas prematuramente la pantalla canónica.
9. Espera mi validación en Power Apps Studio antes de avanzar.
10. Si aparece un error, detén el siguiente bloque, corrige, documenta la regla y espera nueva validación.
11. Separa los test seeds del código productivo.
12. Conecta flows y persistencia únicamente usando contratos verificados.
13. Implementa loading, empty y error states para módulos remotos.
14. Implementa protección ante cambios sin guardar antes de permitir navegación destructiva.
15. Mantén un manual de usuario vivo durante el desarrollo.

## Primera entrega requerida

No construyas todavía la pantalla completa.

Entrega únicamente:

1. auditoría del repositorio;
2. fuentes de verdad confirmadas;
3. riesgos y restricciones;
4. árbol objetivo de controles;
5. plan numerado de bloques;
6. estructura documental de la nueva pantalla;
7. Bloque 01 — shell mínimo de la pantalla.
```

---

# 27. Referencia práctica: patrón probado

El desarrollo de una pantalla compleja mediante este protocolo debe parecerse conceptualmente a esta progresión:

```text
Shell
  ↓ validate
Header
  ↓ validate
Workspace layout
  ↓ validate
Typed runtime state
  ↓ validate
Primary queue/list
  ↓ validate
Overview
  ↓ validate
Actions
  ↓ validate
Session activity
  ↓ validate
Comments / remote read
  ↓ validate
Custom fields / edit + save
  ↓ validate
Progress
  ↓ validate
Related data
  ↓ validate
Dirty guard
  ↓ validate
Source-screen integration
  ↓ validate
Final hardening
  ↓
Canonical consolidation
```

La potencia de la metodología no está en esa lista concreta, sino en el ciclo repetido:

> **Diseñar una pieza → publicar → integrar → validar → corregir si es necesario → documentar → continuar.**

---

# 28. Regla final para el agente

Cuando exista tensión entre velocidad y certeza, debe prevalecer la certeza.

Cuando exista tensión entre un bloque grande y varios bloques pequeños, deben prevalecer los bloques pequeños.

Cuando exista tensión entre una suposición y el repositorio, debe prevalecer el repositorio.

Cuando exista tensión entre una validación teórica y Power Apps Studio, debe prevalecer Power Apps Studio.

La pantalla se construye **por evidencia acumulada**, no por confianza en una generación monolítica.
