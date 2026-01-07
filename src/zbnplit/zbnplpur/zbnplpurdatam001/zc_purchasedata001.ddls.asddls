@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for Customized Purchase Data Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
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
define view entity ZC_PurchaseData001
  with parameters
    @EndUserText.label: 'Company'
    pCompany  : bukrs,
    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    pFromDate : datum,
    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    pToDate   : datum
  as select from ZR_PurchaseData001
  association [1]    to I_CompanyCode        as _CompanyCode   on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_Supplier           as _Supplier      on  $projection.Supplier = _Supplier.Supplier
  association [0..1] to I_PurchaseOrderAPI01 as _PurchaseOrder on  $projection.PurchaseOrder = _PurchaseOrder.PurchaseOrder

  association [0..1] to ZDIM_GLAccount       as _GLAccount     on  $projection.InventoryGLHead = _GLAccount.GLAccount
  association        to I_FiscalCalendarDate as _TimeDim       on  _TimeDim.CalendarDate      = $projection.MIRODate
                                                               and _TimeDim.FiscalYearVariant = 'V3'
{
  @Semantics.fiscal.yearVariant: true
  _TimeDim.FiscalYearVariant,

  @EndUserText.label: 'Year'
  _TimeDim.FiscalYear              as FinYear,

  @EndUserText.label: 'Quarter'
  _TimeDim.FiscalQuarter           as Quarter,

  @Semantics.calendar.yearMonth
  @EndUserText.label: 'YearMonth'
  _TimeDim._CalendarDate.YearMonth as YearMonth,

  @ObjectModel.foreignKey.association: '_CompanyCode'
  CompanyCode,
  
  @ObjectModel.foreignKey.association: '_PurchaseOrder'
  @EndUserText.label: 'Purchase Order'
  PurchaseOrder,
  //  PurchaseOrderItem,
  @EndUserText.label: 'MIRO Entry No.'
  MIROEntryNo,
  @EndUserText.label: 'MIRO FYear'
  MiroEntryFiscalYear,
  @EndUserText.label: 'MIRO Date'
  MIRODate,
  @EndUserText.label: 'MIRO Journal'
  MIROJournalEntry,
  @EndUserText.label: 'MIRO Journal Type'
  MIROJournalEntryType,
  @EndUserText.label: 'MIRO Journal FYear'
  MIROJournalEntryFiscalYear,
  @EndUserText.label: 'Supplier Invoice Date'
  SupplierInvoiceDt,
  @EndUserText.label: 'Supplier Invoice No.'
  SupplierInvoiceNo,
  @ObjectModel.foreignKey.association: '_Supplier'
  @EndUserText.label: 'Supplier'
  Supplier,

  @EndUserText.label: 'Currency'
  DocumentCurrency,

  @EndUserText.label: 'Invoice Gross Amount'
  concat(cast(curr_to_decfloat_amount(InvoiceGrossAmount) as abap.char(15)),' ') as InvoiceGrossAmount,
  
  @EndUserText.label: 'Business Place'
  BusinessPlace,
  @EndUserText.label: '_InvItemSr'
  MIROItemSrNo,
  @EndUserText.label: 'Plant'
  Plant,
  @EndUserText.label: 'Material Code'
  Material,
  @EndUserText.label: 'Material'
  ProductName,
  @EndUserText.label: 'Material Type'
  ProductType,
  @EndUserText.label: 'Material Group'
  ProductGroupName,
  @EndUserText.label: 'Material Sub-Group'
  ProductSubGroupName,

  @EndUserText.label: 'Inventory G/L Head'
  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_GLAccountStdVH',
               element: 'GLAccount' }
  }]
  @ObjectModel.foreignKey.association: '_GLAccount'
  InventoryGLHead,
  @EndUserText.label: 'UOM'
  PurchaseOrderQuantityUnit,
  @EndUserText.label: 'Quantity'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  @Aggregation.default: #SUM
  QuantityInPurchaseOrderUnit,

  //    @EndUserText.label: 'Rate-'
  //  PurchaseOrderPriceUnit,
  //  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderPriceUnit'
  //  QtyInPurchaseOrderPriceUnit,
  @EndUserText.label: 'Amount'
  @Semantics.amount.currencyCode: 'DocumentCurrency'
  @Aggregation.default: #SUM
  SupplierInvoiceItemAmount,
  @EndUserText.label: 'Item-TaxCode'
  TaxCode,
  @EndUserText.label: 'Item-Tax'
  TaxDesc,
  @EndUserText.label: 'Item-Tax Rate'
  concat(cast(get_numeric_value(TaxRate) as abap.char(15)),' ') as TaxRate,
  _GLAccount,
  _TimeDim,
  _CompanyCode,
  _PurchaseOrder,
  _Supplier
}
where
      CompanyCode = $parameters.pCompany
  and MIRODate    between $parameters.pFromDate and $parameters.pToDate
