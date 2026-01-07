@EndUserText.label: 'TMG for With Holding tax'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TmgForWithHoldingTa
  as select from zwithholdingtmg
  association to parent ZI_TmgForWithHoldingTa_S as _TmgForWithHoldinAll on $projection.SingletonID = _TmgForWithHoldinAll.SingletonID
{
  key officialwhldgtaxcode as Officialwhldgtaxcode,
  key withholdingtaxcode     as Withholdingtaxcode,
  country as Country,
  withholdingtaxtype as Withholdingtaxtype,
  whldgtaxrelevantpercent as Whldgtaxrelevantpercent,
  withholdingtaxpercent as Withholdingtaxpercent,
  @Consumption.hidden: true
  1 as SingletonID,
  _TmgForWithHoldinAll
  
}
