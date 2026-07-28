param(
    [Parameter(Mandatory = $true)]
    [string] $Path
)

$ErrorActionPreference = 'Stop'

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
Add-Type -AssemblyName System.IO.Compression.FileSystem

$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedPath)

try {
    function Read-ZipEntry {
        param([Parameter(Mandatory = $true)][string] $Name)

        $entry = $archive.GetEntry($Name)
        if ($null -eq $entry) {
            throw "Missing workbook entry: $Name"
        }

        $reader = [System.IO.StreamReader]::new($entry.Open())
        try {
            return $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }
    }

    [xml] $sharedStringsXml = Read-ZipEntry 'xl/sharedStrings.xml'
    $sharedNs = [System.Xml.XmlNamespaceManager]::new($sharedStringsXml.NameTable)
    $sharedNs.AddNamespace('m', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')
    $sharedStrings = @(
        $sharedStringsXml.SelectNodes('//m:si', $sharedNs) | ForEach-Object {
            (
                $_.SelectNodes('.//m:t', $sharedNs) |
                    ForEach-Object { $_.InnerText }
            ) -join ''
        }
    )

    [xml] $sheetXml = Read-ZipEntry 'xl/worksheets/sheet1.xml'
    $sheetNs = [System.Xml.XmlNamespaceManager]::new($sheetXml.NameTable)
    $sheetNs.AddNamespace('m', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')

    $headers = @(
        $sheetXml.SelectNodes('//m:sheetData/m:row[@r="1"]/m:c', $sheetNs) |
            ForEach-Object {
                $value = $_.SelectSingleNode('./m:v', $sheetNs)
                if ($_.t -eq 's') {
                    $sharedStrings[[int] $value.InnerText]
                }
                else {
                    $value.InnerText
                }
            }
    )

    $requiredCurrentHeaders = @(
        'ProjectId',
        'TemplateId',
        'PunchId',
        'PunchExportLogId',
        'RowHash',
        'Original Row Hash'
    )

    $missing = @($requiredCurrentHeaders | Where-Object { $_ -notin $headers })
    if ($missing.Count -gt 0) {
        throw "Missing current technical headers: $($missing -join ', ')"
    }

    if ($null -eq $sheetXml.SelectSingleNode('//m:sheetProtection', $sheetNs)) {
        throw 'Punches worksheet is not protected.'
    }

    [xml] $tableXml = Read-ZipEntry 'xl/tables/table1.xml'
    if ($tableXml.table.name -ne 'tblPunches') {
        throw "Expected tblPunches; found $($tableXml.table.name)."
    }

    [xml] $workbookXml = Read-ZipEntry 'xl/workbook.xml'
    $workbookNs = [System.Xml.XmlNamespaceManager]::new($workbookXml.NameTable)
    $workbookNs.AddNamespace('m', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')
    $hiddenNames = @(
        $workbookXml.SelectNodes('//m:sheet[@state="hidden"]', $workbookNs) |
            ForEach-Object { $_.name }
    )

    foreach ($requiredSheet in @('Export Information', 'Column Map', 'Validation Lists', 'Import Log')) {
        if ($requiredSheet -notin $hiddenNames) {
            throw "Expected hidden worksheet: $requiredSheet"
        }
    }

    [pscustomobject] @{
        Workbook = $resolvedPath
        PunchTable = $tableXml.table.name
        PunchTableRange = $tableXml.table.ref
        HeaderCount = $headers.Count
        Protected = $true
        HiddenSupportSheets = $hiddenNames
        CurrentTechnicalHeaders = $requiredCurrentHeaders
        MissingI01Headers = @(
            'ExportBatchId',
            'WorkItemId',
            'RowVersion',
            'ExportedAtUtc',
            'RowChecksum'
        ) | Where-Object { $_ -notin $headers }
    }
}
finally {
    $archive.Dispose()
}
