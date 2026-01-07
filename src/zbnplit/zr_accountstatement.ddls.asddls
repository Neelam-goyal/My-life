@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Account Statement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_AccountStatement
  as select from    I_OperationalAcctgDocItem as item
    inner join      I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                               and item.FiscalYear         = _JournalEntry.FiscalYear
                                                               and item.AccountingDocument = _JournalEntry.AccountingDocument
    inner join      I_Supplier                as _Supplier     on item.Supplier = _Supplier.Supplier
    left outer join ZR_AccountStatementTDS    as _TDSRecord    on  item.CompanyCode        = _TDSRecord.CompanyCode
                                                               and item.FiscalYear         = _TDSRecord.FiscalYear
                                                               and item.AccountingDocument = _TDSRecord.AccountingDocument
  association [0..1] to I_GLAccountText as _GLAccount on  item.ChartOfAccounts = _GLAccount.ChartOfAccounts
                                                      and item.GLAccount       = _GLAccount.GLAccount
                                                      and _GLAccount.Language  = $session.system_language
{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,
  key item.AccountingDocumentItem,
      item.Supplier                                            as PartyCode,
      _Supplier.SupplierFullName                               as PartyName,
      item.GLAccount,
      _GLAccount.GLAccountName,
      item.PostingDate,
      item.DocumentDate,
      item.NetDueDate,
      item.AccountingDocumentType,
      _JournalEntry.DocumentReferenceID,
      item.ReferenceDocumentType,
      coalesce(
      item.OriginalReferenceDocument,item.AssignmentReference) as OriginalReferenceDocument,
      item.PaymentReference,
      item.InvoiceReference,
      item.SalesDocument,
      item.PurchasingDocument,
      item.DocumentItemText,
      item._JournalEntry.BusinessTransactionType,
      item.CostCenter,
      item.ProfitCenter,
      item.FunctionalArea,
      item.BusinessArea,
      item.BusinessPlace,
      item.Segment,
      item.Plant,
      case when item.SpecialGLCode = '' and item.SpecialGLTransactionType = ''
      then 1
      else 0
      end as IsExcSplGL,
      item.SpecialGLCode,
      item.SpecialGLTransactionType,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _TDSRecord.TDSAmtinCmpCodeCurr,
      item.ControllingArea,
      _JournalEntry.ReversalReason,
      _JournalEntry.IsReversal,
      _JournalEntry.IsReversed,

      case when _JournalEntry.IsReversal = 'X'
            or _JournalEntry.IsReversed = 'X'
            then 0
            else 1
            end                                                as IsRevDoc,

      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                           as ReversedReferenceDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                           as ReversalReferenceDocument,
      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                   as ReversedDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                   as ReverseDocument,
      item.IsSalesRelated,

      item.DebitCreditCode,

      item.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @Aggregation.default: #SUM
      item.AmountInCompanyCodeCurrency,
      _JournalEntry.JournalEntryLastChangeDateTime
}
where
      item.FiscalPeriod                >  '000'
  //  and _JItem.SourceLedger              =  '0L'
  and item.AmountInTransactionCurrency <> 0
  and item.FinancialAccountType        =  'K' // Supplier Line Entry
  and item.SpecialGLCode               <> 'F'

union all

select from       I_OperationalAcctgDocItem as item
  inner join      I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                             and item.FiscalYear         = _JournalEntry.FiscalYear
                                                             and item.AccountingDocument = _JournalEntry.AccountingDocument
  inner join      I_Customer                as _Customer     on item.Customer = _Customer.Customer
  left outer join ZR_AccountStatementTDS    as _TDSRecord    on  item.CompanyCode        = _TDSRecord.CompanyCode
                                                             and item.FiscalYear         = _TDSRecord.FiscalYear
                                                             and item.AccountingDocument = _TDSRecord.AccountingDocument
association [0..1] to I_GLAccountText as _GLAccount on  item.ChartOfAccounts = _GLAccount.ChartOfAccounts
                                                    and item.GLAccount       = _GLAccount.GLAccount
                                                    and _GLAccount.Language  = $session.system_language
{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,
  key item.AccountingDocumentItem,
      item.Customer                                                     as PartyCode,
      _Customer.CustomerFullName                                        as PartyName,
      item.GLAccount,
      _GLAccount.GLAccountName,
      item.PostingDate,
      item.DocumentDate,
      item.NetDueDate,
      item.AccountingDocumentType,
      _JournalEntry.DocumentReferenceID,
      item.ReferenceDocumentType,
      coalesce(item.OriginalReferenceDocument,item.AssignmentReference) as OriginalReferenceDocument,
      item.PaymentReference,
      item.InvoiceReference,
      item.SalesDocument,
      item.PurchasingDocument,
      item.DocumentItemText,

      item._JournalEntry.BusinessTransactionType,
      item.CostCenter,
      item.ProfitCenter,
      item.FunctionalArea,
      item.BusinessArea,
      item.BusinessPlace,
      item.Segment,
      item.Plant,
      case when item.SpecialGLCode = '' and item.SpecialGLTransactionType = ''
      then 1
      else 0
      end as IsExcSplGL,
      item.SpecialGLCode,
      item.SpecialGLTransactionType,
      _TDSRecord.TDSAmtinCmpCodeCurr,
      item.ControllingArea,
      _JournalEntry.ReversalReason,
      _JournalEntry.IsReversal,
      _JournalEntry.IsReversed,

      case when _JournalEntry.IsReversal = 'X'
            or _JournalEntry.IsReversed = 'X'
            then 0
            else 1
            end                                                         as IsRevDoc,

      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                                    as ReversedReferenceDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                                    as ReversalReferenceDocument,
      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                            as ReversedDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                            as ReverseDocument,
      item.IsSalesRelated,

      item.DebitCreditCode,

      item.CompanyCodeCurrency,

      item.AmountInCompanyCodeCurrency,
      _JournalEntry.JournalEntryLastChangeDateTime 
}
where
      item.FiscalPeriod                >  '000'
  //  and _JItem.SourceLedger              =  '0L'
  and item.AmountInTransactionCurrency <> 0
  and item.FinancialAccountType        =  'D' // Customer Line Entry
  and item.AccountingDocumentType      <> 'WL'
  and item.AccountingDocumentType      <> 'WE'
  and item.AccountingDocumentType      <> 'WA'
  and item.SpecialGLCode               <> 'F'
