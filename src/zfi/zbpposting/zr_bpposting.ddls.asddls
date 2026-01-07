@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZBPPOSTING'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BPPOSTING
  as select from zbpposting
{
  key companycode as Companycode,
  key documentdate as Documentdate,
  key createdtime as Createdtime,
  key line_no as LineNum,
  postingdate as Postingdate,
  vouchertype as Vouchertype,
  type1 as Type1,
  type2 as Type2,
  businesspartner1 as Businesspartner1,
  businesspartner2 as Businesspartner2,
  special_gl_code1 as SpecialGlCode1,
  special_gl_code2 as SpecialGlCode2,
  @Semantics.amount.currencyCode: 'Currencycode'
  amount1 as Amount1,
  @Semantics.amount.currencyCode: 'Currencycode'
  amount2 as Amount2,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currencycode as Currencycode,
  amt_type1 as AmtType1,
  amt_type2 as AmtType2,
  business_place1 as BusinessPlace1,
  business_place2 as BusinessPlace2,
  profit_center1 as ProfitCenter1,
  profit_center2 as ProfitCenter2,
  item_text1 as ItemText1,
  item_text2 as ItemText2,
  assignment1 as Assignment1,
  assignment2 as Assignment2,
  approved_by as ApprovedBy,
  approved_at as ApprovedAt,
  isdeleted as Isdeleted,
  accdoc1 as Accdoc1,
  accdoc2 as Accdoc2,
  accdocyear1 as Accdocyear1,
  accdocyear2 as Accdocyear2,
  error_log as ErrorLog,
  isposted as Isposted,
  validate1 as Validate1,
  validate2 as Validate2,
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
