function main(
  workbook: ExcelScript.Workbook,
  rowsJson: string,
  columnMapJson: string,
  exportInfoJson: string,
  exportMode: string,
  selectedColumnsJson: string
): void {
  type Scalar = string | number | boolean | null;
  type GenericRow = { [key: string]: Scalar };
  type ColumnMapRow = {
    ColumnName?: string;
    FieldDefId?: number;
    FieldKey?: string;
    Label?: string;
    FieldType?: string;
    IsEditableInExcel?: boolean;
    SortOrder?: number;
    OptionsJson?: string;
  };

  const rows = parseJsonArray<GenericRow>(rowsJson, "rowsJson");
  const columnMap = parseJsonArray<ColumnMapRow>(
    columnMapJson,
    "columnMapJson"
  );
  const exportInfo = parseJsonObject<GenericRow>(
    exportInfoJson,
    "exportInfoJson"
  );

  const normalizedExportMode = normalizeExportMode(exportMode);
  const isClientExport = normalizedExportMode === "CLIENT";

  const selectedColumns = isClientExport
    ? parseJsonArray<SelectedExportColumn>(
        selectedColumnsJson,
        "selectedColumnsJson"
      )
    : [];

  const punchesSheet = getOrCreateWorksheet(workbook, "Punches");
  const exportInfoSheet = getOrCreateWorksheet(
    workbook,
    "Export Information"
  );
  const columnMapSheet = getOrCreateWorksheet(workbook, "Column Map");
  const validationSheet = getOrCreateWorksheet(
    workbook,
    "Validation Lists"
  );
  const importLogSheet = getOrCreateWorksheet(workbook, "Import Log");

  deleteLegacySheets(workbook, [
    "Sheet1",
    "ExportInfo",
    "ColumnMap"
  ]);

  const managedSheets = [
    punchesSheet,
    exportInfoSheet,
    columnMapSheet,
    validationSheet,
    importLogSheet
  ];

  managedSheets.forEach((sheet) => {
    sheet.setVisibility(ExcelScript.SheetVisibility.visible);
    unprotectIfNeeded(sheet);
    deleteAllTables(sheet);
    clearWorksheet(sheet);
  });

  const effectiveExportInfo: GenericRow = {
    ...exportInfo,
    ExportMode: normalizedExportMode,
    CanBeImported: isClientExport
      ? false
      : exportInfo["CanBeImported"]
  };

  if (rows.length === 0) {
    writeEmptyPunchesSheet(punchesSheet);
    writeExportInformation(
      exportInfoSheet,
      effectiveExportInfo,
      0,
      normalizedExportMode
    );

    if (isClientExport) {
      deleteClientTechnicalSheets(
        columnMapSheet,
        validationSheet,
        importLogSheet
      );
      exportInfoSheet.setVisibility(
        ExcelScript.SheetVisibility.hidden
      );
    } else {
      writeColumnMap(columnMapSheet, columnMap);
      writeValidationLists(validationSheet, columnMap);
      writeImportLog(importLogSheet);
      finalizeWorkbookSheets(
        exportInfoSheet,
        columnMapSheet,
        validationSheet,
        importLogSheet
      );
    }

    return;
  }

  const sourceHeaders = Object.keys(rows[0]);

  if (sourceHeaders.length === 0) {
    throw new Error(
      "The export dataset does not contain any columns."
    );
  }

  const preparedMap = buildColumnMetadata(columnMap);
  const allHeaders = buildFinalHeaderOrder(
    sourceHeaders,
    preparedMap
  );

  const resolvedClientColumns = isClientExport
    ? resolveClientColumns(
        sourceHeaders,
        allHeaders,
        selectedColumns
      )
    : {
        headers: allHeaders,
        labelMap: new Map<string, string>()
      };

  const finalHeaders = resolvedClientColumns.headers;

  if (finalHeaders.length === 0) {
    throw new Error(
      "The client export does not contain any valid selected columns."
    );
  }

  const effectiveColumnMap = isClientExport
    ? filterColumnMapForHeaders(columnMap, finalHeaders)
    : columnMap;

  const finalRows = buildFinalRows(
    rows,
    finalHeaders,
    preparedMap
  );

  const displayHeaders = finalHeaders.map((header) =>
    resolvedClientColumns.labelMap.get(header) ??
    getDisplayHeader(header, preparedMap)
  );

  const technicalColumns = new Set<string>([
    "ProjectId",
    "PunchId",
    "PunchExportLogId",
    "RowHash",
    "OriginalRowHash",
    "ImportStatus",
    "ImportMessage",
    "TotalRows"
  ]);

  const auxiliaryColumns = new Set<string>([
    "UnitCode",
    "TypeCode",
    "TemplateId",
    "PunchCoordinator",
    "Originator",
    "CategoryCode",
    "StatusCode",
    "InspectionType",
    "EntryType",
    "EntryTypeColor",
    "RejectCount",
    "ElementCodeMapped",
    "ItemsRaw",
    "SubcontractorId",
    "SubcontractorCode",
    "SubcontractorShortName",
    "LastCommentByEmail"
  ]);

  if (!isClientExport) {
    writeValidationLists(
      validationSheet,
      effectiveColumnMap
    );
  }

  writePunchesWorksheet(
    punchesSheet,
    finalHeaders,
    displayHeaders,
    finalRows,
    preparedMap,
    technicalColumns,
    auxiliaryColumns,
    validationSheet,
    !isClientExport
  );

  writeExportInformation(
    exportInfoSheet,
    effectiveExportInfo,
    finalRows.length,
    normalizedExportMode
  );

  if (isClientExport) {
    deleteClientTechnicalSheets(
      columnMapSheet,
      validationSheet,
      importLogSheet
    );

    exportInfoSheet.setVisibility(
      ExcelScript.SheetVisibility.hidden
    );
  } else {
    writeColumnMap(columnMapSheet, effectiveColumnMap);
    writeImportLog(importLogSheet);

    finalizeWorkbookSheets(
      exportInfoSheet,
      columnMapSheet,
      validationSheet,
      importLogSheet
    );
  }
}

interface SelectedExportColumn {
  ColumnKey?: string;
  ColumnLabel?: string;
  SortOrder?: number;
}

interface ResolvedClientColumns {
  headers: string[];
  labelMap: Map<string, string>;
}

interface ColumnMetadata {
  labelMap: Map<string, string>;
  fieldTypeMap: Map<string, string>;
  editableColumns: Set<string>;
  optionsMap: Map<string, string[]>;
  sortOrderMap: Map<string, number>;
}

function parseJsonArray<T>(json: string, argumentName: string): T[] {
  try {
    const parsed: unknown = JSON.parse(json || "[]");
    if (!Array.isArray(parsed)) {
      throw new Error();
    }
    return parsed as T[];
  } catch {
    throw new Error(`${argumentName} does not contain a valid JSON array.`);
  }
}

function parseJsonObject<T>(json: string, argumentName: string): T {
  try {
    const parsed: unknown = JSON.parse(json || "{}");
    if (parsed === null || Array.isArray(parsed) || typeof parsed !== "object") {
      throw new Error();
    }
    return parsed as T;
  } catch {
    throw new Error(`${argumentName} does not contain a valid JSON object.`);
  }
}

function normalizeExportMode(value: string): "CLIENT" | "INTERNAL" {
  return String(value ?? "")
    .trim()
    .toUpperCase() === "INTERNAL"
    ? "INTERNAL"
    : "CLIENT";
}

function resolveClientColumns(
  sourceHeaders: string[],
  allHeaders: string[],
  selectedColumns: SelectedExportColumn[]
): ResolvedClientColumns {
  const sourceHeaderSet = new Set<string>(sourceHeaders);
  const availableHeaderSet = new Set<string>(allHeaders);

  const forbiddenClientColumns = new Set<string>([
    "ProjectId",
    "PunchId",
    "PunchExportLogId",
    "RowHash",
    "OriginalRowHash",
    "ImportStatus",
    "ImportMessage",
    "TotalRows",
    "TemplateId",
    "SubcontractorId"
  ]);

  const normalizedSelections = selectedColumns
    .map((item, index) => {
      const columnKey = String(item.ColumnKey ?? "").trim();
      const columnLabel = String(
        item.ColumnLabel ?? columnKey
      ).trim();
      const sortOrder =
        typeof item.SortOrder === "number"
          ? item.SortOrder
          : index;

      return {
        columnKey,
        columnLabel: columnLabel || columnKey,
        sortOrder,
        sourceIndex: index
      };
    })
    .filter((item) => item.columnKey.length > 0)
    .sort((left, right) =>
      left.sortOrder - right.sortOrder ||
      left.sourceIndex - right.sourceIndex
    );

  const headers: string[] = [];
  const labelMap = new Map<string, string>();
  const seen = new Set<string>();

  normalizedSelections.forEach((selection) => {
    const key = selection.columnKey;

    if (
      seen.has(key) ||
      forbiddenClientColumns.has(key) ||
      !sourceHeaderSet.has(key) ||
      !availableHeaderSet.has(key)
    ) {
      return;
    }

    headers.push(key);
    labelMap.set(key, selection.columnLabel);
    seen.add(key);
  });

  return {
    headers,
    labelMap
  };
}

function filterColumnMapForHeaders<T extends {
  ColumnName?: string;
}>(
  columnMap: T[],
  headers: string[]
): T[] {
  const selectedHeaders = new Set<string>(headers);

  return columnMap.filter((item) => {
    const columnName = String(
      item.ColumnName ?? ""
    ).trim();

    return columnName.length > 0 &&
      selectedHeaders.has(columnName);
  });
}

function deleteClientTechnicalSheets(
  columnMapSheet: ExcelScript.Worksheet,
  validationSheet: ExcelScript.Worksheet,
  importLogSheet: ExcelScript.Worksheet
): void {
  columnMapSheet.delete();
  validationSheet.delete();
  importLogSheet.delete();
}

function getOrCreateWorksheet(
  workbook: ExcelScript.Workbook,
  name: string
): ExcelScript.Worksheet {
  return workbook.getWorksheet(name) ?? workbook.addWorksheet(name);
}

function deleteLegacySheets(
  workbook: ExcelScript.Workbook,
  names: string[]
): void {
  names.forEach((name) => {
    const sheet = workbook.getWorksheet(name);
    if (sheet) {
      sheet.delete();
    }
  });
}

function unprotectIfNeeded(sheet: ExcelScript.Worksheet): void {
  const protection = sheet.getProtection();
  if (protection.getProtected()) {
    protection.unprotect();
  }
}

function deleteAllTables(sheet: ExcelScript.Worksheet): void {
  sheet.getTables().forEach((table) => table.delete());
}

function clearWorksheet(sheet: ExcelScript.Worksheet): void {
  const usedRange = sheet.getUsedRange();
  if (usedRange) {
    usedRange.clear(ExcelScript.ClearApplyTo.all);
  }
}

function buildColumnMetadata(
  columnMap: {
    ColumnName?: string;
    Label?: string;
    FieldType?: string;
    IsEditableInExcel?: boolean;
    SortOrder?: number;
    OptionsJson?: string;
  }[]
): ColumnMetadata {
  const metadata: ColumnMetadata = {
    labelMap: new Map<string, string>(),
    fieldTypeMap: new Map<string, string>(),
    editableColumns: new Set<string>(),
    optionsMap: new Map<string, string[]>(),
    sortOrderMap: new Map<string, number>()
  };

  columnMap.forEach((item) => {
    const columnName = String(item.ColumnName ?? "").trim();
    if (!columnName) {
      return;
    }

    const label = String(item.Label ?? columnName).trim() || columnName;
    const fieldType = String(item.FieldType ?? "Text").trim() || "Text";

    metadata.labelMap.set(columnName, label);
    metadata.fieldTypeMap.set(columnName, fieldType);
    metadata.sortOrderMap.set(
      columnName,
      typeof item.SortOrder === "number" ? item.SortOrder : 999999
    );

    if (item.IsEditableInExcel === true) {
      metadata.editableColumns.add(columnName);
    }

    metadata.optionsMap.set(
      columnName,
      parseOptionsJson(item.OptionsJson)
    );
  });

  return metadata;
}

function parseOptionsJson(optionsJson?: string): string[] {
  if (!optionsJson || !String(optionsJson).trim()) {
    return [];
  }

  try {
    const parsed: unknown = JSON.parse(optionsJson);

    if (Array.isArray(parsed)) {
      return parsed
        .map((value) => String(value ?? "").trim())
        .filter((value) => value.length > 0);
    }

    if (parsed && typeof parsed === "object") {
      const candidateKeys = ["options", "values", "items", "choices"];
      for (const key of candidateKeys) {
        const candidate = (parsed as { [key: string]: unknown })[key];
        if (Array.isArray(candidate)) {
          return candidate
            .map((value) => {
              if (value && typeof value === "object") {
                const objectValue = value as { [key: string]: unknown };
                return String(
                  objectValue.label ??
                  objectValue.value ??
                  objectValue.name ??
                  ""
                ).trim();
              }
              return String(value ?? "").trim();
            })
            .filter((value) => value.length > 0);
        }
      }
    }
  } catch {
    return String(optionsJson)
      .split(/[;,|]/)
      .map((value) => value.trim())
      .filter((value) => value.length > 0);
  }

  return [];
}

function buildFinalHeaderOrder(
  sourceHeaders: string[],
  metadata: ColumnMetadata
): string[] {
  const preferredVisibleOrder = [
    "AreaCode",
    "SystemCode",
    "SubsystemCode",
    "ElementCode",
    "ElementDiscipline",
    "Code",
    "Description",
    "Category",
    "Discipline",
    "Status",
    "InspectionCode",
    "InspectionName",
    "SubcontractorName",
    "DepartmentAction",
    "LastCommentOn",
    "LastCommentText",
    "CommentCount"
  ];

  const technicalOrder = [
    "ProjectId",
    "PunchId",
    "PunchExportLogId",
    "RowHash"
  ];

  const auxiliaryOrder = [
    "UnitCode",
    "TypeCode",
    "TemplateId",
    "PunchCoordinator",
    "Originator",
    "CategoryCode",
    "StatusCode",
    "InspectionType",
    "EntryType",
    "EntryTypeColor",
    "Topic",
    "RejectCount",
    "ElementCodeMapped",
    "ItemsRaw",
    "SubcontractorId",
    "SubcontractorCode",
    "SubcontractorShortName",
    "LastCommentByEmail",
    "TotalRows"
  ];

  const customHeaders = sourceHeaders
    .filter((header) => metadata.fieldTypeMap.has(header))
    .sort((left, right) => {
      const leftOrder = metadata.sortOrderMap.get(left) ?? 999999;
      const rightOrder = metadata.sortOrderMap.get(right) ?? 999999;
      return leftOrder - rightOrder || left.localeCompare(right);
    });

  const reserved = new Set<string>([
    ...preferredVisibleOrder,
    ...technicalOrder,
    ...auxiliaryOrder,
    ...customHeaders,
    "NewComment"
  ]);

  const otherHeaders = sourceHeaders.filter(
    (header) => !reserved.has(header)
  );

  const ordered = [
    ...preferredVisibleOrder,
    ...customHeaders,
    "NewComment",
    ...otherHeaders,
    ...auxiliaryOrder,
    ...technicalOrder,
    "OriginalRowHash",
    "ImportStatus",
    "ImportMessage"
  ];

  const available = new Set<string>([
    ...sourceHeaders,
    "OriginalRowHash",
    "ImportStatus",
    "ImportMessage"
  ]);

  const result: string[] = [];
  const seen = new Set<string>();

  ordered.forEach((header) => {
    if (available.has(header) && !seen.has(header)) {
      result.push(header);
      seen.add(header);
    }
  });

  sourceHeaders.forEach((header) => {
    if (!seen.has(header)) {
      result.push(header);
      seen.add(header);
    }
  });

  return result;
}

function buildFinalRows(
  rows: { [key: string]: string | number | boolean | null }[],
  headers: string[],
  metadata: ColumnMetadata
): (string | number | boolean)[][] {
  return rows.map((row) => {
    return headers.map((header) => {
      if (header === "OriginalRowHash") {
        return normalizeExcelValue(row["RowHash"]);
      }

      if (header === "ImportStatus" || header === "ImportMessage") {
        return "";
      }

      const rawValue = row[header];
      const fieldType = metadata.fieldTypeMap.get(header) ?? "";

      if (fieldType === "MultiChoice") {
        return normalizeMultiChoiceValue(rawValue);
      }

      if (fieldType === "YesNo" || fieldType === "Boolean") {
        return normalizeBooleanValue(rawValue);
      }

      if (
        fieldType === "Date" ||
        fieldType === "DateTime" ||
        header === "LastCommentOn" ||
        header === "CustomLastUpdatedOn"
      ) {
        return normalizeDateValue(rawValue);
      }

      return normalizeExcelValue(rawValue);
    });
  });
}

function getDisplayHeader(
  header: string,
  metadata: ColumnMetadata
): string {
  const fixedLabels: { [key: string]: string } = {
    AreaCode: "Area",
    SystemCode: "System",
    SubsystemCode: "Subsystem",
    ElementCode: "Element",
    ElementDiscipline: "Element Discipline",
    Code: "Punch",
    InspectionCode: "Inspection",
    InspectionName: "Inspection Name",
    SubcontractorName: "Subcontractor",
    LastCommentOn: "Last Comment On",
    LastCommentText: "Last Comment",
    CommentCount: "Comment Count",
    NewComment: "New Comment",
    OriginalRowHash: "Original Row Hash",
    ImportStatus: "Import Status",
    ImportMessage: "Import Message"
  };

  return metadata.labelMap.get(header) ?? fixedLabels[header] ?? header;
}

function writePunchesWorksheet(
  sheet: ExcelScript.Worksheet,
  headers: string[],
  displayHeaders: string[],
  rows: (string | number | boolean)[][],
  metadata: ColumnMetadata,
  technicalColumns: Set<string>,
  auxiliaryColumns: Set<string>,
  validationSheet: ExcelScript.Worksheet,
  allowEditing: boolean
): void {
  const rowCount = rows.length;
  const columnCount = headers.length;

  const headerRange = sheet.getRangeByIndexes(0, 0, 1, columnCount);
  headerRange.setValues([displayHeaders]);

  const dataRange = sheet.getRangeByIndexes(1, 0, rowCount, columnCount);
  dataRange.setValues(rows);

  const fullRange = sheet.getRangeByIndexes(
    0,
    0,
    rowCount + 1,
    columnCount
  );

  const table = sheet.addTable(fullRange, true);
  table.setName("tblPunches");
  table.setPredefinedTableStyle("TableStyleMedium2");
  table.setShowBandedRows(true);

  sheet.getFreezePanes().freezeRows(1);

  formatPunchesHeader(headerRange);
  formatPunchesData(dataRange);

  const editableFill = "#DDEBF7";
  const newCommentFill = "#E2F0D9";
  const readOnlyFill = "#F3F4F6";

  dataRange.getFormat().getProtection().setLocked(true);
  headerRange.getFormat().getProtection().setLocked(true);

  headers.forEach((header, columnIndex) => {
    const columnDataRange = sheet.getRangeByIndexes(
      1,
      columnIndex,
      rowCount,
      1
    );
    const fullColumnRange = sheet.getRangeByIndexes(
      0,
      columnIndex,
      rowCount + 1,
      1
    );
    const fieldType = metadata.fieldTypeMap.get(header) ?? "";
    const isEditable = metadata.editableColumns.has(header);
    const isNewComment = header === "NewComment";
    const isTechnical = technicalColumns.has(header);
    const isAuxiliary = auxiliaryColumns.has(header);

    applyColumnNumberFormat(
      header,
      fieldType,
      columnDataRange,
      rowCount
    );

    configureColumnWidthAndWrapping(
      header,
      fieldType,
      fullColumnRange
    );

    if (allowEditing && (isEditable || isNewComment)) {
      columnDataRange
        .getFormat()
        .getProtection()
        .setLocked(false);

      columnDataRange
        .getFormat()
        .getFill()
        .setColor(
          isNewComment
            ? newCommentFill
            : editableFill
        );

      headerRange
        .getCell(0, columnIndex)
        .getFormat()
        .getFill()
        .setColor(
          isNewComment
            ? "#70AD47"
            : "#5B9BD5"
        );
    } else if (!isTechnical && !isAuxiliary) {
      columnDataRange
        .getFormat()
        .getFill()
        .setColor(readOnlyFill);
    }

    if (isTechnical || isAuxiliary) {
      fullColumnRange.setColumnHidden(true);
    }
  });

  if (allowEditing) {
    applyEditableColumnValidations(
      sheet,
      headers,
      rowCount,
      metadata,
      validationSheet
    );
  }

  const usedRange = sheet.getUsedRange();
  if (usedRange) {
    usedRange.getFormat().setVerticalAlignment(
      ExcelScript.VerticalAlignment.center
    );
  }

  dataRange.getFormat().setRowHeight(36);

  sheet.getProtection().protect({
    allowAutoFilter: true,
    allowSort: true,
    allowFormatColumns: false,
    allowFormatRows: false,
    allowInsertRows: false,
    allowDeleteRows: false,
    allowInsertColumns: false,
    allowDeleteColumns: false,
    allowPivotTables: false
  });
}

function formatPunchesHeader(headerRange: ExcelScript.Range): void {
  const format = headerRange.getFormat();
  format.getFill().setColor("#1F4E78");
  format.getFont().setColor("#FFFFFF");
  format.getFont().setBold(true);
  format.setWrapText(true);
  format.setHorizontalAlignment(ExcelScript.HorizontalAlignment.center);
  format.setVerticalAlignment(ExcelScript.VerticalAlignment.center);
  format.setRowHeight(30);
}

function formatPunchesData(dataRange: ExcelScript.Range): void {
  const format = dataRange.getFormat();
  format.setVerticalAlignment(ExcelScript.VerticalAlignment.center);
  format.getFont().setSize(10);
}

function applyColumnNumberFormat(
  header: string,
  fieldType: string,
  range: ExcelScript.Range,
  rowCount: number
): void {
  if (rowCount <= 0) {
    return;
  }

  if (fieldType === "Date") {
    applyNumberFormat(range, rowCount, "dd/mm/yyyy");
    return;
  }

  if (
    fieldType === "DateTime" ||
    header === "LastCommentOn" ||
    header === "CustomLastUpdatedOn"
  ) {
    applyNumberFormat(range, rowCount, "dd/mm/yyyy hh:mm");
    return;
  }

  if (fieldType === "Number") {
    applyNumberFormat(range, rowCount, "#,##0.####");
    return;
  }

  if (fieldType === "Integer") {
    applyNumberFormat(range, rowCount, "#,##0");
  }
}

function configureColumnWidthAndWrapping(
  header: string,
  fieldType: string,
  range: ExcelScript.Range
): void {
  const format = range.getFormat();
  format.setWrapText(false);

  const longTextHeaders = new Set<string>([
    "Description",
    "DepartmentAction",
    "LastCommentText",
    "NewComment",
    "ItemsRaw",
    "ImportMessage"
  ]);

  if (longTextHeaders.has(header)) {
    format.setColumnWidth(header === "NewComment" ? 260 : 240);
    format.setWrapText(true);
    return;
  }

  if (fieldType === "MultiChoice" || fieldType === "Text") {
    format.setColumnWidth(180);
    format.setWrapText(true);
    return;
  }

  if (fieldType === "Date" || fieldType === "DateTime") {
    format.setColumnWidth(115);
    return;
  }

  if (fieldType === "Number" || fieldType === "Integer") {
    format.setColumnWidth(90);
    return;
  }

  const mediumHeaders = new Set<string>([
    "AreaCode",
    "SystemCode",
    "SubsystemCode",
    "ElementCode",
    "ElementDiscipline",
    "Code",
    "Category",
    "Discipline",
    "Status",
    "InspectionCode",
    "SubcontractorName"
  ]);

  format.setColumnWidth(mediumHeaders.has(header) ? 120 : 105);
}

function applyEditableColumnValidations(
  sheet: ExcelScript.Worksheet,
  headers: string[],
  rowCount: number,
  metadata: ColumnMetadata,
  validationSheet: ExcelScript.Worksheet
): void {
  if (rowCount <= 0) {
    return;
  }

  headers.forEach((header, columnIndex) => {
    if (!metadata.editableColumns.has(header)) {
      return;
    }

    const range = sheet.getRangeByIndexes(
      1,
      columnIndex,
      rowCount,
      1
    );

    const fieldType =
      metadata.fieldTypeMap.get(header) ?? "Text";

    const validation =
      range.getDataValidation();

    validation.clear();

    /*
      IMPORTANT:
      Excel does not reliably preserve a list-validation rule whose
      source directly references a different hidden worksheet.

      For Choice and YesNo fields, the permitted values are therefore
      embedded directly in the rule. This makes the dropdown visible
      when the workbook is generated through Power Automate.
    */
    if (
      fieldType === "Choice" ||
      fieldType === "YesNo" ||
      fieldType === "Boolean"
    ) {
      let options =
        metadata.optionsMap.get(header) ?? [];

      if (
        fieldType === "YesNo" ||
        fieldType === "Boolean"
      ) {
        options = ["Yes", "No"];
      }

      options = uniqueValues(
        options
          .map((value) => String(value).trim())
          .filter((value) => value.length > 0)
      );

      if (options.length > 0) {
        const inlineSource =
          options.join(",");

        if (inlineSource.length > 255) {
          throw new Error(
            `The validation list for '${header}' exceeds Excel's 255-character inline-list limit.`
          );
        }

        validation.setRule({
          list: {
            inCellDropDown: true,
            source: inlineSource
          }
        });

        validation.setPrompt({
          message:
            "Select a value from the dropdown list.",
          showPrompt: true,
          title: "Editable field"
        });

        validation.setErrorAlert({
          message:
            "Select one of the values available in the dropdown list.",
          showAlert: true,
          style:
            ExcelScript.DataValidationAlertStyle.stop,
          title: "Invalid value"
        });
      }

      return;
    }

    /*
      Excel has no native multi-select dropdown without VBA.
      MultiChoice remains editable as semicolon-separated text.
    */
    if (fieldType === "MultiChoice") {
      validation.setPrompt({
        message:
          "Enter one or more permitted values separated by semicolons (;).",
        showPrompt: true,
        title: "Multiple values"
      });

      return;
    }

    const address =
      range
        .getCell(0, 0)
        .getAddress()
        .split("!")[1];

    if (
      fieldType === "Number" ||
      fieldType === "Integer"
    ) {
      const numberFormula =
        fieldType === "Integer"
          ? `=OR(${address}="",AND(ISNUMBER(${address}),MOD(${address},1)=0))`
          : `=OR(${address}="",ISNUMBER(${address}))`;

      validation.setRule({
        custom: {
          formula: numberFormula
        }
      });

      validation.setErrorAlert({
        message:
          fieldType === "Integer"
            ? "Enter a whole number or leave the cell blank."
            : "Enter a numeric value or leave the cell blank.",
        showAlert: true,
        style:
          ExcelScript.DataValidationAlertStyle.stop,
        title: "Invalid number"
      });

      return;
    }

    if (
      fieldType === "Date" ||
      fieldType === "DateTime"
    ) {
      validation.setRule({
        custom: {
          formula:
            `=OR(${address}="",ISNUMBER(${address}))`
        }
      });

      validation.setErrorAlert({
        message:
          "Enter a valid Excel date or leave the cell blank.",
        showAlert: true,
        style:
          ExcelScript.DataValidationAlertStyle.stop,
        title: "Invalid date"
      });
    }
  });
}

function writeValidationLists(
  sheet: ExcelScript.Worksheet,
  columnMap: {
    ColumnName?: string;
    Label?: string;
    FieldType?: string;
    OptionsJson?: string;
  }[]
): void {
  const columns: { key: string; label: string; values: string[] }[] = [];

  columnMap.forEach((item) => {
    const key = String(item.ColumnName ?? "").trim();
    if (!key) {
      return;
    }

    const fieldType = String(item.FieldType ?? "").trim();
    let values = parseOptionsJson(item.OptionsJson);

    if (fieldType === "YesNo" || fieldType === "Boolean") {
      values = ["Yes", "No"];
    }

    if ((fieldType === "Choice" || fieldType === "YesNo" || fieldType === "Boolean") && values.length > 0) {
      columns.push({
        key,
        label: String(item.Label ?? key).trim() || key,
        values: uniqueValues(values)
      });
    }
  });

  if (columns.length === 0) {
    sheet.getRange("A1").setValue("No validation lists configured.");
    return;
  }

  columns.forEach((column, index) => {
    const headerCell = sheet.getCell(0, index);
    headerCell.setValue(column.label);
    headerCell.getFormat().getFont().setBold(true);
    headerCell.getFormat().getFill().setColor("#D9EAF7");

    const values = column.values.map((value) => [value]);
    sheet
      .getRangeByIndexes(1, index, values.length, 1)
      .setValues(values);
  });

  const usedRange = sheet.getUsedRange();
  if (usedRange) {
    usedRange.getFormat().autofitColumns();
  }
}


function writeExportInformation(
  sheet: ExcelScript.Worksheet,
  exportInfo: {
    [key: string]: string | number | boolean | null
  },
  rowCount: number,
  exportMode: "CLIENT" | "INTERNAL"
): void {
  const isClientExport = exportMode === "CLIENT";

  const titleRange = sheet.getRange("A1:B1");
  titleRange.merge();
  titleRange.setValue("PULSE â€” Punch Export");
  titleRange.getFormat().getFill().setColor("#1F4E78");
  titleRange.getFormat().getFont().setColor("#FFFFFF");
  titleRange.getFormat().getFont().setBold(true);
  titleRange.getFormat().getFont().setSize(16);
  titleRange.getFormat().setHorizontalAlignment(
    ExcelScript.HorizontalAlignment.center
  );
  titleRange.getFormat().setRowHeight(32);

  const generatedOn = normalizeDateValue(
    exportInfo["ExportedOnUtc"]
  );

  const infoRows: (string | number | boolean)[][] = [
    [
      "Project",
      normalizeExcelValue(exportInfo["ProjectId"])
    ],
    [
      "Generated",
      generatedOn
    ],
    [
      "Generated by",
      normalizeExcelValue(exportInfo["ExportedByName"])
    ],
    [
      "User email",
      normalizeExcelValue(exportInfo["ExportedByEmail"])
    ],
    [
      "Export log",
      normalizeExcelValue(exportInfo["PunchExportLogId"])
    ],
    [
      "Rows",
      rowCount
    ],
    [
      "Export mode",
      exportMode
    ],
    [
      "Can be imported",
      isClientExport
        ? "No"
        : normalizeBooleanValue(
            exportInfo["CanBeImported"]
          )
    ],
    [
      "Workbook version",
      "3.0"
    ]
  ];

  const infoStartRow = 2;
  const infoRange = sheet.getRangeByIndexes(
    infoStartRow,
    0,
    infoRows.length,
    2
  );

  infoRange.setValues(infoRows);

  const labelRange = sheet.getRangeByIndexes(
    infoStartRow,
    0,
    infoRows.length,
    1
  );

  labelRange.getFormat().getFont().setBold(true);
  labelRange.getFormat().getFill().setColor("#D9EAF7");

  sheet
    .getRangeByIndexes(
      infoStartRow + 1,
      1,
      1,
      1
    )
    .setNumberFormat("dd/mm/yyyy hh:mm");

  const instructionTitleRow =
    infoStartRow + infoRows.length + 2;

  const instructionTitleRange =
    sheet.getRangeByIndexes(
      instructionTitleRow,
      0,
      1,
      2
    );

  instructionTitleRange.merge();
  instructionTitleRange.setValue("Instructions");
  instructionTitleRange
    .getFormat()
    .getFill()
    .setColor("#5B9BD5");
  instructionTitleRange
    .getFormat()
    .getFont()
    .setColor("#FFFFFF");
  instructionTitleRange
    .getFormat()
    .getFont()
    .setBold(true);

  const instructions = isClientExport
    ? [
        "This client export contains only the columns selected in PULSE.",
        "Columns not selected were physically excluded from the workbook.",
        "The workbook is protected and is not intended for re-import into PULSE.",
        "Do not rename headers when using the workbook as a reporting reference."
      ]
    : [
        "Edit only the blue cells and the green New Comment cells.",
        "Do not rename headers, delete rows, add columns or modify hidden sheets.",
        "For fields with multiple values, separate each value using a semicolon (;).",
        "Use the dropdown lists whenever they are available.",
        "Save the workbook in XLSX format before importing it into PULSE."
      ];

  const instructionRows =
    instructions.map((instruction) => [
      "â€¢",
      instruction
    ]);

  const instructionRange =
    sheet.getRangeByIndexes(
      instructionTitleRow + 1,
      0,
      instructionRows.length,
      2
    );

  instructionRange.setValues(instructionRows);

  sheet
    .getRangeByIndexes(
      instructionTitleRow + 1,
      0,
      instructionRows.length,
      1
    )
    .getFormat()
    .setHorizontalAlignment(
      ExcelScript.HorizontalAlignment.center
    );

  sheet
    .getRangeByIndexes(
      instructionTitleRow + 1,
      1,
      instructionRows.length,
      1
    )
    .getFormat()
    .setWrapText(true);

  sheet.getRange("A:A").getFormat().setColumnWidth(155);
  sheet.getRange("B:B").getFormat().setColumnWidth(360);

  const usedRange = sheet.getUsedRange();

  if (usedRange) {
    usedRange
      .getFormat()
      .setVerticalAlignment(
        ExcelScript.VerticalAlignment.center
      );
  }

  instructionRange.getFormat().setRowHeight(28);
}

function writeColumnMap(
  sheet: ExcelScript.Worksheet,
  columnMap: {
    [key: string]: string | number | boolean | null | undefined;
  }[]
): void {
  if (columnMap.length === 0) {
    sheet.getRange("A1").setValue("No custom fields configured.");
    return;
  }

  const headers = Object.keys(columnMap[0]);
  const values = columnMap.map((row) =>
    headers.map((header) => normalizeExcelValue(row[header]))
  );

  sheet.getRangeByIndexes(0, 0, 1, headers.length).setValues([headers]);
  sheet.getRangeByIndexes(1, 0, values.length, headers.length).setValues(values);

  const fullRange = sheet.getRangeByIndexes(
    0,
    0,
    values.length + 1,
    headers.length
  );
  const table = sheet.addTable(fullRange, true);
  table.setName("tblColumnMap");
  table.setPredefinedTableStyle("TableStyleMedium2");

  const usedRange = sheet.getUsedRange();
  if (usedRange) {
    usedRange.getFormat().autofitColumns();
    usedRange.getFormat().setWrapText(true);
  }
}

function writeImportLog(sheet: ExcelScript.Worksheet): void {
  const headers = [["Row", "Status", "Message"]];
  sheet.getRange("A1:C1").setValues(headers);
  sheet.getRange("A1:C1").getFormat().getFill().setColor("#1F4E78");
  sheet.getRange("A1:C1").getFormat().getFont().setColor("#FFFFFF");
  sheet.getRange("A1:C1").getFormat().getFont().setBold(true);
  sheet.getRange("A:A").getFormat().setColumnWidth(70);
  sheet.getRange("B:B").getFormat().setColumnWidth(95);
  sheet.getRange("C:C").getFormat().setColumnWidth(320);
}

function writeEmptyPunchesSheet(sheet: ExcelScript.Worksheet): void {
  sheet.getRange("A1").setValue("No punches matched the current filters.");
  sheet.getRange("A1").getFormat().getFont().setBold(true);
  sheet.getRange("A1").getFormat().getFill().setColor("#D9EAF7");
  sheet.getRange("A:A").getFormat().setColumnWidth(300);
}

function finalizeWorkbookSheets(
  exportInfoSheet: ExcelScript.Worksheet,
  columnMapSheet: ExcelScript.Worksheet,
  validationSheet: ExcelScript.Worksheet,
  importLogSheet: ExcelScript.Worksheet
): void {
  exportInfoSheet.setVisibility(ExcelScript.SheetVisibility.hidden);
  columnMapSheet.setVisibility(ExcelScript.SheetVisibility.hidden);
  validationSheet.setVisibility(ExcelScript.SheetVisibility.hidden);
  importLogSheet.setVisibility(ExcelScript.SheetVisibility.hidden);
}

function normalizeExcelValue(
  value: string | number | boolean | null | undefined
): string | number | boolean {
  if (value === null || value === undefined) {
    return "";
  }
  return value;
}

function normalizeBooleanValue(
  value: string | number | boolean | null | undefined
): string {
  if (value === null || value === undefined || value === "") {
    return "";
  }

  if (typeof value === "boolean") {
    return value ? "Yes" : "No";
  }

  if (typeof value === "number") {
    return value === 0 ? "No" : "Yes";
  }

  const normalized = String(value).trim().toLowerCase();
  if (["true", "yes", "1", "si", "sÃ­"].includes(normalized)) {
    return "Yes";
  }
  if (["false", "no", "0"].includes(normalized)) {
    return "No";
  }

  return String(value);
}

function normalizeMultiChoiceValue(
  value: string | number | boolean | null | undefined
): string {
  if (value === null || value === undefined || value === "") {
    return "";
  }

  if (typeof value !== "string") {
    return String(value);
  }

  const raw = value.trim();
  if (!raw) {
    return "";
  }

  try {
    const parsed: unknown = JSON.parse(raw);
    if (Array.isArray(parsed)) {
      return parsed
        .map((item) => String(item ?? "").trim())
        .filter((item) => item.length > 0)
        .join(";");
    }
  } catch {
    return raw
      .split(";")
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
      .join(";");
  }

  return raw;
}

function normalizeDateValue(
  value: string | number | boolean | null | undefined
): string | number {
  if (value === null || value === undefined || value === "") {
    return "";
  }

  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "boolean") {
    return value ? 1 : 0;
  }

  const rawValue = String(value).trim();
  if (!rawValue) {
    return "";
  }

  const parsedDate = new Date(rawValue);
  if (Number.isNaN(parsedDate.getTime())) {
    return rawValue;
  }

  const excelEpochUtc = Date.UTC(1899, 11, 30, 0, 0, 0);
  const parsedDateUtc = Date.UTC(
    parsedDate.getUTCFullYear(),
    parsedDate.getUTCMonth(),
    parsedDate.getUTCDate(),
    parsedDate.getUTCHours(),
    parsedDate.getUTCMinutes(),
    parsedDate.getUTCSeconds()
  );

  return (parsedDateUtc - excelEpochUtc) / 86400000;
}

function applyNumberFormat(
  range: ExcelScript.Range,
  rowCount: number,
  formatCode: string
): void {
  if (rowCount <= 0) {
    return;
  }

  range.setNumberFormat(formatCode);
}

function uniqueValues(values: string[]): string[] {
  const result: string[] = [];
  const seen = new Set<string>();

  values.forEach((value) => {
    const normalized = value.trim();
    const key = normalized.toLowerCase();
    if (normalized && !seen.has(key)) {
      result.push(normalized);
      seen.add(key);
    }
  });

  return result;
}

function quoteSheetName(name: string): string {
  return `'${name.replace(/'/g, "''")}'`;
}

function stripSheetName(address: string): string {
  const separatorIndex = address.indexOf("!");
  return separatorIndex >= 0
    ? address.substring(separatorIndex + 1)
    : address;
}


