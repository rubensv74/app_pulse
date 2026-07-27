# Punch Dashboard — Contrato 2.3

El contrato conserva todos los nodos 2.2 y añade `timeline`.

```json
{
  "timeline": [
    {
      "SnapshotRunId": 138,
      "SnapshotDate": "2026-07-24T09:15:00",
      "SnapshotSequence": 7,
      "Open": 245,
      "Cleared": 81,
      "Closed": 319,
      "Total": 645,
      "OpenDelta": -16,
      "OpenDeltaPercent": -6.13
    }
  ],
  "contractVersion": "2.3"
}
```

Se devuelven como máximo los siete últimos snapshots completados, ordenados cronológicamente.
