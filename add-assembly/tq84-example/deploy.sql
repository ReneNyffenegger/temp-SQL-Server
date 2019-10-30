-- create database trusted_db
--   with trustworthy on;
-- 
-- declare
--    @hash binary(64) = convert(binary(64), '0x' + '9F1DD887420E514BF45FAE0E6BD518A56952DA089C200CC373C7CC0334086EDD8E0C5644C6DA84D963D457BCA824B7213EABC9101612C9004E0B92C796547238', 1);
-- exec sys.sp_drop_trusted_assembly
--    @hash        = @hash;
-- 
-- go
-- 
-- declare
--    @hash binary(64) = convert(binary(64), '0x' + '292BA15FC14BCEEE41E7079CB884F4AA3FEE0AF2AE76D4FC6D3927D81A33E3BE1C6BA542CB615CDE92946DA19E51EA312D370A1D1AA69292B193ACC8A5834176', 1);
-- exec sys.sp_add_trusted_assembly
--    @hash        = @hash,
--    @description = N'source.dll';
-- go
-- 
-- 
-- select * from sys.trusted_assemblies;
-- 
-- drop   function tq84_clr_repeatString;
-- drop   function tq84_clr_nonSqlTypes;
-- 
-- drop   assembly if exists tq84_clr;
-- 
-- create assembly tq84_clr
-- from
--   'C:\Users\OMIS.Rene\github\temp\SQL-Server\add-assembly\source.dll';

go
create function tq84_clr_repeatString(@str nvarchar(max), @iter smallint)
  returns  nvarchar(max)
  external name tq84_asmb.[NS.CLS].repeatString
go

create function tq84_clr_nonSqlTypes(@str nvarchar(max), @i int)
  returns  nvarchar(max)
  external name tq84_asmb.[NS.CLS].nonSqlTypes
go

--create function tq84_clr_createInstance()
--  returns  object
--  external name tq84_clr.[NS.CLS].createInstance
--go


select dbo.tq84_clr_repeatString('abc', 5)
select dbo.tq84_clr_nonSqlTypes ('abc', 5)

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
