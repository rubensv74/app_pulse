# Fase 7 — Punch Review Workspace

Esta carpeta contiene los bloques incrementales para construir `scr_PunchReview` en Power Apps Studio sin pegar una pantalla monolítica.

## Rama de publicación

Los bloques validados y listos para utilizar se publican directamente en `main`:

```text
main/punch-review/blocks/
```

## Regla de uso

Los archivos de `blocks/` no sustituyen automáticamente los YAML canónicos de `main/screens`. Son bloques controlados para copiar en Studio o incorporar al archivo canónico después de validar cada incremento.

Cada bloque indica:

- archivo y control afectados;
- operación exacta: crear, añadir como hijo o sustituir propiedad/control;
- dependencias previas;
- prueba mínima;
- criterio de aceptación.

## Orden obligatorio y estado

1. `01_screen_shell.pa.yaml` — validado
2. `02_header_premium.children.pa.yaml` — validado
3. `03_workspace_layout.children.pa.yaml` — validado
4. `04_runtime_state.onvisible.pa.yaml` — validado
5. `05_review_queue.replace-control.pa.yaml` — validado
6. `05A_review_queue_test_seed.optional.powerfx` — opcional para pruebas
7. `06_punch_overview.replace-control.pa.yaml` — validado
8. `07_review_actions.replace-control.pa.yaml` — validado
9. `08_session_activity.replace-control.pa.yaml` — pendiente de validación en Studio
10. `08A_help_trigger.add-child.pa.yaml` — pendiente de validación en Studio
11. `08B_bilingual_help_modal.add-screen-child.pa.yaml` — pendiente de validación en Studio

No se debe pegar un bloque posterior si el anterior no guarda, abre la pantalla y pasa App Checker sin errores nuevos.

## Manual de usuario

El manual funcional en español se mantiene en:

```text
main/punch-review/user-guide/MANUAL_USUARIO_PUNCH_REVIEW.md
```

Es un documento vivo y debe actualizarse cuando se valide una nueva función de la pantalla.

La pantalla también incorpora una ayuda resumida bilingüe mediante un modal con dos pestañas modernas:

```text
Español | English
```

## Registro de compatibilidad

Antes de crear o modificar un bloque debe revisarse:

```text
main/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
```

Regla confirmada:

```text
Label@2.5.1 no admite RadiusBottomLeft, RadiusBottomRight, RadiusTopLeft ni RadiusTopRight.
```

Para una píldora redondeada se utiliza un `GroupContainer@1.5.0` con radios y un `Label@2.5.1` sin radios en su interior.

## Convención de nombres

- Pantalla: `scr_PunchReview`
- Controles: prefijo `PR`
- Colecciones: prefijo `colPunchReview`
- Variables: prefijo `varPunchReview`
- Controles internos de servicio: prefijo `btnPR_`

## Validación mínima por bloque

1. Ejecutar `git pull origin main`.
2. Guardar el bloque en Studio.
3. Esperar a que termine la validación de fórmulas.
4. Abrir App Checker.
5. Navegar a la pantalla.
6. Confirmar que no existen solapamientos ni referencias rotas.
7. No continuar si aparece PA1001, PA2108, una propiedad no soportada o un error de tipo.

## Fuente de verdad

Las referencias visuales y funcionales se basan en:

- `main/screens/Home/scr_Home.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`
- `main/components/cmp_SidebarNav.pa.yaml`
- resto de componentes actualizados en `main/components/`
