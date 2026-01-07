@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZBOOK_TRANS002'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BOOKTRANS_001
  as select from zbook_trans
{
  key bankrecoid as Bankrecoid,
  key voucher_no as VoucherNo,
  partycode as Partycode,
  partyname as Partyname,
  paymenttype as Paymenttype,
  fiscalyear as Fiscalyear,
  dates as Dates,
  amount as Amount,
  assignment_ref as AssignmentRef,
  cleared_date as ClearedDate,
  cleared_voucherno as ClearedVoucherno,
  clear_doc1 as ClearDoc1,
  clear_doc2 as ClearDoc2,
  clearing_request as ClearingRequest,
  gl_account as GlAccount,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.lastChangedBy: true
  changedby as Changedby,
  @Semantics.systemDateTime.lastChangedAt: true
  changedat as Changedat,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as Locallastchangedat
}
