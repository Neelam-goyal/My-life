@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cust Supp Journal Vouchers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CUST_SUPP_JV
  as select from I_OperationalAcctgDocItem as A
{
  key A.CompanyCode,
  key A.AccountingDocument,
  key A.FiscalYear,

      max(A.Customer) as Customer,
      max(A.Supplier) as Supplier

}
where
        not(
          A.Customer         = ''
          and A.Supplier     = ''
        )
  and(
        FinancialAccountType = 'D' // Only Customer and Supplier Line Entry
    or  FinancialAccountType = 'K'
  )
group by
  A.CompanyCode,
  A.AccountingDocument,
  A.FiscalYear,
  A.CompanyCodeCurrency
