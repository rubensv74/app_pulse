/* Run only in a non-production database after deploying Block A scripts. */
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'ExportBatchId' AND t.name=N'uniqueidentifier' AND c.is_nullable=0) THROW 51200,'ExportBatchId schema assertion failed.',1;
IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'PunchExportLogId' AND t.name=N'bigint' AND c.is_nullable=0) THROW 51201,'PunchExportLogId schema assertion failed.',1;
IF NOT EXISTS(SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND c.name=N'RowVersion' AND t.name=N'binary' AND c.max_length=8 AND c.is_nullable=1) THROW 51202,'RowVersion must be binary(8) NULL.',1;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND name IN(N'UX_ExportBatch_PunchExportLogId',N'UQ_ExportBatch_PunchExportLogId') AND is_unique=1) THROW 51203,'Unique PunchExportLogId index is missing.',1;
GO

BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @Log TABLE(PunchExportLogId bigint);
 INSERT @Log EXEC [warroom].[usp_PunchExportLog_Start] @ProjectId=900000001,@TemplateSelector=N'77',@FilterJson=N'[]',@CreatedByEmail=N'codex-test@example.invalid',@CreatedByName=N'Codex test';
 DECLARE @LogId bigint=(SELECT TOP(1) PunchExportLogId FROM @Log);
 DECLARE @Rows nvarchar(max)=N'[{"ProjectId":900000001,"PunchId":1001,"PunchExportLogId":'+CONVERT(nvarchar(20),@LogId)+N',"RowHash":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","OriginalValuesJson":{"Code":"P-1001"}},{"ProjectId":900000001,"PunchId":1002,"PunchExportLogId":'+CONVERT(nvarchar(20),@LogId)+N',"RowHash":"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB","OriginalValuesJson":{"Code":"P-1002"}}]';
 DECLARE @Register TABLE(Success bit,ExportBatchId uniqueidentifier,PunchExportLogId bigint,Status varchar(20),RowCount int,WasAlreadyRegistered bit);
 INSERT @Register EXEC [warroom].[usp_RegisterPunchExportSnapshot] @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=77,@ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',@FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;
 DECLARE @BatchId uniqueidentifier=(SELECT TOP(1) ExportBatchId FROM @Register);
 IF (SELECT COUNT(*) FROM [warroom].[ExportBatchRow] WHERE ExportBatchId=@BatchId)<>2 THROW 51210,'Snapshot row count failed.',1;
 IF EXISTS(SELECT 1 FROM [warroom].[ExportBatchRow] WHERE ExportBatchId=@BatchId AND RowVersion IS NOT NULL) THROW 51211,'RowVersion was not NULL.',1;
 DELETE FROM @Register;
 INSERT @Register EXEC [warroom].[usp_RegisterPunchExportSnapshot] @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=77,@ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',@FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;
 IF NOT EXISTS(SELECT 1 FROM @Register WHERE WasAlreadyRegistered=1) THROW 51212,'Identical retry was not idempotent.',1;
 BEGIN TRY
  EXEC [warroom].[usp_RegisterPunchExportSnapshot] @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=78,@ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',@FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;
  THROW 51213,'Different retry unexpectedly succeeded.',1;
 END TRY BEGIN CATCH IF ERROR_NUMBER()=51213 THROW; END CATCH;
 DECLARE @Complete TABLE(Success bit,ExportBatchId uniqueidentifier,PunchExportLogId bigint,Status varchar(20),RowCount int,WasAlreadyCompleted bit);
 INSERT @Complete EXEC [warroom].[usp_CompletePunchExportBatch] @PunchExportLogId=@LogId,@FileName=N'block-a-test.xlsx',@RowCount=2;
 DELETE FROM @Complete;
 INSERT @Complete EXEC [warroom].[usp_CompletePunchExportBatch] @PunchExportLogId=@LogId,@FileName=N'block-a-test.xlsx',@RowCount=2;
 IF NOT EXISTS(SELECT 1 FROM @Complete WHERE WasAlreadyCompleted=1) THROW 51214,'Repeated completion was not idempotent.',1;
 ROLLBACK TRANSACTION;
 SELECT TestResult=N'PASS - snapshot, retry, completion and rollback assertions';
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO
