USE [GraniteDatabaseDE]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_SSRS_ParameterSplit]    Script Date: 22/04/26 12:09:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[SSRS_ParameterSplit]
   (@RepParam nvarchar(max), @Delim char(1)= ',')
RETURNS @Values TABLE (Item nvarchar(100))AS
-- based on John Sansoms StackOverflow answer:
-- http://stackoverflow.com/a/512300/22194

  BEGIN
  DECLARE @chrind INT
  DECLARE @Piece nvarchar(100)
  SELECT @chrind = 1 
  WHILE @chrind > 0
    BEGIN
      SELECT @chrind = CHARINDEX(@Delim,@RepParam)
      IF @chrind  > 0
        SELECT @Piece = LEFT(@RepParam,@chrind - 1)
      ELSE
        SELECT @Piece = @RepParam
      INSERT  @Values(Item) VALUES(@Piece)
      SELECT @RepParam = RIGHT(@RepParam,LEN(@RepParam) - @chrind)
      IF LEN(@RepParam) = 0 BREAK
    END
  RETURN
  END 
GO


