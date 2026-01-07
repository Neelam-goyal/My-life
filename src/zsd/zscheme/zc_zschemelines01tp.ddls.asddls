@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZSchemeLines'
@ObjectModel.semanticKey: [ 'Productcode' ]
@Search.searchable: true
define view entity ZC_ZSchemeLines01TP
  as projection on ZR_ZSchemeLines01TP as ZSchemeLines
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Schemecode,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Productcode,
  Productdesc,
  Schemegroupcode,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _ZScheme : redirected to parent ZC_ZScheme02TP
  
}
