@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Document Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_InvoicingDocItem
  as select from I_BillingDocumentItem as Item
{
      //Key
  key Item.BillingDocument,
  key Item.BillingDocumentItem,

      //Category
      _BillingDocument.SDDocumentCategory, -- VBTYP from VBRK
      _BillingDocument.BillingDocumentCategory, -- FKTYP from VBRK

      //Organization
      _BillingDocument.SalesOrganization, -- VKORG from VBRK

      //Invoicing
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      Item.BillingQuantity, -- FKIMG from VBRP

      Item.BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Item.BillingQuantityInBaseUnit, -- FKLMG from VBRP
      Item.BaseUnit,
      _BillingDocument.BillingDocumentIsCancelled, -- FKSTO from VBRK
      _BillingDocument.CancelledBillingDocument, -- SFAKN from VBRK
      --CE1911, JB 16.09.2019
      _BillingDocument.BillingDocumentIsTemporary, -- DRAFT from VBRK
      
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Item.NetAmount,
      Item.TransactionCurrency,
      
      //Reference
      Item.SalesDocument, -- AUBEL from VBRP
      Item.SalesDocumentItem -- AUPOS from VBRP
}

where
  (
    (
      (
            _BillingDocument.BillingDocumentCategory    =  'A'
      ) -- order related invocing
      or(
            _BillingDocument.BillingDocumentCategory    =  'L'
      ) -- delivery related invoicing
      or(
            _BillingDocument.BillingDocumentCategory    =  'I'
        and Item.ValueChainCategory                     =  'ICSL'
      )
    ) -- BK 27.08.2021: Include Intercompany Invoice for advanced Intercopnay Processing
    and(
            _BillingDocument.BillingDocumentIsCancelled != 'X'
    ) -- excluding cancelled invoice documents
    and(
            _BillingDocument.CancelledBillingDocument   =  ' '
    ) -- excluding cancellation documents
    and(
            _BillingDocument.SDDocumentCategory         != 'U'
    ) -- excluding pro forma invoices

    --CE1911, JB 19.09.2019
    and(
            _BillingDocument.BillingDocumentIsTemporary =  ' '
    ) -- excluding temporary (=draft) billing docs
  )
