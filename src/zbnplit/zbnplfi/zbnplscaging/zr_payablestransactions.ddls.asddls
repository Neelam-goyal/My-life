@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payables Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

// All transactions of Supplier that are either supplier or customer

define view entity ZR_PayablesTransactions
  as select from ZR_AccountStatement as data
    inner join   I_Supplier          as Supp       on  data.PartyCode            =  Supp.Supplier
                                                   and Supp.SupplierAccountGroup <> 'Z005'
    inner join   ZR_USER_CMPY_ACCESS as _cmpAccess on  _cmpAccess.CompCode = data.CompanyCode
                                                   and _cmpAccess.userid   = $session.user

{
  key data.CompanyCode,
  key data.AccountingDocument,
  key data.FiscalYear,
  key data.AccountingDocumentItem,
      data.PartyCode,
      data.PartyName,
      data.GLAccount,
      data.GLAccountName,
      data.PostingDate,
      data.DocumentDate,
      data.NetDueDate,
      data.DocumentReferenceID,
      data.AccountingDocumentType,
      data.ReferenceDocumentType,
      data.OriginalReferenceDocument,
      data.PaymentReference,
      data.InvoiceReference,
      data.SalesDocument,
      data.PurchasingDocument,
      data.DocumentItemText,
      data.BusinessTransactionType,
      data.CostCenter,
      data.ProfitCenter,
      data.FunctionalArea,
      data.BusinessArea,
      data.BusinessPlace,
      data.Segment,
      data.Plant,
      data.ControllingArea,
      data.IsSalesRelated,
      data.DebitCreditCode,
      data.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @Aggregation.default: #SUM
      data.AmountInCompanyCodeCurrency
}
where
  data.IsRevDoc = 1
  and data.GLAccount <> '0021101900'
