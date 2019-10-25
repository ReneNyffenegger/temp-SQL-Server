--
--
--
use AdventureWorks2017  
go
  
DECLARE @contactID Int;  
DECLARE @customerID Int;  
  
EXEC dbo.usp_CreateContact N'<Contact xmlns="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactData"><Individual>  
<Title>Dr.</Title>  
<FirstName>Kim</FirstName>  
<LastName>Smith</LastName>  
<EmailAddress>kim@proseware.com</EmailAddress>  
<PasswordHash>F1AF7A6028F2FEA29292C09603F1C209BB84B518</PasswordHash>  
<PasswordSalt>2Hdr7Jc=</PasswordSalt>  
<Demographics>  
<IndividualSurvey xmlns="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">  
<TotalChildren>2</TotalChildren>  
<NumberChildrenAtHome>1</NumberChildrenAtHome>  
</IndividualSurvey>  
</Demographics>  
</Individual>  
</Contact>', @contactID OUTPUT, @customerID OUTPUT;  
  
PRINT 'Individual Contact ID = ' + CAST(@contactID as varchar(10));  
PRINT 'Individual Customer ID = ' + CAST(@customerID as varchar(10));  
  
EXEC dbo.usp_CreateContact N'  
<Contact xmlns="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactData"><Store>  
<FirstName>Catherine</FirstName>  
<LastName>Smith</LastName>  
<EmailAddress>catherine@proseware.com</EmailAddress>  
<PasswordHash>D584F3AC519BA083DD814023495F267E6A613F7C</PasswordHash>  
<PasswordSalt>bseDC8g=</PasswordSalt>  
<CustomerID>391</CustomerID>  
<ContactTypeID>14</ContactTypeID>  
</Store>  
</Contact>', @contactID OUTPUT, @customerID OUTPUT;  
  
PRINT 'Store Contact ID = ' + CAST(@contactID as varchar(10));  
PRINT 'Store Customer ID = ' + CAST(@customerID as varchar(10));  
  
EXEC dbo.usp_CreateContact N'  
<Contact xmlns="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactData"><Vendor>  
<FirstName>Amy</FirstName>  
<LastName>Smith</LastName>  
<EmailAddress>amy@proseware.com</EmailAddress>  
<PasswordHash>00753C6EEC3659B4A5C30AC048F258C610EBE248</PasswordHash>  
<PasswordSalt>wyUl4hA=</PasswordSalt>  
<VendorID>7</VendorID>  
<ContactTypeID>17</ContactTypeID>  
</Vendor>  
</Contact>', @contactID OUTPUT, @customerID OUTPUT;  
  
PRINT 'Vendor Contact ID = ' + CAST(@contactID as varchar(10));  
PRINT 'Vendor Customer ID = ' + CAST(@customerID as varchar(10));  
  
EXEC dbo.usp_CreateContact N'  
<Contact xmlns="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactData"><Employee>  
<FirstName>Ramona</FirstName>  
<LastName>Smith</LastName>  
<EmailAddress>ramona@proseware.com</EmailAddress>  
<PasswordHash>4BE320740C7461F79A3CE3E177EA03A9FE3DDD26</PasswordHash>  
<PasswordSalt>Pfz9Qzg=</PasswordSalt>  
<NationalIDNumber>739117</NationalIDNumber>  
<LoginID>ramonas</LoginID>  
<DepartmentID>11</DepartmentID>  
<ManagerID>42</ManagerID>  
<ShiftID>1</ShiftID>  
<JobTitle>Information System Specialist</JobTitle>  
<Address>  
<AddressLine1>3 Penny Lane</AddressLine1>  
<AddressLine2>Apartment 2A</AddressLine2>  
<City>Seattle</City>  
<StateProvinceID>79</StateProvinceID>  
<PostalCode>98121</PostalCode>  
</Address>  
<BirthDate>1972-04-01T03:29:17-08:00</BirthDate>  
<MaritalStatus>M</MaritalStatus>  
<Gender>F</Gender>  
<HireDate>1999-08-07T13:35:17-08:00</HireDate>  
<SalariedFlag>true</SalariedFlag>  
<VacationHours>12</VacationHours>  
<SickLeaveHours>8</SickLeaveHours>  
</Employee>  
</Contact>', @contactID OUTPUT, @customerID OUTPUT;  
  
PRINT 'Employee Contact ID = ' + CAST(@contactID as varchar(10));  
  
PRINT 'Employee Customer ID = ' + CAST(@customerID as varchar(10));  
