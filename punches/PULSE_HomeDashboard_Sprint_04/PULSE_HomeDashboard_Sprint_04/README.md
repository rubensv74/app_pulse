# PULSE — Home Punch Dashboard · Sprint 04

## Implementado

Integración real entre el Punch Dashboard de Home y `scr_Punches`.

### Home

Los drill-through utilizan ahora las variables reales de Punch List:

- `varFilter_PunchTemplateId`
- `varFilter_PunchStatusCode`
- `varFilter_PunchCategoryCode`
- `varFilter_SubsystemsCsv`
- `varFilter_Subsystem`
- `varFilter_Subcontractor`
- `varFilter_PunchDiscipline`

Además:

- limpia filtros dinámicos anteriores;
- establece el origen `Dashboard`;
- establece retorno a `Home`;
- activa carga automática;
- reinicia la paginación.

### Punch List

- conserva los filtros recibidos desde Home;
- no borra el subsistema al entrar desde Dashboard;
- fuerza página 1 y carga automática;
- corrige el botón Back para usar `varPunches_ReturnView`;
- mantiene intacto el acceso manual.

## Archivos

- `scr_Home_1_Sprint04.pa.yaml`
- `scr_Punches_Sprint04.pa.yaml`

## Integración

1. Sustituye las dos pantallas por los archivos completos.
2. Confirma la conexión `Warroom_GetPunchDashboardBundle`.
3. Prueba KPI, matriz, TOP Code y Subcontractor.
4. Verifica el regreso desde Punch List a Home.

## Nombre de Home

Se conserva `scr_Home_1`, que es el nombre del código recibido. Si la pantalla productiva se llama `scr_Home`, renómbrala al integrar.
