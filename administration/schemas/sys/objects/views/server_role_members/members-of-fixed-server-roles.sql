SELECT
-- sp1.is_fixed_role,
   SP1.name AS ServerRoleName, 
   isnull (SP2.name, 'No members') AS LoginName   
FROM
   sys.server_role_members AS SRM                                               RIGHT OUTER JOIN
   sys.server_principals   AS SP1 ON SRM.role_principal_id  = SP1.principal_id  LEFT OUTER JOIN
   sys.server_principals   AS SP2 ON SRM.member_principal_id = SP2.principal_id
WHERE
   SP1.is_fixed_role = 1 -- Remove for SQL Server 2008
ORDER BY
   SP1.name;
