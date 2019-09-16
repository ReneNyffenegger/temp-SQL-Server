--
-- https://renenyffenegger.ch/notes/development/databases/SQL-Server/sql/batch/batches-with-syntax-errors
--
set nocount on

print('First statement in batch 1');
select 42/7;
print('Last statement in batch 1');

go

print('First statement in batch 2');
select 42/0;
print('Last statement in batch 2');

go

print('First statement in batch 3');
select 42/6;
print('Last statement in batch 3');

go
