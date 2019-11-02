SELECT
   name,
   principal_id,
   owning_principal_id
   default_database_name_name,
   credential_id,
   type_desc,
   is_disabled, 
   case when is_srvrolemember('sysadmin'    , name) = 1 then 'sysadmin'     end is_sysadmin,
   case when is_srvrolemember('dbcreator'   , name) = 1 then 'dbcreator'    end is_dbcreator,
   case when is_srvrolemember('bulkadmin'   , name) = 1 then 'bulkadmin'    end is_bulkadmin,
   case when is_srvrolemember('diskadmin'   , name) = 1 then 'diskadmin'    end is_diskadmin,
   case when is_srvrolemember('processadmin', name) = 1 then 'processadmin' end is_processadmin,
   sid,
   type,
   default_language_name,
   create_date,
   modify_date
FROM
   master.sys.server_principals 
order by
   principal_id;
