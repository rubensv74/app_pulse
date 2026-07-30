/* Read-only classification of incomplete Punch export attempts. */
SET NOCOUNT ON;
GO
SELECT l.PunchExportLogId,l.ProjectId,l.ExportStatus,l.CreatedOn,l.RowCount AS LogRowCount,l.FileName AS LogFileName,l.FileUrl,l.ErrorMessage,b.ExportBatchId,b.Status AS BatchStatus,b.RowCount AS BatchRowCount,SnapshotRowCount=COUNT(br.WorkItemId),Classification=CASE WHEN b.ExportBatchId IS NULL THEN 'SIN_BATCH' WHEN b.Status='CREATED' AND COUNT(br.WorkItemId)=b.RowCount THEN 'BATCH_CREATED' WHEN b.Status='READY' AND COUNT(br.WorkItemId)=b.RowCount AND l.ExportStatus='Completed' THEN 'BATCH_READY' ELSE 'INCONSISTENT' END
FROM [warroom].[PunchExportLog] l
LEFT JOIN [warroom].[ExportBatch] b ON b.PunchExportLogId=l.PunchExportLogId
LEFT JOIN [warroom].[ExportBatchRow] br ON br.ExportBatchId=b.ExportBatchId
WHERE l.ExportStatus<>'Completed' OR b.Status<>'READY' OR b.ExportBatchId IS NULL
GROUP BY l.PunchExportLogId,l.ProjectId,l.ExportStatus,l.CreatedOn,l.RowCount,l.FileName,l.FileUrl,l.ErrorMessage,b.ExportBatchId,b.Status,b.RowCount
ORDER BY l.CreatedOn,l.PunchExportLogId;
GO
