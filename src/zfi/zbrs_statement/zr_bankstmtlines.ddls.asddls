@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZBANKSTMTLINES'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_BANKSTMTLINES
  as select from zbankstmtlines
   association to parent ZR_BANKSTMT as _Statement  on $projection.StatementID = _Statement.StatementID
{
  key voucher_no as VoucherNo,
  key statement_id as StatementID,
  line_no as LineNum,
  dates as Dates,
  utr as Utr,
  type as Type,
  description as Description,
  amount as Amount,
  cleared as Cleared,
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
  _Statement
}
