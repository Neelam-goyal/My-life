@AbapCatalog.sqlViewName: 'YTEST'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Details'
define view ZJOURNALENTRY as select from I_Customer as a 
       left outer join I_Address_2 as b
       on (a.AddressID = b.AddressID )
       left outer join I_AddressEmailAddress_2 as c 
       on (b.AddressID = c.AddressID )
       
{
        key a.Customer,
        a.CustomerName,
        a.CustomerAccountGroup,
        a.CustomerFullName,
        a.AuthorizationGroup,
        a.VATRegistration,
        a.TaxNumber3 ,
        a.AddressID,
        a.Region,
        a.OrganizationBPName2,
        a.CityName,
        a.PostalCode,
        a.StreetName,
        a.Country,
        a.TelephoneNumber1,
        a.FaxNumber,
        b.StreetPrefixName1,
        b.StreetPrefixName2,
        b.AddressPersonID,
        b.AddressRepresentationCode,
        c.EmailAddress
}
