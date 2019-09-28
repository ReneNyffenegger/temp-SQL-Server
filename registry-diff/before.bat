@echo ff

reg query hklm\software\microsoft /f sql > sql.before

rem reg export  HKLM\Software\Microsoft

reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft ODBC Driver 13 for SQL Server"  odbc.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server"                     sqlserver.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2005 Redist"         sql.2005.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2008 Redist"         sql.2008.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2012 Redist"         sql.2012.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2014 Redist"         sql.2014.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2016 Redist"         sql.2016.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2017 Redist"         sql.2017.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server 2019 CTP2.2 Redist"  sql.2019.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server Compact Edition"     sql.ce.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server Local DB"            sql.ldb.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\Microsoft SQL Server Native Client 11.0"  sql.nclnt.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\MSADALSQL"                                msadal.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\MSODBCSQL13"                              msodbcsql13.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\MSSQLServer"                              mssqlserver.before
reg export "HKEY_LOCAL_MACHINE\software\microsoft\SQLNCLI11"                                sqlncli11.before
