@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZBPPOSTING'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_BPPOSTING
  provider contract transactional_query
  as projection on ZR_BPPOSTING
{
  key Companycode,
  key Documentdate,
  key Createdtime,
  key LineNum,
  Postingdate,
  Vouchertype,
  Type1,
  Type2,
  Businesspartner1,
  Businesspartner2,
  SpecialGlCode1,
  SpecialGlCode2,
  @Semantics: {
    amount.currencyCode: 'Currencycode'
  }
  Amount1,
  @Semantics: {
    amount.currencyCode: 'Currencycode'
  }
  Amount2,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  Currencycode,
  AmtType1,
  AmtType2,
  BusinessPlace1,
  BusinessPlace2,
  ProfitCenter1,
  ProfitCenter2,
  ItemText1,
  ItemText2,
  Assignment1,
  Assignment2,
  ApprovedBy,
  ApprovedAt,
  Accdoc1,
  Accdoc2,
  Accdocyear1,
  Accdocyear2,
  ErrorLog,
  Isdeleted,
  Isposted,
  Validate1,
  Validate2,
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
  LocalLastChangedAt
}
where Isposted = '' and Isdeleted = ''
