# Mapa de dependencias runtime de Pulse

Esta carpeta describe cómo se conectan las pantallas, los flows de Power Automate y SQL.

## Objetivo

Permitir que una persona o una skill responda preguntas como:

- qué flows usa una pantalla;
- qué procedimiento ejecuta cada flow;
- qué tablas consulta o modifica un procedimiento;
- qué piezas podrían quedar obsoletas;
- qué impacto tendría cambiar un contrato.

## Principios

1. El repositorio contiene el mapa canónico de ingeniería.
2. El entorno instalado sigue siendo la evidencia de lo que realmente se ejecuta.
3. El ZIP de la solución se usa solo como entrada temporal de análisis.
4. No se almacena aquí la solución desempaquetada.
5. Una dependencia observada se distingue de una inferida.
6. Las recomendaciones nunca equivalen a autorización para eliminar.

## Estructura

| Carpeta | Propósito |
|---|---|
| `screens/` | Fichas e inventario de pantallas |
| `flows/` | Fichas e inventario de flows |
| `sql/tables/` | Catálogo funcional de tablas |
| `sql/stored-procedures/` | Catálogo funcional de procedimientos |
| `sql/queries/` | Consultas relevantes que no tengan procedimiento propio |
| `mappings/` | Relaciones entre capas |
| `recommendations/` | Elementos a revisar manualmente |
| `generated/` | Fuente estructurada JSON/CSV para agentes y skills |

## Estado inicial

Baseline: `baseline_pulse_1_0_0_5.zip`  
Fecha de análisis: 2026-08-15  
Cobertura inicial: Configuración y Overview.  
Madurez: `PARTIAL_BASELINE`.

La estructura está lista. El inventario completo de todas las pantallas y flows se realizará como una capacidad posterior de extracción y reconciliación.
