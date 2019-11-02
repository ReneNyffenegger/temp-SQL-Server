select
   o.name,
   x.name
from
   sys.sysowners o  full outer join
   sys.sysxlgns  x on o.name = x.name
