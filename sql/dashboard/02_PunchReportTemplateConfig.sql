CREATE TABLE [warroom].[PunchReportTemplateConfig](
	[ProjectId] [bigint] NOT NULL,
	[TemplateId] [bigint] NOT NULL,
	[IsIncluded] [bit] NOT NULL,
	[DisplayOrder] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[CreatedBy] [nvarchar](450) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](450) NULL,
 CONSTRAINT [PK_PunchReportTemplateConfig] PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC,
	[TemplateId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [warroom].[PunchReportTemplateConfig] ADD  DEFAULT ((0)) FOR [IsIncluded]
GO

ALTER TABLE [warroom].[PunchReportTemplateConfig] ADD  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [warroom].[PunchReportTemplateConfig] ADD  DEFAULT (sysdatetime()) FOR [CreatedOn]
GO
