@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW FOR EMPLOYEE FINAL'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_PROVIDER ],
  modelingPattern: #ANALYTICAL_CUBE
}
define view entity ZDD_EMPLOYEE_FINAL as

  select from ZDD_SUPPLIER_JOIN
  {
    key FiscalPeriod,
    key CompanyCode,
        GLAccount,
        GLAccountName,
        BusinessPartner,
        BusinessPartnerFullName,
        @Semantics.amount.currencyCode: 'curr'
        DebitAmountInCoCodeCrcy,
        @Semantics.amount.currencyCode: 'curr'
        CreditAmountInCoCodeCrcy,
        curr,
        PostingDate,
        ProfitCenter
  }

  union 

  select from ZDD_EMPLOYEE
  {
    key FiscalPeriod,
    key CompanyCode,
        GLAccount,
        GLAccountName,
        BusinessPartner,
        BusinessPartnerFullName,
//        @Semantics.amount.currencyCode: 'curr'
        DebitAmountInCoCodeCrcy,
//        @Semantics.amount.currencyCode: 'curr'
        CreditAmountInCoCodeCrcy,
        curr,
        PostingDate,
        ProfitCenter
  }
