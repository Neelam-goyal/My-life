@Metadata.allowExtensions: true
@EndUserText.label: 'Production Breakdown'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PRODBREAKDOWN
  provider contract transactional_query
  as projection on ZR_PRODBREAKDOWN
{
  key CompCode,
  key Prodordcode,
  key Brkdndate,
  key Brkdnstarttime,
  Brkdnendtime,
  Shift,
  Reasoncode,
  Reasondesc,
  subReasoncode,
  subReasondesc,
  Remarks,
  Operatorname,
  Breakdownpercentage,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZC_TIMEDIFFBRKDWN'
  @EndUserText.label: 'Break Down Time in Minutes'
  virtual BrkDwnInMin : int4
  
}
