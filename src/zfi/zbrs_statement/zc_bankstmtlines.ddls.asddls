@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZBANKSTMTLINES'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_BANKSTMTLINES
  as projection on ZR_BANKSTMTLINES
{
  key VoucherNo,
  key StatementID,
  LineNum,
  Dates,
  Utr,
  Type,
  Description,
  Amount,
  Cleared,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LocalLastChangedAt,
  _Statement:redirected to parent ZC_BANKSTMT
}
