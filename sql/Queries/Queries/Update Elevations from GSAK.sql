use CacheDB;

select c.cacheid,c.elevation as my_elevation,
--g.elevation * 0.3048 as gsak_elevation
g.elevation as gsak_elevation
 from caches c  join (select cast(code as varchar) code,elevation from OPENQUERY(GSAKMain, 'select code,elevation from caches')) g on c.cacheid = g.code join states s on s.StateId = c.StateId where c.elevation = 0  and s.name = 'new york' order by gsak_elevation;

update c set
--c.elevation = g.elevation * 0.3048
c.elevation = g.elevation
from caches c join (select cast(code as varchar) code,elevation from OPENQUERY(GSAKMain, 'select code,elevation from caches')) g on c.cacheid = g.code join states s on s.StateId = c.StateId where c.elevation = 0 and g.elevation is not null and s.name = 'new york';
