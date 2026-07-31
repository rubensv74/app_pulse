/****** Object:  Table [warroom].[PunchReportStatusConfig]    Script Date: 7/31/2026 5:30:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [warroom].[PunchReportStatusConfig](
	[ProjectId] [bigint] NOT NULL,
	[StatusCode] [varchar](20) NOT NULL,
	[IsIncluded] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[CreatedBy] [nvarchar](450) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](450) NULL,
 CONSTRAINT [PK_PunchReportStatusConfig] PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC,
	[StatusCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [warroom].[PunchReportStatusConfig] ADD  CONSTRAINT [DF_PunchReportStatusConfig_IsIncluded]  DEFAULT ((1)) FOR [IsIncluded]
GO

ALTER TABLE [warroom].[PunchReportStatusConfig] ADD  CONSTRAINT [DF_PunchReportStatusConfig_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [warroom].[PunchReportStatusConfig] ADD  CONSTRAINT [DF_PunchReportStatusConfig_CreatedOn]  DEFAULT (sysdatetime()) FOR [CreatedOn]
GO
