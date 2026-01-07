@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZBANKSTMT'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_BANKSTMT
  provider contract transactional_query
  as projection on ZR_BANKSTMT
{
  key StatementID,
  Bankcode,
  Bankname,
  Housebank,
  Fromdate,
  Todate,
  Status,
  Company,
  Closingbalance,
  Openingbalance,
  Statementdate,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BS_GHV'
  virtual DeleteAllowed : abap_boolean,
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
  _StatementLines: redirected to composition child ZC_BANKSTMTLINES
}
