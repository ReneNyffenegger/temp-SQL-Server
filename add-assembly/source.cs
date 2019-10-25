//
//  csc -target:library source.cs
//
namespace NS {

   public class CLS {

//    private static int i_;

      public static System.Data.SqlTypes.SqlString repeatString(
         System.Data.SqlTypes.SqlString str,
         System.Data.SqlTypes.SqlInt16  iter) {

         System.Data.SqlTypes.SqlString ret = new System.Data.SqlTypes.SqlString("", str.LCID);

//       -------------------------------------------------------------------------------------------------
//
//         CREATE ASSEMBLY failed because method 'repeatString' on type 'NS.CLS' in safe assembly 'source'
//         is storing to a static field. Storing to a static field is not allowed in safe assemblies.
//
//       i_ = iter.Value;
//       -------------------------------------------------------------------------------------------------

         for (short i = 0; i<iter.Value; i++) {
            ret += str;
         }

         return ret;
      }

      public static System.String nonSqlTypes(System.String str, int i) {

         System.String ret = "";
         for (short j = 0; j<i; j++) {
            ret += str;
         }

         return ret;

      }

//    public static CLS createInstance() {
//       return new CLS();
//    }

   }
}
