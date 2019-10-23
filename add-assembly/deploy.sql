create database trusted_db
  with trustworthy on;

declare
   @hash binary(64) = convert(binary(64), '0x' + '2B65E33F8A873DA3BDB5FD1F9BB459A51D9D918E4972B4089BD043096F230524E24083B4ADD255EE1ACAAF8A2D7511669E635DA600E655B4BB84F2D5FED8DB9C', 1);
exec sys.sp_drop_trusted_assembly
   @hash        = @hash;

go

declare
   @hash binary(64) = convert(binary(64), '0x' + '082B7506D1EB924C2D7E7045F77192B85275B116F1E78E4385DA3020E413DEC739745AF8C5AC8170012B84014919D9A2046225DBAB1B707D2157A859DB4A482E', 1);
exec sys.sp_add_trusted_assembly
   @hash        = @hash,
   @description = N'source.dll';
go


select * from sys.trusted_assemblies;

drop   function tq84_clr_function;
drop   assembly if exists tq84_clr;
create assembly tq84_clr
from
  'C:\Users\OMIS.Rene\github\temp\SQL-Server\add-assembly\source.dll';


create function tq84_clr_repeatString(@str nvarchar(max), @iter smallint)
  returns  nvarchar(max)
  external name tq84_clr.[NS.CLS].repeatString
go

create function tq84_clr_nonSqlTypes(@str nvarchar(max), @i int)
  returns  nvarchar(max)
  external name tq84_clr.[NS.CLS].nonSqlTypes
go


select dbo.tq84_clr_repeatString('abc', 5)
select dbo.tq84_clr_nonSqlTypes ('abc', 5)
-- 
-- 
-- 
-- 
-- USE master;
-- GO
-- -- Get clr_name value from the sys.assemblies
-- DECLARE @clr_name nvarchar(4000)
-- select @clr_name=clr_name
-- from DeployDB.sys.assemblies
-- where assembly_id=65537
-- 
-- -- Get Hash from Assembly
-- declare @Content varbinary(max)
-- select @Content=content
-- from DeployDB.sys.assembly_files
-- where assembly_id=65537
-- DECLARE @hash varbinary(64);
-- SELECT @hash = HASHBYTES('SHA2_512',@Content)
-- 
-- EXEC sys.sp_add_trusted_assembly @hash = @hash,
-- @description = @clr_name;
-- 
-- -- Chek the trusted assembly
-- SELECT * FROM sys.trusted_assemblies
