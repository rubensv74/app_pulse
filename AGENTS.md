# Instrucciones para agentes

La documentación de desarrollo, protocolos y lecciones aprendidas del repositorio siguen siendo la fuente de verdad para el método incremental de PULSE.

## GitHub Actions — Local First / Remote Gate

- No utilizar GitHub Actions como bucle de desarrollo ni añadir ejecución automática por cada `push` salvo necesidad técnica documentada.
- Validar primero en el entorno local y, para Power Platform, en las herramientas reales que correspondan.
- Reservar Actions para Pull Requests, releases, despliegues, comprobaciones que requieran infraestructura remota o ejecución manual deliberada.
- Aplicar filtros por rutas, `concurrency` y cancelación de ejecuciones obsoletas cuando se creen workflows automáticos.
- No generar artifacts, matrices o jobs costosos si no existe un consumidor o riesgo concreto que los justifique.
- Antes de ampliar CI, justificar qué riesgo cubre, por qué no basta la validación local y cuál es el momento mínimo en el que debe ejecutarse.

Principio obligatorio: **validar localmente primero; ejecutar GitHub Actions solo como gate remoto necesario.**
