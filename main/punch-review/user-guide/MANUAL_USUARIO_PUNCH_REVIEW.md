# Manual de usuario — Punch Review Workspace

**Aplicación:** PULSE  
**Pantalla:** Punch Review Workspace  
**Versión del manual:** 0.9  
**Idioma:** Español  
**Estado:** Documento vivo. Se actualizará con cada bloque funcional validado.

---

## 1. ¿Para qué sirve esta pantalla?

Punch Review Workspace permite revisar Punches uno detrás de otro sin tener que abrir y cerrar continuamente el panel de detalle.

La pantalla reúne en un único espacio:

- una cola de Punches pendientes de revisar;
- la información principal del Punch seleccionado;
- acciones de revisión;
- comentarios del Punch;
- actividad realizada durante la sesión;
- campos personalizados;
- progreso de revisión;
- Punches relacionados o contexto de la selección.

El objetivo es facilitar las reuniones de revisión, reducir cambios de pantalla y mantener una secuencia clara de trabajo.

---

## 2. Importante: revisión de sesión

La marca **Reviewed** todavía es temporal.

Esto significa que:

- se mantiene mientras la sesión de la aplicación continúa activa;
- sirve para organizar la revisión actual;
- todavía no se guarda en SQL;
- puede perderse al cerrar o recargar la aplicación.

La pantalla muestra el aviso **Session review only** para recordar esta limitación.

Los comentarios son diferentes: se consultan y guardan mediante los servicios reales de comentarios. Por tanto, un comentario añadido correctamente no es una marca temporal de la sesión.

Los campos personalizados se conectarán a su servicio real en un bloque posterior.

---

## 3. Partes principales de la pantalla

### 3.1. Encabezado

En la parte superior se muestran:

- el nombre de la pantalla;
- el proyecto activo;
- la plantilla de Punch;
- el alcance de la cola;
- el botón para volver a Punch List;
- el acceso a la ayuda integrada.

### 3.2. Review Queue

La columna izquierda contiene los Punches que forman la cola de revisión.

Cada fila muestra:

- código del Punch;
- estado;
- descripción;
- disciplina;
- estado de revisión de la sesión.

La fila resaltada en azul es el Punch actualmente seleccionado.

### 3.3. Punch Overview

El panel central muestra los datos principales del Punch seleccionado:

- Punch ID;
- subsistema;
- estado;
- descripción;
- disciplina;
- responsable;
- categoría;
- originador.

Los datos cambian automáticamente al seleccionar otro Punch.

### 3.4. Review Actions

La barra de acciones permite:

- **Mark Reviewed:** marcar el Punch como revisado durante la sesión;
- **Undo Review:** retirar la marca de revisión;
- **Open Punch List:** abrir la pantalla Punch List con el Punch actual preparado como contexto.

### 3.5. Comments

El panel Comments permite:

- cargar los comentarios del Punch seleccionado;
- actualizar la lista;
- navegar entre páginas cuando hay muchos comentarios;
- consultar autor, fecha, tipo y contenido;
- añadir un comentario nuevo.

El contador del encabezado muestra el número total de comentarios informado por el servicio.

### 3.6. Session Activity

Este panel registra las acciones realizadas durante la sesión, por ejemplo:

- Punch marcado como revisado;
- marca de revisión retirada;
- comentario añadido;
- campos personalizados guardados.

No representa el historial corporativo completo del Punch.

---

## 4. Cómo utilizar la cola de revisión

### Paso 1 — Cargar una cola

La cola se creará desde Home o Punch List cuando se implemente la integración completa.

Durante el desarrollo se puede utilizar el botón temporal **Load test queue** para cargar cinco Punches de prueba.

### Paso 2 — Seleccionar un Punch

Pulsa cualquier fila de Review Queue.

La fila seleccionada cambia de color y el panel Punch Overview se actualiza.

Cuando la integración del Bloque 09A está activa, Comments también carga la página 1 del Punch seleccionado.

### Paso 3 — Navegar en secuencia

Utiliza los controles anterior y siguiente de la cola.

El indicador muestra la posición actual, por ejemplo:

```text
2 of 5
```

### Paso 4 — Buscar

Escribe en el campo de búsqueda para localizar por:

- código de Punch;
- descripción;
- subsistema;
- disciplina.

La búsqueda se realiza sobre la cola cargada en la sesión.

### Paso 5 — Filtrar

Los filtros disponibles son:

- **All:** todos los Punches de la cola;
- **Remaining:** Punches aún no revisados;
- **Reviewed:** Punches ya revisados en la sesión.

---

## 5. Cómo marcar un Punch como revisado

1. Selecciona un Punch.
2. Comprueba su información en Punch Overview.
3. Pulsa **Mark Reviewed**.
4. La fila mostrará **Reviewed**.
5. Los contadores Remaining y Reviewed se actualizarán.
6. La acción quedará registrada en Session Activity.

Para corregir una marca accidental:

1. Selecciona el Punch revisado.
2. Pulsa **Undo Review**.
3. La fila volverá a estado no revisado.

---

## 6. Cómo consultar comentarios

1. Selecciona un Punch real.
2. Espera a que termine el indicador **Loading comments...**.
3. Revisa la lista de comentarios.
4. Usa **‹** y **›** cuando exista más de una página.
5. Pulsa **↻** para volver a consultar la página actual.

Cada comentario muestra:

- inicial del autor;
- nombre o correo del autor;
- tipo de comentario;
- fecha y hora;
- texto del comentario.

Si el servicio no puede responder, el panel muestra **Comments unavailable** y el mensaje recibido. Pulsa **↻** para reintentar.

---

## 7. Cómo añadir un comentario

1. Selecciona un Punch.
2. Escribe el texto en **Write a comment...**.
3. Pulsa **Add comment**.
4. Espera la confirmación **Comment added successfully**.
5. El panel vuelve automáticamente a la página 1 y recarga los comentarios.
6. Session Activity registra que se añadió un comentario.

No se permite enviar un comentario vacío.

En esta versión, los comentarios nuevos se guardan con el tipo `GENERAL`. La edición, eliminación, adjuntos y formato enriquecido no están incluidos todavía.

---

## 8. Uso recomendado durante una reunión

1. Abre la cola desde el contexto correcto.
2. Comienza por el primer Punch.
3. Lee la descripción y comprueba disciplina, responsable y categoría.
4. Revisa los comentarios existentes.
5. Añade las observaciones o acuerdos necesarios.
6. Revisa los campos personalizados cuando estén disponibles.
7. Marca el Punch como revisado.
8. Continúa con el siguiente.
9. Comprueba el progreso antes de cerrar la reunión.

La marca Reviewed indica que el Punch ha sido tratado en la sesión, no que esté cerrado técnicamente.

---

## 9. Diferencia entre estado del Punch, revisión y comentarios

No deben confundirse:

- **Punch Status:** estado operativo real, como Open, In Progress, Cleared o Closed.
- **Reviewed in Session:** indica únicamente que el Punch ya se ha revisado durante la sesión actual.
- **Comment:** observación persistida mediante el servicio real de comentarios.

Un Punch puede estar Open, aparecer como Reviewed en la sesión y contener varios comentarios guardados.

---

## 10. Ayuda integrada bilingüe

La pantalla incorpora un modal de ayuda accesible desde el icono de información del encabezado.

El modal contiene dos pestañas reales:

- **Español**
- **English**

La pestaña seleccionada cambia todo el contenido de ayuda. Tras validar Comments, la ayuda integrada debe ampliarse con el parche `09C_help_comments.incremental-patch.pa.yaml`.

---

## 11. Limitaciones actuales

En la versión actual:

- Reviewed no se guarda todavía en SQL;
- la cola completa de todos los Punches no está disponible como snapshot de servidor;
- la navegación a Punch List prepara el identificador, pero puede requerir cargar la página correcta;
- los comentarios no permiten edición, borrado, adjuntos ni formato enriquecido;
- los campos personalizados se implementarán en el siguiente bloque funcional;
- Session Activity no sustituye al historial corporativo del Punch.

Estas limitaciones deben mostrarse de forma explícita para evitar interpretaciones incorrectas.

---

## 12. Resolución de problemas básicos

### La cola está vacía

Abre Punch Review desde Home o Punch List. Durante las pruebas, utiliza **Load test queue**.

### No aparece Mark Reviewed

Comprueba que existe un Punch seleccionado. Para Punches ya revisados, la acción cambia a **Undo Review**.

### Un Punch desaparece al marcarlo

Es normal cuando está activo el filtro **Remaining**. El Punch pasa al grupo Reviewed.

### Comments muestra No Punch selected

Selecciona una fila de Review Queue.

### Comments muestra No comments yet

El Punch seleccionado no tiene comentarios en la página consultada. Puedes añadir el primero desde el compositor inferior.

### Comments muestra Comments unavailable

Comprueba que existe un proyecto activo, que el Punch es real y que los flows están disponibles en la aplicación. Pulsa **↻** para reintentar.

### Add comment permanece deshabilitado

Comprueba que:

- hay un Punch seleccionado;
- el panel no está cargando;
- el cuadro contiene texto no vacío.

### Estoy usando los Punches ficticios del Bloque 05A

Los identificadores del Bloque 05A no existen necesariamente en SQL. Utiliza `09B_comments_test_seed.optional.powerfx` para validar el diseño visual. La prueba completa de los flows requiere un Punch real.

### No veo los cambios después de actualizar el repositorio

Ejecuta:

```bash
git switch main
git pull origin main
```

Después vuelve a copiar el bloque correspondiente en Power Apps Studio.

### La pantalla muestra Session review only

Es un aviso previsto. La marca Reviewed todavía es temporal; los comentarios guardados correctamente no dependen de esta marca.

---

## 13. Historial de actualización del manual

| Versión | Bloques cubiertos | Cambios principales |
|---|---|---|
| 0.5 | 01–05 | Estructura, estado tipado y Review Queue |
| 0.6 | 06 | Punch Overview |
| 0.7 | 07 | Mark Reviewed, Undo Review y Open Punch List |
| 0.8 | 08 | Session Activity y ayuda bilingüe integrada |
| 0.9 | 09 | Carga, paginación y alta de comentarios reales |

---

## 14. Próximas ampliaciones previstas

El manual se ampliará cuando estén validados:

- editor de campos personalizados;
- progreso de revisión;
- tabla de Punches relacionados;
- protección ante cambios sin guardar;
- integración definitiva desde Home y Punch List;
- persistencia del estado Reviewed.
