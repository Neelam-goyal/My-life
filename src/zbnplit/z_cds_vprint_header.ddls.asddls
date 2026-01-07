@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Voucher Print Header Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_CDS_VPRINT_HEADER
  with parameters
    p_CompanyCode        : abap.char(4),
    p_FiscalYear         : abap.numc(4),
    p_AccountingDocument : abap.char(10)
  as select from    I_JournalEntry               as mst
    inner join      I_AccountingDocumentTypeText as adt   on  mst.AccountingDocumentType = adt.AccountingDocumentType
                                                          and adt.Language               = $session.system_language
    left outer join I_BusTransactionTypeText     as bt    on  mst.BusinessTransactionType = bt.BusinessTransactionType
                                                          and bt.Language                 = $session.system_language
    left outer join I_ReferenceDocumentTypeText  as rdt   on  mst.ReferenceDocumentType = rdt.ReferenceDocumentType
                                                          and rdt.Language              = $session.system_language
    left outer join I_BusinessTransactionType    as btt   on mst.BusinessTransactionType = btt.BusinessTransactionType
    left outer join I_BusTransactionCategoryText as btct  on  btt.BusinessTransactionCategory = btct.BusinessTransactionCategory
                                                          and btct.Language                   = $session.system_language
    left outer join I_JournalEntryItem           as jitem on  mst.CompanyCode        = jitem.CompanyCode
                                                          and mst.FiscalYear         = jitem.FiscalYear
                                                          and mst.AccountingDocument = jitem.AccountingDocument
    left outer join I_CompanyCode                as icc   on mst.CompanyCode = icc.CompanyCode
    left outer join I_Address_2                  as ia2   on icc.AddressID = ia2.AddressID
{
  key mst.CompanyCode,
  key mst.FiscalYear,
  key mst.AccountingDocument,
      icc.CompanyCodeName,

      ia2.HouseNumber                                                     as HouseNumber,
      ia2.StreetName                                                      as Street,
      ia2.PostalCode                                                      as PINCode,
      ia2.CityName                                                        as City,
      ia2.Region,
      ia2.Country,
      //  mst._CompanyCode._Address.Building as CompanyAddress,
      mst.CompanyCodeCurrency                                             as Currency,
      mst.AccountingDocumentType,
      adt.AccountingDocumentTypeName,
      mst.BusinessTransactionType,
      bt.BusinessTransactionTypeName,
      btct.BusinessTransactionCategory,
      btct.BusTransactionCategoryName,
      mst.DocumentDate,
      mst.PostingDate,
      mst.ReferenceDocumentType,
      rdt.ReferenceDocumentTypeName,
      mst.DocumentReferenceID,
      mst.OriginalReferenceDocument,
      mst.AccountingDocumentHeaderText                                    as MiscText,
      left(max(jitem.ProfitCenter),4)                                     as PlantCode,
      max(jitem._ProfitCenterTxt.ProfitCenterName)                        as Profitcenter,

      cast(max(abs(jitem.AmountInCompanyCodeCurrency)) as abap.dec(18,2)) as Amount,
      mst.AccountingDocCreatedByUser,
      mst._User.UserDescription,
      cast( dats_tims_to_tstmp( mst.AccountingDocumentCreationDate, mst.CreationTime,
                        abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' )
      as tzntstmpl)                                                       as CreatedOn,
      mst.JournalEntryLastChangeDateTime                                  as LastChangedOn
}
where
      mst.CompanyCode        = $parameters.p_CompanyCode
  and mst.FiscalYear         = $parameters.p_FiscalYear
  and mst.AccountingDocument = $parameters.p_AccountingDocument


group by
  mst.CompanyCode,
  mst.FiscalYear,
  mst.AccountingDocument,
  icc.CompanyCodeName,
  //  mst._CompanyCode.CityName,
  //  mst._CompanyCode._Address.Building as CompanyAddress,
  mst.CompanyCodeCurrency,
  mst.AccountingDocumentType,
  adt.AccountingDocumentTypeName,
  mst.BusinessTransactionType,
  bt.BusinessTransactionTypeName,
  mst.DocumentDate,
  mst.PostingDate,
  mst.ReferenceDocumentType,
  rdt.ReferenceDocumentTypeName,
  mst.DocumentReferenceID,
  mst.OriginalReferenceDocument,
  mst.AccountingDocumentHeaderText,
  mst.AccountingDocCreatedByUser,
  mst._User.UserDescription,
  mst.AccountingDocumentCreationDate,
  mst.CreationTime,
  mst.JournalEntryLastChangeDateTime,
  btct.BusinessTransactionCategory,
  btct.BusTransactionCategoryName,
  ia2.HouseNumber,
  ia2.StreetName,
  ia2.PostalCode,
  ia2.CityName,
  ia2.Country,
  ia2.Region
