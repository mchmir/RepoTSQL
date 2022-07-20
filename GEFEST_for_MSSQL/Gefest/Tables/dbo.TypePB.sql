﻿CREATE TABLE [dbo].[TypePB] (
  [IDTypePB] [int] IDENTITY,
  [IDTypeBatch] [int] NULL,
  [Name] [varchar](50) NULL,
  CONSTRAINT [PK__TypePB__3C34F16F] PRIMARY KEY CLUSTERED ([IDTypePB])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TypePB] WITH NOCHECK
  ADD CONSTRAINT [FK__TypePB__IDTypeBa__42E1EEFE] FOREIGN KEY ([IDTypeBatch]) REFERENCES [dbo].[TypeBatch] ([IDTypeBatch])
GO