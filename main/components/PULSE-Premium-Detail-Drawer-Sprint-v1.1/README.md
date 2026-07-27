# Sprint — PULSE Premium Detail Drawer

## Entregables

- `cmp_DetailDrawer_Premium.pa.yaml`: nuevo componente completo.
- `scr_Punches_premium_integration.patch.yaml`: bloques completos que sustituyen la integración actual.
- `MIGRATION_CHECKLIST.md`: orden seguro de importación y validación.

## Decisión técnica

El componente nuevo no ejecuta Flows. Presenta datos y dispara eventos. `scr_Punches` conserva las operaciones de Comments y Custom Fields mediante botones host ocultos. Esto elimina la duplicación que existía entre `cmp_DetailDrawer_old` y la pantalla.

## Compatibilidad

El componente usa el esquema Source Code de Power Apps y controles compatibles ya presentes en la aplicación:

- `GroupContainer@1.5.0`
- `Rectangle@2.3.0`
- `Label@2.5.1`
- `Classic/Button@2.2.0`
- `Classic/Icon@2.5.0`
- `Classic/TextInput@2.3.2`
- `Gallery@2.15.0`
- `Spinner@1.4.6`

No utiliza `Tooltip` ni propiedades experimentales.

## Importante

`Warroom_AddTaskComment` se ha mantenido como nombre de Flow porque es el utilizado por el componente actual para Task/Punch comments. Comprueba únicamente el orden real de parámetros del Flow antes de pegar el botón `btnDrawerPostComment_Punches`.

La edición inline de Custom Fields se conserva en la infraestructura existente. Este sprint moderniza presentación, navegación, carga y arquitectura del drawer. La siguiente iteración puede trasladar los editores existentes al grid premium sin cambiar los Flows.
