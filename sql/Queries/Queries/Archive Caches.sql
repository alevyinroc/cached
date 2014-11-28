-- Locate caches which aren't in the GSAK database
select c.cacheid,c.cachename, s.Name,c.lastupdated from caches c left outer join (select cast(code as varchar) code,state from OPENQUERY(GSAKMain, 'select code,state from caches')) g on c.cacheid = g.code join states s on s.StateId = c.StateId join statuses st on c.cachestatus = st.statusid where st.statusname <> 'Archived' and  g.code is null and s.name = 'new york' order by c.lastupdated;

-- Archive all caches not found in GSAK
update  c set c.cachestatus = 2, c.lastupdated = getutcdate() from caches c left outer join (select cast(code as varchar) code,state from OPENQUERY(GSAKMain, 'select code,state from caches')) g on c.cacheid = g.code join states s on s.StateId = c.StateId  join statuses st on c.cachestatus = st.statusid where st.statusname <> 'Archived' and g.code is null and s.name = 'new york';
