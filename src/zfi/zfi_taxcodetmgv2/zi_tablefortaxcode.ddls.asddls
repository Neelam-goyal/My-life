@EndUserText.label: 'TABLE FOR TAX CODE'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TableForTaxCode
  as select from zwht_taxcode
  association to parent ZI_TableForTaxCode_S as _TableForTaxCodeAll on $projection.SingletonID = _TableForTaxCodeAll.SingletonID
{
  key country as Country,
  key officialwhldgtaxcode as Officialwhldgtaxcode,
  key withholdingtaxcode as Withholdingtaxcode,
  key withholdingtaxtype as Withholdingtaxtype,
  key glaccount as Glaccount,
  whldgtaxrelevantpercent as Whldgtaxrelevantpercent,
  withholdingtaxpercent as Withholdingtaxpercent,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  @Consumption.hidden: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _TableForTaxCodeAll
  
}
