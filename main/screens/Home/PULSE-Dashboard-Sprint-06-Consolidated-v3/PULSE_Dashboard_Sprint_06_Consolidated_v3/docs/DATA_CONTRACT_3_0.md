# PULSE Punch Dashboard — Data Contract 3.0

El procedimiento devuelve una fila y una columna `result` con un objeto JSON.

```json
{
  "success": true,
  "hasSnapshot": true,
  "message": "",
  "snapshotInfo": [],
  "summary": [],
  "matrix": [],
  "timeline": [],
  "insights": [],
  "subsystems": [],
  "subcontractors": [],
  "contractVersion": "3.0"
}
```

## insights

| Campo | Tipo | Descripción |
|---|---|---|
| InsightId | number | Identificador estable dentro de la respuesta |
| Priority | number | Orden ascendente de presentación |
| Severity | string | `CRITICAL`, `WARNING`, `SUCCESS` o `INFO` |
| InsightType | string | Tipo funcional del insight |
| Title | string | Encabezado ejecutivo |
| Message | string | Explicación legible |
| MetricValue | number | Valor destacado |
| MetricLabel | string | Unidad mostrada |
| StatusCode | string | Filtro opcional para drill-through |
| CategoryCode | string | Filtro opcional para drill-through |
| SubsystemCode | string | Filtro opcional para drill-through |
| SubcontractorId | number | Filtro opcional; `-1` significa no aplicable |
| DisciplineCode | string | Filtro opcional para drill-through |

## Compatibilidad

El contrato conserva todos los nodos v2.3. La única ampliación funcional es `insights`; por tanto el Flow mantiene las mismas entradas y la misma salida `result`.
