# C17 — Lecciones de diseño del Punch Review Workspace

## Propósito

Registrar decisiones verificadas durante la recomposición del Punch Review Workspace para evitar repetir retrabajos en futuras pantallas PULSE.

## Hallazgos

### 1. El espacio debe asignarse por importancia funcional, no por simetría

La composición inicial daba demasiado ancho a Comments / Custom Fields en el rail y demasiado espacio central a Session Activity.

La clasificación correcta resultó ser:

```text
TRABAJO ACTIVO
- Punch Overview
- Comments
- Custom Fields

CONTEXTO DE SESIÓN
- Review Progress
- Session Activity
```

Resultado:

```text
Main workspace dominante
Right rail contextual estrecho
```

### 2. Un rail contextual debe tener ancho acotado

La validación visual de C17-A confirmó que un rail de aproximadamente 260–280 px puede mantener visible el contexto sin competir con el área principal.

Regla PULSE:

> Los paneles contextuales deben reclamar el mínimo ancho útil. El crecimiento horizontal de la pantalla debe beneficiar primero al workspace operativo.

### 3. Los componentes deben adaptarse internamente al nuevo host

`cmp_ReviewProgressPro` fue diseñado inicialmente para un host más ancho. Reducir solo la instancia habría producido una composición pobre.

C17-B compactó el rendering interno y el donut, conservando el contrato funcional.

Regla:

> Cuando un componente cambia de archetype/host, adaptar padding, jerarquía y visualización interna; no confiar en compresión externa.

### 4. Información pasiva persistente funciona bien agrupada

Review Progress y Session Activity responden a dos preguntas relacionadas:

```text
¿cómo avanza la sesión?
¿qué ha ocurrido en esta sesión?
```

Agruparlos en el rail crea una jerarquía más coherente que repartirlos en zonas distintas.

### 5. Comments y Custom Fields forman una unidad de trabajo

Ambos son módulos activos ligados al Punch actual y deben compartir la zona principal debajo del Overview.

C17-C adopta inicialmente 50/50 y exige validar contenido real antes de cambiar la proporción.

### 6. No conservar paneles solo porque ya están construidos

`Related in Queue` se dejó fuera del layout operativo al comprobar que su valor no justificaba el espacio consumido.

Regla:

> La existencia de un componente no es argumento suficiente para mantenerlo visible.

### 7. No corregir clipping ensanchando el rail

Si un panel del rail falla visualmente, la primera respuesta debe ser revisar su diseño interno, wrapping o densidad.

No debe recuperarse ancho del workspace principal para compensar una geometría interna deficiente.

## Aplicación futura

Antes de diseñar una pantalla operativa PULSE con tres zonas, clasificar cada módulo como:

```text
PRIMARY WORK
SUPPORTING WORK
CONTEXT
ON-DEMAND
```

Después definir la geometría.

No comenzar por una distribución visual simétrica y decidir la prioridad después.

## Knowledge Base

La recomendación generalizada se mantiene en:

`functional-engineering-knowledge-base/20-patterns/ux-ui/active-workspace-context-rail-layout.md`
