@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Employee Statement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_EmpStatement

  as select from    I_OperationalAcctgDocItem as item
    inner join      I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                               and item.FiscalYear         = _JournalEntry.FiscalYear
                                                               and item.AccountingDocument = _JournalEntry.AccountingDocument
    inner join      ZR_USER_CMPY_ACCESS       as _cmpAccess    on  _cmpAccess.CompCode = item.CompanyCode
                                                               and _cmpAccess.userid   = $session.user

    left outer join I_Supplier                as _Supplier     on  item.Supplier                  = _Supplier.Supplier
                                                               and _Supplier.SupplierAccountGroup = 'Z005' -- Only Emplyoees

    left outer join I_Supplier                as _Customer     on  item.Customer                  = _Customer.Supplier
                                                               and _Customer.SupplierAccountGroup = 'Z005' -- Only Emplyoees extended as customer

    association [0..1] to I_GLAccountText as _GLAccount on  item.ChartOfAccounts = _GLAccount.ChartOfAccounts
                                                      and item.GLAccount       = _GLAccount.GLAccount
                                                      and _GLAccount.Language  = $session.system_language
{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,
  key item.AccountingDocumentItem,
      coalesce(_Supplier.Supplier, _Customer.Supplier)                  as EmpCode,
      coalesce(_Supplier.SupplierFullName,_Customer.SupplierFullName)   as EmpName,
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
      end                                                               as IsExcSplGL,
      item.SpecialGLCode,
      item.SpecialGLTransactionType,

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
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      item.AmountInCompanyCodeCurrency,
      _JournalEntry.JournalEntryLastChangeDateTime
}
where
      item.FiscalPeriod                                  >  '000'
  and item.AmountInTransactionCurrency                   <> 0
  and coalesce( _Supplier.Supplier, _Customer.Supplier ) is not null
