/* Canonical Punch export snapshot migration - 2026-07-30 */
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
BEGIN TRY
 BEGIN TRANSACTION;
 IF OBJECT_ID(N'[warroom].[ExportBatch]',N'U') IS NULL THROW 51100,'warroom.ExportBatch does not exist. Run the foundation script.',1;
 IF OBJECT_ID(N'[warroom].[ExportBatchRow]',N'U') IS NULL THROW 51101,'warroom.ExportBatchRow does not exist. Run the foundation script.',1;
 IF OBJECT_ID(N'[warroom].[PunchExportLog]',N'U') IS NULL THROW 51102,'warroom.PunchExportLog does not exist.',1;
 IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'ExportBatchId' AND t.name=N'uniqueidentifier' AND c.is_nullable=0) THROW 51103,'ExportBatch.ExportBatchId is not uniqueidentifier NOT NULL; automatic key migration is not supported.',1;
 IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'PunchExportLogId' AND t.name=N'bigint' AND c.is_nullable=0) THROW 51104,'ExportBatch.PunchExportLogId is not bigint NOT NULL; automatic data migration is not supported.',1;
 IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND c.name=N'ExportBatchId' AND t.name=N'uniqueidentifier' AND c.is_nullable=0) THROW 51105,'ExportBatchRow.ExportBatchId is not uniqueidentifier NOT NULL.',1;
 IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND c.name=N'RowVersion' AND t.name=N'binary' AND c.max_length=8) THROW 51106,'ExportBatchRow.RowVersion is not binary(8); automatic type conversion is not supported.',1;
 IF EXISTS(SELECT PunchExportLogId FROM [warroom].[ExportBatch] GROUP BY PunchExportLogId HAVING COUNT(*)>1) THROW 51107,'Duplicate PunchExportLogId values prevent the canonical unique index.',1;
 IF EXISTS(SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND name=N'RowVersion' AND is_nullable=0) ALTER TABLE [warroom].[ExportBatchRow] ALTER COLUMN [RowVersion] binary(8) NULL;
 IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND name=N'UX_ExportBatch_PunchExportLogId') CREATE UNIQUE INDEX [UX_ExportBatch_PunchExportLogId] ON [warroom].[ExportBatch]([PunchExportLogId]);
 IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND referenced_object_id=OBJECT_ID(N'[warroom].[ExportBatch]')) THROW 51108,'ExportBatchRow to ExportBatch foreign key is missing.',1;
 COMMIT TRANSACTION;
 SELECT Migration=N'20260730_align_punch_export_snapshot_model',Success=CAST(1 AS bit),RowVersionIsNullable=CONVERT(bit,(SELECT is_nullable FROM sys.columns WHERE object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND name=N'RowVersion'));
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO
