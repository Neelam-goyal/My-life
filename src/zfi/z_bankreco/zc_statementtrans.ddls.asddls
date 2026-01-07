@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZSTATEMENT_TRANS001'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_STATEMENTTRANS
  as projection on ZR_STATEMENTTRANS
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
  Locallastchangedat,
  _BankReco: redirected to parent ZC_BANKRECO
}
