$source_file   = 'source.cs'
$assembly_name = 'tq84_asmb.dll'
csc -target:library $source_file -out:$assembly_name
