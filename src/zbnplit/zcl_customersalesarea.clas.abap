CLASS zcl_customersalesarea DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS GetData FOR TABLE FUNCTION ztblf_customersalesarea.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUSTOMERSALESAREA IMPLEMENTATION.


  METHOD getdata
   BY DATABASE FUNCTION
         FOR HDB
         LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY
         USING ZDIM_Customer ZDIM_CustomerSalesArea.

    Result =
        Select
        100 as Client,

         a.Customer,
         a.CustomerName,
         a.gstin,
         a.City,
         a.Region as State,
         a.Country,
         b.SalesOrganization SalesOrg,
         b.DistributionChannel DistChannel,
         b.Division,
         a.SSCode,
         row_number ( ) over ( Partition By a.Customer,b.SalesOrganization Order By b.RecordCreatedDate Desc ) as Sr
        From ZDIM_Customer as a
        Left Outer Join ZDIM_CustomerSalesArea as b on a.Customer=B.Customer;

    Return
        Select Client,SalesOrg, Customer,CustomerName,gstin,City,State,Country,DistChannel,Division,SSCode
        From :Result
        Where Sr = 1;

  endmethod.
ENDCLASS.
