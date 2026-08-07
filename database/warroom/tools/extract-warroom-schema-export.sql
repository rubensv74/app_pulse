


/*==============================================================================
  EXTRACCIÓN DE DEFINICIONES DEL ESQUEMA WARROOM
  Compatible con SQL Server 2017+ y Azure SQL Database

  OBJETIVO
  --------
  Extraer y reconstruir:

      1. Esquema.
      2. Tablas.
      3. Columnas.
      4. Tipos de datos.
      5. Nulabilidad.
      6. Columnas IDENTITY.
      7. Columnas calculadas.
      8. Valores DEFAULT.
      9. Claves primarias.
     10. Restricciones UNIQUE.
     11. Restricciones CHECK.
     12. Claves foráneas.
     13. Índices convencionales y columnstore.
     14. Procedimientos almacenados.
     15. Hash SHA-256 de cada definición.
     16. Script consolidado del esquema.

  RESULTADOS
  ----------
  Resultado 1: resumen de objetos encontrados.
  Resultado 2: una fila por objeto con su definición.
  Resultado 3: script SQL completo concatenado.

  CORRECCIÓN APLICADA
  -------------------
  STRING_AGG exige que el separador sea un literal o una variable.
  Por eso se utilizan @CommaCRLF y @DoubleCRLF, en lugar de
  expresiones como N',' + @CRLF dentro de STRING_AGG.
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SchemaName sysname = N'warroom';

/*
    0 = salida limpia para generar warroom-schema.sql mediante sqlcmd.
    1 = muestra también el resumen y el detalle por objeto en SSMS.
*/
DECLARE @IncludeDiagnosticResults bit = 0;

DECLARE @CRLF nvarchar(2) =
    NCHAR(13) + NCHAR(10);

/* STRING_AGG solo admite un literal o una variable como separador. */
DECLARE @CommaCRLF nvarchar(3) =
    N',' + @CRLF;

DECLARE @DoubleCRLF nvarchar(4) =
    @CRLF + @CRLF;

/*------------------------------------------------------------------------------
  Validación del esquema
------------------------------------------------------------------------------*/

IF SCHEMA_ID(@SchemaName) IS NULL
BEGIN
    DECLARE @ErrorMessage nvarchar(2048) =
        N'El esquema '
        + QUOTENAME(@SchemaName)
        + N' no existe en la base de datos '
        + QUOTENAME(DB_NAME())
        + N'.';

    THROW 50001, @ErrorMessage, 1;
END;

/*------------------------------------------------------------------------------
  Tabla temporal de resultados
------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS #ObjectDefinitions;

CREATE TABLE #ObjectDefinitions
(
    DefinitionOrder int            NOT NULL,
    ObjectType      nvarchar(50)   NOT NULL,
    SchemaName      sysname        NOT NULL,
    ObjectName      sysname        NOT NULL,
    Definition      nvarchar(max)  NULL
);

/*==============================================================================
  1. DEFINICIÓN DEL ESQUEMA
==============================================================================*/

INSERT INTO #ObjectDefinitions
(
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    Definition
)
VALUES
(
    1,
    N'SCHEMA',
    @SchemaName,
    @SchemaName,
    N'IF SCHEMA_ID(N'''
    + REPLACE(@SchemaName, N'''', N'''''')
    + N''') IS NULL'
    + @CRLF
    + N'    EXEC(N''CREATE SCHEMA '
    + QUOTENAME(@SchemaName)
    + N' AUTHORIZATION [dbo]'');'
    + @CRLF
    + N'GO'
);

/*==============================================================================
  2. TABLAS
==============================================================================*/

;WITH TablesInSchema AS
(
    SELECT
        tableInfo.object_id,
        schemaInfo.name AS SchemaName,
        tableInfo.name AS TableName
    FROM sys.tables AS tableInfo
    INNER JOIN sys.schemas AS schemaInfo
        ON schemaInfo.schema_id = tableInfo.schema_id
    WHERE
        schemaInfo.name = @SchemaName
        AND tableInfo.is_ms_shipped = 0
)
INSERT INTO #ObjectDefinitions
(
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    Definition
)
SELECT
    CONVERT
    (
        int,
        1000
        + ROW_NUMBER() OVER
        (
            ORDER BY
                tableInfo.SchemaName,
                tableInfo.TableName
        )
    ) AS DefinitionOrder,
    N'TABLE' AS ObjectType,
    tableInfo.SchemaName,
    tableInfo.TableName,
    N'CREATE TABLE '
    + QUOTENAME(tableInfo.SchemaName)
    + N'.'
    + QUOTENAME(tableInfo.TableName)
    + @CRLF
    + N'('
    + @CRLF
    + columnDefinitions.ColumnsSql
    + CASE
        WHEN keyDefinitions.KeysSql IS NOT NULL
        THEN
            @CommaCRLF
            + keyDefinitions.KeysSql
        ELSE N''
      END
    + CASE
        WHEN checkDefinitions.ChecksSql IS NOT NULL
        THEN
            @CommaCRLF
            + checkDefinitions.ChecksSql
        ELSE N''
      END
    + @CRLF
    + N');'
    + @CRLF
    + N'GO' AS Definition
FROM TablesInSchema AS tableInfo

CROSS APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                CASE
                    /*----------------------------------------------------------
                      Columna calculada
                    ----------------------------------------------------------*/
                    WHEN computedColumn.definition IS NOT NULL
                    THEN
                        N'    '
                        + QUOTENAME(columnInfo.name)
                        + N' AS '
                        + computedColumn.definition
                        + CASE
                            WHEN computedColumn.is_persisted = 1
                            THEN N' PERSISTED'
                            ELSE N''
                          END

                    /*----------------------------------------------------------
                      Columna convencional
                    ----------------------------------------------------------*/
                    ELSE
                        N'    '
                        + QUOTENAME(columnInfo.name)
                        + N' '
                        +
                        CASE
                            /* Tipo definido por el usuario */
                            WHEN dataType.is_user_defined = 1
                            THEN
                                QUOTENAME
                                (
                                    SCHEMA_NAME(dataType.schema_id)
                                )
                                + N'.'
                                + QUOTENAME(dataType.name)

                            /* Tipos cuya longitud se almacena en bytes */
                            WHEN dataType.name IN
                            (
                                N'varchar',
                                N'char',
                                N'varbinary',
                                N'binary'
                            )
                            THEN
                                dataType.name
                                + N'('
                                + CASE
                                    WHEN columnInfo.max_length = -1
                                    THEN N'MAX'
                                    ELSE
                                        CONVERT
                                        (
                                            nvarchar(20),
                                            columnInfo.max_length
                                        )
                                  END
                                + N')'

                            /* Tipos Unicode: max_length está en bytes */
                            WHEN dataType.name IN
                            (
                                N'nvarchar',
                                N'nchar'
                            )
                            THEN
                                dataType.name
                                + N'('
                                + CASE
                                    WHEN columnInfo.max_length = -1
                                    THEN N'MAX'
                                    ELSE
                                        CONVERT
                                        (
                                            nvarchar(20),
                                            columnInfo.max_length / 2
                                        )
                                  END
                                + N')'

                            /* Tipos numéricos */
                            WHEN dataType.name IN
                            (
                                N'decimal',
                                N'numeric'
                            )
                            THEN
                                dataType.name
                                + N'('
                                + CONVERT
                                (
                                    nvarchar(20),
                                    columnInfo.precision
                                )
                                + N','
                                + CONVERT
                                (
                                    nvarchar(20),
                                    columnInfo.scale
                                )
                                + N')'

                            /* Tipos temporales con escala */
                            WHEN dataType.name IN
                            (
                                N'datetime2',
                                N'datetimeoffset',
                                N'time'
                            )
                            THEN
                                dataType.name
                                + N'('
                                + CONVERT
                                (
                                    nvarchar(20),
                                    columnInfo.scale
                                )
                                + N')'

                            /* Precisión de FLOAT */
                            WHEN dataType.name = N'float'
                            THEN
                                dataType.name
                                + N'('
                                + CONVERT
                                (
                                    nvarchar(20),
                                    columnInfo.precision
                                )
                                + N')'

                            ELSE dataType.name
                        END

                        /* COLLATION */
                        + CASE
                            WHEN columnInfo.collation_name IS NOT NULL
                            THEN
                                N' COLLATE '
                                + columnInfo.collation_name
                            ELSE N''
                          END

                        /* IDENTITY */
                        + CASE
                            WHEN identityColumn.object_id IS NOT NULL
                            THEN
                                N' IDENTITY('
                                + CONVERT
                                (
                                    nvarchar(100),
                                    identityColumn.seed_value
                                )
                                + N','
                                + CONVERT
                                (
                                    nvarchar(100),
                                    identityColumn.increment_value
                                )
                                + N')'
                            ELSE N''
                          END

                        /* ROWGUIDCOL */
                        + CASE
                            WHEN columnInfo.is_rowguidcol = 1
                            THEN N' ROWGUIDCOL'
                            ELSE N''
                          END

                        /* SPARSE */
                        + CASE
                            WHEN columnInfo.is_sparse = 1
                            THEN N' SPARSE'
                            ELSE N''
                          END

                        /* NULL / NOT NULL */
                        + CASE
                            WHEN columnInfo.is_nullable = 1
                            THEN N' NULL'
                            ELSE N' NOT NULL'
                          END

                        /* DEFAULT */
                        + CASE
                            WHEN defaultConstraint.object_id IS NOT NULL
                            THEN
                                N' CONSTRAINT '
                                + QUOTENAME(defaultConstraint.name)
                                + N' DEFAULT '
                                + defaultConstraint.definition
                            ELSE N''
                          END
                END
                AS nvarchar(max)
            ),
            @CommaCRLF
        ) WITHIN GROUP
        (
            ORDER BY columnInfo.column_id
        ) AS ColumnsSql
    FROM sys.columns AS columnInfo
    INNER JOIN sys.types AS dataType
        ON dataType.user_type_id = columnInfo.user_type_id
    LEFT JOIN sys.identity_columns AS identityColumn
        ON identityColumn.object_id = columnInfo.object_id
        AND identityColumn.column_id = columnInfo.column_id
    LEFT JOIN sys.default_constraints AS defaultConstraint
        ON defaultConstraint.object_id =
            columnInfo.default_object_id
    LEFT JOIN sys.computed_columns AS computedColumn
        ON computedColumn.object_id = columnInfo.object_id
        AND computedColumn.column_id = columnInfo.column_id
    WHERE
        columnInfo.object_id = tableInfo.object_id
) AS columnDefinitions

OUTER APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                N'    CONSTRAINT '
                + QUOTENAME(keyConstraint.name)
                + N' '
                + CASE keyConstraint.type
                    WHEN N'PK' THEN N'PRIMARY KEY '
                    WHEN N'UQ' THEN N'UNIQUE '
                  END
                + CASE
                    WHEN keyIndex.type = 1
                    THEN N'CLUSTERED '
                    WHEN keyIndex.type = 2
                    THEN N'NONCLUSTERED '
                    ELSE N''
                  END
                + N'('
                + keyColumns.ColumnList
                + N')'
                AS nvarchar(max)
            ),
            @CommaCRLF
        ) WITHIN GROUP
        (
            ORDER BY
                keyConstraint.type,
                keyConstraint.name
        ) AS KeysSql
    FROM sys.key_constraints AS keyConstraint
    INNER JOIN sys.indexes AS keyIndex
        ON keyIndex.object_id =
            keyConstraint.parent_object_id
        AND keyIndex.index_id =
            keyConstraint.unique_index_id
    CROSS APPLY
    (
        SELECT
            STRING_AGG
            (
                CAST
                (
                    QUOTENAME(keyColumn.name)
                    + CASE
                        WHEN indexColumn.is_descending_key = 1
                        THEN N' DESC'
                        ELSE N' ASC'
                      END
                    AS nvarchar(max)
                ),
                N', '
            ) WITHIN GROUP
            (
                ORDER BY indexColumn.key_ordinal
            ) AS ColumnList
        FROM sys.index_columns AS indexColumn
        INNER JOIN sys.columns AS keyColumn
            ON keyColumn.object_id =
                indexColumn.object_id
            AND keyColumn.column_id =
                indexColumn.column_id
        WHERE
            indexColumn.object_id =
                keyConstraint.parent_object_id
            AND indexColumn.index_id =
                keyConstraint.unique_index_id
            AND indexColumn.key_ordinal > 0
    ) AS keyColumns
    WHERE
        keyConstraint.parent_object_id =
            tableInfo.object_id
) AS keyDefinitions

OUTER APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                N'    CONSTRAINT '
                + QUOTENAME(checkConstraint.name)
                + N' CHECK '
                + CASE
                    WHEN checkConstraint.is_not_for_replication = 1
                    THEN N'NOT FOR REPLICATION '
                    ELSE N''
                  END
                + checkConstraint.definition
                AS nvarchar(max)
            ),
            @CommaCRLF
        ) WITHIN GROUP
        (
            ORDER BY checkConstraint.name
        ) AS ChecksSql
    FROM sys.check_constraints AS checkConstraint
    WHERE
        checkConstraint.parent_object_id =
            tableInfo.object_id
) AS checkDefinitions;

/*==============================================================================
  3. CLAVES FORÁNEAS

  Se generan después de las tablas para evitar problemas de dependencia.
==============================================================================*/

;WITH ForeignKeysInSchema AS
(
    SELECT
        foreignKey.object_id,
        foreignKey.name AS ForeignKeyName,
        foreignKey.parent_object_id,
        foreignKey.referenced_object_id,
        foreignKey.delete_referential_action_desc,
        foreignKey.update_referential_action_desc,
        foreignKey.is_not_for_replication,
        foreignKey.is_not_trusted,
        foreignKey.is_disabled,
        parentSchema.name AS ParentSchemaName,
        parentTable.name AS ParentTableName,
        referencedSchema.name AS ReferencedSchemaName,
        referencedTable.name AS ReferencedTableName
    FROM sys.foreign_keys AS foreignKey
    INNER JOIN sys.tables AS parentTable
        ON parentTable.object_id =
            foreignKey.parent_object_id
    INNER JOIN sys.schemas AS parentSchema
        ON parentSchema.schema_id =
            parentTable.schema_id
    INNER JOIN sys.tables AS referencedTable
        ON referencedTable.object_id =
            foreignKey.referenced_object_id
    INNER JOIN sys.schemas AS referencedSchema
        ON referencedSchema.schema_id =
            referencedTable.schema_id
    WHERE
        parentSchema.name = @SchemaName
        AND parentTable.is_ms_shipped = 0
)
INSERT INTO #ObjectDefinitions
(
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    Definition
)
SELECT
    CONVERT
    (
        int,
        2000
        + ROW_NUMBER() OVER
        (
            ORDER BY
                foreignKey.ParentTableName,
                foreignKey.ForeignKeyName
        )
    ) AS DefinitionOrder,
    N'FOREIGN_KEY' AS ObjectType,
    foreignKey.ParentSchemaName,
    foreignKey.ParentTableName
    + N'.'
    + foreignKey.ForeignKeyName AS ObjectName,
    N'ALTER TABLE '
    + QUOTENAME(foreignKey.ParentSchemaName)
    + N'.'
    + QUOTENAME(foreignKey.ParentTableName)
    + CASE
        WHEN foreignKey.is_not_trusted = 1
        THEN N' WITH NOCHECK'
        ELSE N' WITH CHECK'
      END
    + N' ADD CONSTRAINT '
    + QUOTENAME(foreignKey.ForeignKeyName)
    + N' FOREIGN KEY ('
    + parentColumns.ColumnList
    + N') REFERENCES '
    + QUOTENAME(foreignKey.ReferencedSchemaName)
    + N'.'
    + QUOTENAME(foreignKey.ReferencedTableName)
    + N' ('
    + referencedColumns.ColumnList
    + N')'
    + CASE
        WHEN foreignKey.delete_referential_action_desc
            <> N'NO_ACTION'
        THEN
            N' ON DELETE '
            + REPLACE
            (
                foreignKey.delete_referential_action_desc,
                N'_',
                N' '
            )
        ELSE N''
      END
    + CASE
        WHEN foreignKey.update_referential_action_desc
            <> N'NO_ACTION'
        THEN
            N' ON UPDATE '
            + REPLACE
            (
                foreignKey.update_referential_action_desc,
                N'_',
                N' '
            )
        ELSE N''
      END
    + CASE
        WHEN foreignKey.is_not_for_replication = 1
        THEN N' NOT FOR REPLICATION'
        ELSE N''
      END
    + N';'
    + @CRLF
    + CASE
        WHEN foreignKey.is_disabled = 1
        THEN
            N'ALTER TABLE '
            + QUOTENAME(foreignKey.ParentSchemaName)
            + N'.'
            + QUOTENAME(foreignKey.ParentTableName)
            + N' NOCHECK CONSTRAINT '
            + QUOTENAME(foreignKey.ForeignKeyName)
            + N';'
            + @CRLF
        ELSE N''
      END
    + N'GO' AS Definition
FROM ForeignKeysInSchema AS foreignKey

CROSS APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                QUOTENAME(parentColumn.name)
                AS nvarchar(max)
            ),
            N', '
        ) WITHIN GROUP
        (
            ORDER BY
                foreignKeyColumn.constraint_column_id
        ) AS ColumnList
    FROM sys.foreign_key_columns AS foreignKeyColumn
    INNER JOIN sys.columns AS parentColumn
        ON parentColumn.object_id =
            foreignKeyColumn.parent_object_id
        AND parentColumn.column_id =
            foreignKeyColumn.parent_column_id
    WHERE
        foreignKeyColumn.constraint_object_id =
            foreignKey.object_id
) AS parentColumns

CROSS APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                QUOTENAME(referencedColumn.name)
                AS nvarchar(max)
            ),
            N', '
        ) WITHIN GROUP
        (
            ORDER BY
                foreignKeyColumn.constraint_column_id
        ) AS ColumnList
    FROM sys.foreign_key_columns AS foreignKeyColumn
    INNER JOIN sys.columns AS referencedColumn
        ON referencedColumn.object_id =
            foreignKeyColumn.referenced_object_id
        AND referencedColumn.column_id =
            foreignKeyColumn.referenced_column_id
    WHERE
        foreignKeyColumn.constraint_object_id =
            foreignKey.object_id
) AS referencedColumns;

/*==============================================================================
  4. ÍNDICES

  Incluye:
      - CLUSTERED
      - NONCLUSTERED
      - CLUSTERED COLUMNSTORE
      - NONCLUSTERED COLUMNSTORE

  No repite índices creados automáticamente por PRIMARY KEY o UNIQUE.
==============================================================================*/

;WITH IndexesInSchema AS
(
    SELECT
        tableInfo.object_id,
        schemaInfo.name AS SchemaName,
        tableInfo.name AS TableName,
        indexInfo.index_id,
        indexInfo.name AS IndexName,
        indexInfo.type,
        indexInfo.type_desc,
        indexInfo.is_unique,
        indexInfo.has_filter,
        indexInfo.filter_definition,
        indexInfo.is_disabled,
        indexInfo.ignore_dup_key,
        indexInfo.allow_row_locks,
        indexInfo.allow_page_locks,
        indexInfo.fill_factor,
        indexInfo.is_padded
    FROM sys.tables AS tableInfo
    INNER JOIN sys.schemas AS schemaInfo
        ON schemaInfo.schema_id =
            tableInfo.schema_id
    INNER JOIN sys.indexes AS indexInfo
        ON indexInfo.object_id =
            tableInfo.object_id
    WHERE
        schemaInfo.name = @SchemaName
        AND tableInfo.is_ms_shipped = 0
        AND indexInfo.name IS NOT NULL
        AND indexInfo.is_primary_key = 0
        AND indexInfo.is_unique_constraint = 0
        AND indexInfo.is_hypothetical = 0
        AND indexInfo.type IN
        (
            1,  -- CLUSTERED
            2,  -- NONCLUSTERED
            5,  -- CLUSTERED COLUMNSTORE
            6   -- NONCLUSTERED COLUMNSTORE
        )
)
INSERT INTO #ObjectDefinitions
(
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    Definition
)
SELECT
    CONVERT
    (
        int,
        3000
        + ROW_NUMBER() OVER
        (
            ORDER BY
                indexInfo.TableName,
                indexInfo.IndexName
        )
    ) AS DefinitionOrder,
    N'INDEX' AS ObjectType,
    indexInfo.SchemaName,
    indexInfo.TableName
    + N'.'
    + indexInfo.IndexName AS ObjectName,

    CASE
        /*--------------------------------------------------------------
          Índice columnstore agrupado
        --------------------------------------------------------------*/
        WHEN indexInfo.type = 5
        THEN
            N'CREATE CLUSTERED COLUMNSTORE INDEX '
            + QUOTENAME(indexInfo.IndexName)
            + N' ON '
            + QUOTENAME(indexInfo.SchemaName)
            + N'.'
            + QUOTENAME(indexInfo.TableName)
            + N';'

        /*--------------------------------------------------------------
          Índice columnstore no agrupado
        --------------------------------------------------------------*/
        WHEN indexInfo.type = 6
        THEN
            N'CREATE NONCLUSTERED COLUMNSTORE INDEX '
            + QUOTENAME(indexInfo.IndexName)
            + N' ON '
            + QUOTENAME(indexInfo.SchemaName)
            + N'.'
            + QUOTENAME(indexInfo.TableName)
            + N' ('
            + columnstoreColumns.ColumnList
            + N');'

        /*--------------------------------------------------------------
          Índice convencional
        --------------------------------------------------------------*/
        ELSE
            N'CREATE '
            + CASE
                WHEN indexInfo.is_unique = 1
                THEN N'UNIQUE '
                ELSE N''
              END
            + REPLACE
            (
                indexInfo.type_desc,
                N'_',
                N' '
            )
            + N' INDEX '
            + QUOTENAME(indexInfo.IndexName)
            + N' ON '
            + QUOTENAME(indexInfo.SchemaName)
            + N'.'
            + QUOTENAME(indexInfo.TableName)
            + N' ('
            + keyColumns.ColumnList
            + N')'
            + CASE
                WHEN includedColumns.ColumnList IS NOT NULL
                THEN
                    N' INCLUDE ('
                    + includedColumns.ColumnList
                    + N')'
                ELSE N''
              END
            + CASE
                WHEN indexInfo.has_filter = 1
                THEN
                    N' WHERE '
                    + indexInfo.filter_definition
                ELSE N''
              END
            + N' WITH'
            + @CRLF
            + N'('
            + @CRLF
            + N'    PAD_INDEX = '
            + CASE
                WHEN indexInfo.is_padded = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + N','
            + @CRLF
            + N'    FILLFACTOR = '
            + CONVERT
            (
                nvarchar(10),
                indexInfo.fill_factor
            )
            + N','
            + @CRLF
            + N'    IGNORE_DUP_KEY = '
            + CASE
                WHEN indexInfo.ignore_dup_key = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + N','
            + @CRLF
            + N'    ALLOW_ROW_LOCKS = '
            + CASE
                WHEN indexInfo.allow_row_locks = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + N','
            + @CRLF
            + N'    ALLOW_PAGE_LOCKS = '
            + CASE
                WHEN indexInfo.allow_page_locks = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + @CRLF
            + N');'
    END
    + @CRLF
    + CASE
        WHEN indexInfo.is_disabled = 1
        THEN
            N'ALTER INDEX '
            + QUOTENAME(indexInfo.IndexName)
            + N' ON '
            + QUOTENAME(indexInfo.SchemaName)
            + N'.'
            + QUOTENAME(indexInfo.TableName)
            + N' DISABLE;'
            + @CRLF
        ELSE N''
      END
    + N'GO' AS Definition
FROM IndexesInSchema AS indexInfo

OUTER APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                QUOTENAME(columnInfo.name)
                + CASE
                    WHEN indexColumn.is_descending_key = 1
                    THEN N' DESC'
                    ELSE N' ASC'
                  END
                AS nvarchar(max)
            ),
            N', '
        ) WITHIN GROUP
        (
            ORDER BY indexColumn.key_ordinal
        ) AS ColumnList
    FROM sys.index_columns AS indexColumn
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id =
            indexColumn.object_id
        AND columnInfo.column_id =
            indexColumn.column_id
    WHERE
        indexColumn.object_id =
            indexInfo.object_id
        AND indexColumn.index_id =
            indexInfo.index_id
        AND indexColumn.key_ordinal > 0
        AND indexColumn.is_included_column = 0
) AS keyColumns

OUTER APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                QUOTENAME(columnInfo.name)
                AS nvarchar(max)
            ),
            N', '
        ) WITHIN GROUP
        (
            ORDER BY indexColumn.index_column_id
        ) AS ColumnList
    FROM sys.index_columns AS indexColumn
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id =
            indexColumn.object_id
        AND columnInfo.column_id =
            indexColumn.column_id
    WHERE
        indexColumn.object_id =
            indexInfo.object_id
        AND indexColumn.index_id =
            indexInfo.index_id
        AND indexColumn.is_included_column = 1
) AS includedColumns

OUTER APPLY
(
    SELECT
        STRING_AGG
        (
            CAST
            (
                QUOTENAME(columnInfo.name)
                AS nvarchar(max)
            ),
            N', '
        ) WITHIN GROUP
        (
            ORDER BY indexColumn.index_column_id
        ) AS ColumnList
    FROM sys.index_columns AS indexColumn
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id =
            indexColumn.object_id
        AND columnInfo.column_id =
            indexColumn.column_id
    WHERE
        indexColumn.object_id =
            indexInfo.object_id
        AND indexColumn.index_id =
            indexInfo.index_id
        AND indexColumn.column_id > 0
) AS columnstoreColumns;

/*==============================================================================
  5. PROCEDIMIENTOS ALMACENADOS
==============================================================================*/

INSERT INTO #ObjectDefinitions
(
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    Definition
)
SELECT
    CONVERT
    (
        int,
        4000
        + ROW_NUMBER() OVER
        (
            ORDER BY
                schemaInfo.name,
                procedureInfo.name
        )
    ) AS DefinitionOrder,
    N'STORED_PROCEDURE' AS ObjectType,
    schemaInfo.name AS SchemaName,
    procedureInfo.name AS ObjectName,

    CASE
        WHEN sqlModule.definition IS NULL
        THEN
            N'-- No se ha podido recuperar la definición de '
            + QUOTENAME(schemaInfo.name)
            + N'.'
            + QUOTENAME(procedureInfo.name)
            + N'.'
            + @CRLF
            + N'-- El procedimiento puede estar cifrado o ser de tipo CLR.'
            + @CRLF
            + N'GO'

        ELSE
            N'SET ANSI_NULLS '
            + CASE
                WHEN sqlModule.uses_ansi_nulls = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + N';'
            + @CRLF
            + N'GO'
            + @CRLF
            + N'SET QUOTED_IDENTIFIER '
            + CASE
                WHEN sqlModule.uses_quoted_identifier = 1
                THEN N'ON'
                ELSE N'OFF'
              END
            + N';'
            + @CRLF
            + N'GO'
            + @CRLF
            + sqlModule.definition
            + @CRLF
            + N'GO'
    END AS Definition
FROM sys.procedures AS procedureInfo
INNER JOIN sys.schemas AS schemaInfo
    ON schemaInfo.schema_id =
        procedureInfo.schema_id
LEFT JOIN sys.sql_modules AS sqlModule
    ON sqlModule.object_id =
        procedureInfo.object_id
WHERE
    schemaInfo.name = @SchemaName
    AND procedureInfo.is_ms_shipped = 0;

/*==============================================================================
  RESULTADO 1
  Resumen de objetos encontrados
==============================================================================*/

IF @IncludeDiagnosticResults = 1
BEGIN

SELECT
    ObjectType,
    COUNT(*) AS ObjectCount
FROM #ObjectDefinitions
GROUP BY ObjectType
ORDER BY
    MIN(DefinitionOrder);

/*==============================================================================
  RESULTADO 2
  Una fila por objeto.

  Es la salida recomendada para:
      - Guardar cada objeto por separado.
      - Exportar a CSV o JSON.
      - Comparar hashes.
      - Versionar cambios de forma incremental.
==============================================================================*/

SELECT
    DefinitionOrder,
    ObjectType,
    SchemaName,
    ObjectName,
    CONVERT
    (
        varchar(64),
        HASHBYTES
        (
            N'SHA2_256',
            CONVERT
            (
                varbinary(max),
                ISNULL(Definition, N'')
            )
        ),
        2
    ) AS DefinitionHash,
    Definition
FROM #ObjectDefinitions
ORDER BY
    DefinitionOrder,
    SchemaName,
    ObjectName;


END;

/*==============================================================================
  RESULTADO 3
  Script SQL completo y concatenado.

  STRING_AGG utiliza @DoubleCRLF porque el separador debe ser un literal
  o una variable; no puede ser una expresión concatenada.
==============================================================================*/

SELECT
    STRING_AGG
    (
        CAST(Definition AS nvarchar(max)),
        @DoubleCRLF
    ) WITHIN GROUP
    (
        ORDER BY DefinitionOrder
    ) AS FullWarroomDefinition
FROM #ObjectDefinitions;