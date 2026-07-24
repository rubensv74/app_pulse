# Punch Dashboard — Contrato 2.1

## Vertical incluida

Executive KPIs con comparación frente al snapshot completado inmediatamente anterior.

## `summary[]`

```json
{
  "StatusCode": "OPEN",
  "StatusName": "Open",
  "StatusOrder": 10,
  "StatusColor": "#EF4444",
  "PunchCount": 245,
  "PreviousPunchCount": 231,
  "Delta": 14,
  "DeltaPercent": 6.06,
  "Trend": "Up"
}
```

## Reglas

- Sin snapshot anterior: `Delta = 0`, `DeltaPercent = 0`, `Trend = "Neutral"`.
- `Trend`: `Up`, `Down` o `Neutral`.
- No se elimina ningún nodo del contrato anterior.
