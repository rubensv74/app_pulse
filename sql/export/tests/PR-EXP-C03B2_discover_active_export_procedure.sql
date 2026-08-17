/*
    PULSE — PR-EXP-C03B2 — diagnóstico del procedimiento de export activo

    READ ONLY.
    Este script no crea, modifica ni elimina objetos ni datos.

    Motivo:
    El repositorio contiene el source de
    warroom.usp_ExportProjectPunchesExtended_Pivoted,
    pero la base de datos donde se ejecutó C03B2 devolvió OBJECT_ID = NULL.

    Objetivo:
    localizar el procedimiento realmente desplegado en ESTA base de datos
    antes de intentar modificar ningún export existente.
*/

SET NOCOUNT ON;

------------------------------------------------------------
-- RESULT 1 — contexto real de ejecución
------------------------------------------------------------
SELECT
    ServerName = @@SERVERNAME,
    DatabaseName = DB_NAME(),
    LoginName = SUSER_SNAME(),
    CurrentUserName = USER_NAME();

------------------------------------------------------------
-- RESULT 2 — comprobación de nombres exactos conocidos
------------------------------------------------------------
SELECT
    CandidateName,
    ObjectId = OBJECT_ID(CandidateName, N'P'),
    ExistsAsProcedure = CONVERT(bit, CASE WHEN OBJECT_ID(CandidateName, N'P') IS NULL THEN 0 ELSE 1 END)
FROM
(
    VALUES
        (N'warroom.usp_ExportProjectPunchesExtended_Pivoted'),
        (N'dbo.usp_ExportProjectPunchesExtended_Pivoted')
) x(CandidateName);

------------------------------------------------------------
-- RESULT 3 — procedimientos cuyo nombre parece de export Punch
------------------------------------------------------------
SELECT
    SchemaName = s.name,
    ProcedureName = p.name,
    FullName = QUOTENAME(s.name) + N'.' + QUOTENAME(p.name),
    p.create_date,
    p.modify_date
FROM sys.procedures p
INNER JOIN sys.schemas s
    ON s.schema_id = p.schema_id
WHERE
       p.name LIKE N'%Export%Punch%'
    OR p.name LIKE N'%Punch%Export%'
    OR p.name LIKE N'%ExportProjectPunch%'
ORDER BY s.name, p.name;

------------------------------------------------------------
-- RESULT 4 — procedimientos que parecen construir el dataset
-- de export aunque tengan otro nombre
------------------------------------------------------------
SELECT
    SchemaName = s.name,
    ProcedureName = p.name,
    FullName = QUOTENAME(s.name) + N'.' + QUOTENAME(p.name),
    References_wap_PunchPaged = CONVERT(bit, CASE WHEN m.definition LIKE N'%wap_PunchPaged%' THEN 1 ELSE 0 END),
    References_PunchExportLog = CONVERT(bit, CASE WHEN m.definition LIKE N'%PunchExportLog%' THEN 1 ELSE 0 END),
    References_RowHash = CONVERT(bit, CASE WHEN m.definition LIKE N'%RowHash%' THEN 1 ELSE 0 END),
    References_OriginalValuesJson = CONVERT(bit, CASE WHEN m.definition LIKE N'%OriginalValuesJson%' THEN 1 ELSE 0 END),
    References_LastCommentText = CONVERT(bit, CASE WHEN m.definition LIKE N'%LastCommentText%' THEN 1 ELSE 0 END),
    References_NewComment = CONVERT(bit, CASE WHEN m.definition LIKE N'%NewComment%' THEN 1 ELSE 0 END),
    p.modify_date
FROM sys.procedures p
INNER JOIN sys.schemas s
    ON s.schema_id = p.schema_id
INNER JOIN sys.sql_modules m
    ON m.object_id = p.object_id
WHERE
    m.definition LIKE N'%wap_PunchPaged%'
    AND
    (
           p.name LIKE N'%Export%'
        OR m.definition LIKE N'%PunchExportLog%'
        OR m.definition LIKE N'%OriginalValuesJson%'
        OR m.definition LIKE N'%RowHash%'
        OR m.definition LIKE N'%NewComment%'
    )
ORDER BY
    CASE WHEN p.name LIKE N'%Export%' THEN 0 ELSE 1 END,
    s.name,
    p.name;

------------------------------------------------------------
-- RESULT 5 — cualquier procedimiento que mencione los objetos
-- característicos del export v3/import-ready
------------------------------------------------------------
SELECT
    SchemaName = s.name,
    ProcedureName = p.name,
    FullName = QUOTENAME(s.name) + N'.' + QUOTENAME(p.name),
    MatchReason = CONCAT(
        CASE WHEN m.definition LIKE N'%PunchExportLog%' THEN N'PunchExportLog; ' ELSE N'' END,
        CASE WHEN m.definition LIKE N'%OriginalValuesJson%' THEN N'OriginalValuesJson; ' ELSE N'' END,
        CASE WHEN m.definition LIKE N'%RowHash%' THEN N'RowHash; ' ELSE N'' END,
        CASE WHEN m.definition LIKE N'%LastCommentText%' THEN N'LastCommentText; ' ELSE N'' END,
        CASE WHEN m.definition LIKE N'%NewComment%' THEN N'NewComment; ' ELSE N'' END
    ),
    p.modify_date
FROM sys.procedures p
INNER JOIN sys.schemas s
    ON s.schema_id = p.schema_id
INNER JOIN sys.sql_modules m
    ON m.object_id = p.object_id
WHERE
       m.definition LIKE N'%PunchExportLog%'
    OR m.definition LIKE N'%OriginalValuesJson%'
    OR m.definition LIKE N'%RowHash%'
    OR m.definition LIKE N'%LastCommentText%'
    OR m.definition LIKE N'%NewComment%'
ORDER BY s.name, p.name;

/*
Interpretación:

- Si RESULT 2 muestra ExistsAsProcedure = 0 para ambos nombres,
  el source del repositorio no está desplegado con ese nombre en esta BD.

- Si RESULT 3/4/5 devuelve otro procedimiento, NO modificar todavía nada.
  Ese nombre y su definición deben revisarse primero.

- Si RESULT 3/4/5 no devuelve ningún candidato, el siguiente gate es
  capturar la definición real del flow Warroom_ExportPunchesToExcel_Codex,
  porque no existe evidencia de qué procedimiento utiliza en runtime.
*/
