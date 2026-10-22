# `scr_Home` — revisión de carga y eficiencia

Fecha de revisión: 2026-10-22  
Fuentes: export Studio recibido el 2026-10-22, inventario actual en `power-apps/screens/Home/scr_Home.pa.yaml`, captura y vídeo de prueba recibido el 2026-10-22. La exportación de Studio de las 12:44 y el vídeo de las 18:10 son momentos distintos; el vídeo no confirma que las fórmulas exportadas en el YAML sean las que se ejecutaron.

## Resultado visible de la prueba

- El camino normal llega al dashboard y permite seleccionar una celda del heatmap; se actualizan la distribución por disciplina y la lista asociada.
- El overlay global bloquea la pantalla durante unos 24 segundos y ya no aparece alrededor del segundo 27. Esto es tiempo observado en el clip, no una medición del flujo ni de un entorno controlado.
- El clip no prueba la carga sin proyecto, doble solicitud, paginación, cambio de tamaño de página, ordenación, acciones de fila/lote ni guardado del diálogo de campos personalizados.
- Los valores mostrados en este clip son Total 13.874, Open 6.803, Closed 6.975 y finalización 50,3 %. El remanente es 96; el clip no aporta evidencia para clasificarlo como `CLEARED`.

## Hallazgos estáticos adicionales

| Prioridad | Hallazgo | Evidencia y efecto | Cambio propuesto |
|---|---|---|---|
| Alta | Los tres cargadores contienen guardas de salida inseguras. | El export Studio contiene cinco `Exit()` ejecutables en `btnHome_LoadPunchDashboard_1`, `btnHome_LoadPendingSubsystems_2` y `btnHome_LoadHive_2`. Un guard de interacción no debe cerrar la aplicación. En Hive, el guard de proyecto ausente está además comentado y el flujo puede continuar sin contexto. | Sustituir cada salida por ramas excluyentes `If`; fórmulas candidatas en los archivos `.fx.txt` de esta carpeta. |
| Alta | La actualización Punch elimina primero el último snapshot válido. | Antes de la llamada de reemplazo se pone `varPunchDashboardHasSnapshot` en falso y se limpian resumen, matriz, timeline, insights, punches, heatmap y selección. Un error de red deja al usuario sin los datos anteriores. | En una actualización del mismo proyecto/plantilla, mantener el snapshot hasta que la respuesta nueva sea válida. Limpiar al cambiar de contexto. Aplicar cuando el cambio de plantilla/proyecto se diferencie de refresh. |
| Alta | La búsqueda y construcción del modelo de Home sucede en un único `OnSelect` muy grande. | El cargador mezcla llamadas a conectores, parseo JSON, normalización, agregaciones, construcción cartesiana del heatmap, KPI y estado visual. Un fallo intermedio puede dejar colecciones parciales y la depuración de latencia no distingue servidor de cliente. | Separar fases: obtener/validar respuesta, normalizar snapshot, derivar modelos, publicar snapshot, cerrar estado. Mantener los parámetros de flujo sin cambios. |
| Media | Hay trabajo y estados intermedios duplicados al construir el heatmap. | El mismo cargador construye `colPunchExecutiveDistribution` desde el conjunto OPEN y después vuelve a construirla desde todos los estados. También publica la selección inicial dos veces. La primera distribución/selección se reemplaza antes de terminar la carga. | Conservar una sola derivación de distribución y una sola asignación de selección inicial. Construir modelos en colecciones temporales y publicarlos al completar. |
| Media | El heatmap crea una matriz cartesiana mediante bucles anidados y filtros repetidos. | Por cada combinación contratista × categoría se vuelve a filtrar `colPunchExecutiveHeatmapSource` para sumar. El coste crece con el número de combinaciones y se ejecuta en el cliente. | Agrupar una vez por `SubcontractorId` + `CategoryCode`, calcular los totales una vez y luego completar solo celdas necesarias. Verificar el límite real de filas y el resultado con la respuesta del mismo snapshot antes de cambiar. |
| Media | Seleccionar de nuevo el proyecto actual dispara el ciclo de cambio completo. | `cmbHome_ProjectSelector_2.OnChange` solo verifica que `Self.Selected.ProjectId` no esté en blanco; no compara el ID elegido con `varProjectId`. | Añadir comparación normalizada entre proyecto elegido y actual antes de activar `varGlobalLoading` y `varProjectSwitching`. |
| Media | El selector de plantilla recalcula el nombre para mostrar en `Items` y `DefaultSelectedItems`. | Ambos usan `AddColumns(... TemplateDisplayText ...)` sobre el mismo catálogo. | Materializar `TemplateDisplayText` una vez al cargar el catálogo y reutilizarlo. Comprobar si otras pantallas comparten esa colección antes de cambiar su esquema. |
| Media | El overlay de carga tapa el shell incluso cuando existe un snapshot usable. | El vídeo muestra el overlay global hasta ~24 s; el esqueleto de Home también depende de `varExecutiveDashboardStatus`, `varGlobalLoading` y `varHomeLoading`. | Primera carga: skeleton local con forma de dashboard. Refresh del mismo contexto: mantener contenido y mostrar progreso inline. Cambio de proyecto: overlay breve solo durante el cambio de contexto. |
| Media | Tabla y barra de acciones mantienen affordances sin callbacks útiles. | El `cmp_DataTableProV2` de la export deja `OnContextAction` y `OnBulkAction` en blanco y `OnRowsPerPage` sin handler; existen acciones visibles de comentario/columnas/más que terminan en aviso o en otra affordance. | Conectar cada acción a una operación real con contrato validado o ocultar/eliminar el control hasta que esa operación exista. No simular éxito con notificaciones. |
| Media | El estado mostrado de la tabla no tiene contrato coherente para página, rango y orden. | El rango visible está fijado en 1–25; el tamaño de página del componente no actualiza el host y el orden local se aplica a `colPunchExecutiveGridFiltered`, que representa la página ya recibida. | Definir el contrato con `warroom_GetPunchDashboardCellDetails` primero. Después mantener página, tamaño, rango y sort en un único estado host y enviar sort/paging al servidor si el flujo lo soporta. |
| Baja | `OnVisible` tiene muchas inicializaciones secuenciales. | En cada entrada se evalúan defaults de paleta, colecciones, selección, grid, tema Hive, errores y estado de carga. Parte está protegida por flags, pero los defaults quedan repartidos entre más de 40 expresiones `If(IsBlank(...))`. | Agrupar inicialización Home en una única rutina idempotente y no reinicializar colecciones que ya tengan snapshot válido. No mover el bootstrap global a Home. |
| Baja | El branch TASKS y varios controles legacy siguen en la pantalla aunque el selector está oculto. | `conHomeDashboardTabs_1.Visible=false`; conviven dashboard Punch, dashboard Hive/TASKS y controles ocultos de grid/drawer. | Clasificar como activo, compatibilidad o retirado; quitar solo tras confirmar referencias `Select(control)` y consumidores compartidos. |

## Parches disponibles

Los archivos `btnHome_LoadPunchDashboard_1.OnSelect.fx.txt`, `btnHome_LoadPendingSubsystems_2.OnSelect.fx.txt` y `btnHome_LoadHive_2.OnSelect.fx.txt` contienen reemplazos completos de guardas. Conservan el número y orden de argumentos de los `.Run()`, el parseo JSON, `IfError`, `FirstError` y la limpieza final del estado. El guard de contexto inválido o carga duplicada ya no usa `Exit()`.

Comprobaciones estáticas sobre esas tres fórmulas:

- Balance de paréntesis y no quedan llamadas activas a `Exit()`.
- Conteo de `.Run()` preservado frente a la fuente en cada cargador.
- No se cambió el contrato de las llamadas a los flujos.
- No se ha compilado Power Fx en Studio ni ejecutado App Checker. El vídeo prueba el camino normal de la versión instalada, pero no las ramas inválidas/duplicadas.

## Secuencia de refactor

1. Aplicar y compilar en Studio los tres reemplazos de guardas.
2. Revisar el handler posterior a la prueba y actualizar la exportación en repositorio para alinear fuente Studio y YAML.
3. Mantener el snapshot durante refresh, con limpieza explícita únicamente cuando cambia proyecto o plantilla.
4. Eliminar derivaciones dobles de distribución/selección y consolidar el modelo de presentación.
5. Optimizar cálculo del heatmap con una agrupación y validar recuentos frente al mismo `SnapshotRunId`.
6. Unificar callbacks de tabla y contratos de paginación/orden con la definición real del Flow.
7. Reemplazar overlay por skeleton inicial y progreso inline de refresh; validar proyecto vacío, error y recuperación.
8. Hacer revisión visual y accesible en escritorio y anchura mínima soportada.

## Gate pendiente

Power Apps Studio debe confirmar compilación/App Checker después de pegar las fórmulas. La fuente de los flows y la exportación de pantalla posterior a la prueba son necesarias para modificar paginación, orden, callbacks o sincronizar la fórmula final instalada. Mientras tanto, estos artefactos son parches revisables basados en la exportación fechada; no se describen como aplicados al runtime.


## Candidate implementation recorded in the PR branch

The complete canonical screen source in `power-apps/screens/Home/scr_Home.pa.yaml` now contains a reviewable candidate implementation for the local fixes:

- All three Home loaders use mutually exclusive context/loading branches; no `Exit()` remains in those three formulas.
- The Punch loader consumes the force-refresh request only after project and duplicate-load guards pass.
- The Hive loader sets global loading state only after a valid project and idle-state check, so a blank project cannot reach its Flow call.
- Selecting the already active project does not start a project-switch cycle.
- The template selector uses the existing collection directly and computes display text in `ItemDisplayText`; it no longer creates the same `AddColumns` projection for both `Items` and `DefaultSelectedItems`.

Static comparison against the branch's prior complete screen source preserved per-loader counts of `.Run()`, `IfError`, and `FirstError`. Parentheses/brackets/braces are balanced and the three modified loader formulas contain no `Exit()`. The screen source is still only a repository candidate: Power Fx compilation, App Checker, and runtime behavior have not been validated in Studio.

The patch intentionally leaves snapshot retention on refresh and the table paging/sort/actions unchanged. The former needs project/template context ownership and error-path validation; the latter needs the actual detail-flow contract. Those remain explicit follow-up work rather than inferred changes.
