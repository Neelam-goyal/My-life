@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Production Breakdown'
define root view entity ZR_PRODBREAKDOWN
  as select from zprodbreakdown
{
  key comp_code as CompCode,
  key prodordcode as Prodordcode,
  key brkdndate as Brkdndate,
  key brkdnstarttime as Brkdnstarttime,
  brkdnendtime as Brkdnendtime,
  shift as Shift,
  reasoncode as Reasoncode,
  reasondesc as Reasondesc,
  subreasoncode as subReasoncode,
  subreasondesc as subReasondesc,
  remarks as Remarks,
  operatorname as Operatorname,
  breakdownpercentage as Breakdownpercentage,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt  
  
}
