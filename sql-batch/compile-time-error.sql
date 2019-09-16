--
-- development/databases/SQL-Server/sql/batch/batches-with-logical-errors
--
set nocount on

print('First statement in batch 1');
select 'One';
print('Last statement in batch 1');

go

print('First statement in batch 2');
select this_is_not_a_valid_statement;
print('Last statement in batch 2');

go

print('First statement in batch 3');
select 'Three';
print('Last statement in batch 3');

go
