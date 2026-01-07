@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW FOR EMPLOYEE'
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

define view entity ZDD_SUPPLIER_JOIN
as select from I_BusinessPartner as bp

left outer join I_AccountingDocumentJournal(P_Language: 'E') as a
    on 
         a.Supplier = bp.BusinessPartner

{
  key a.FiscalPeriod,
  key a.CompanyCode,
  a.GLAccount,
  a.GLAccountName,
  bp.BusinessPartner,
  bp.BusinessPartnerFullName,
  @Semantics.amount.currencyCode: 'curr'
  a.DebitAmountInCoCodeCrcy,
  @Semantics.amount.currencyCode: 'curr'
  a.CreditAmountInCoCodeCrcy,
  a.FunctionalCurrency as curr,
  a.PostingDate,
  a.ProfitCenter
}
where a.Ledger = '0L'
  and a.IsReversal is initial
          and a.IsReversed is initial
          and a.ReversalReferenceDocument is initial
          and bp.BusinessPartnerGrouping = 'Z005'
  
  
  

  
