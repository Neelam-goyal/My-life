@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Voucher Master'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_BNPLIT_VUMST
  as select from    I_JournalEntry               as mst
    inner join      I_AccountingDocumentTypeText as dt    on  mst.AccountingDocumentType = dt.AccountingDocumentType
                                                          and dt.Language                = $session.system_language
    inner join      I_OperationalAcctgDocItem           as jitem on  mst.CompanyCode        = jitem.CompanyCode
                                                          and mst.FiscalYear         = jitem.FiscalYear
                                                          and mst.AccountingDocument = jitem.AccountingDocument

    left outer join I_User                       as user  on mst.AccountingDocCreatedByUser = user.UserID
    left outer join I_BusTransactionTypeText     as bt    on  mst.BusinessTransactionType = bt.BusinessTransactionType
                                                          and bt.Language                 = $session.system_language
    left outer join I_ReferenceDocumentTypeText  as rdt   on  mst.ReferenceDocumentType = rdt.ReferenceDocumentType
                                                          and rdt.Language              = $session.system_language
{
  key mst.CompanyCode,
  key mst.FiscalYear,
  key mst.AccountingDocument                                                                        as VoucherNo,
      concat(concat(concat(mst.AccountingDocumentType, ' ('),dt.AccountingDocumentTypeName), ')' )  as VoucherType,
      concat(concat(concat(bt.BusinessTransactionType ,' ('),bt.BusinessTransactionTypeName), ')' ) as TransactionType,
      mst.DocumentDate,
      mst.PostingDate,
      user.UserDescription                                                                          as CreatedBy,
      
      cast( dats_tims_to_tstmp( mst.AccountingDocumentCreationDate, mst.CreationTime,
                              abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' )
          as tzntstmpl)                                                                             as CreatedOn,
      mst.JournalEntryLastChangeDateTime                                                            as LastChangedOn,
      concat(concat(concat(rdt.ReferenceDocumentType ,' ('),rdt.ReferenceDocumentTypeName), ')' )   as ReferenceDocumentType,
      mst.DocumentReferenceID,
      mst.OriginalReferenceDocument,
      mst.AccountingDocumentHeaderText                                                              as MiscText,
      mst.TransactionCurrency,
      cast(max(abs(jitem.AmountInCompanyCodeCurrency)) as abap.dec(18,2))                           as Amount
}

group by
  mst.CompanyCode,
  mst.FiscalYear,
  mst.AccountingDocument,
  mst.AccountingDocumentType,
  dt.AccountingDocumentTypeName,
  bt.BusinessTransactionType,
  bt.BusinessTransactionTypeName,
  mst.DocumentDate,
  mst.PostingDate,
  user.UserDescription,
  mst.AccountingDocumentCreationDate,
  mst.CreationTime,
  mst.JournalEntryLastChangeDateTime,
  rdt.ReferenceDocumentType,
  rdt.ReferenceDocumentTypeName,
  mst.DocumentReferenceID,
  mst.OriginalReferenceDocument,
  mst.AccountingDocumentHeaderText,
  mst.TransactionCurrency
