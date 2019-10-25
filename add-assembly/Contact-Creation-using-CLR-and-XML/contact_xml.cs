//
//  csc  /target:library Contact_xml.cs
//  csc  /reference:C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Data.dll /reference:C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.dll /reference:C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.XML.dll /target:library Contacts.cs
//
using System;  
using System.IO;  
using System.Data;  
using System.Data.SqlTypes;  
using System.Xml;  
using System.Collections.Generic;  
using System.Globalization;  
using System.Runtime.Serialization;  
using Microsoft.SqlServer.Server;  
using System.Data.SqlClient;  
    /// <summary>  
    /// Utility class for creating contact information.  A row in the contact table  
    /// is inserted.  Additionally, rows in one or more other tables are inserted based on  
    /// the information provided in the XML document passed to the CreateContact function.  
    /// For individuals and employees, the contact record is one to one relationship with   
    /// the respective tables so those rows are created when the contact record is created.  
    /// For stores and vendors, there is a one to many relationship for contacts, so a row is added to   
    /// either the Sales.StoreContact or Purchasing.VendorContact table (as appropriate), but   
    /// neither store or vendor rows are inserted into the database.  
    ///   
    /// </summary>  
    public sealed class ContactUtils  
    {  
  
        private ContactUtils()  
        {  
        }  
  
        public static void CreateContact(SqlString contactData,  
                                         out SqlInt32 contactId,  
                                         out SqlInt32 customerId)  
        {  
            //TODO: When we can pass XML from T-SQL then contactData can be a SqlXmlReader  
using (StringReader sr = new StringReader(contactData.Value))  
{  
XmlReader reader = XmlReader.Create(sr);  
ContactCreator creator = null;  
  
try  
{  
reader.MoveToContent();  
EnsureEqual(reader.LocalName, "Contact");  
reader.MoveToContent();  
reader.ReadStartElement();  
  
switch (reader.LocalName)  
{  
case "Individual": creator = new IndividualCreator(); break;  
case "Store": creator = new StoreCreator(); break;  
case "Vendor": creator = new VendorCreator(); break;  
case "Employee": creator = new EmployeeCreator(); break;  
default: break;  
}  
  
if (creator != null)  
{  
reader.ReadStartElement();  
reader.MoveToContent();  
creator.LoadDictionary(reader);  
creator.Create();  
contactId = creator.ContactId;  
customerId = creator.CustomerId;  
}  
else  
{  
contactId = -1;  
customerId = -1;  
  
throw new AWUtilitiesContactParseException(  
"Individual | Store | Vendor | Employee", reader.LocalName);  
}  
}  
finally  
{  
reader.Close();  
}  
}  
        }  
  
        public static void EnsureEqual(String localName,  
                                       String desiredLocalName)  
        {  
if (localName == null) throw new ArgumentNullException("localName");  
            if (!localName.Equals(desiredLocalName))  
            {  
                throw new AWUtilitiesContactParseException(desiredLocalName,  
                                                       localName);  
            }  
        }  
    }  
  
    /// <summary>  
    ///Base class for all the contact creation classes.  Responsible for parsing the XML,  
    ///providing the public API for all types of contacts, and for inserting the row   
    ///in the Person.Contact table.  
    /// </summary>  
  
    public abstract class ContactCreator  
    {  
  
        internal int parameterCount;  
        internal int valueCount;  
  
        internal Dictionary<String, String> contactDictionary = new Dictionary<  
            String, String>();  
  
        private static readonly String[] xmlColumns = new String[] {  
"AdditionalContactInfo", "Demographics"  
};  
  
        private static readonly String[] nestedColumns = new String[] {  
"Address"  
};  
  
        public int ContactId  
        {  
            get  
            {  
                String val;  
                if (contactDictionary.TryGetValue("ContactID", out val))  
                    return Int32.Parse(val, CultureInfo.InvariantCulture);  
                else  
                    return -1;  
            }  
            set  
            {  
                contactDictionary["ContactID"]  
                    = value.ToString(CultureInfo.InvariantCulture);  
            }  
        }  
  
        public int CustomerId  
        {  
            get  
            {  
                string val;  
  
                if (contactDictionary.TryGetValue("CustomerID", out val))  
                    return Int32.Parse(val, CultureInfo.InvariantCulture);  
                else  
  
                    //Not every contact is for a customer.  Return -1 in that case.  
                    return -1;  
            }  
            set  
            {  
                contactDictionary["CustomerID"]  
                    = value.ToString(CultureInfo.InvariantCulture);  
            }  
        }  
  
        public void LoadDictionary(XmlReader reader)  
        {  
            while (reader.IsStartElement())  
            {  
                String key = reader.LocalName;  
                String val;  
  
                if (Array.IndexOf(xmlColumns, key) > -1)  
                    val = reader.ReadInnerXml();  
                else if (Array.IndexOf(nestedColumns, key) > -1)  
                {  
                    reader.ReadStartElement();  
                    LoadDictionary(reader);  
                    reader.ReadEndElement();  
                    continue;  
                }  
                else  
                    val = reader.ReadElementString();  
  
                contactDictionary.Add(key, val);  
            }  
        }  
  
        protected void ResetCounters(int valueForReset)  
        {  
            parameterCount = valueForReset;  
            valueCount = valueForReset;  
        }  
  
        public String MaybeParameter(String name)  
        {  
            if (contactDictionary.ContainsKey(name))  
            {  
                if (parameterCount++ == 0)  
                    return name;  
                else  
                    return ", " + name;  
            }  
            else  
                return string.Empty;  
        }  
  
        public String MaybeValue(String name)  
        {  
            if (contactDictionary.ContainsKey(name))  
            {  
                if (valueCount++ == 0)  
                    return "@" + name;  
                else  
                    return ", @" + name;  
            }  
            else  
                return string.Empty;  
        }  
  
public static object TypeConvert(String valueToConvert, SqlDbType parameterType)  
        {  
if (valueToConvert == null)   
throw new ArgumentNullException("valueToConvert");  
            switch (parameterType)  
            {  
                case SqlDbType.BigInt:  
                    return Int64.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                case SqlDbType.Int:  
                    return Int32.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                case SqlDbType.SmallInt:  
                    return Int16.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                case SqlDbType.TinyInt:  
                    return Byte.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                case SqlDbType.Bit:  
                    {  
                        if (valueToConvert.Equals("1") ||  
                            valueToConvert.Equals("true")) return 1;  
                        else  
                            return 0;  
                    }  
  
                case SqlDbType.NVarChar:  
                case SqlDbType.VarChar:  
                case SqlDbType.NChar:  
                case SqlDbType.NText:  
                case SqlDbType.Text:  
                case SqlDbType.Char:  
                case SqlDbType.Xml:  
                    return valueToConvert;  
  
                case SqlDbType.DateTime:  
                    return DateTime.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                case SqlDbType.Money:  
                    return Decimal.Parse(valueToConvert,  
                        CultureInfo.InvariantCulture);  
  
                default:  
                    return "unknown conversion";  
            }  
        }  
  
        public void MaybeAddCommandParameter(String keyName, String parameterName,  
                                             SqlCommand command,  
                                             SqlDbType parameterType,  
                                             bool isRequired,  
                                             String defaultValue)  
        {  
            if (isRequired || contactDictionary.ContainsKey(keyName))  
            {  
                SqlParameter param =  
                             new SqlParameter("@" + parameterName, parameterType);  
                String val = (contactDictionary.ContainsKey(keyName)) ?  
                             contactDictionary[keyName] : defaultValue;  
  
                param.Value = TypeConvert(val, parameterType);  
                command.Parameters.Add(param);  
            }  
        }  
        public void MaybeAddCommandParameter(String name, SqlCommand command,  
                                             SqlDbType parameterType,  
                                             bool isRequired,  
                                             String defaultValue)  
        {  
            MaybeAddCommandParameter(name, name, command, parameterType,  
                                     isRequired, defaultValue);  
        }  
  
        public void MaybeAddCommandParameter(String name, SqlCommand command,  
                                             SqlDbType parameterType, int size,  
                                             bool isRequired,  
                                             String defaultValue)  
        {  
            if (isRequired || contactDictionary.ContainsKey(name))  
            {  
                MaybeAddCommandParameter(name, command, parameterType,  
                                         isRequired, defaultValue);  
                command.Parameters[command.Parameters.Count - 1].Size = size;  
            }  
        }  
  
        public void MaybeAddCommandParameter(String keyName, String paramName, SqlCommand command,  
                                             SqlDbType parameterType, int size,  
                                             bool isRequired,  
                                             String defaultValue)  
        {  
            if (isRequired || contactDictionary.ContainsKey(keyName))  
            {  
                MaybeAddCommandParameter(keyName, paramName, command, parameterType,  
                                         isRequired, defaultValue);  
                command.Parameters[command.Parameters.Count - 1].Size = size;  
            }  
        }  
  
        public virtual void Create()  
        {  
            using (SqlConnection conn = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                ResetCounters(1);  
  
                string parameters = String.Format(CultureInfo.InvariantCulture,  
                    "NameStyle{0}, FirstName{1}, LastName{2}{3}{4}{5}, "  
                    + "PasswordHash, PasswordSalt{6}",  
                    MaybeParameter("Title"), MaybeParameter("MiddleName"),  
                    MaybeParameter("Suffix"), MaybeParameter("EmailAddress"),  
                    MaybeParameter("EmailPromotion"), MaybeParameter("Phone"),  
                    MaybeParameter("AdditionalContactInfo"));  
                string values = String.Format(CultureInfo.InvariantCulture,  
                    "@NameStyle{0}, @FirstName{1}, @LastName{2}{3}{4}{5}, "  
                    + "@PasswordHash, @PasswordSalt{6}",  
                    MaybeValue("Title"), MaybeValue("MiddleName"),  
                    MaybeValue("Suffix"), MaybeValue("EmailAddress"),  
                    MaybeValue("EmailPromotion"), MaybeValue("Phone"),  
                    MaybeValue("AdditionalContactInfo"));  
  
                String text = String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Person.Contact ({0}) VALUES ({1}); "  
                    + "SELECT CAST(SCOPE_IDENTITY() as Int);",  
                    parameters, values);  
                command.CommandText = text;  
                MaybeAddCommandParameter("NameStyle", command,  
                    SqlDbType.Bit, true, "0");  
                MaybeAddCommandParameter("Title", command,  
                    SqlDbType.NVarChar, 8, false, null);  
                MaybeAddCommandParameter("FirstName", command,  
                    SqlDbType.NVarChar, 50, true, string.Empty);  
                MaybeAddCommandParameter("MiddleName", command,  
                    SqlDbType.NVarChar, 50, false, null);  
                MaybeAddCommandParameter("LastName", command,  
                    SqlDbType.NVarChar, 50, true, string.Empty);  
                MaybeAddCommandParameter("Suffix", command,  
                    SqlDbType.NVarChar, 10, false, null);  
                MaybeAddCommandParameter("EmailAddress", command,  
                    SqlDbType.NVarChar, 50, true, string.Empty);  
                MaybeAddCommandParameter("EmailPromotion", command,  
                    SqlDbType.Int, false, null);  
                MaybeAddCommandParameter("Phone", command,  
                    SqlDbType.NVarChar, 25, false, null);  
                MaybeAddCommandParameter("PasswordHash", command,  
                    SqlDbType.VarChar, 40, true, string.Empty);  
                MaybeAddCommandParameter("PasswordSalt", command,  
                    SqlDbType.VarChar, 10, true, string.Empty);  
                MaybeAddCommandParameter("AdditionalContactInfo", command,  
                    SqlDbType.Xml, false, null);  
                conn.Open();  
                this.ContactId = (int)command.ExecuteScalar();  
            }  
        }  
    }  
  
    /// <summary>  
    ///A base class based on ContactCreator which is responsible for inserting information about  
    ///a customer by inserting a row in the   
    ///Sales.Customer table.  Currently only used by the IndividualCreator class, but  
    ///it might be useful if there was a variant made of the StoreCreator which actually inserted  
    ///a Sales.Store row.   
    /// </summary>  
  
    public abstract class CustomerCreator : ContactCreator  
    {  
        public override void Create()  
        {  
            base.Create();  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                if (!contactDictionary.ContainsKey("CustomerType"))  
                    contactDictionary["CustomerType"] = "I";  
                ResetCounters(0);  
                string parameters = String.Format(CultureInfo.InvariantCulture,   
                    "{0}{1}{2}", MaybeParameter("SalesPersonID"),  
                    MaybeParameter("TerritoryID"),  
                    //CustomerType is always present, but we  
                    //need to get the commas right  
                    MaybeParameter("CustomerType"));  
                string values = String.Format(CultureInfo.InvariantCulture,   
                    "{0}{1}{2}", MaybeValue("SalesPersonID"),  
                    MaybeValue("TerritoryID"), MaybeValue("CustomerType"));  
                command.CommandText = String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Sales.Customer ({0}) VALUES ({1}); "  
                    + "SELECT CAST(SCOPE_IDENTITY() as Int);",  
                    parameters, values);  
                MaybeAddCommandParameter("SalesPersonID", command,  
                    SqlDbType.Int, false, null);  
                MaybeAddCommandParameter("TerritoryID", command,  
                    SqlDbType.Int, false, null);  
                MaybeAddCommandParameter("CustomerType", command,  
                    SqlDbType.NChar, 1, true, "I");  
                conn.Open();  
                this.CustomerId = (int)command.ExecuteScalar();  
            }  
        }  
    }  
  
    /// <summary>  
    ///Responsible for adding information about an individual purchasing by   
    ///inserting a row in the Sales.Individual table.  
    /// </summary>  
  
    public class IndividualCreator : CustomerCreator  
    {  
        public override void Create()  
        {  
            base.Create();  
            using (SqlConnection conn  
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                ResetCounters(2);  
                String parameters = String.Format(CultureInfo.InvariantCulture,  
                    "CustomerID, ContactID{0}", MaybeParameter("Demographics"));  
                String values = String.Format(CultureInfo.InvariantCulture,  
                    "@CustomerID, @ContactID{0}", MaybeValue("Demographics"));  
                command.CommandText =  
                    String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Sales.Individual ({0}) VALUES ({1});",  
                    parameters, values);  
                MaybeAddCommandParameter("CustomerID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("ContactID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("Demographics", command,  
                    SqlDbType.Xml, false, null);  
                conn.Open();  
                command.ExecuteNonQuery();  
            }  
        }  
    }  
  
    /// <summary>  
    ///Responsible for relating a contact to a store by inserting a row in the   
    ///Sales.StoreContact table.  
    /// </summary>  
  
    public class StoreCreator : ContactCreator  
    {  
        public override void Create()  
        {  
            base.Create();  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                command.CommandText =  
                    String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Sales.StoreContact (CustomerID, ContactID, "  
                    + "ContactTypeID) VALUES (@CustomerID, @ContactID, @ContactTypeID);");  
                MaybeAddCommandParameter("CustomerID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("ContactID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("ContactTypeID", command,  
                    SqlDbType.TinyInt, true, string.Empty);  
                conn.Open();  
                command.ExecuteNonQuery();  
            }  
        }  
    }  
  
    /// <summary>  
    ///Responsible for relating a contact to a vendor by inserting a row in the   
    ///Purchasing.VendorContact table.  
    /// </summary>  
  
    public class VendorCreator : ContactCreator  
    {  
        public override void Create()  
        {  
            base.Create();  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                String parameters = "VendorID, ContactID, ContactTypeID";  
                String values = String.Format(CultureInfo.InvariantCulture,   
                    "@VendorID, @ContactID, @ContactTypeID");  
  
                command.CommandText =  
                    String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Purchasing.VendorContact ({0}) VALUES ({1});",  
                    parameters, values);  
                MaybeAddCommandParameter("VendorID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("ContactID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("ContactTypeID", command,  
                    SqlDbType.TinyInt, true, string.Empty);  
                conn.Open();  
                command.ExecuteNonQuery();  
            }  
        }  
    }  
  
    /// <summary>  
    ///Responsible for adding information about an employee by creating an address and then  
    ///inserting a row in the HumanResources.Employee table.  
    /// </summary>  
  
    public class EmployeeCreator : ContactCreator  
    {  
        public override void Create()  
        {  
            base.Create();  
            CreateAddress();  
            int employeeID = -1;  
            using (SqlConnection conn = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                ResetCounters(3);  
                String parameters = String.Format(CultureInfo.InvariantCulture,  
                    "NationalIDNumber, ContactID, LoginID{0}, Title, "  
                    + "BirthDate, MaritalStatus, Gender, HireDate, "  
                    + "SalariedFlag, VacationHours, SickLeaveHours",  
                    MaybeParameter("ManagerID"));  
                String values = String.Format(CultureInfo.InvariantCulture,  
                    "@NationalIDNumber, @ContactID, @LoginID{0}, @Title, "  
                    + "@BirthDate, @MaritalStatus, @Gender, @HireDate, "  
                    + "@SalariedFlag, @VacationHours, @SickLeaveHours",  
                    MaybeValue("ManagerID"));  
  
                command.CommandText =  
                    String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO HumanResources.Employee ({0}) VALUES ({1}); "   
                    + "SELECT CAST(SCOPE_IDENTITY() as Int);",   
                    parameters, values);  
                MaybeAddCommandParameter("NationalIDNumber", command,  
                    SqlDbType.NVarChar, 15, true, string.Empty);  
                MaybeAddCommandParameter("ContactID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("LoginID", command,  
                    SqlDbType.NVarChar, 256, true, string.Empty);  
                MaybeAddCommandParameter("ManagerID", command,  
                    SqlDbType.Int, false, null);  
                MaybeAddCommandParameter("JobTitle", "Title", command,  
                    SqlDbType.NVarChar, 50, true, string.Empty);  
                MaybeAddCommandParameter("BirthDate", command,  
                    SqlDbType.DateTime, true, string.Empty);  
                MaybeAddCommandParameter("MaritalStatus", command,  
                    SqlDbType.NChar, 1, true, string.Empty);  
                MaybeAddCommandParameter("Gender", command,  
                    SqlDbType.NChar, 1, true, string.Empty);  
                MaybeAddCommandParameter("HireDate", command,  
                    SqlDbType.DateTime, true, string.Empty);  
                MaybeAddCommandParameter("SalariedFlag", command,  
                    SqlDbType.Bit, true, "1");  
                MaybeAddCommandParameter("VacationHours", command,  
                    SqlDbType.SmallInt, true, "0");  
                MaybeAddCommandParameter("SickLeaveHours", command,  
                    SqlDbType.SmallInt, true, "0");  
                conn.Open();  
                employeeID = (int)command.ExecuteScalar();  
            }  
            CreateEmployeeAdddress(employeeID,  
                int.Parse(contactDictionary["AddressID"],  
                System.Globalization.CultureInfo.InvariantCulture));  
            CreateEmployeeDepartmentHistory(employeeID,  
                int.Parse(contactDictionary["DepartmentID"],  
                System.Globalization.CultureInfo.InvariantCulture),  
                int.Parse(contactDictionary["ShiftID"],  
                System.Globalization.CultureInfo.InvariantCulture));  
  
        }  
  
        public void CreateAddress()  
        {  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand command = conn.CreateCommand();  
  
                ResetCounters(4);  
  
                String parameters = String.Format(CultureInfo.InvariantCulture,  
                    "AddressLine1{0}, City, StateProvinceID, PostalCode",  
                    MaybeParameter("AddressLine2"));  
                String values = String.Format(CultureInfo.InvariantCulture,  
                "@AddressLine1{0}, @City, @StateProvinceID, @PostalCode",  
                    MaybeValue("AddressLine2"));  
  
                command.CommandText =  
                    String.Format(CultureInfo.InvariantCulture,  
                    "INSERT INTO Person.Address ({0}) VALUES ({1}); "  
                    + "SELECT CAST(SCOPE_IDENTITY() as Int);",  
                    parameters, values);  
                MaybeAddCommandParameter("AddressLine1", command,  
                    SqlDbType.NVarChar, 60, true, string.Empty);  
                MaybeAddCommandParameter("AddressLine2", command,  
                    SqlDbType.NVarChar, 60, false, null);  
                MaybeAddCommandParameter("City", command,  
                    SqlDbType.NVarChar, 30, true, string.Empty);  
                MaybeAddCommandParameter("StateProvinceID", command,  
                    SqlDbType.Int, true, string.Empty);  
                MaybeAddCommandParameter("PostalCode", command,  
                    SqlDbType.NVarChar, 15, true, string.Empty);  
                conn.Open();  
                contactDictionary["AddressID"] = command.ExecuteScalar().ToString();  
            }  
        }  
  
        public static void CreateEmployeeAdddress(int employeeId, int addressId)  
        {  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand cmd = conn.CreateCommand();  
                cmd.CommandText = "INSERT INTO HumanResources.EmployeeAddress "   
                    + "(EmployeeID, AddressID) VALUES (@EmployeeID, @AddressID)";  
                cmd.Parameters.AddWithValue("@EmployeeID", employeeId);  
                cmd.Parameters.AddWithValue("@AddressID", addressId);  
                conn.Open();  
                cmd.ExecuteNonQuery();  
            }  
        }  
  
        public static void CreateEmployeeDepartmentHistory(int employeeId, int departmentId, int shiftId)  
        {  
            using (SqlConnection conn   
                = new SqlConnection("context connection=true"))  
            {  
                SqlCommand cmd = conn.CreateCommand();  
                cmd.CommandText = "INSERT INTO HumanResources.EmployeeDepartmentHistory "   
                    + "(EmployeeID, DepartmentID, ShiftID, StartDate) VALUES "   
                    + "(@EmployeeID, @DepartmentID, @ShiftID, @StartDate)";  
                cmd.Parameters.AddWithValue("@EmployeeID", employeeId);  
                cmd.Parameters.AddWithValue("@DepartmentID", departmentId);  
                cmd.Parameters.AddWithValue("@ShiftID", shiftId);  
                cmd.Parameters.AddWithValue("@StartDate", DateTime.Now);  
                conn.Open();  
                cmd.ExecuteNonQuery();  
            }  
        }  
    }  
  
    /// <summary>  
    ///Used to indicate when parsing the xml document for creating a contact is   
    ///not in the proper form.  
    /// </summary>  
    [Serializable]  
    public class AWUtilitiesContactParseException : Exception  
    {  
        private String expected = "Unknown";  
  
        private String actual = "Unknown";  
  
        public String Expected  
        {  
            get  
            {  
                return expected;  
            }  
            set  
            {  
                expected = value;  
            }  
        }  
  
        public String Actual  
        {  
            get  
            {  
                return actual;  
            }  
            set  
            {  
                actual = value;  
            }  
        }  
  
        public AWUtilitiesContactParseException()  
        {  
        }  
  
        public AWUtilitiesContactParseException(String message)  
            : base(message)  
        {  
        }  
  
        public AWUtilitiesContactParseException(string message, Exception innerException)  
            : base(message, innerException)  
        {  
        }  
  
        protected AWUtilitiesContactParseException(SerializationInfo info, StreamingContext context)  
            : base(info, context)  
        {  
        }  
  
        public AWUtilitiesContactParseException(String expected, String actual)  
        {  
            this.Expected = expected;  
            this.Actual = actual;  
        }  
  
        public override String ToString()  
        {  
            return String.Format(CultureInfo.CurrentUICulture,  
                "Parsing error during contact creation, expected element {0}, found element {1}.",  
                this.Expected, this.Actual);  
        }  
  
        [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Demand, SerializationFormatter = true)]  
        public override void GetObjectData(SerializationInfo info, StreamingContext context)  
        {  
            // Use the method of the base class.  
            base.GetObjectData(info, context);  
        }  
    }  
  
