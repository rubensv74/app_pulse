# Plantilla de Encargo — Nueva Interfaz SaaS Power Apps

**Uso:** copiar este documento como punto de partida para una nueva pantalla o aplicación.  
**Objetivo:** obligar al agente a trabajar con contexto funcional, arquetipo, design system y construcción modular desde el primer momento.

---

# ENCARGO — [NOMBRE DE LA PANTALLA / MÓDULO]

Debes diseñar y construir `[SCREEN_NAME]` dentro del repositorio `[OWNER/REPO]`.

La solución debe seguir obligatoriamente estos documentos:

```text
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
```

Si el proyecto no es PULSE, sustituye `PULSE_DESIGN_SYSTEM.md` por el design system específico del producto, pero conserva el framework, el protocolo y los arquetipos.

---

## 1. Contexto funcional

```text
PRODUCT: [producto]
MODULE: [módulo]
PRIMARY_USERS: [usuarios]
BUSINESS_CONTEXT: [contexto]
PRIMARY_JOB: [trabajo principal que debe completar el usuario]
FREQUENCY: [uso ocasional / diario / continuo]
DATA_VOLUME: [volumen aproximado]
COLLABORATION_NEEDS: [comentarios, handoff, approvals, etc.]
AUDIT_NEEDS: [sí/no + detalle]
SUCCESS_CRITERION: [resultado observable]
```

---

## 2. Arquitectura SaaS

Antes de escribir YAML debes estudiar `SAAS_INTERFACE_ARCHETYPES.md` y proponer:

```text
PRIMARY_ARCHETYPE: [uno]
SECONDARY_PATTERNS: [cero o varios]
RATIONALE: [por qué]
```

No diseñes primero tarjetas, grids o botones. Debes justificar la arquitectura a partir del trabajo del usuario.

---

## 3. Objetivo funcional

`[DESCRIBIR OBJETIVO]`

### En alcance

- `[FUNCION_1]`
- `[FUNCION_2]`
- `[FUNCION_3]`

### Fuera de alcance

- `[EXCLUSION_1]`
- `[EXCLUSION_2]`

---

## 4. Repositorio y fuentes de verdad

```text
REPOSITORY: [OWNER/REPO]
BASE_BRANCH: [main]
PUBLICATION_MODE: [DIRECT_MAIN | FEATURE_BRANCH]
CANONICAL_SCREEN_PATH: [ruta]
COMPONENTS_PATH: [ruta]
FLOWS_PATH: [ruta]
SQL_PATH: [ruta]
SCREEN_WORK_PATH: [ruta]
REFERENCE_SCREENS: [rutas]
REFERENCE_COMPONENTS: [rutas]
```

El repositorio actual es la fuente de verdad. No inventes contratos si puedes inspeccionarlos.

---

## 5. PDS / Design System

Debes aplicar desde el Bloque 01:

- canonical colors;
- typography scale;
- spacing;
- radii;
- selection language;
- action hierarchy;
- panel grammar;
- loading/empty/error;
- accessibility rules.

No introduzcas nuevos colores primarios, radios arbitrarios o estilos locales sin decisión documentada.

---

## 6. Reutilización

Clasifica cada elemento candidato como:

```text
REUSE_AS_IS
REUSE_WITH_DESIGN_SYSTEM_INPUTS
REUSE_LOGIC_ONLY
REIMPLEMENT
DO_NOT_REUSE
```

No reutilices deuda visual únicamente porque ya exista código.

---

## 7. Construcción modular

Debes aplicar estrictamente el protocolo.

Antes del Bloque 01 entrega:

1. auditoría del repositorio;
2. fuentes de verdad confirmadas;
3. incompatibilidades conocidas;
4. arquetipo y patrones secundarios;
5. árbol objetivo de controles;
6. contratos de datos;
7. componentes reutilizables;
8. riesgos;
9. plan numerado de bloques;
10. estructura de documentación.

Después entrega **un bloque cada vez**.

Cada bloque debe indicar:

```text
BLOCK
Operation
Target control
Target property
Parent
Exact location
Dependencies
Scope
Out of scope
Compatibility
Validation
Repository path
Commit
```

No avances hasta que el bloque anterior haya sido validado en Power Apps Studio.

---

## 8. Política de datos y backend

- Primero interacción local.
- Después lectura remota.
- Después escritura.
- Después integración con otras pantallas.
- Reutilizar contracts de flows/SP verificados.
- Implementar loading/empty/error/retry.
- No mostrar Saved hasta confirmación del backend.
- Implementar dirty guard cuando exista edición.

---

## 9. Documentación viva

Mantén durante la construcción:

```text
README.md
SCREEN_SPECIFICATION.md
SCREEN_ARCHITECTURE.md
DESIGN_DECISIONS.md
POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
blocks/
user-guide/MANUAL_USUARIO_[SCREEN].md
```

Todo debe guardarse en el repositorio aunque también se entregue contenido copiable o descargable en el chat.

---

## 10. Quality gates

```text
Gate A — Architecture
Gate B — Visual Foundation
Gate C — Local Interaction
Gate D — Remote Read
Gate E — Write / Business Action
Gate F — Integration
```

Cada gate debe quedar documentado.

---

## 11. Primera entrega requerida

No construyas todavía toda la pantalla.

Entrega únicamente:

1. auditoría actual;
2. propuesta de arquetipo;
3. arquitectura objetivo;
4. estrategia de reutilización;
5. secuencia de bloques;
6. riesgos;
7. estructura documental;
8. Bloque 01 mínimo, solo si todo lo anterior está suficientemente confirmado.

---

# Regla final

> **Diseñar el trabajo → seleccionar el arquetipo → aplicar el Design System → congelar arquitectura → construir por bloques → validar → documentar → continuar.**