@EndUserText.label: 'StateCodeMaster'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZI_Statecodemaster
  as select from zstatecodemaster
  association to parent ZI_Statecodemaster_S as _StatecodemasterAll on $projection.SingletonID = _StatecodemasterAll.SingletonID
{
  key statecode as Statecode,
  statecodenum as Statecodenum,
  @Consumption.hidden: true
  1 as SingletonID,
  _StatecodemasterAll
  
}
