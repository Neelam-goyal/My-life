@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
//@ObjectModel: {
//  sapObjectNodeType.name: 'ZBANK_RECO'
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_BANKRECO
  provider contract transactional_query
  as projection on ZR_BANKRECO
{
  key Bankrecoid,
  Bank,
  Company,
  Statementdate,
  Status,
  FiscalYear,
  BankName,
  
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
  _Booktrans: redirected to composition child ZC_BOOKTRANS,
  _StatementTrans: redirected to composition child ZC_STATEMENTTRANS
}
