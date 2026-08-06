# Fase 7 — Punch Review Workspace

Esta carpeta contiene los bloques incrementales para construir `scr_PunchReview` en Power Apps Studio sin pegar una pantalla monolítica.

## Rama de trabajo

`feature/phase-7-punch-review-blocks`

## Regla de uso

Los archivos de `blocks/` no sustituyen automáticamente los YAML canónicos de `main/screens`. Son bloques controlados para copiar en Studio o incorporar más adelante al archivo canónico después de validar cada incremento.

Cada bloque indica:

- archivo y control afectados;
- operación exacta: crear, añadir como hijo o sustituir propiedad;
- dependencias previas;
- prueba mínima;
- criterio de aceptación.

## Orden obligatorio

1. `01_screen_shell.pa.yaml`
2. `02_header_premium.children.pa.yaml`
3. `03_workspace_layout.children.pa.yaml`
4. `04_runtime_state.onvisible.pa.yaml`

No se debe pegar un bloque posterior si el anterior no guarda, abre la pantalla y pasa App Checker sin errores nuevos.

## Alcance del primer lote

Este primer lote construye únicamente:

- la pantalla `scr_PunchReview`;
- el sidebar reutilizando `cmp_SidebarNav`;
- el header premium;
- la geometría global del workspace;
- el estado tipado de sesión y las colecciones vacías.

Todavía no incluye flows, comentarios, custom fields, donut, DataTable ni integración desde Home/Punches. Esa separación es deliberada: permite validar la estructura y los tipos antes de introducir contratos externos.

## Convención de nombres

- Pantalla: `scr_PunchReview`
- Controles: prefijo `PR`
- Colecciones: prefijo `colPunchReview`
- Variables: prefijo `varPunchReview`
- Controles internos de servicio: prefijo `btnPR_`

## Validación mínima por bloque

1. Guardar en Studio.
2. Esperar a que termine la validación de fórmulas.
3. Abrir App Checker.
4. Navegar a la pantalla.
5. Confirmar que no aparecen controles solapados ni referencias rotas.
6. No continuar si aparece PA1001, PA2108, una propiedad no soportada o un error de tipo.

## Fuente de verdad

Las referencias visuales y de componentes se basan en:

- `main/screens/Home/scr_Home.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`
- `main/components/cmp_SidebarNav.pa.yaml`
- resto de componentes actualizados en `main/components/`
