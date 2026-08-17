function main(workbook: ExcelScript.Workbook): string {
  type Scalar = string | number | boolean;
  type ImportRow = {
    "Export Batch ID": Scalar;
    ProjectId: Scalar;
    TemplateId: Scalar;
    "Work Item ID": Scalar;
    "Row Checksum": Scalar;
    "New Comment": Scalar;
  };

  const table = workbook.getTable("tblPunches");
  if (!table) {
    throw new Error("PR-IMP-C05: governed table 'tblPunches' was not found.");
  }

  const rowCount = table.getRowCount();
  if (rowCount <= 0) {
    throw new Error("PR-IMP-C05: the governed Punches table contains no rows.");
  }

  const headerValues = table.getHeaderRowRange().getValues()[0];
  const headers = headerValues.map((value) => String(value ?? "").trim());

  const requiredHeaders = [
    "Export Batch ID",
    "ProjectId",
    "TemplateId",
    "Work Item ID",
    "Row Checksum",
    "New Comment"
  ];

  const headerIndex = new Map<string, number>();
  headers.forEach((header, index) => {
    headerIndex.set(normalizeHeader(header), index);
  });

  const missing = requiredHeaders.filter(
    (header) => !headerIndex.has(normalizeHeader(header))
  );

  if (missing.length > 0) {
    throw new Error(
      "PR-IMP-C05: this workbook is not import-ready. Missing governed columns: " +
      missing.join(", ") + "."
    );
  }

  const data = table.getRangeBetweenHeaderAndTotal().getValues();

  const rows: ImportRow[] = data.map((values) => ({
    "Export Batch ID": getRequiredValue(values, headerIndex, "Export Batch ID"),
    ProjectId: getRequiredValue(values, headerIndex, "ProjectId"),
    TemplateId: getRequiredValue(values, headerIndex, "TemplateId"),
    "Work Item ID": getRequiredValue(values, headerIndex, "Work Item ID"),
    "Row Checksum": String(
      getRequiredValue(values, headerIndex, "Row Checksum")
    ).trim(),
    "New Comment": getOptionalValue(values, headerIndex, "New Comment")
  }));

  return JSON.stringify(rows);
}

function normalizeHeader(value: string): string {
  return String(value ?? "")
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, "");
}

function getRequiredValue(
  row: (string | number | boolean)[],
  index: Map<string, number>,
  header: string
): string | number | boolean {
  const position = index.get(normalizeHeader(header));
  if (position === undefined) {
    throw new Error("PR-IMP-C05: required column not found: " + header + ".");
  }

  const value = row[position];
  if (value === "" || value === null || value === undefined) {
    throw new Error("PR-IMP-C05: required value is blank in column: " + header + ".");
  }

  return value;
}

function getOptionalValue(
  row: (string | number | boolean)[],
  index: Map<string, number>,
  header: string
): string | number | boolean {
  const position = index.get(normalizeHeader(header));
  if (position === undefined) {
    return "";
  }

  return row[position] ?? "";
}
