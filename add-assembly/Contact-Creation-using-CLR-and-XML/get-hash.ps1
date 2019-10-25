$assembly = $args[0]

if (! (test-path $assembly) ) {
   echo "Assembly $assembly does not exist"
   exit
}

(get-fileHash -algorithm SHA512 $assembly).hash
