drop function if exists tq84_div;
go

create function tq84_div (
  @n1 numeric,
  @n2 numeric
)
returns float
as begin

   if @n2 = 0 return null;

   return cast(@n1 as float) / cast (@n2 as float);

end;
go
