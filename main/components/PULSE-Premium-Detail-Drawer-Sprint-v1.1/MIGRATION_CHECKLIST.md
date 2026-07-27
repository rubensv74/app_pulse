# Migration checklist

1. Importa `cmp_DetailDrawer_Premium.pa.yaml` como componente nuevo.
2. No elimines `cmp_DetailDrawer_old`.
3. En `scr_Punches`, sustituye `conLayer_Drawer_4` por el bloque premium.
4. Conserva temporalmente todos los botones ocultos existentes.
5. Cambia referencias `comp_DetailDrawer_4` por `comp_DetailDrawer_Premium_Punches`.
6. Sustituye `btnDrawerLoad_Punches_1.OnSelect`.
7. Sustituye `galPunches_2.OnSelect`.
8. Agrega los tres botones host del patch.
9. Revisa el nombre de `btnCT_SaveAll_4`; si tu botón de guardado masivo tiene otro nombre, cambia únicamente esa referencia.
10. Comprueba el orden de parámetros de `Warroom_AddTaskComment`.
11. Prueba:
   - abrir/cerrar;
   - responsive por debajo de 1100 px;
   - Summary sin Flow;
   - Comments con loader;
   - Fields con loader;
   - Manage Fields para Admin/SuperAdmin;
   - cierre y apertura de otro Punch sin datos residuales.
12. Tras validar Punches, reutiliza el componente en Tasks y retira `cmp_DetailDrawer_old`.
