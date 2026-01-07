@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZSTATEMENT_TRANS001'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_STATEMENTTRANS_001
  as select from zstatement_trans
{
  key bankrecoid as Bankrecoid,
  key voucher_no as VoucherNo,
  key statementid as Statementid,
  dates as Dates,
  utr as Utr,
  paymenttype as Paymenttype,
  description as Description,
  amount as Amount,
  cleared_voucherno as ClearedVoucherno,
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
