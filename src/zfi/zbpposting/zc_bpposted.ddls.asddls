@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'BP Payments Posted CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_BPPOSTED 
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

  @Semantics.amount.currencyCode: 'Currencycode'
  Amount1,

  @Semantics.amount.currencyCode: 'Currencycode'
  Amount2,

  @Semantics.currencyCode: true
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
  Isdeleted,
  Accdoc1,
  Accdoc2,
  Accdocyear1,
  Accdocyear2,
  ErrorLog,
  Isposted,
  Validate1,
  Validate2,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
}
where Isposted = 'X' and Isdeleted = '';
