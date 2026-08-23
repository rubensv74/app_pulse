# PULSE — Guía rápida de encargos para IA

| Ámbito | Acción | Plantilla de la frase para hacer la llamada |
|---|---|---|
| UI | Continuar pantalla | `Usa CONTINUE_SCREEN_EDITING y continúa con la pantalla [PANTALLA].` |
| UI | Crear pantalla | `Usa CREATE_NEW_SCREEN para crear la pantalla [PANTALLA].` |
| UI | Auditar pantalla | `Usa REVIEW_SCREEN para auditar [PANTALLA] antes de modificarla.` |
| UI | Crear componente | `Usa CREATE_SHARED_COMPONENT para crear un componente premium reusable para [NECESIDAD].` |
| UI | Revisar componente | `Usa REVIEW_SHARED_COMPONENT para revisar [COMPONENTE].` |
| UI | Preparar Visual Gate | `Usa PREPARE_VISUAL_GATE para preparar [PANTALLA] para el Visual Gate.` |
| UI | Revisar coherencia visual | `Usa REVIEW_VISUAL_CONSISTENCY para comparar [PANTALLA/S] con PDS.` |
| Funcional | Continuar feature | `Usa CONTINUE_FEATURE_DEVELOPMENT y continúa con [FUNCIONALIDAD].` |
| Funcional | Diseñar flujo | `Usa DESIGN_FUNCTIONAL_FLOW para diseñar el flujo de [PROCESO].` |
| Funcional | Revisar modelo | `Usa REVIEW_FUNCTIONAL_MODEL para auditar el modelo de [ÁREA].` |
| PULSE | Continuar Punch Dashboard | `Usa CONTINUE_PUNCH_DASHBOARD y continúa el Punch Dashboard desde el estado actual.` |
| PULSE | Continuar Punch Review Workspace | `Usa CONTINUE_PUNCH_REVIEW_WORKSPACE y continúa Punch Review Workspace.` |
| PULSE | Continuar intercambio Excel | `Usa CONTINUE_PUNCH_EXCEL_EXCHANGE y continúa export/import Excel de Punches.` |
| Datos/SQL | Diseñar contrato de datos | `Usa DESIGN_DATA_CONTRACT para definir el contrato de [ENTIDAD/FLUJO].` |
| Datos/SQL | Crear incremento SQL | `Usa DESIGN_SQL_INCREMENT para implementar [OBJETIVO SQL].` |
| Datos/SQL | Revisar SQL | `Usa REVIEW_SQL_CHANGE para revisar [OBJETO/SCRIPT].` |
| Datos/SQL | Optimizar SQL | `Usa OPTIMIZE_SQL_QUERY para optimizar [CONSULTA/VISTA/SP].` |
| Datos/SQL | Auditar BD | `Usa AUDIT_DATABASE_CHANGE para auditar [CAMBIO/MODELO].` |
| Datos/SQL | Investigar discrepancia | `Usa INVESTIGATE_DATA_DISCREPANCY para investigar [FUENTE A] vs [FUENTE B].` |
| Power Platform | Crear incremento Power Apps | `Usa CREATE_POWER_APPS_INCREMENT para construir [ID/NOMBRE].` |
| Power Platform | Revisar incremento Power Apps | `Usa REVIEW_POWER_APPS_INCREMENT para revisar [ID/NOMBRE].` |
| Power Platform | Crear flow | `Usa CREATE_POWER_AUTOMATE_FLOW para crear [FLOW/OBJETIVO].` |
| Power Platform | Revisar flow | `Usa REVIEW_POWER_AUTOMATE_FLOW para auditar [FLOW].` |
| Calidad | Auditar repositorio | `Usa AUDIT_REPOSITORY_CONTEXT antes de trabajar en [ÁREA].` |
| Calidad | Planificar incrementos | `Usa PLAN_IMPLEMENTATION_INCREMENT para convertir [NECESIDAD] en incrementos verificables.` |
| Calidad | Revisar incremento | `Usa REVIEW_INCREMENT para revisar [INCREMENTO].` |
| Calidad | Preparar release | `Usa PREPARE_RELEASE_GATE para preparar [CAMBIO] con evidencias y rollback.` |
| Calidad | Investigar defecto | `Usa INVESTIGATE_DEFECT para diagnosticar [ERROR].` |
| Documentación | Documentar ADR | `Usa DOCUMENT_DECISION_ADR para documentar [DECISIÓN].` |
| Documentación | Lección aprendida | `Usa DOCUMENT_LESSON_LEARNED para documentar [APRENDIZAJE].` |
| Documentación | Actualizar docs | `Usa UPDATE_PROJECT_DOCUMENTATION tras [CAMBIO].` |

## UI
Todo encargo de UI debe consultar primero PDS y `COMPONENT_CATALOG.md`. Si el gap es reusable, debe crear/evolucionar el componente compartido y actualizar su lifecycle antes de aprobar la pantalla.