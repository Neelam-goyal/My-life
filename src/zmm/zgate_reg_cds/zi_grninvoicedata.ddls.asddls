@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Grn data definition'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_GRNInvoiceData as select from I_MaterialDocumentHeader_2 as GRNHeader
    left outer join I_MaterialDocumentItem_2 as GRNItem on GRNItem.MaterialDocument = GRNHeader.MaterialDocument and GRNItem.GoodsMovementIsCancelled != 'X' 
  and GRNItem.GoodsMovementType = '101' 
    left outer join I_SuplrInvcItemPurOrdRefAPI01 as InvoiceRef on InvoiceRef.ReferenceDocument = GRNHeader.MaterialDocument
                                                          and InvoiceRef.ReferenceDocumentItem = GRNItem.MaterialDocumentItem
                                                          and InvoiceRef.ReferenceDocumentFiscalYear = GRNHeader.MaterialDocumentYear
    left outer join I_SupplierInvoiceAPI01 as Invoice on Invoice.SupplierInvoice = InvoiceRef.SupplierInvoice
                                                and Invoice.FiscalYear = InvoiceRef.ReferenceDocumentFiscalYear
    left outer join C_SupplierInvoiceDEX as InvoiceDex on InvoiceDex.SupplierInvoice = InvoiceRef.SupplierInvoice
                                                 and InvoiceDex.FiscalYear = InvoiceRef.FiscalYear
                                                 and InvoiceDex.CompanyCode = GRNItem.CompanyCode
    left outer join ztaxcode as TaxCode on TaxCode.taxcode = InvoiceRef.TaxCode {
    key GRNHeader.MaterialDocumentHeaderText as GateNo,
    key GRNItem.PurchaseOrder as DocumentNo,
    key GRNItem.PurchaseOrderItem as DocumentItemNo,
    GRNItem.MaterialDocument as GRNNum,
    GRNItem.DocumentDate as GRNDate,
    @Semantics.quantity.unitOfMeasure: 'unit'
    GRNItem.QuantityInBaseUnit as GRNQty,
    @UI.hidden: true
    GRNItem.EntryUnit as unit,
    GRNItem.MaterialDocumentItem as GRNItem,
    GRNItem.MaterialDocumentYear as GRNYear,
       case 
      when InvoiceDex.ReverseDocument is not null and InvoiceDex.ReverseDocument <> '' 
        then 'X' 
      else ' ' 
    end as isreversed,
    
    case 
      when InvoiceDex.ReverseDocument is not null and InvoiceDex.ReverseDocument <> '' 
        then InvoiceDex.ReverseDocument 
      else ' ' 
    end as refinvno,

//    InvoiceDex.ReverseDocument as ReverseDocument,
    InvoiceRef.SupplierInvoice as SupplierInvoice,
    InvoiceRef.SupplierInvoiceItem as SupplierInvoiceItem,
    InvoiceRef.FiscalYear as FiscalYear,
    @Semantics.amount.currencyCode: 'curr'
    InvoiceRef.SupplierInvoiceItemAmount as NetAmount,
    InvoiceRef.DocumentCurrency as curr,
    InvoiceRef.TaxCode as TaxCode,
    Invoice.PostingDate as InvPostingDate,
    TaxCode.rate as TaxRate,
    TaxCode.description as TaxCodeName,
    TaxCode.transactiontypedetermination as TransactionType
}
where  InvoiceDex.IsInvoice is not initial;
