@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZBANK_RECO'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BANKRECO
  as select from zbank_reco
 composition [1..*] of ZR_BOOKTRANS  as _Booktrans
 composition [1..*] of ZR_STATEMENTTRANS as _StatementTrans
{
  key bankrecoid as Bankrecoid,
  bank as Bank,
  company as Company,
  statementdate as Statementdate,
  status as Status,
  fiscalyear  as FiscalYear,
  bankname     as BankName,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.lastChangedBy: true
  changedby as Changedby,
  @Semantics.systemDateTime.lastChangedAt: true
  changedat as Changedat,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as Locallastchangedat,
  _Booktrans,
  _StatementTrans
}
