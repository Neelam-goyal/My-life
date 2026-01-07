@EndUserText.label: 'TMG for With Holding tax'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TmgForWithHold
  as select from zdt_taxcode
  association to parent ZI_TmgForWithHold_S as _TmgForWithHoldinAll on $projection.SingletonID = _TmgForWithHoldinAll.SingletonID
{
  key country as Country,
  key officialwhldgtaxcode as Officialwhldgtaxcode,
  key withholdingtaxcode as Withholdingtaxcode,
  withholdingtaxtype as Withholdingtaxtype,
  whldgtaxrelevantpercent as Whldgtaxrelevantpercent,
  withholdingtaxpercent as Withholdingtaxpercent,
  glaccount as Glaccount,
  @Consumption.hidden: true
  1 as SingletonID,
  _TmgForWithHoldinAll
  
}
