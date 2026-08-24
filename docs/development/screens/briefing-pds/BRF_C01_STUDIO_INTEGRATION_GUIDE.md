# BRF-C01 — Guía de integración y validación en Power Apps Studio

**Pantalla:** `scr_Briefing_PDS`  
**Capacidad:** `BRF-C01 — Premium shell and visual states`  
**Estado:** PENDIENTE DE GATE REAL EN POWER APPS STUDIO

## 1. Qué vas a validar

Esta prueba no valida SQL, flows, IA, Teams ni Outlook. Solo valida:

- que Power Apps Studio acepta la nueva pantalla;
- que la composición premium se renderiza correctamente;
- que los nueve estados visuales son distinguibles y mutuamente excluyentes;
- que las tres pestañas locales funcionan;
- que el Evidence Drawer abre/cierra;
- que el sidebar se hidrata correctamente o puede corregirse de forma localizada;
- que no aparecen nuevos errores de App Checker atribuibles a `scr_Briefing_PDS`.

## 2. Archivo a utilizar

Abre el archivo:

`docs/development/screens/briefing-pds/blocks/BRF_C01_scr_Briefing_PDS.full-screen.pa.yaml`

Este archivo contiene el `Screens:` completo de `scr_Briefing_PDS`.

## 3. Preparar la pantalla vacía

En Power Apps Studio:

1. Crea una pantalla nueva y vacía.
2. Renómbrala exactamente:

```text
scr_Briefing_PDS
```

3. No copies controles desde Punch Review ni desde otra pantalla.
4. Confirma que `cmp_SidebarNav` ya existe en la biblioteca de componentes de la app.

## 4. Sustituir el Source Code

1. Abre **View code / Source Code** de `scr_Briefing_PDS`.
2. Sustituye completamente el contenido de la pantalla vacía por el contenido del archivo BRF-C01.
3. Guarda.
4. Espera a que Studio termine de validar fórmulas.
5. No corrijas manualmente propiedades antes de saber si existe un error real.

## 5. Gate técnico inicial

Antes de evaluar el diseño:

```text
[ ] Studio acepta la raíz Screens:
[ ] scr_Briefing_PDS se puede abrir
[ ] no aparece PA1001 atribuible al bloque
[ ] no aparece PA2108 atribuible a controles nativos
[ ] no aparece PA2301 por componente inexistente
[ ] App Checker no añade errores nuevos atribuibles a la pantalla
```

Si aparece un error, conserva:

- código de error;
- mensaje completo;
- línea/columna;
- control si Studio lo identifica;
- Session ID;
- captura si ayuda a localizar el defecto.

No avances a BRF-C02.

## 6. Comprobación específica del Sidebar

La nueva pantalla **no añade todavía Briefing a la navegación global**. Durante BRF-C01 el módulo padre activo es `PunchReview`.

Comprueba:

```text
[ ] Sidebar visible a la izquierda
[ ] PunchReview aparece como módulo activo, si existe en colSidebarNavItems
[ ] el logo y el menú se renderizan normalmente
[ ] el footer no muestra literalmente Text / Text
[ ] si hay proyecto real seleccionado, el footer conserva su contexto
```

### Si el footer muestra `Text / Text`

Esto reproduce un problema de hidratación ya documentado en Home_PDS. No elimines la pantalla ni modifiques el componente.

Haz únicamente esto:

1. Elimina `cmpBRF_Sidebar` de `conBRF_ScreenRoot`.
2. Inserta manualmente **Insert > Custom > cmp_SidebarNav**.
3. Muévelo como primer hijo de `conBRF_ScreenRoot`.
4. Renómbralo `cmpBRF_Sidebar`.
5. Configura:

```text
Width            = 154
Height           = Parent.Height
ActiveKey        = "PunchReview"
AppVersion       = "PULSE"
EnvironmentLabel = "ENV.PRE.TR.162"
IsCollapsed      = true
Items            = colSidebarNavItems
NavItems         = colSidebarNavItems
ProjectCode      = Coalesce(varSelectedProject.ProjectCode, "")
ProjectName      = Coalesce(varSelectedProject.ProjectName, "")
UserRole         = Coalesce(varUserRole, "reader")
```

6. Guarda y vuelve a abrir la pantalla.

Si la instancia insertada manualmente no expone esos inputs, ese sí es un gate de componente y debe reportarse.

## 7. Validación visual — estado inicial DRAFT

Al abrir la pantalla debe aparecer por defecto `DRAFT`.

Comprueba:

```text
[ ] header premium visible
[ ] etiqueta BRF-C01 · SYNTHETIC visible
[ ] contexto Project / Review Session / Meeting Date / Status legible
[ ] KPI strip: 63 / 21 / 34 / 7 / 4
[ ] tabs Briefing / Meeting Notes / Email
[ ] Executive Summary
[ ] Review Quality
[ ] Key Decisions
[ ] Progress & Changes
[ ] Blockers & Risks
[ ] Outstanding from this review
[ ] Action Register
[ ] Briefing lifecycle
[ ] Source Activity
```

Criterio visual: la pantalla debe parecer una extensión natural de PULSE, no un formulario ni un dashboard genérico.

## 8. Validación de los nueve estados

Utiliza el selector **Visual state** del header.

### NO_SESSION

Esperado:

- no aparece el workspace;
- aparece `No review session selected`;
- se indica expresamente que no existe conexión backend.

### READY

Esperado:

- aparece `Ready to prepare briefing`;
- se muestran los totales sintéticos disponibles;
- la acción primaria dice `Generate briefing`.

### GENERATING

Esperado:

- aparece la superficie `Preparing briefing…`;
- la acción primaria queda deshabilitada;
- no se presenta ningún resultado como generado realmente.

### DRAFT

Esperado:

- workspace completo;
- banner de draft;
- acción primaria `Approve Briefing`.

### NEEDS_REVIEW

Esperado:

- workspace completo;
- banner ámbar de revisión;
- `Review Quality` muestra 8 / 2 / 1 / 0 / 84/84;
- acción primaria `Review issues`.

### APPROVED

Esperado:

- estado verde/approved;
- Meeting Notes y Email se presentan como outputs derivados;
- Send puede habilitarse únicamente en la pestaña Email.

### STALE

Esperado:

- aviso claro de que el briefing está desactualizado;
- texto: `3 source changes occurred...`;
- acción primaria `Refresh from session`;
- Send bloqueado en Email.

### SENT

Esperado:

- estado final visual de sent snapshot;
- debe decir claramente que no se ha enviado realmente ningún email;
- acción primaria deshabilitada.

### ERROR

Esperado:

- superficie de error recuperable;
- no se interpreta texto libre de ningún error real;
- Retry devuelve visualmente a READY.

## 9. Validación de tabs

Desde un estado workspace (`DRAFT`, `NEEDS_REVIEW`, `APPROVED`, `STALE` o `SENT`):

```text
[ ] Briefing muestra el workspace principal
[ ] Meeting Notes muestra el documento sintético
[ ] Email muestra el compositor sintético
[ ] la selección visual cambia de pestaña
[ ] no se pierden ni duplican paneles al cambiar de tab
```

En `APPROVED`, pulsa `Send` únicamente como prueba local si quieres verificar la transición a `SENT`. No existe llamada a Outlook.

## 10. Validación de Evidence Drawer

Desde Briefing:

1. Pulsa `View evidence` en Executive Summary, Key Decisions, Blockers, Source Activity o Source Punches del Action Register.
2. Comprueba:

```text
[ ] drawer aparece a la derecha
[ ] no desplaza ni rompe el layout base
[ ] claim visible
[ ] 5 fuentes sintéticas visibles
[ ] botón Close cierra el drawer
[ ] el texto advierte que no son Punches reales
```

## 11. Calidad visual obligatoria

Comprueba al menos a zoom normal y 125%:

```text
[ ] ningún ModernText estático muestra mini-scrollbar
[ ] ningún título o label queda cortado verticalmente
[ ] no hay overlap entre módulos
[ ] no aparecen espacios muertos anómalos
[ ] el Action Register sigue siendo legible
[ ] el header no se desborda de forma destructiva
[ ] si falta anchura, el scroll horizontal aparece solo en zonas donde está previsto
[ ] colores de warning/danger se usan solo en información realmente semántica
[ ] superficies normales usan borde, no sombra decorativa
```

Si es posible, reduce también el ancho de Studio para comprobar que la columna derecha se apila bajo el workspace sin romper la pantalla.

## 12. Evidencia que necesito para cerrar BRF-C01

Idealmente:

1. captura de `DRAFT` a pantalla completa;
2. captura de `STALE`;
3. captura con Evidence Drawer abierto;
4. confirmación de App Checker;
5. cualquier error con Session ID si existe.

No necesitas probar los nueve estados con nueve capturas si el selector funciona correctamente; sí debes recorrerlos todos.

## 13. Criterio de cierre

BRF-C01 solo pasa a `ACCEPTED` si:

```text
SOURCE_ACCEPTED_IN_STUDIO     PASS
APP_CHECKER                   PASS o sin errores nuevos atribuibles
SIDEBAR                       PASS o corregido mediante hidratación manual
NINE_VISUAL_STATES            PASS
THREE_TABS                    PASS
EVIDENCE_DRAWER               PASS
ACTION_REGISTER               PASS
VISUAL_HIERARCHY              PASS
RESPONSIVE_BASIC              PASS
STATIC_TEXT_OVERFLOW          PASS
```

Hasta entonces:

```text
BRF-C01 = GATED_BY_STUDIO
BRF-C02 = NOT_AUTHORIZED
```
