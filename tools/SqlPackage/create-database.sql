set nocount on
-- drop   database if exists SqlPackageTest;
-- drop   database if exists SqlPackageDB;
drop   database if exists SqlPackageTestDB;

create database SqlPackageTestDB;
go

use SqlPackageTestDB;

create table numbers (
   id  integer primary key,
   num varchar(10)
);

insert into numbers values (1, 'one'  );
insert into numbers values (2, 'two'  );
insert into numbers values (3, 'three');
insert into numbers values (4, 'four' );

create table words (
   id  integer primary key,
   wrd varchar(10)
);

insert into words values (1, 'foo');
insert into words values (2, 'bar');
insert into words values (3, 'baz');

create table junk (
   id  integer primary key,
   jnk varchar(10)
);

insert into junk values (1, 'abc');
insert into junk values (2, 'xyz');

go

create function maxNumber() returns varchar(10) as -- {
begin
  declare @ret varchar(10);

  select
     @ret = num
  from (
    select
       row_number() over (order by id desc) rn,
       num
    from
       numbers
  ) s
  where
    rn = 1;

  return @ret;
end; -- }

go
