# Procedimiento → tabla

Cobertura inicial centrada en la configuración publicada y Overview.

| Procedimiento | Relación | Tabla |
|---|---|---|
| `warroom.usp_ReportConfig_Publish` | `READS/WRITES` | `warroom.ReportConfigVersion` |
| `warroom.usp_ReportConfig_Publish` | `WRITES` | snapshots de nodos, asignaciones y estados publicados |
| `warroom.usp_ReportConfig_GetPublishedVersion` | `READS` | `warroom.ReportConfigVersion` |
| `warroom.usp_GenerateOverviewSnapshot` | `WRITES` | `warroom.OverviewSnapshot` |
| `warroom.usp_GenerateOverviewSnapshot` | `WRITES` | `warroom.OverviewSnapshotHeader` |
| `warroom.usp_GenerateOverviewSnapshot` | `WRITES` | `warroom.OverviewSnapshotMetric` |
| `warroom.usp_GetOverviewSnapshot` | `READS` | `warroom.OverviewSnapshot` |
| `warroom.usp_GetOverviewSnapshot` | `READS` | `warroom.OverviewSnapshotHeader` |
| `warroom.usp_GetOverviewSnapshot` | `READS` | `warroom.OverviewSnapshotMetric` |

Esto es un baseline parcial, no un inventario exhaustivo del esquema.
