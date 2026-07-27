# Contrato 2.2 — Heat Map

Cada elemento de `matrix[]` conserva los campos existentes y añade:

```json
{
  "Intensity": 100,
  "IntensityBand": "CRITICAL"
}
```

`Intensity` se normaliza contra el mayor valor de toda la matriz.

Bandas: `NONE`, `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`.
