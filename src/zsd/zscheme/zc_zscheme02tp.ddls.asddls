@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZScheme'
@ObjectModel.semanticKey: [ 'Schemecode' ]
@Search.searchable: true
define root view entity ZC_ZScheme02TP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_ZScheme02TP as ZScheme
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Schemecode,
  Validfrom,
  Validto,
  Customergroup,
  Schemeqty,
  Freeqty,
  Minimumqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _ZSchemeLines : redirected to composition child ZC_ZSchemeLines01TP
  
}
