@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base CDS to Purchase Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PurchaseData001
  as select from    I_SupplierInvoiceAPI01        as supplierinvoice
    left outer join      I_JournalEntry                as journalentry on  journalentry.ReferenceDocumentType     = 'RMRP'
                                                                  and journalentry.OriginalReferenceDocument = supplierinvoice.SupplierInvoiceWthnFiscalYear
                                                                  and journalentry.CompanyCode               = supplierinvoice.CompanyCode
                                                                  and journalentry.AccountingDocumentType = 'RE'

    inner join      I_SuplrInvcItemPurOrdRefAPI01 as invoiceitem  on  invoiceitem.SupplierInvoice = supplierinvoice.SupplierInvoice
                                                                  and invoiceitem.FiscalYear      = supplierinvoice.FiscalYear

    inner join      ZDIM_Product                  as product      on invoiceitem.PurchaseOrderItemMaterial = product.Product

    left outer join I_JournalEntryItem            as WEPosting    on  WEPosting.SourceLedger           = '0L'
                                                                    and WEPosting.ReferenceDocumentType  = 'MKPF'
                                                                    and WEPosting.FinancialAccountType   = 'M'
                                                                    and WEPosting.PurchasingDocument     = invoiceitem.PurchaseOrder
                                                                    and WEPosting.PurchasingDocumentItem = invoiceitem.PurchaseOrderItem
    left outer join ZR_TAXCODE                    as Item_Tax     on invoiceitem.TaxCode = Item_Tax.Taxcode

{

  key invoiceitem.FiscalYear                        as MIROEntryFiscalYear,
  key invoiceitem.SupplierInvoice                   as MIROEntryNo,
  key invoiceitem.SupplierInvoiceItem               as MIROItemSrNo,
      supplierinvoice.CompanyCode,

      invoiceitem.PurchaseOrder,
      invoiceitem.PurchaseOrderItem,

      supplierinvoice.PostingDate                   as MIRODate,
      journalentry.AccountingDocument               as MIROJournalEntry,
      supplierinvoice.AccountingDocumentType        as MIROJournalEntryType,
      journalentry.FiscalYear                       as MIROJournalEntryFiscalYear,

      supplierinvoice.DocumentDate                  as SupplierInvoiceDt,
      supplierinvoice.SupplierInvoiceIDByInvcgParty as SupplierInvoiceNo,
      supplierinvoice.InvoicingParty                as Supplier,

      supplierinvoice.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      supplierinvoice.InvoiceGrossAmount,

      supplierinvoice.BusinessPlace,


      invoiceitem.Plant,
      invoiceitem.PurchaseOrderItemMaterial         as Material,
      product.ProductName,
      product.ProductType,
      product.ProductGroupName,
      product.ProductSubGroupName,

      //      max(WEPosting.GLAccount)                      as InventoryGLHead,
      max(WEPosting.GLAccount)                      as InventoryGLHead,
      invoiceitem.PurchaseOrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      invoiceitem.QuantityInPurchaseOrderUnit,

      invoiceitem.PurchaseOrderPriceUnit,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderPriceUnit'
      invoiceitem.QtyInPurchaseOrderPriceUnit,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      invoiceitem.SupplierInvoiceItemAmount,

      invoiceitem.TaxCode,
      Item_Tax.Description                          as TaxDesc,
      Item_Tax.Rate                                 as TaxRate



}
group by
  supplierinvoice.CompanyCode,

  invoiceitem.PurchaseOrder,
  invoiceitem.PurchaseOrderItem,

  invoiceitem.SupplierInvoice,
  invoiceitem.FiscalYear,

  supplierinvoice.PostingDate,
  journalentry.AccountingDocument,
  supplierinvoice.AccountingDocumentType,
  journalentry.FiscalYear,


  supplierinvoice.DocumentDate,
  supplierinvoice.SupplierInvoiceIDByInvcgParty,
  supplierinvoice.InvoicingParty,

  supplierinvoice.DocumentCurrency,
  supplierinvoice.InvoiceGrossAmount,

  supplierinvoice.BusinessPlace,
  invoiceitem.SupplierInvoiceItem,
  invoiceitem.Plant,
  invoiceitem.PurchaseOrderItemMaterial,
  product.ProductName,
  product.ProductType,
  product.ProductGroup,
  product.ProductGroupName,
  product.ProductSubGroupName,

  invoiceitem.PurchaseOrderQuantityUnit,
  invoiceitem.QuantityInPurchaseOrderUnit,

  invoiceitem.PurchaseOrderPriceUnit,
  invoiceitem.QtyInPurchaseOrderPriceUnit,

  invoiceitem.SupplierInvoiceItemAmount,

  invoiceitem.TaxCode,
  Item_Tax.Description,
  Item_Tax.Rate
