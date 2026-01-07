@EndUserText.label: 'Database Table of BrandCategory TMG'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@Metadata.allowExtensions: true
define view entity ZI_DatabaseTableOfBran
  as select from zdt_tmg
  association to parent ZI_DatabaseTableOfBran_S as _DatabaseTableOfBAll on $projection.SingletonID = _DatabaseTableOfBAll.SingletonID
{
  key brand_code as BrandCode,
  brand_desc as BrandDesc,
  @Consumption.hidden: true
  1 as SingletonID,
  _DatabaseTableOfBAll
  
}
