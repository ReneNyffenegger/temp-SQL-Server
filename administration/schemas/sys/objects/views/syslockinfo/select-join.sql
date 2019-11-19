select
   d.name,
   convert (smallint, req_spid) As spid
from
   master.dbo.syslockinfo  l                                                join
   master.dbo.spt_values   v on l.rsc_type     = v.number and v.type = 'LR' join
   master.dbo.spt_values   x on l.req_status   = x.number and x.type = 'LS' join
   master.dbo.spt_values   u on l.req_mode + 1 = u.number and u.type = 'L'  join
   master.dbo.sysdatabases d on l.rsc_dbid     = d.dbid
where   
   l.rsc_dbid = (
       select top 1 dbid
	   from 
          master..sysdatabases 
        where name like 'steve_omis_modelle'
   )
