$assembly_dll = $args[0]

if (! (test-path $assembly_dll) ) {
   write-output "$assembly_dll does not exist"
   exit
}

$assembly_name = split-path $assembly_dll -leafBase

# $assembly_dll = 'tq84_asmb.dll'
$assembly_hash = (get-fileHash -algorithm SHA512 $assembly_dll).hash

# $assembly_hex  = (get-content -encoding byte -raw $assembly_dll).foreach( { '{0:X2}' -f $_ } ) -join ''
$assembly_hex  = (get-content  -asByteStream $assembly_dll).foreach( { '{0:X2}' -f $_ } ) -join ''

remove-item install.sql -errorAction silentlyContinue

@"
declare
   @hash binary(64) = convert(binary(64), '0x' + '$assembly_hash', 1);
exec sys.sp_add_trusted_assembly
   @hash        = @hash,
   @description = N'$assembly_name'
go

drop assembly if exists $assembly_name;

create assembly  $assembly_name from 0x$assembly_hex
go

"@ | out-file -append install.sql



# $assembly_hex

# $assembly_hash
