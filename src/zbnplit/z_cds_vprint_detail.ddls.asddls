@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Voucher Print Detail Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_CDS_VPRINT_DETAIL 
 with parameters
    p_CompanyCode        : abap.char(4),
    p_FiscalYear         : abap.numc(4),
    p_AccountingDocument : abap.char(10)

  as select from    I_OperationalAcctgDocItem  as item
  
    left outer join I_BusinessAreaText          as _BusinessAreaText          on  item.BusinessArea          = _BusinessAreaText.BusinessArea
                                                                              and _BusinessAreaText.Language = $session.system_language
  
    left outer join I_GLAccountText             as _GLAccountText             on  item.ChartOfAccounts    = _GLAccountText.ChartOfAccounts
                                                                              and item.GLAccount          = _GLAccountText.GLAccount
                                                                              and _GLAccountText.Language = $session.system_language

    left outer join I_CostCenterText            as _CostCenterText            on  item.ControllingArea     =  _CostCenterText.ControllingArea
                                                                              and item.CostCenter          =  _CostCenterText.CostCenter
                                                                              and item.PostingDate         <= _CostCenterText.ValidityEndDate
                                                                              and item.PostingDate         >= _CostCenterText.ValidityStartDate
                                                                              and _CostCenterText.Language = $session.system_language
  
    left outer join I_ProfitCenterText          as _ProfitCenterText          on  item.ControllingArea       =  _ProfitCenterText.ControllingArea
                                                                              and item.ProfitCenter          =  _ProfitCenterText.ProfitCenter
                                                                              and item.PostingDate           <= _ProfitCenterText.ValidityEndDate
                                                                              and item.PostingDate           >= _ProfitCenterText.ValidityStartDate
                                                                              and _ProfitCenterText.Language = $session.system_language
  
    left outer join I_FunctionalAreaText        as _FunctionalAreaText        on  item.FunctionalArea          = _FunctionalAreaText.FunctionalArea
                                                                              and _FunctionalAreaText.Language = $session.system_language

    left outer join I_SegmentText               as _SegmentText               on  item.Segment          = _SegmentText.Segment
                                                                              and _SegmentText.Language = $session.system_language
 
    left outer join I_PostingKeyText            as _PostingKeyText            on  item.PostingKey          = _PostingKeyText.PostingKey
                                                                              and _PostingKeyText.Language = $session.system_language
//    left outer join I_SubLedgerAccLineItemTypeT as _SubLedgerAccLineItemTypeT on  item.SubLedgerAcctLineItemType      = _SubLedgerAccLineItemTypeT.SubLedgerAcctLineItemType
//                                                                              and _SubLedgerAccLineItemTypeT.Language = $session.system_language
//    left outer join I_GLAccountText             as _AlternativeGLAccountText  on  item.CountryChartOfAccounts        = _AlternativeGLAccountText.ChartOfAccounts
//                                                                              and item.AlternativeGLAccount          = _AlternativeGLAccountText.GLAccount
//                                                                              and _AlternativeGLAccountText.Language = $session.system_language
  
    left outer join I_Plant                     as _Plant                     on item.Plant = _Plant.Plant

    left outer join I_Customer                  as _Customer                  on item.Customer = _Customer.Customer

    left outer join I_Supplier                  as _Supplier                  on item.Supplier = _Supplier.Supplier

      left outer join I_ProductText                  as _ProductText                   on  item.Product          = _ProductText.Product
                                                                                       and _ProductText.Language = $session.system_language
  
    left outer join I_HouseBankAccountText      as _HouseBankAccountText      on  item.HouseBank                 = _HouseBankAccountText.HouseBank
                                                                              and item.CompanyCode               = _HouseBankAccountText.CompanyCode
                                                                              and item.HouseBankAccount          = _HouseBankAccountText.HouseBankAccount
                                                                              and _HouseBankAccountText.Language = $session.system_language
  
{
//  key item.SourceLedger,
  key item.CompanyCode,
  key item.FiscalYear,
  key item.AccountingDocument,
  key item.LedgerGLLineItem,
//      item.LedgerFiscalYear,
//      item.use as AccountingDocCreatedByUser,

      item.PostingDate,
      item.DocumentDate,
      item.AccountingDocumentType,
      item.AccountingDocumentItem,
      item.AssignmentReference,
      item.AccountingDocumentCategory,


//      item.GLRecordType,
//      item.JrnlEntrAltvFYConsecutiveID,
      item.ControllingArea,
      item._ControllingArea.ControllingAreaName,
    
      item.DebitCreditCode,

            item.CompanyCodeCurrency,
            @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
            item.AmountInCompanyCodeCurrency,
            @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
            case
               when item.DebitCreditCode = 'H' then abs( item.AmountInCompanyCodeCurrency)
               else abap.curr'0.00'
            end                                                         as CreditAmountInCoCodeCrcy,
            @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
            case
               when item.DebitCreditCode = 'S' then item.AmountInCompanyCodeCurrency
               else abap.curr'0.00'
            end                                                         as DebitAmountInCoCodeCrcy,

      item.ReferenceDocumentType,
      item.GLAccount,
      _GLAccountText.GLAccountName,

      item.ChartOfAccounts,

      item.CostCenter,
      _CostCenterText.CostCenterName,

      item.ProfitCenter,
      _ProfitCenterText.ProfitCenterName,

      item.FunctionalArea,
      _FunctionalAreaText.FunctionalAreaName,

      item.BusinessArea,
      _BusinessAreaText.BusinessAreaName,

      item.Segment,
      _SegmentText.SegmentName,


//      item.ExchangeRateDate,
      item.PostingKey,
      _PostingKeyText.PostingKeyName,

      item.TransactionTypeDetermination,

      item.AlternativeGLAccount,
      item.InvoiceReference,
      item.InvoiceReferenceFiscalYear,
      item.FollowOnDocumentType,
      item.InvoiceItemReference,
      item.PurchasingDocument,
      item.PurchasingDocumentItem,
      item.AccountAssignmentNumber,
      item.DocumentItemText,
      item.SalesDocument,
      item.SalesDocumentItem,

            item.Product,
            _ProductText.ProductName,
      item.Plant,
      _Plant.PlantName,

      item.Supplier,
      _Supplier.SupplierName,
      cast(_Supplier.Country as abap.char(3))           as SupplierCountry,

      item.Customer,
      _Customer.CustomerName,
      cast(_Customer.Country as abap.char(3) )          as CustomerCountry,


      item.TaxCode,
   
      item.HouseBank,

      //      _HouseBankText.HouseBankName                                                           as HouseBankName,

      item.HouseBankAccount,
      _HouseBankAccountText.HouseBankAccountDescription as HouseBankAccountDescription,
      item.IsOpenItemManaged,
      item.ClearingDate,
      item.ClearingJournalEntryFiscalYear,
      item.ClearingJournalEntry,
      
      item.ValueDate,
     
      item.CostOriginGroup,
      item.OffsettingAccount,
      item.OffsettingAccountType,
      item.OffsettingChartOfAccounts,
      item.PersonnelNumber,

      item.NetDueDate
   

}
where
//      item.SourceLedger       = '0L'
   item.CompanyCode        = $parameters.p_CompanyCode
  and item.AccountingDocument = $parameters.p_AccountingDocument
  and item.FiscalYear         = $parameters.p_FiscalYear
