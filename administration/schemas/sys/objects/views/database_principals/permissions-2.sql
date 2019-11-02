--
-- The following query joins sys.database_principals and sys.database_permissions to sys.objects and sys.schemas to list permissions granted or denied to specific schema objects.
--
-- Does not seem to return anything!
--
SELECT
   pr.principal_id,
   pr.name,
   pr.type_desc,   
   pr.authentication_type_desc,
   pe.state_desc,   
   pe.permission_name,
   s.name + '.' + o.name AS ObjectName  
FROM
   sys.database_principals  AS pr                                                JOIN
   sys.database_permissions AS pe  ON pe.grantee_principal_id = pr.principal_id  JOIN
   sys.objects              AS o   ON pe.major_id = o.object_id                  JOIN
   sys.schemas              AS s   ON o.schema_id = s.schema_id;  
