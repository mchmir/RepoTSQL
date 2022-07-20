﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO









CREATE PROCEDURE [dbo].[spPCGetConsamerDataFullNew] (@Account varchar(20),@year int,@Month int)
AS
BEGIN
	SET NOCOUNT ON;
declare @IdGRU int
--declare @IdContract int
declare @IdPeriod int
--declare @IDGObject int
--declare @IdGRU int
--declare @dBegin datetime
--declare @dEnd datetime
--set @dBegin='2005-05-01'
--set @dEnd='2009-02-02'


--select idcontract from contract where account=2851003
--select @IdContract=idcontract from contract where account=2851003

	--SELECT [IDPeriod]  FROM [Gefest].[dbo].[Period] where [Year]=2017 and [Month]=4
	select @IdPeriod=[IDPeriod]  FROM [Period] where [Year]=@year and [Month]=@Month
	declare @IdPeriodPred int
	select top 1 @IdPeriodPred=dbo.fGetPredPeriodVariable(@IdPeriod)
--select @IdGRU=IdGRU from GObject with (nolock) where IdContract=@IdContract
--select @IDGObject=IDGObject,@IdGRU=IdGRU from GObject with (nolock) where IdContract=@IdContract
select top 1 @IdPeriodPred=dbo.fGetPredPeriodVariable(@IdPeriod)
declare @dBegin datetime
declare @dEnd datetime
set @dBegin= dbo.fGetDatePeriod(@IdPeriod,1)
set @dEnd= dbo.fGetDatePeriod(@IdPeriod,0)
print @dEnd

 select @IdGRU=gb.IdGRU
 from Contract c
 inner join GObject gb with (nolock) on gb.IdContract=c.IdContract
 where c.account=@Account 


declare @T table (idcontract int, idgmeter int)
insert into @T(idcontract, idgmeter)
select c.IdContract, max(gm.idgmeter)
from contract c with (nolock) 
inner join GObject g  with (nolock) on g.IdContract=c.IdContract
	and g.IdGRU=@IdGru 	and isnull(c.PrintChetIzvehen,0)=0
left join GMeter gm  with (nolock) on gm.IdGObject=g.IdGObject
	and dbo.fGetStatusPU (@dEnd,gm.idgmeter)=1 
group by c.idcontract

select distinct c.Account, c.IdContract, gm.idgmeter, dbo.fGetStatusPU (@dEnd,gm.idgmeter) StatusGMeter,
dbo.fGetCountLives(g.idgobject ,@IdPeriod) CL,
isnull( dbo.fGetLastBalance(@IdPeriodPred, c.IdContract, 0),0) BalanceNaNach, isnull( dbo.fGetLastBalance (@IdPeriod, c.IdContract, 0),0) BalanceNaKonec, 
isnull (sum(d.Documentamount),0) SummaOplat,
convert(float, 0.00) as SummaNach,
convert(float,0.00) as FactAmount,
convert(float,0.00) as KorrekAmount,
convert(float,0.00) as Peny,
convert(float,0.00) as GosPochlina,
convert(float,0.00) as Oplat,
convert(float,0.00) as Tech,
convert(float,0.00) as TechOplat,
convert(float,0.00) as PerenosOplat,
convert(float, dbo.fGetLastPGValue(@IDPeriod, 1, @idgru)) as Tariff,
convert(float, dbo.fGetLastPGNorma(@IDPeriod, 1, @idgru)) as Norma,
np.NSurname+' '+left(ltrim(isnull(np.NName,'')),1)+'. ' +left(ltrim(isnull(np.NPatronic,'')),1)+'.'  FIO,  
s.name+ ', '+ltrim(str(hs.housenumber))+isnull(hs.housenumberchar,'')+ '-'+ltrim(a.flat) Adres, 
isnull(dbo.fLastIndicationYarMonthGet(gm.IdGMeter,@dEnd),0) GetIndication, --конечные показания но по дате не всегда правильно, потому как у некоторых показаний нету потребления
--isnull(dbo.fLastIndicationIDPeriodGet(gm.IdGMeter,@idperiod),0) GetIndication, --конечные показание
convert(datetime, null) DateGetIndication, --дата конечных показаний
isnull(dbo.fLastIndicationIDPeriod(gm.IdGMeter, @IdPeriodPred),0) LastIndication, --начальные показание
convert(datetime, null) DateLastIndication ,
isnull(tt.name,'')+'('+isnull(ltrim(tt.ClassAccuracy),'')+')' Marka,
isnull(gm.Serialnumber,'б/н') Serialnumber,
convert(int, 1) as FactUse, @dBegin as Date, dateadd(yy, tt.servicelife, case when gm.dateverify='1800-01-01' then gm.datefabrication else gm.dateverify end) dateverify,
convert(int,1) as TypeCloseGmeter

into #tmpChetIzvehe
from contract c with (nolock) 
inner join GObject g  with (nolock) on g.IdContract=c.IdContract
	and g.IdGRU=@IdGru 	and isnull(c.PrintChetIzvehen,0)=0
inner join address a  with (nolock) on a.idaddress=g.idaddress
inner join street s with (nolock)  on s.idstreet=a.idstreet
inner join house hs  with (nolock) on hs.idhouse=a.idhouse
inner join gru h with (nolock)  on h.idgru=g.idgru
inner join person np with (nolock)  on np.idperson=c.Idperson
left join @t gm1 on gm1.IdContract=c.IdContract
left join GMeter gm  with (nolock) on gm1.idgmeter=gm.idgmeter--gm.IdGObject=g.IdGObject
	--and dbo.fGetStatusPU (@dEnd,gm.idgmeter)=1 
left join typegmeter tt with (nolock)  on gm.idtypegmeter=tt.idtypegmeter
left join Document d  with (nolock) on d.idcontract=c.idcontract
and  d.IdPeriod=@IdPeriod and (d.idtypedocument=1  or d.idtypedocument=3)
 group by c.IdContract, c.Account, g.IDGobject, 
 np.NSurname, np.NName, np.NPatronic,  h.name ,s.name, hs.housenumber, hs.housenumberchar, 
 gm.IdGMeter, a.flat, tt.name, tt.ClassAccuracy,
 gm.Serialnumber,tt.servicelife,gm.dateverify,gm.DateFabrication


update #tmpChetIzvehe
set Oplat=convert(float,qq.DA)
from #tmpChetIzvehe c
inner join (select sum(d.Documentamount) DA, IdContract
from Document d  with (nolock)
where IdPeriod=@IdPeriod and idtypedocument=1 
group by d.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set TechOplat=convert(float,qq.AO)
from #tmpChetIzvehe c
inner join (select sum(o.amountoperation) AO, f.IdContract
from Document f  with (nolock) 
inner join operation o with (nolock) on f.iddocument=o.iddocument
and f.IdPeriod=@IdPeriod and f.idtypedocument=1 
inner join balance b with (nolock) on o.idbalance=b.idbalance
and idaccounting=6
group by f.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set PerenosOplat=convert(float,qq.DA)
from #tmpChetIzvehe c
inner join (select sum(Documentamount) DA, IdContract
from Document d  with (nolock)
where IdPeriod=@IdPeriod 	and d.idtypedocument=3 
group by IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set SummaNach=convert(float,qq.DA),FactUse=isnull(ff.idtypefu,1)
from #tmpChetIzvehe c
inner join (select -sum(o.amountoperation) DA, f.IdContract, f.iddocument
from Document f  with (nolock)
inner join operation o  with (nolock) on o.iddocument=f.iddocument
inner join balance b with (nolock) on b.idbalance=o.idbalance
and b.idaccounting<>4
where f.IdPeriod=@IdPeriod
	and f.idtypedocument=5 
group by f.IdContract,f.iddocument) qq on qq.IdContract=c.IdContract
inner join operation o  with (nolock) on o.iddocument=qq.iddocument
inner join factuse ff with (nolock) on o.idoperation=ff.idoperation

update #tmpChetIzvehe
set GosPochlina=convert(float,qq.AO)
from #tmpChetIzvehe c
inner join (select sum(o.amountoperation) AO, f.IdContract
from Document f  with (nolock) 
inner join operation o with (nolock) on f.iddocument=o.iddocument
and f.IdPeriod=@IdPeriod and f.idtypedocument=13 and o.idtypeoperation=2 
inner join balance b with (nolock) on o.idbalance=b.idbalance
and idaccounting=3
group by f.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set Peny=convert(float,qq.AO)
from #tmpChetIzvehe c
inner join (select -sum(o.amountoperation) AO, f.IdContract
from Document f  with (nolock) 
inner join operation o with (nolock) on f.iddocument=o.iddocument
and f.IdPeriod=@IdPeriod and f.idtypedocument=5 and o.idtypeoperation=2 
inner join balance b with (nolock) on o.idbalance=b.idbalance
and idaccounting=4
group by f.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set tech=convert(float,qq.AO)
from #tmpChetIzvehe c
inner join (select -sum(o.amountoperation) AO, f.IdContract
from Document f  with (nolock) 
inner join operation o with (nolock) on f.iddocument=o.iddocument
and f.IdPeriod=@IdPeriod and (f.idtypedocument=6 or f.idtypedocument=17 or f.idtypedocument=24) and o.idtypeoperation=2 
inner join balance b with (nolock) on o.idbalance=b.idbalance
and idaccounting=6
group by f.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set Tariff=Tariff*(select top 1 value from Tariff with (nolock) where idperiod=@idperiod),
Norma=Norma*(select top 1 value from Tariff with (nolock) where idperiod=@idperiod)

update #tmpChetIzvehe
set KorrekAmount=qq.DA
from #tmpChetIzvehe c
inner join (select -sum(f.Documentamount) DA, IdContract
from Document f  with (nolock) 
where f.IdPeriod=@IdPeriod 
	and (f.idtypedocument=7 or f.idtypedocument=11 or f.idtypedocument=14)
group by f.IdContract) qq on qq.IdContract=c.IdContract

update #tmpChetIzvehe
set FactAmount=qq.FA
from #tmpChetIzvehe c
inner join (select sum(f.Factamount) fA, g.IdContract
from Factuse f  with (nolock)
inner join Gobject g  with (nolock) on g.idgobject=f.idgobject
inner join operation o with (nolock) on o.idoperation=f.idoperation
inner join document d  with (nolock) on d.iddocument=o.iddocument
and f.IdPeriod=@IdPeriod and d.idtypedocument=5
	--and g.IdGRU=@IdGru 
group by g.IdContract) qq on qq.IdContract=c.IdContract


update #tmpChetIzvehe
set korrekAmount=0
where korrekAmount is null

update #tmpChetIzvehe
set DateGetIndication=(select top 1 convert(datetime,qq.datedisplay,20) from  indication qq  with (nolock) where qq.display=c.GetIndication and c.idgmeter=qq.idgmeter order by datedisplay desc)
from #tmpChetIzvehe c
--inner join (select top 1 convert(datetime,qq.datedisplay,20)rr indication qq  with (nolock) where qq.display=c.GetIndication )d

update #tmpChetIzvehe
set TypeCloseGmeter=(
select top 1 pd.value from document d 
inner join pd on pd.iddocument=d.iddocument
and idtypepd=33 and d.idcontract=c.idcontract
order by d.documentdate desc) from #tmpChetIzvehe c where c.statusGmeter=2

update #tmpChetIzvehe
set TypeCloseGmeter=999 from #tmpChetIzvehe
inner join (select idcontract from gobject where idstatusgobject=2) obj on obj.idcontract=#tmpChetIzvehe.idcontract


update #tmpChetIzvehe
set TypeCloseGmeter=1
where TypeCloseGmeter is null

update #tmpChetIzvehe
set DateLastIndication=(select top 1 convert(datetime,qq.datedisplay,20) from  indication qq  with (nolock) where qq.display=c.LastIndication and c.idgmeter=qq.idgmeter and  qq.datedisplay<isnull(c.DateGetIndication,GetDate()) order by datedisplay desc)
from #tmpChetIzvehe c
--inner join indication qq  with (nolock)  on qq.idgmeter=c.idgmeter
--where qq.display=c.LastIndication and qq.datedisplay<isnull(c.DateGetIndication,GetDate())


--select t.* 
--from #tmpChetIzvehe t
--left join (select idcontract from gobject  with (nolock)  where idstatusgobject=2 and idgru=@idgru and isnull( dbo.fGetLastBalance (@IdPeriod, IdContract, 0),0)>-1) c on c.idcontract=t.idcontract
--where c.idcontract is null
--order by account
select t.* 
from Contract c
inner join GObject gb with (nolock) on gb.IdContract=c.IdContract
inner join GMeter gm with (nolock) on gb.IDGObject=gm.IDGObject
inner join dbo.StatusGMeter sm on sm.IDStatusGMeter=gm.IDStatusGMeter
inner join dbo.TypeGMeter tm on tm.IDTypeGMeter=gm.IDTypeGMeter
left join dbo.PersonalCabinet pc on pc.account=c.account
left join dbo.Phone p on p.IDPerson=c.IDPerson
left join #tmpChetIzvehe t on t.IdContract=c.IdContract
left join (select idcontract from gobject  with (nolock)  where idstatusgobject=2 and idgru=@idgru and isnull( dbo.fGetLastBalance (@IdPeriod, IdContract, 0),0)>-1) cc on cc.idcontract=t.idcontract
where cc.idcontract is null  and c.account=@Account 
order by gm.IDStatusGMeter 

drop table #tmpChetIzvehe
END








GO