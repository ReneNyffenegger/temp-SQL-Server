--
--   https://stackoverflow.com/a/44189905/180275
--
select
    serverproperty('ServerName' )                                  as serverName,  
    serverproperty('MachineName')                                  as machineName,
    case 
        when serverproperty('InstanceName') IS NULL then ''
        else serverproperty('InstanceName')
    end                                                            as instanceName  ,
    ''                                                             as port          , --need to update to strip from Servername. Note: Assumes Registered Server is named with Port
    substring (
      (select @@VERSION), 1, charIndex('-',(select @@version))-1 ) as productName   ,
    serverproperty('ProductVersion'     )                          as productVersion,  
    serverproperty('ProductLevel'       )                          as productLevel,
    serverproperty('ProductMajorVersion')                          as productMajorVersion,
    serverproperty('ProductMinorVersion')                          as productMinorVersion,
    serverproperty('ProductBuild'       )                          as productBuild,
    serverproperty('Edition') as Edition,
    case serverproperty('EngineEdition')
        when 1 then 'PERSONAL'
        when 2 then 'STANDARD'
        when 3 then 'ENTERPRISE'
        when 4 then 'EXPRESS'
        when 5 then 'SQL DATABASE'
        when 6 then 'SQL DATAWAREHOUSE'
    end                                                            as engineEdition,  
    case serverproperty('IsHadrEnabled')
        when 0 then 'The Always On Availability Groups feature is disabled'
        when 1 then 'The Always On Availability Groups feature is enabled'
        else 'Not applicable'
    end                                                            as hadrEnabled,
    case serverproperty('HadrManagerStatus')
        when 0 then 'Not started, pending communication'
        when 1 then 'Started and running'
        when 2 then 'Not started and failed'
        else 'Not applicable'
    end                                                            as hadrManagerStatus,
    case serverproperty('IsSingleUser')
        when 0 then 'No'
        else 'Yes'
    end                                                            as inSingleUserMode,
    case serverproperty('IsClustered')
        when 1 then 'Clustered'
        when 0 then 'Not Clustered'
        else 'Not applicable'
    end                                                            as isClustered,
    ''                                                             as serverEnvironment,
    ''                                                             as serverStatus,
    ''                                                             as comments
;
