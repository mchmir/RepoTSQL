﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fLastIndication](@IdGMeter int, @Date datetime)
--------------*************Функция поиска показаний по П****************----------------
RETURNS float AS  
BEGIN 
declare @Display float
select top 1 @Display= Display
from indication with (nolock) 
where idgmeter = @IdGMeter and convert(datetime,round(convert(float,DateDisplay),0, 3),20)<=convert(datetime,round(convert(float,@Date),0, 3),20)--convert(datetime, @Date, 20)-- and  isnull(idtypeIndication,0)<>4 
order by DateDisplay desc , idtypeIndication desc
return @Display
END





GO