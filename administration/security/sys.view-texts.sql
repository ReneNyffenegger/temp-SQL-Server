CREATE VIEW sys.assemblies AS -- {
 SELECT s.name AS name,   
  r.indepid AS principal_id,  
  s.id AS assembly_id,  
  convert(nvarchar(4000), assemblyproperty(s.name, 'CLRName')) collate Latin1_General_BIN AS clr_name,  
  convert(tinyint, s.intprop) AS permission_set,  
  i.name AS permission_set_desc,  
  sysconv(bit, s.status & 1) AS is_visible, -- ASM_EXPLICIT_REG  
  s.created AS create_date,  
  s.modified AS modify_date,  
  convert(bit, case when s.id < 65536 then 0 else 1 end) AS is_user_defined       -- x_MinUserAssemblyID  
 FROM sys.sysclsobjs s  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = s.id AND r.class = 52 AND r.depsubid = 0 -- SRC_ASMOWNER  
 LEFT JOIN sys.syspalvalues i ON i.class = 'ASPS' AND i.value = s.intprop  
 WHERE s.class = 10  
  AND has_access('AS', s.id) = 1 -- SOC_ASSEMBLY  
-- }

CREATE VIEW sys.asymmetric_keys AS -- {
 SELECT a.name AS name,  
  r.indepid AS principal_id,  
  a.id AS asymmetric_key_id,  
  a.encrtype AS pvt_key_encryption_type,  
  ce.name AS pvt_key_encryption_type_desc,  
  a.thumbprint AS thumbprint,  
  a.algorithm AS algorithm,  
  case when vpt.value = 6 then -- x_emd_EKMProvider = 6  
      convert(varbinary(60),asymkeyproperty(a.id, 'algorithm_desc'))  
      else alg.name end AS algorithm_desc,  
  a.bitlength AS key_length,  
  convert(varbinary(85), asymkeyproperty(a.id, 'sid')) AS sid,  
  convert(nvarchar(128), asymkeyproperty(a.id, 'string_sid')) AS string_sid,  
  a.pukey AS public_key,  
  convert(nvarchar(260), v.value) AS attested_by,  
  n.name as provider_type,  
  convert (uniqueidentifier, vpg.value) AS cryptographic_provider_guid,  
  vpa.value AS cryptographic_provider_algid  
 FROM sys.sysasymkeys a  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = a.id AND r.class = 64 AND r.depsubid = 0  
 LEFT JOIN sys.syspalnames ce ON ce.class = 'CETY' AND ce.value = a.encrtype  
 LEFT JOIN sys.syspalnames alg ON alg.class = 'ENAL' AND alg.value = a.algorithm  
 LEFT JOIN sys.sysobjvalues v ON v.valclass = 34 AND v.objid = a.id AND v.subobjid = 0 AND v.valnum = 0 -- SVC_AKATTESTINGDLLPATH  
 LEFT JOIN sys.sysobjvalues vpt ON vpt.valclass = 31 AND vpt.objid = a.id AND vpt.subobjid = 0 AND vpt.valnum = 1 -- SVC_AKPROVPROPS/PROV_TYPE_PROP  
 LEFT JOIN sys.sysobjvalues vpg ON vpg.valclass = 31 AND vpg.objid = a.id AND vpg.subobjid = 0 AND vpg.valnum = 2 -- SVC_AKPROVPROPS/PROV_GUID_PROP  
 LEFT JOIN sys.sysobjvalues vpa ON vpa.valclass = 31 AND vpa.objid = a.id AND vpa.subobjid = 0 AND vpa.valnum = 3 -- SVC_AKPROVPROPS/PROV_ALGID_PROP  
 LEFT JOIN sys.syspalvalues n ON n.class = 'CPKP' AND n.value = vpt.value  
 WHERE has_access('AK', a.id) = 1  
-- }

CREATE VIEW sys.certificates AS  -- {
 SELECT c.name,  
  c.id AS certificate_id,  
  r.indepid AS principal_id,  
  c.encrtype AS pvt_key_encryption_type,  
  ce.name AS pvt_key_encryption_type_desc,  
  sysconv(bit, ~c.status & 0x1) AS is_active_for_begin_dialog,  
  convert(nvarchar(442), certproperty(c.id, 'issuer_name')) AS issuer_name,  
  convert(nvarchar(64),  certproperty(c.id, 'cert_serial_number')) AS cert_serial_number,  
  convert(varbinary(85), certproperty(c.id, 'sid')) AS sid,  
  convert(nvarchar(128), certproperty(c.id, 'string_sid')) AS string_sid,  
  convert(nvarchar(4000),certproperty(c.id, 'subject')) AS subject,  
  convert(datetime, certproperty(c.id, 'expiry_date')) AS expiry_date,  
  convert(datetime, certproperty(c.id, 'start_date')) AS start_date,  
  c.thumbprint AS thumbprint,  
  convert(nvarchar(260), v.value) AS attested_by,  
  c.lastpkeybackup AS pvt_key_last_backup_date,  
  convert(int, certproperty(c.id, 'key_length')) AS key_length  
 FROM sys.syscerts c  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = c.id AND r.class = 62 AND r.depsubid = 0 -- SRC_CERTOWNER  
 LEFT JOIN sys.syspalnames ce ON ce.class = 'CETY' AND ce.value = c.encrtype  
 LEFT JOIN sys.sysobjvalues v ON v.valclass = 33 AND v.objid = c.id AND v.subobjid = 0 AND v.valnum = 0 -- SVC_CRATTESTINGDLLPATH  
 WHERE has_access('CE', c.id) = 1  
-- }

CREATE VIEW sys.databases AS   -- {
 SELECT d.name,   
  d.id AS database_id,  
  r.indepid AS source_database_id,  
  d.sid AS owner_sid,  
  d.crdate AS create_date,  
  d.cmptlevel AS compatibility_level,  
  -- coll.value = null means that a collation was not specified for the DB and the server default is used instead  
  convert(sysname, case when serverproperty('EngineEdition') = 5 AND d.id = 1 then serverproperty('collation')  
                                 else CollationPropertyFromID(convert(int, isnull(coll.value, p.cid)), 'name') end) AS collation_name,  
  iif ((serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x10000000) = 1), cast (3 as tinyint), p.user_access) AS user_access,  
  iif ((serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x10000000) = 1), 'NO_ACCESS', ua.name) AS user_access_desc,  
  sysconv(bit, d.status & 0x400) AS is_read_only,   -- DBR_RDONLY  
  sysconv(bit, d.status & 1) AS is_auto_close_on,   -- DBR_CLOSE_ON_EXIT  
  sysconv(bit, d.status & 0x400000) AS is_auto_shrink_on,  -- DBR_AUTOSHRINK  
  case when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000020) = 1) then cast (1 as tinyint) -- RESTORING  
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000080) = 1) then cast (7 as tinyint) -- COPYING  
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000100) = 1) then cast (4 as tinyint) -- SUSPECT  
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x08000000) = 1) then cast (8 as tinyint) -- QUORUM_RECOVERY_PENDING  
      when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x04000000) = 1) then cast (9 as tinyint) -- CREATING  
    else p.state   
    end AS state, -- 7 is COPYING and 4 is SUSPECT state for database copy (UNDO: Need to have a clean way to set states in dbtable for a user db)  
  case when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000020) = 1) then 'RESTORING'   
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000080) = 1) then 'COPYING'   
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x00000100) = 1) then 'SUSPECT'  
    when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x08000000) = 1) then CONVERT(nvarchar(60), N'QUORUM_RECOVERY_PENDING')  
      when (serverproperty('EngineEdition') = 5) AND (sysconv(bit, d.status & 0x04000000) = 1) then 'CREATING'  
    else st.name   
    end AS state_desc,  
  sysconv(bit, d.status & 0x200000) AS is_in_standby,  -- DBR_STANDBY  
  case when serverproperty('EngineEdition') = 5 then convert(bit, 0) else p.is_cleanly_shutdown end AS is_cleanly_shutdown,  
  sysconv(bit, d.status & 0x80000000) AS is_supplemental_logging_enabled, -- DBR_SUPPLEMENT_LOG  
        case when (serverproperty('EngineEdition') = 5) then sysconv(tinyint, sysconv(bit,(d.status & 0x00100000)))  
             else p.snapshot_isolation_state end AS snapshot_isolation_state,  
        case when (serverproperty('EngineEdition') = 5) and (sysconv(bit, d.status & 0x00100000) = 1) then 'ON'  
             when (serverproperty('EngineEdition') = 5) and (sysconv(bit, d.status & 0x00100000) = 0) then 'OFF'  
             else si.name end AS snapshot_isolation_state_desc,    
  sysconv(bit, d.status & 0x800000) AS is_read_committed_snapshot_on,  -- DBR_READCOMMITTED_SNAPSHOT  
        case when (serverproperty('EngineEdition') = 5)   
          then case   
            when sysconv(bit,(d.status & 0x00000008)) = 1  
             then cast(3 as tinyint)  
             when sysconv(bit,(d.status & 0x00000004)) = 1  
             then cast(2 as tinyint)  
            else  
             cast(1 as tinyint)  
               end   
              else p.recovery_model   
        end AS recovery_model,  
  case when (serverproperty('EngineEdition') = 5)   
          then case   
            when sysconv(bit,(d.status & 0x00000008)) = 1  
             then CONVERT(nvarchar(60), N'SIMPLE')  
            when sysconv(bit,(d.status & 0x00000004)) = 1  
             then CONVERT(nvarchar(60), N'BULK_LOGGED')  
            else  
             CONVERT(nvarchar(60), N'FULL')  
            end   
     else ro.name   
     end AS recovery_model_desc,                
  p.page_verify_option, pv.name AS page_verify_option_desc,  
  sysconv(bit, d.status2 & 0x1000000) AS is_auto_create_stats_on,   -- DBR_AUTOCRTSTATS  
  sysconv(bit, d.status2 & 0x00400000) AS is_auto_create_stats_incremental_on, -- DBR_AUTOCRTSTATSINC  
  sysconv(bit, d.status2 & 0x40000000) AS is_auto_update_stats_on,  -- DBR_AUTOUPDSTATS  
  sysconv(bit, d.status2 & 0x80000000) AS is_auto_update_stats_async_on, -- DBR_AUTOUPDSTATSASYNC  
  sysconv(bit, d.status2 & 0x4000) AS is_ansi_null_default_on,   -- DBR_ANSINULLDFLT  
  sysconv(bit, d.status2 & 0x4000000) AS is_ansi_nulls_on,    -- DBR_ANSINULLS  
  sysconv(bit, d.status2 & 0x2000) AS is_ansi_padding_on,     -- DBR_ANSIPADDING  
  sysconv(bit, d.status2 & 0x10000000) AS is_ansi_warnings_on,   -- DBR_ANSIWARNINGS  
  sysconv(bit, d.status2 & 0x1000) AS is_arithabort_on,     -- DBR_ARITHABORT  
  sysconv(bit, d.status2 & 0x10000) AS is_concat_null_yields_null_on,  -- DBR_CATNULL  
  sysconv(bit, d.status2 & 0x800) AS is_numeric_roundabort_on,   -- DBR_NUMEABORT  
  sysconv(bit, d.status2 & 0x800000) AS is_quoted_identifier_on,   -- DBR_QUOTEDIDENT  
  sysconv(bit, d.status2 & 0x20000) AS is_recursive_triggers_on,   -- DBR_RECURTRIG  
  sysconv(bit, d.status2 & 0x2000000) AS is_cursor_close_on_commit_on, -- DBR_CURSCLOSEONCOM  
  sysconv(bit, d.status2 & 0x100000) AS is_local_cursor_default,   -- DBR_DEFLOCALCURS  
  sysconv(bit, d.status2 & 0x20000000) AS is_fulltext_enabled,   -- DBR_FTENABLED  
  sysconv(bit, d.status2 & 0x200) AS is_trustworthy_on,    -- DBR_TRUSTWORTHY  
  sysconv(bit, d.status2 & 0x400) AS is_db_chaining_on,    -- DBR_DBCHAINING  
  sysconv(bit, d.status2 & 0x08000000) AS is_parameterization_forced, -- DBR_UNIVERSALAUTOPARAM  
  sysconv(bit, d.status2 & 64) AS is_master_key_encrypted_by_server, -- DBR_MASTKEY  
  sysconv(bit, d.status2 & 0x00000010) AS is_query_store_on,   -- DBR_QDSENABLED  
  sysconv(bit, d.category & 1) AS is_published,  
  sysconv(bit, d.category & 2) AS is_subscribed,  
  sysconv(bit, d.category & 4) AS is_merge_published,  
  sysconv(bit, d.category & 16) AS is_distributor,  
  sysconv(bit, d.category & 32) AS is_sync_with_backup,  
  d.svcbrkrguid AS service_broker_guid,  
  sysconv(bit, case when d.scope = 0 then 1 else 0 end) AS is_broker_enabled,  
  p.log_reuse_wait, lr.name AS log_reuse_wait_desc,  
  sysconv(bit, d.status2 & 4) AS is_date_correlation_on,   -- DBR_DATECORRELATIONOPT  
  sysconv(bit, d.category & 64) AS is_cdc_enabled,  
  sysconv(bit, d.status2 & 0x100) AS is_encrypted,     -- DBR_ENCRYPTION  
  convert(bit, d.status2 & 0x8) AS is_honor_broker_priority_on,    -- DBR_HONORBRKPRI  
  sgr.guid AS replica_id,  
  sgr2.guid AS group_database_id,  
  ssr.indepid AS resource_pool_id,  
  default_language_lcid = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(smallint, p.default_language) else null end,  
  default_language_name = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(sysname, sld.name) else null end,  
  default_fulltext_language_lcid = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(int, p.default_fulltext_language) else null end,  
  default_fulltext_language_name = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(sysname, slft.name) else null end,  
  is_nested_triggers_on = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(bit, p.allow_nested_triggers) else null end,  
  is_transform_noise_words_on = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(bit, p.transform_noise_words) else null end,  
  two_digit_year_cutoff = case when ((d.status2 & 0x80000)=0x80000 AND p.containment = 1) then convert(smallint, p.two_digit_year_cutoff) else null end,  
  containment = sysconv(tinyint, (d.status2 & 0x80000)/0x80000), -- DBR_IS_CDB  
  containment_desc = convert(nvarchar(60), cdb.name),  
  p.recovery_seconds AS target_recovery_time_in_seconds,  
  p.delayed_durability,  
  case when (p.delayed_durability = 0) then CAST('DISABLED' AS nvarchar(60)) -- LCOPT_DISABLED  
    when (p.delayed_durability = 1) then CAST('ALLOWED' AS nvarchar(60)) -- LCOPT_ALLOWED  
    when (p.delayed_durability = 2) then CAST('FORCED' AS nvarchar(60)) -- LCOPT_FORCED  
    else NULL  
    end AS delayed_durability_desc,  
  convert(bit, d.status2 & 0x80) AS   
  is_memory_optimized_elevate_to_snapshot_on,    -- DBR_HKELEVATETOSNAPSHOT  
  sysconv(bit, d.category & 0x100) AS is_federation_member,  
  convert(bit, isnull(rda.value, 0)) AS is_remote_data_archive_enabled,  
  convert(bit, p.is_mixed_page_allocation_on) AS is_mixed_page_allocation_on,  
  sysconv(bit, d.category & 0x400) AS is_temporal_history_retention_enabled   --DBR_IS_TEMPORAL_RETENTION_ENABLED  
 FROM sys.sysdbreg d OUTER APPLY OpenRowset(TABLE DBPROP, (case when serverproperty('EngineEdition') = 5 then DB_ID() else d.id end)) p  
 LEFT JOIN sys.syssingleobjrefs r ON r.depid = d.id AND r.class = 96 AND r.depsubid = 0 -- SRC_VIEWPOINTDB  
 LEFT JOIN sys.syspalvalues st ON st.class = 'DBST' AND st.value = p.state  
 LEFT JOIN sys.syspalvalues ua ON ua.class = 'DBUA' AND ua.value = p.user_access  
 LEFT JOIN sys.syspalvalues si ON si.class = 'DBSI' AND si.value = p.snapshot_isolation_state  
 LEFT JOIN sys.syspalvalues ro ON ro.class = 'DBRO' AND ro.value = p.recovery_model  
 LEFT JOIN sys.syspalvalues pv ON pv.class = 'DBPV' AND pv.value = p.page_verify_option  
 LEFT JOIN sys.syspalvalues lr ON lr.class = 'LRWT' AND lr.value = p.log_reuse_wait  
 LEFT JOIN sys.syssingleobjrefs agdb ON agdb.depid = d.id AND agdb.class = 104 AND agdb.depsubid = 0 -- SRC_AVAILABILITYGROUP   
 LEFT JOIN master.sys.syssingleobjrefs ssr ON ssr.class = 108 AND ssr.depid = d.id -- SRC_RG_DB_TO_POOL  
 LEFT JOIN master.sys.sysclsobjs  ag ON ag.id = agdb.indepid AND ag.class = 67 -- SOC_AVAILABILITY_GROUP  
 LEFT JOIN master.sys.sysguidrefs sgr ON sgr.class = 8 AND sgr.id = ag.id AND sgr.subid = 1 -- GRC_AGGUID / AGGUID_REPLICA_ID  
 LEFT JOIN master.sys.sysguidrefs sgr2 ON sgr2.class = 9 AND sgr2.id = ag.id AND sgr2.subid = d.id -- GRC_AGDBGUID  
 LEFT JOIN sys.syspalvalues cdb ON cdb.class = 'DCDB' AND cdb.value = CASE WHEN (d.status2 & 0x80000)=0x80000 THEN 1 ELSE 0 END  
 LEFT JOIN sys.syslanguages sld ON sld.lcid = p.default_language  
 LEFT JOIN sys.fulltext_languages slft ON slft.lcid = p.default_fulltext_language  
 LEFT JOIN sys.sysobjvalues coll ON coll.valclass = 102 AND coll.subobjid = 0 AND coll.objid = d.id -- SVC_DATACOLLATION  
 LEFT JOIN sys.sysobjvalues rda ON rda.valclass = 116 AND rda.objid = d.id AND rda.valnum = 0 -- SVC_STRETCH & STRETCH_DB_IS_STRETCHED  
 WHERE d.id < 0x7fff  
  AND has_access('DB', (case when serverproperty('EngineEdition') = 5 then DB_ID() else d.id end)) = 1  
-- }

CREATE VIEW sys.database_principals AS -- {
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
-- }

CREATE VIEW sys.server_principals AS  -- {
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
-- }  

CREATE VIEW sys.sql_logins AS -- {
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
-- }  

CREATE VIEW sys.syslogins AS SELECT -- {
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
-- }

-- Note: gid (max group id) not maintained, shiloh logic not correct anyway  
--  
CREATE VIEW sys.sysusers AS -- {
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
-- }  
