@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZBANKSTMT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BANKSTMT
  as select from zbankstmt
 composition [1..*] of ZR_BANKSTMTLINES  as _StatementLines
{
  key statement_id as StatementID,
  bankcode as Bankcode,
  bankname as Bankname,
  housebank as Housebank,
  fromdata as Fromdate,
  todate as Todate,
  status as Status,
  company as Company,
  closingbalance as Closingbalance,
  openingbalance as Openingbalance ,
  statementdate as Statementdate,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  _StatementLines
}
