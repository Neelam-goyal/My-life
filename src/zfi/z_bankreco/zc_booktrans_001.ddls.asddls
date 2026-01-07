@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZBOOK_TRANS002'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_BOOKTRANS_001
  provider contract transactional_query
  as projection on ZR_BOOKTRANS_001
{
  key Bankrecoid,
  key VoucherNo,
  Partycode,
  Partyname,
  Paymenttype,
  Fiscalyear,
  Dates,
  Amount,
  AssignmentRef,
  ClearedDate,
  ClearedVoucherno,
  ClearDoc1,
  ClearDoc2,
  ClearingRequest,
  GlAccount,
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
