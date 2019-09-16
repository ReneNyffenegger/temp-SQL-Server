create table tq84_unique_index_test (
   id    integer      not null,
   val   varchar(10)      null
);

insert into
   tq84_unique_index_test
values
  (1, 'foo'),
  (2,  null),
  (3, 'bar'),
  (4,  null),
  (5, 'baz');

--  create unique index
--      tq84_unique_index_test_uq
--  on
--      tq84_unique_index_test(val);
--
--  The CREATE UNIQUE INDEX statement terminated because a duplicate key was
--  found for the object name 'dbo.tq84_unique_index_test' and the index name
-- 'tq84_unique_index_test_uq'. The duplicate key value is (<NULL>).
--

create unique index
   tq84_unique_index_test_uq
on
   tq84_unique_index_test(val)
where
   val is not null;

drop table tq84_unique_index_test;
