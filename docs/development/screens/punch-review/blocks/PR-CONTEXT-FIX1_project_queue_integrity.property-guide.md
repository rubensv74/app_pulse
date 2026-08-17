# PR-CONTEXT-FIX1 — RETRACTADO

> **NO USAR ESTE FIX.**
>
> Este documento queda retirado porque partía de una interpretación incorrecta de los identificadores de proyecto.
>
> - `70200` es el identificador/código de proyecto que conoce el usuario y que muestra PULSE.
> - `4049` es la clave interna utilizada por la base de datos para los Punches diagnosticados.
> - Los Punches de la prueba sí corresponden funcionalmente al proyecto visible `70200` y seguían en estado `OPEN`.
> - El resultado `Requested=15 / Resolved=0` se produjo porque el validador SQL recibió `70200` en un parámetro que estaba comparando contra la clave interna `4049`.
>
> Por tanto, las comparaciones directas `Value(_raw.ProjectId) <> Value(varProjectId)` introducidas por la versión anterior de este documento son inválidas cuando ambos valores pertenecen a dominios de identificadores distintos.
>
> **Si los tres bloques FIX1-A/B/C ya se pegaron manualmente en Power Apps Studio, no publicar esos cambios. Deben revertirse al estado anterior antes de continuar.**

La corrección del workstream se documenta en:

`PR-EXP-C03B1_project_identifier_mapping.correction.md`

El siguiente paso correcto es resolver explícitamente la traducción entre el código de proyecto visible en PULSE y la clave interna utilizada por el origen SQL, reutilizando el mismo criterio que ya emplean los servicios de Punches. No se debe exponer la clave interna al usuario ni asumir que ambos identificadores son intercambiables.
