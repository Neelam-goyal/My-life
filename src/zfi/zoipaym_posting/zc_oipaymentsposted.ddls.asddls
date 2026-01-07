@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'OI Payments Posted CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_OIPAYMENTSPOSTED 
 provider contract transactional_query
  as projection on ZR_OIPAYMENTS
{
  key Companycode,
  key Documentdate,
  key Bpartner,
  key Createdtime,
  key SpecialGlCode,  
  key LineNum,
  Postingdate,
  Accountingdocument,
  AccountingDocumenttype,
  Glamount,
  Businessplace,
  Sectioncode,
  Gltext,
  Glaccount,
  Housebank,
  Accountid,
  Wbselement,
  Profitcenter,
  @Semantics.currencyCode: true
  Currencycode,
  Assignmentreference,
  Isdeleted,
  Isposted,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
where Isposted = 'X' and Isdeleted = ''
