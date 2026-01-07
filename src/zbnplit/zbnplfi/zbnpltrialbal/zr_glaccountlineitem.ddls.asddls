@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS GL Account Line Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZR_GLAccountLineItem
  with parameters

    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'Upto Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    P_ToDate : datum

  as select from I_GLAccountLineItem as Item

    inner join   ZR_USER_CMPY_ACCESS as _cmpAccess on  _cmpAccess.CompCode = Item.CompanyCode
                                                   and _cmpAccess.userid   = $session.user

    inner join   ZDIM_BonnHierarchy  as node       on Item.GLAccount = node.N5
  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountHierarchy on  $projection.ChartOfAccounts    = _GLAccountHierarchy.ChartOfAccounts
                                                                            and $projection.GLAccountHierarchy = _GLAccountHierarchy.GLAccount

{
      @ObjectModel.foreignKey.association: '_SourceLedger'
  key Item.SourceLedger,
      @ObjectModel.foreignKey.association: '_CompanyCode'
  key Item.CompanyCode,
      @ObjectModel.foreignKey.association: '_FiscalYear'
  key Item.FiscalYear,
      @ObjectModel.foreignKey.association: '_JournalEntry'
  key Item.AccountingDocument,
  key Item.LedgerGLLineItem,
      @ObjectModel.foreignKey.association: '_Ledger'
  key Item.Ledger,
      Item.FiscalYearVariant,
      @Consumption: {
                        filter: {
                                      mandatory: true,
                                    multipleSelections: false,
                                    selectionType: #SINGLE
                                }
                     }
      @Semantics.fiscal.year: true
      @ObjectModel.foreignKey.association: '_LedgerFiscalYearForVariant'
      Item.LedgerFiscalYear,
      Item.FiscalPeriod,
      @ObjectModel.foreignKey.association: '_FiscalYearPeriodForVariant'
      @Semantics.fiscal.yearPeriod: true
      Item.FiscalYearPeriod,
      node.N0,
      node.N1,
      node.N2,
      node.N3,
      node.N4,
      Item.PostingDate,
      Item.DocumentDate,
      Item.AccountingDocumentType as DocumentType,
      

      @ObjectModel.foreignKey.association: '_AccountingDocumentCategory'
      Item.AccountingDocumentCategory,

      @ObjectModel.foreignKey.association: '_ChartOfAccounts'
      Item.ChartOfAccounts,

      @ObjectModel.foreignKey.association: '_ControllingArea'
      Item.ControllingArea,


      Item.GLAccount,
      @ObjectModel.foreignKey.association: '_GLAccountHierarchy'
      Item.GLAccount as GLAccountHierarchy,

      Item._GLAccountInChartOfAccounts.IsBalanceSheetAccount,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CostCenterStdVH',
                     element: 'CostCenter' }
        }]
      @ObjectModel.foreignKey.association: '_CostCenter'
      Item.CostCenter,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_ProfitCenterStdVH',
                     element: 'ProfitCenter' }
        }]
      @ObjectModel.foreignKey.association: '_ProfitCenter'
      Item.ProfitCenter,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_FunctionalArea',
                     element: 'FunctionalArea' }
        }]
      @ObjectModel.foreignKey.association: '_FunctionalArea'
      Item.FunctionalArea,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_BusinessAreaStdVH',
                     element: 'BusinessArea' }
        }]
      @ObjectModel.foreignKey.association: '_BusinessArea'
      Item.BusinessArea,

      @ObjectModel.foreignKey.association: '_FinancialTransactionType'
      Item.FinancialTransactionType,

      @ObjectModel.foreignKey.association: '_BusinessTransactionCategory'
      Item.BusinessTransactionCategory,

      @ObjectModel.foreignKey.association: '_BusinessTransactionType'
      Item.BusinessTransactionType,

      @Consumption.valueHelpDefinition: [
            { entity:  { name:    'I_Supplier_VH',
                     element: 'Supplier' }
            }]
      @ObjectModel.foreignKey.association: '_Supplier'
      Item.Supplier,

      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_Customer_VH',
                     element: 'Customer' }
        }]
      @ObjectModel.foreignKey.association: '_Customer'

      Item.Customer,
      cast(
            case
             when Item.FinancialAccountType = 'K' or Item.FinancialAccountType = 'D'
             then case
                 when length(Item.Supplier)<= 2 or Item.Supplier is null
                         then Item.Customer
                     else Item.Supplier end
             end
             as abap.char(10)
       )             as SubCode,

      @ObjectModel.foreignKey.association: '_FinancialAccountType'
      Item.FinancialAccountType,

      @ObjectModel.foreignKey.association: '_SpecialGLCode'
      Item.SpecialGLCode,

      @ObjectModel.foreignKey.association: '_ReferenceDocumentType'
      Item.ReferenceDocumentType,

      Item.ReferenceDocument,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Item.DebitAmountInCoCodeCrcy,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Item.CreditAmountInCoCodeCrcy,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Item.AmountInCompanyCodeCurrency,

      Item.CompanyCodeCurrency,

      Item.IsReversal,
      Item.IsReversed,

      Item._CostCenter,
      Item._ProfitCenter,
      Item._SourceLedger,
      Item._CompanyCode,
      Item._FiscalYear,
      Item._BusinessArea,
      Item._FunctionalArea,
      Item._GLAccountInChartOfAccounts,
      Item._LedgerFiscalYearForVariant,
      Item._FiscalYearPeriodForVariant,
      Item._Supplier,
      Item._Customer,
      Item._JournalEntry,
      Item._Ledger,
      Item._ChartOfAccounts,
      Item._ControllingArea,
      Item._FinancialTransactionType,
      Item._BusinessTransactionCategory,
      Item._BusinessTransactionType,
      Item._FinancialAccountType,
      Item._SpecialGLCode,
      Item._ReferenceDocumentType,
      Item._AccountingDocumentCategory,
      _GLAccountHierarchy


}
where
      Item.SourceLedger = '0L'
  and Item.PostingDate  <= $parameters.P_ToDate
//  and Item.CompanyCode      = 'BBPL'
//  and Item.LedgerFiscalYear = '2025'
