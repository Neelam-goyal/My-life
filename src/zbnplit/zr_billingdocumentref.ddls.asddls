@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tracking Reference of Billing Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BillingDocumentRef
  as select from I_BillingDocument     as a
    inner join   I_BillingDocumentItem as b on a.BillingDocument = b.BillingDocument
{
  key a.BillingDocument,
      a.BillingDocumentDate,
      a.AccountingDocument,
      a.FiscalYear,
      a.CompanyCode,
      a.DocumentReferenceID as InvNo,
      b.SalesDocument       as SalesOrder,
      b.ReferenceSDDocument as OutBoundDlv
}
group by
  a.BillingDocument,
  a.BillingDocumentDate,
  a.AccountingDocument,
  a.FiscalYear,
  a.CompanyCode,
  b.SalesDocument,
  b.ReferenceSDDocument,
  a.DocumentReferenceID
