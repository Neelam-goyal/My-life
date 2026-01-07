@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GRN Helper Data Definition'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGRN_Helper as select from ZI_GRNInvoiceData as GRN {
    key GRN.GateNo,
    key GRN.DocumentNo,
    key lpad(GRN.DocumentItemNo, 6, '0') as DocumentItemNo,
        GRN.GRNNum,
        GRN.GRNDate,
    @Semantics.quantity.unitOfMeasure: 'unit'
        GRN.GRNQty,
    @UI.hidden: true
        GRN.unit,
        GRN.GRNItem,
        GRN.GRNYear,
        GRN.isreversed,
        GRN.refinvno,
//        GRN.ReverseDocument,
        GRN.SupplierInvoice,
        GRN.SupplierInvoiceItem,
        GRN.FiscalYear,
    @Semantics.amount.currencyCode: 'curr'
        GRN.NetAmount,
    @UI.hidden: true    
        GRN.curr,
        GRN.TaxCode,
        GRN.InvPostingDate,
        GRN.TaxRate,
        GRN.TaxCodeName,
        GRN.TransactionType
}

