select distinct
	OwnerId,
	OwnerName
from
	caches
union
select distinct
	lownerid,
	lby
from
	logs
;