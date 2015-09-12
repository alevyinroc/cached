 select cast(a.county as varchar(50)) as county, cast(a.country as varchar(50)) as country, cast(a.[state] as varchar(50)) as [state] into #LocationNames from (
SELECT county,country,[state] from OPENQUERY([Far-off puzzles], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([Home200], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([My Finds], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([My Hides], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([New England], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([Niagara Falls], 'select county,country,state from caches') UNION all 
SELECT county,country,[state] from OPENQUERY([NJ], 'select county,country,state from caches') UNION all
SELECT county,country,[state] from OPENQUERY([Seattle], 'select county,country,state from caches') 
) A  ;

--select distinct county,country,state from #locationnames order by county,country,state;

--drop table #locationnames;
begin transaction
insert into countries (Name) select distinct country from #locationnames where country not in (select name from countries)
select * from countries;
rollback transaction

begin transaction
insert into states (Name) select distinct [state] from #LocationNames where [state] not in (select name from states) and [state] is not null;
select * from states;
rollback transaction

--select distinct [state] from #LocationNames where [state] not in (select name from states) and [state] is not null;
select * from states order by name;

select * from counties;
select * from countries;