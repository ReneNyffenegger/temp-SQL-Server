#
#  Get the content of a file as a byte array:
#
# $arrayOfBytes = get-content -encoding byte -raw contact_xml.dll
  $arrayOfBytes = get-content -asByteStream  -raw contact_xml.dll

$arrayOfBytes.GetType().FullName
#
#  System.Byte[]

#
#  Format each element of the byte array to a hexadecimal
#  representation, resulting in an array of strings, each
#  of which is two characters wide:
#
$arrayOfHex = $arrayOfBytes.foreach( { '{0:X2}' -f $_ } )

#
#  Join the elements of the string array to create
#  one string:
#
$hexString = $arrayOfHex -join ''

#
#  Print the string
#
$hexString
