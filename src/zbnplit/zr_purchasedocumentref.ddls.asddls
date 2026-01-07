@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For Tracking Ref. of Purchase Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PurchaseDocumentRef
  as select from    I_SupplierInvoiceAPI01        as A
    left outer join I_SuplrInvcItemPurOrdRefAPI01 as B on  A.SupplierInvoice = B.SupplierInvoice
                                                       and A.FiscalYear      = B.FiscalYear
{
  key A.SupplierInvoice,
  key A.FiscalYear,
      A.SupplierInvoiceWthnFiscalYear,
      A.CompanyCode,
      A.DocumentDate,
      A.PostingDate,
      A.SupplierInvoiceIDByInvcgParty,
      A.InvoicingParty,
      B.PurchaseOrder
}
group by  A.SupplierInvoice,                 
          A.FiscalYear,                      
          A.SupplierInvoiceWthnFiscalYear,   
          A.CompanyCode,                     
          A.DocumentDate,                    
          A.PostingDate,                     
          A.SupplierInvoiceIDByInvcgParty,   
          A.InvoicingParty,                  
          B.PurchaseOrder                    
