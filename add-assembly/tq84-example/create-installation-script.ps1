$assembly_dll = $args[0]

if (! (test-path $assembly_dll) ) {
   write-output "$assembly_dll does not exist"
   exit
}

# $assembly_name =                             split-path $assembly_dll -leafBase
  $assembly_name = [IO.Path]::GetFileNameWithoutExtension($assembly_dll)

$install_file  = "install-$assembly_name.sql"

# $assembly_dll = 'tq84_asmb.dll'
$assembly_hash = (get-fileHash -algorithm SHA512 $assembly_dll).hash

# $assembly_hex  = (get-content -encoding byte -raw $assembly_dll).foreach( { '{0:X2}' -f $_ } ) -join ''
# $assembly_hex  = (get-content  -asByteStream                 $assembly_dll).foreach( { '{0:X2}' -f $_ } ) -join ''
  $assembly_hex  = (get-content  -encoding Byte -readCount 0   $assembly_dll).foreach( { '{0:X2}' -f $_ } ) -join ''
# $assembly_hex

remove-item $install_file -errorAction silentlyContinue

@"

use master; -- 2020-02-10 (?)
go

declare -- {
   @hash binary(64);
declare
   cur   cursor for select hash from sys.trusted_assemblies where description = '$assembly_name';

open  cur;
fetch next from cur into @hash;
while @@fetch_status = 0 begin -- {
      exec sp_drop_trusted_assembly @hash;
      fetch next from cur into @hash;
end; -- }
close cur;
deallocate cur;
go -- }



declare
   @hash binary(64) = convert(binary(64), '0x' + '$assembly_hash', 1);
exec sys.sp_add_trusted_assembly
   @hash        = @hash,
   @description = N'$assembly_name'
go

drop assembly if exists $assembly_name;

create assembly  $assembly_name from 0x$assembly_hex
go

"@ | out-file -append $install_file


# $assembly_hex

# $assembly_hash
