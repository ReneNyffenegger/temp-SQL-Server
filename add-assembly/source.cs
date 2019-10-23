namespace NS {

   public class CLS {

      public static System.Data.SqlTypes.SqlString repeatString(
         System.Data.SqlTypes.SqlString str,
         System.Data.SqlTypes.SqlInt16  iter) {

         System.Data.SqlTypes.SqlString ret = new System.Data.SqlTypes.SqlString("", str.LCID);

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

   }
}
