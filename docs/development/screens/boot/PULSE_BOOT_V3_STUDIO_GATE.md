# PULSE BOOT 03 — Validación y pendientes de integración

## Fuente conservada
- `scr_Boot_PremiumProjectGallery.candidate.pa.yaml`: Source Code completo recibido de paquete previo.
- `PULSE_BOOT_V3_README_INSTALACION_Y_CONTRATOS.md`: guía de instalación, contratos y gate en Studio.
- `APP_ONSTART_GATE.powerfx`: nota de inicialización.
- `media-manifest.json`: siete recursos obligatorios, nombres exactos de Power Apps Media, tamaños y SHA256 del paquete original.

## Contrato funcional a conservar
`App.OnStart` inicializa sesión, seguridad y catálogo con `WarRoom_EnabledProjects_GetActive.Run().result`.
`colEnabledProjectsUI` alimenta la galería. La acción de apertura prepara `varPendingProjectId`, `varGlobalLoadAction="PROJECT_CHANGE"` y `varGlobalLoadPending=true` y navega a `scr_Home`. Es `tmrGlobalLoader_2` de Home quien realiza el commit y carga del contexto real; Boot no debe duplicar la lógica.

## Estado verificable
- [x] Fuente completa y guía escritas en rama aislada.
- [x] Repositorio público autorizado por su propietario.
- [ ] **Archivos multimedia binarios todavía NO guardados en GitHub.** Solo registrados en manifest. Los originales permanecen en `PULSE_BOOT_V3_PREMIUM_PROJECT_GALLERY_COMPLETO.zip` entregado al usuario en el chat.
- [ ] Definición aceptada por Power Apps Studio.
- [ ] Verificación de referencias Media (7 nombres).
- [ ] Comparativa visual de 1366×768, 1600×900 y 1920×1080.
- [ ] Prueba real de los estados BOOT LOADING/SELECT_PROJECT/EMPTY/ERROR, búsqueda, orden y selección.
- [ ] Confirmar una sola ejecución de catálogo en inicio normal.
- [ ] Confirmar que Home recibe ProjectId e invoca exactamente una vez `PROJECT_CHANGE` por selección; sin condiciones de carrera.
- [ ] Prueba de regresión del selector posterior en Home.

**NO fusionar ni marcar como desplegado por tener archivos Source Code en GitHub.**
