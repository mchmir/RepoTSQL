use Gefest
go


select * 
from period p
where p.Month = 1 and p.Year = 2022;

-------------------------------------------------

SELECT 
       spid as idproc,
       db_name(dbid) as '��� ��',
       program_name as '���������',
       loginame as '��� ����� SQL Server',
       hostname AS '��� ������� �������',
       status
FROM sys.sysprocesses
WHERE dbid > 0;
-----------------------------------------------

select top 5 * 
from Period p
order by p.DateBegin Desc;

select count(*)
from AAAERC7

