# =============================================================================
# EXPORTAR ESQUEMA WARROOM A UN ARCHIVO SQL
# Ejecutar pegando TODO este bloque directamente en PowerShell.
#
# No ejecuta ningún archivo .ps1.
# No requiere cambiar ExecutionPolicy.
# =============================================================================

$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# 1. CONFIGURACIÓN
# -----------------------------------------------------------------------------

$RepoRoot = "C:\Users\seijo\Documents\GitHub\app_pulse"

$Server = "dbs-hointegration-dev.database.windows.net"
$Database = "db-homeoffice-dev"
$User = "tradminhomeoffice"

$InputFile = Join-Path `
    $RepoRoot `
    "database\warroom\tools\extract-warroom-schema-export.sql"

$OutputDirectory = Join-Path `
    $RepoRoot `
    "database\warroom"

$OutputFile = Join-Path `
    $OutputDirectory `
    "warroom-schema.sql"

# -----------------------------------------------------------------------------
# 2. MOSTRAR CONFIGURACIÓN
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " EXPORTACIÓN SQL - ESQUEMA WARROOM" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Servidor :" $Server
Write-Host "Base     :" $Database
Write-Host "Usuario  :" $User
Write-Host "Entrada  :" $InputFile
Write-Host "Salida   :" $OutputFile
Write-Host ""

# -----------------------------------------------------------------------------
# 3. COMPROBAR SQLCMD
# -----------------------------------------------------------------------------

$sqlcmd = Get-Command "sqlcmd.exe" -ErrorAction SilentlyContinue

if (-not $sqlcmd) {
    $sqlcmd = Get-Command "sqlcmd" -ErrorAction SilentlyContinue
}

if (-not $sqlcmd) {

    Write-Host ""
    Write-Host "ERROR: No se ha encontrado sqlcmd." -ForegroundColor Red
    Write-Host ""
    Write-Host "Comprueba si está instalado ejecutando:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    sqlcmd -?" -ForegroundColor White
    Write-Host ""

    throw "sqlcmd no está disponible en el PATH."
}

Write-Host "OK - sqlcmd localizado:" -ForegroundColor Green
Write-Host $sqlcmd.Source
Write-Host ""

# -----------------------------------------------------------------------------
# 4. COMPROBAR CONSULTA SQL
# -----------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $InputFile)) {

    Write-Host ""
    Write-Host "ERROR: No existe el archivo de consulta:" -ForegroundColor Red
    Write-Host ""
    Write-Host $InputFile -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Guarda primero la consulta SQL en esa ubicación." -ForegroundColor Yellow

    throw "No existe la consulta SQL de entrada."
}

Write-Host "OK - Consulta SQL encontrada." -ForegroundColor Green

# -----------------------------------------------------------------------------
# 5. CREAR CARPETA DESTINO SI NO EXISTE
# -----------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $OutputDirectory)) {

    New-Item `
        -ItemType Directory `
        -Path $OutputDirectory `
        -Force | Out-Null

    Write-Host "OK - Carpeta creada:" -ForegroundColor Green
    Write-Host $OutputDirectory
}
else {

    Write-Host "OK - Carpeta destino existente." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 6. ELIMINAR EXPORTACIÓN ANTERIOR
# -----------------------------------------------------------------------------

if (Test-Path -LiteralPath $OutputFile) {

    Write-Host ""
    Write-Host "Existe una exportación anterior." -ForegroundColor Yellow
    Write-Host "Se reemplazará:" -ForegroundColor Yellow
    Write-Host $OutputFile

    Remove-Item `
        -LiteralPath $OutputFile `
        -Force
}

# -----------------------------------------------------------------------------
# 7. USAR UTF-8 EN LA CONSOLA
# -----------------------------------------------------------------------------

$PreviousCodePage = (
    chcp
) -replace '[^\d]', ''

chcp 65001 | Out-Null

# -----------------------------------------------------------------------------
# 8. EJECUTAR SQLCMD
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CONECTANDO A SQL SERVER" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Cuando aparezca Password:, introduce la contraseña SQL." -ForegroundColor Yellow
Write-Host "Los caracteres pueden no mostrarse mientras escribes." -ForegroundColor Yellow
Write-Host ""

try {

    & $sqlcmd.Source `
        -S $Server `
        -d $Database `
        -U $User `
        -i $InputFile `
        -o $OutputFile `
        -h -1 `
        -y 0 `
        -w 65535 `
        -f 65001 `
        -l 30 `
        -b

    $SqlCmdExitCode = $LASTEXITCODE
}
finally {

    if ($PreviousCodePage) {
        chcp $PreviousCodePage | Out-Null
    }
}

# -----------------------------------------------------------------------------
# 9. COMPROBAR RESULTADO SQLCMD
# -----------------------------------------------------------------------------

if ($SqlCmdExitCode -ne 0) {

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " EXPORTACIÓN FALLIDA" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""

    Write-Host "Código devuelto por sqlcmd:" $SqlCmdExitCode -ForegroundColor Red

    if (Test-Path -LiteralPath $OutputFile) {

        Write-Host ""
        Write-Host "Contenido devuelto por SQL Server:" -ForegroundColor Yellow
        Write-Host ""

        Get-Content `
            -LiteralPath $OutputFile `
            -Tail 50
    }

    throw "sqlcmd ha terminado con errores."
}

# -----------------------------------------------------------------------------
# 10. COMPROBAR QUE EL ARCHIVO EXISTE
# -----------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $OutputFile)) {

    throw "sqlcmd terminó pero no se creó warroom-schema.sql."
}

$GeneratedFile = Get-Item -LiteralPath $OutputFile

if ($GeneratedFile.Length -eq 0) {

    throw "warroom-schema.sql se ha creado vacío."
}

# -----------------------------------------------------------------------------
# 11. INFORMACIÓN DEL ARCHIVO GENERADO
# -----------------------------------------------------------------------------

$SizeKB = [math]::Round(
    $GeneratedFile.Length / 1KB,
    2
)

$SizeMB = [math]::Round(
    $GeneratedFile.Length / 1MB,
    2
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " EXPORTACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Archivo:" -ForegroundColor Cyan
Write-Host $GeneratedFile.FullName
Write-Host ""

Write-Host "Tamaño:" -ForegroundColor Cyan
Write-Host "$SizeKB KB ($SizeMB MB)"
Write-Host ""

# -----------------------------------------------------------------------------
# 12. VALIDACIONES BÁSICAS DEL CONTENIDO
# -----------------------------------------------------------------------------

Write-Host "Validando contenido..." -ForegroundColor Cyan
Write-Host ""

$TableMatches = (
    Select-String `
        -LiteralPath $OutputFile `
        -Pattern "CREATE TABLE " `
        -SimpleMatch
).Count

$ProcedureMatches = (
    Select-String `
        -LiteralPath $OutputFile `
        -Pattern "PROCEDURE " `
        -SimpleMatch
).Count

$ForeignKeyMatches = (
    Select-String `
        -LiteralPath $OutputFile `
        -Pattern " FOREIGN KEY " `
        -SimpleMatch
).Count

$IndexMatches = (
    Select-String `
        -LiteralPath $OutputFile `
        -Pattern "CREATE " |
    Where-Object {
        $_.Line -match "INDEX"
    }
).Count

Write-Host "CREATE TABLE encontrados       :" $TableMatches
Write-Host "PROCEDURE encontrados          :" $ProcedureMatches
Write-Host "FOREIGN KEY encontrados        :" $ForeignKeyMatches
Write-Host "Índices encontrados aprox.     :" $IndexMatches
Write-Host ""

# -----------------------------------------------------------------------------
# 13. COMPARAR CON LOS VALORES ESPERADOS DE TU EXTRACCIÓN ACTUAL
# -----------------------------------------------------------------------------

$ExpectedTables = 53
$ExpectedForeignKeys = 14
$ExpectedIndexes = 69
$ExpectedProcedures = 114

Write-Host "Valores esperados según la extracción actual:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tablas               :" $ExpectedTables
Write-Host "Foreign Keys         :" $ExpectedForeignKeys
Write-Host "Índices              :" $ExpectedIndexes
Write-Host "Stored Procedures    :" $ExpectedProcedures
Write-Host ""

if ($TableMatches -ne $ExpectedTables) {

    Write-Host "ADVERTENCIA: el número de tablas no coincide." -ForegroundColor Yellow
}
else {

    Write-Host "OK - Tablas verificadas." -ForegroundColor Green
}

if ($ForeignKeyMatches -ne $ExpectedForeignKeys) {

    Write-Host "ADVERTENCIA: el número de FK no coincide." -ForegroundColor Yellow
}
else {

    Write-Host "OK - Foreign Keys verificadas." -ForegroundColor Green
}

if ($ProcedureMatches -lt $ExpectedProcedures) {

    Write-Host "ADVERTENCIA: parecen faltar procedimientos." -ForegroundColor Yellow
}
else {

    Write-Host "OK - Procedimientos presentes." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 14. MOSTRAR PRIMERAS LÍNEAS
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PRIMERAS LÍNEAS DEL ARCHIVO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Get-Content `
    -LiteralPath $OutputFile `
    -TotalCount 20

# -----------------------------------------------------------------------------
# 15. RESULTADO FINAL
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " LISTO PARA GIT" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "El archivo generado es:" -ForegroundColor Cyan
Write-Host ""
Write-Host $OutputFile -ForegroundColor White
Write-Host ""

Write-Host "Puedes revisarlo ahora en VS Code." -ForegroundColor Green
Write-Host ""
