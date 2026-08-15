# Contrato del mapa runtime

## Tipos de nodo

- `screen`
- `flow`
- `stored_procedure`
- `table`
- `query`

## Tipos de relación

- `CALLS`: una pantalla ejecuta un flow.
- `EXECUTES`: un flow ejecuta un procedimiento.
- `READS`: un procedimiento o consulta lee una tabla.
- `WRITES`: un procedimiento modifica una tabla.
- `DEPENDS_ON`: dependencia que no encaja en las anteriores.

## Evidencia

Cada relación debe incluir:

| Campo | Significado |
|---|---|
| `source` | Identificador del origen |
| `target` | Identificador del destino |
| `relation` | Tipo de relación |
| `evidence` | Archivo o artefacto donde se observó |
| `confidence` | `observed`, `derived` o `manual` |
| `baseline` | Solución o snapshot analizado |
| `notes` | Aclaración opcional |

`observed` significa que la llamada aparece directamente en el source. `derived` significa que se obtuvo analizando una definición. `manual` requiere revisión humana.

## Compatibilidad

`generated/runtime-map.json` es la fuente recomendada para skills. Los Markdown son vistas humanas y el CSV facilita filtros y revisiones rápidas.
