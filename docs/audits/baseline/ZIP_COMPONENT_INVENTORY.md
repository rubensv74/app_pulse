# ZIP solution component inventory

`solution.xml` declares exactly three root components:

| Type | Name/GUID | Present physically | Assessment |
|---|---|---:|---|
| 300 Canvas App | `new_pulse_9584c` | Yes | Present |
| 29 Workflow | `1d37f98f-2d8b-f111-ab10-000d3a21ce45` | Yes | `Warroom_ExportPunchesToExcel_Codex` |
| 29 Workflow | `4aa15d31-858a-f111-ab10-000d3a21ce45` | Yes | `warroom_GetPunchDashboardBundle` |

No Dataverse tables, custom connectors, web resources, plugins, security roles, choices, model-driven apps, custom APIs, AI models, environment-variable definitions/values, Office Scripts, desktop flows, or service endpoints are included as root components. `MissingDependencies` is empty, but the Canvas App itself references numerous external flows and four connection-reference logical names; an empty manifest dependency list is not proof those runtime dependencies are included.
