# Connection-reference inventory — 1.0.0.2

| Logical name | Connector | Root component | Used by | Classification |
|---|---|---:|---|---|
| `new_sharedsqldw_ce25b` | Azure SQL Data Warehouse | No | Canvas App and SQL-backed flows | UNRESOLVED |
| `new_sharedsqldw_2d156aca17` | Azure SQL Data Warehouse | No | Canvas App and SQL-backed flows | UNRESOLVED |
| `new_sharedsqldw_8d7b12c454` | Azure SQL Data Warehouse | No | Canvas App / export-related binding | UNRESOLVED |
| `new_sharedsqldw_bddb2` | Azure SQL Data Warehouse | No | Dashboard bundle binding | UNRESOLVED |

All four previous logical names remain in Canvas/customization metadata, and workflow definitions reference connector keys (`shared_sqldw`, plus Excel/SharePoint for exports). None of the four is a type-10078 root component; no external-dependency contract justifies them. Therefore they cannot be classified INCLUDED or safely EXTERNAL.

Additional connector APIs evidenced: `shared_excelonlinebusiness`, `shared_sharepointonline`, `shared_office365`, `shared_office365users`, `shared_sql`, and `shared_logicflows`. No secret values are reported.
