# Mapa de dependencias runtime de Pulse

Inventario estático completo de la solución exportada y del catálogo SQL `warroom`.

## Cobertura

| Elemento | Cantidad |
|---|---:|
| Pantallas | 12 |
| Componentes Canvas | 38 |
| Objetos App | 1 |
| Flows incluidos en la solución | 70 |
| Procedimientos almacenados | 114 |
| Tablas | 53 |
| Conectores | 5 |
| Relaciones | 469 |
| Flows sin referencia Canvas observada | 34 |
| Referencias de pantalla no resueltas en la solución | 2 |
| Destinos de navegación no incluidos en el export | 1 |
| Procedimientos referenciados fuera del catálogo `warroom` | 3 |

## Cómo usarlo

- `screens/`: ficha de cada pantalla.
- `components/`: ficha de cada componente Canvas.
- `app/`: inicialización global y llamadas observadas en App.
- `flows/`: ficha de cada flow.
- `sql/stored-procedures/`: ficha de cada procedimiento.
- `sql/tables/`: ficha de cada tabla.
- `mappings/`: vistas humanas entre capas.
- `generated/runtime-map.json`: fuente principal para agentes y skills.
- `generated/runtime-map.csv`: relaciones filtrables.
- `recommendations/flows-to-review.md`: revisión manual, nunca eliminación automática.

## Límites

`STATIC_FULL_EXPORT` significa cobertura completa de los artefactos presentes en el ZIP y el catálogo, no demostración de uso en runtime. SQL dinámico, consumidores externos, child flows y llamadas construidas dinámicamente pueden requerir evidencia adicional.

El ZIP se usa como entrada temporal; no se almacena desempaquetado.
