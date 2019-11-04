#
#  sn -k PubPriv.snk
#

$source_file   = 'source.cs'
$assembly_name = 'tq84_asmb.dll'
csc -target:library $source_file -keyfile:PubPriv.snk -out:$assembly_name
