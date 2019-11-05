CREATE VIEW sys.database_principals AS  
 SELECT u.name,  
  u.id AS principal_id,  
  u.type,  
  n.name AS type_desc,  
  u.dfltsch AS default_schema_name,  
  u.created AS create_date,  
  u.modified AS modify_date,  
  r.indepid AS owning_principal_id,  
  u.sid,  
  sysconv(bit, case when u.id >= 16384 and u.id < 16400 then 1 else 0 end) AS is_fixed_role,  
  u.authentication_type,  
  aty.name AS authentication_type_desc,  
  u.deflanguage as default_language_name,  
  l.lcid as default_language_lcid,  
  sysconv(bit, IIF(u.status & 0x20 = 0x20, 1, 0)) as allow_encrypted_value_modifications  
 FROM (  
  SELECT *,  
   CASE   
    -- Guest is always authentication type none  
    WHEN type = 'S' AND id = 2 THEN 0  
    -- Users without password and without SQL SID prefix are instance auth  
    WHEN type = 'S' AND password IS NULL AND cast(sid as binary(9)) <> 0x010500000000000903 THEN 1  
    -- Users with passwords are database auth  
    WHEN type = 'S' AND password IS NOT NULL THEN 2  
    -- Windows users are always windows auth  
    WHEN type = 'U' OR type = 'G' THEN 3  
    -- External Users or External Groups  
    WHEN type = 'E' OR type = 'X' THEN 4  
    -- Users without passwords, certificate, key users, etc. have no authentication type  
    ELSE 0  
   END AS authentication_type  
  FROM sys.sysowners) u  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = u.id AND r.class = 51 AND r.depsubid = 0 -- SRC_ROLEOWNER  
 LEFT JOIN sys.syspalnames n ON n.class = 'USTY' AND n.value = u.type  
 LEFT JOIN sys.syspalnames aty ON aty.class = 'DBAT' AND aty.value = u.authentication_type  
 LEFT JOIN sys.syslanguages l ON u.deflanguage COLLATE catalog_default = l.name COLLATE catalog_default  
 WHERE u.type <> 'L'  
  AND has_access('US', u.id) = 1 -- PR_ALIAS  
  
 
 CREATE VIEW sys.server_principals AS  
 SELECT p.name,  
  p.id AS principal_id,  
  p.sid, p.type,  
  n.name AS type_desc,  
  is_disabled = sysconv(bit, p.status & 0x80),  
  p.crdate AS create_date,  
  p.modate AS modify_date,  
  p.dbname AS default_database_name,  
  p.lang AS default_language_name,  
  r.indepid AS credential_id,  
  (case when p.id >= 2 and p.id < 11 then 1 else ro.indepid end) AS owning_principal_id,  
  sysconv(bit, case when p.id >= 3 and p.id < 11 then 1 else 0 end) AS is_fixed_role    
 FROM master.sys.sysxlgns p  
 LEFT JOIN sys.syspalnames n ON n.class = 'LGTY' AND n.value = p.type  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = p.id AND r.class = 63 AND r.depsubid = 0 -- SRC_LOGIN_CREDENTIAL  
 LEFT JOIN sys.syssingleobjrefs ro ON ro.depid = p.id AND ro.class = 61 AND ro.depsubid = 0 -- SRC_SRVROLELOGINOWNER  
 WHERE has_access('LG', p.id) = 1  
  AND p.type <> 'M' -- exclude component logins  
  
  
CREATE VIEW sys.sql_logins AS  
 SELECT p.name,  
  p.id AS principal_id,  
  p.sid, p.type,  
  n.name AS type_desc,  
  sysconv(bit, p.status & 0x80) AS is_disabled,  
  p.crdate AS create_date,  
  p.modate AS modify_date,  
  p.dbname AS default_database_name,  
  p.lang AS default_language_name,  
  r.indepid AS credential_id,  
  sysconv(bit, p.status & 0x10000) AS is_policy_checked,  
  sysconv(bit, p.status & 0x20000) AS is_expiration_checked,  
  convert(varbinary(256), LoginProperty(p.name, 'PasswordHash')) AS password_hash  
 FROM master.sys.sysxlgns p  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = p.id AND r.class = 63 AND r.depsubid = 0 -- SRC_LOGIN_CREDENTIAL  
 LEFT JOIN sys.syspalnames n ON n.class = 'LGTY' AND n.value = p.type  
 WHERE type = 'S'  
  AND has_access('LG', id) = 1    
  
  
 CREATE VIEW sys.syslogins AS SELECT  
 sid = p.sid,  
 status = convert(smallint, 8 +  
  CASE WHEN m.state in ('G','W') THEN 1 ELSE 2 END),  
 createdate = p.create_date,  
 updatedate = p.modify_date,  
 accdate = p.create_date,  
 totcpu = convert(int, 0),  
 totio = convert(int, 0),  
 spacelimit = convert(int, 0),  
 timelimit = convert(int, 0),  
 resultlimit = convert(int, 0),  
 name = p.name,  
 dbname = p.default_database_name,  
 password = convert(sysname, LoginProperty(p.name, 'PasswordHash')),  
 language = p.default_language_name,  
 denylogin = convert(int, CASE WHEN m.state ='D' THEN 1 ELSE 0 END),  
 hasaccess = convert(int, CASE WHEN m.state in ('G','W') THEN 1 ELSE 0 END),  
 isntname = convert(int, CASE WHEN p.type in ('G','U') THEN 1 ELSE 0 END),  
 isntgroup = convert(int, CASE WHEN p.type='G' THEN 1 ELSE 0 END),  
 isntuser = convert(int, CASE WHEN p.type='U' THEN 1 ELSE 0 END),  
 sysadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 3), 0)), --x_MDLoginIdSysAdmin  
 securityadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 4), 0)), --x_MDLoginIdSecAdmin  
 serveradmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 5), 0)), --x_MDLoginIdServAdmin  
 setupadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 6), 0)), --x_MDLoginIdSetupAdmin  
 processadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 7), 0)), --x_MDLoginIdProcAdmin  
 diskadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 8), 0)), --x_MDLoginIdDiskAdmin  
 dbcreator = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 9), 0)), --x_MDLoginIdDBCreator  
 bulkadmin = convert(int, ISNULL ((SELECT 1 FROM sys.server_role_members WHERE member_principal_id = p.principal_id  
  AND role_principal_id = 10), 0)), --x_MDLoginIdBulkAdmin  
 loginname = p.name  
FROM sys.server_principals p LEFT JOIN master.sys.sysprivs m  
 ON m.class = 100 AND m.id = 0 AND m.subid = 0 AND m.grantee = p.principal_id AND m.grantor = 1 AND m.type = 'COSQ'  
WHERE p.type <> 'R'  
  
  
  
-- Note: gid (max group id) not maintained, shiloh logic not correct anyway  
--  
CREATE VIEW sys.sysusers AS  
 SELECT uid = convert(smallint, u.id),  
  status = convert(smallint, case u.type  
   when 'U' then 12 when 'G' then 4 when 'A' then 32 else 0 end),  
  u.name, u.sid,  
  roles = convert(varbinary(2048), null),  
  createdate = u.created,  
  updatedate = u.modified,  
  altuid = convert(smallint, r.indepid),  
  password = convert(varbinary(256), null),  
  gid = convert(smallint, case u.type when 'R' then u.id else 0 end),  
  environ = convert(varchar(255), null),  
  hasdbaccess = convert(int, case when p.state in ('G','W') then 1 else 0 end),  
  islogin = convert(int, case u.type when 'A' then 0 when 'R' then 0 else 1 end),  
  isntname = convert(int, case u.type when 'U' then 1 when 'G' then 1 else 0 end), -- USR_SID_EXTERNAL  
  isntgroup = convert(int, case u.type when 'G' then 1 else 0 end),  
  isntuser = convert(int, case u.type when 'U' then 1 else 0 end), -- USR_SID_EXTERNAL  
  issqluser = convert(int, case u.type when 'S' then 1 else 0 end),  
  isaliased = convert(int, 0),   -- Aliases were deprecated and removed  
  issqlrole = convert(int, case u.type when 'R' then 1 else 0 end),  
  isapprole = convert(int, case u.type when 'A' then 1 else 0 end)  
 FROM sys.sysowners u  
 LEFT JOIN sys.sysprivs p ON p.class = 0 AND p.id = 0 AND p.subid = 0 AND p.grantee = u.id AND p.grantor = 1 AND p.type = 'CO'  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = u.id AND r.depsubid = 0 AND r.class = case u.type when 'R' then 51 end -- SRC_ROLEOWNER  
 WHERE has_access('US', u.id) = 1  
  
