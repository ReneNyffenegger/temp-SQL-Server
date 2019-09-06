create procedure tq84_drop_table (@table_name varchar(100)) as
begin
  
    if object_id(@table_name, 'U') is not null begin -- {
       execute('drop table '  + @table_name);
       print('Dropped table ' + @table_name);
    end; -- }

end;
