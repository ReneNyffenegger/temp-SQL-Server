set nocount on

declare
   @key        varchar(100),
   @PortNumber varchar( 20);

if charindex('\', convert(char(20), serverproperty('servername')),0) <> 0 begin

   set @key = 'SOFTWARE\MICROSOFT\Microsoft SQL Server\' + @@servicename + '\MSSQLServer\Supersocketnetlib\TCP'

end else begin

   set @key = 'SOFTWARE\MICROSOFT\MSSQLServer\MSSQLServer\Supersocketnetlib\TCP'

end

exec master..xp_regread
   @rootkey    ='HKEY_LOCAL_MACHINE',
   @key        = @key,
   @value_name ='Tcpport',
   @value      = @PortNumber output;

select
   convert(char   (20), serverproperty('servername'  )) as serverName  ,
   convert(char   (20), serverproperty('InstanceName')) as instancename,
   convert(char   (20), serverproperty('MachineName' )) as hostname,
   convert(varchar(10), @PortNumber                   ) as portNumber
;
