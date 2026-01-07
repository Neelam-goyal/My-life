@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZSTATEMENT_TRANS002'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_STATEMENTTRANS_001
  provider contract transactional_query
  as projection on ZR_STATEMENTTRANS_001
{
  key Bankrecoid,
  key VoucherNo,
  key Statementid,
  Dates,
  Utr,
  Paymenttype,
  Description,
  Amount,
  ClearedVoucherno,
  @Semantics: {
    user.createdBy: true
  }
  Createdby,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  Createdat,
  @Semantics: {
    user.lastChangedBy: true
  }
  Changedby,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  Changedat,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  Locallastchangedat
}
