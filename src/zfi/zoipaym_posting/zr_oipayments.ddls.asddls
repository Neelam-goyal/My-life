@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Outgoing Incoming Payments'
define root view entity ZR_OIPAYMENTS
  as select from zoipayments
{
  key companycode as Companycode,
  key documentdate as Documentdate,
  key bpartner as Bpartner,
  key createdtime as Createdtime,
  key special_gl_code as SpecialGlCode,
  key line_no as LineNum,
  postingdate as Postingdate,
  glamount as Glamount,
  accountingdocument as Accountingdocument,
  documenttype as AccountingDocumenttype,
  type as Type,
  businessplace as Businessplace,
  sectioncode as Sectioncode,
  gltext as Gltext,
  taxcode as TaxCode,
   referenceid   as ReferenceID,
   amountinbalancetransaccrcy as AmountInBalanceTransacCrcy,
  glaccount as Glaccount,
  housebank as Housebank,
  accountid as Accountid,
  profitcenter as Profitcenter,
  costcenter as Costcenter,
  wbselement as Wbselement,
  error_log as ErrorLog,
    @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: false
  } ]
  currencycode as Currencycode,
  assignmentreference as Assignmentreference,
  approved_at as ApprovedAt,
  approved_by as ApprovedBy,
  isdeleted as Isdeleted,
  isposted as Isposted,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
