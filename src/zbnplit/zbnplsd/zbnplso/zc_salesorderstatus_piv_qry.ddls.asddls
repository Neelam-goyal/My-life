@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Sales Order Status Query'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]

define transient view entity ZC_SalesOrderStatus_Piv_Qry
  provider contract analytical_query
  with parameters

    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Consumption.derivation: { lookupEntity: 'I_CalendarDate',
    resultElement: 'FirstDayofMonthDate',
    binding: [
    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'p_date_to' } ]
    }
    p_date_from : datum,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    p_date_to   : datum,

    @AnalyticsDetails.query.variableSequence: 3
    @EndUserText.label: 'Sales Org.'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_SalesOrganization', entity.element: 'SalesOrganization'  }]
    pSalesOrg   : vkorg
  as projection on ZCUBE_SalesOrderStatus
                   (p_date_from:$parameters.p_date_from,
                   p_date_to:$parameters.p_date_to,
                   pSalesOrg:$parameters.pSalesOrg) as ordr
{
  //  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}

  @UI.textArrangement: #TEXT_FIRST
  SalesOrganization,

  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}
  @UI.textArrangement: #TEXT_FIRST
  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #SHOW
  DistributionChannel,

  SalesDocument,
  SalesDocumentDate,

  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}
  @UI.textArrangement: #TEXT_FIRST
  SoldToParty,

  SoldToPartyMstDistChannel,
  SoldToPartyMstCity,
  SoldToPartyMstState,
  SoldToPartyMstDivision,

  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}
  @UI.textArrangement: #TEXT_FIRST
  Product,

  @UI.textArrangement: #TEXT_ONLY
  ProductGroup,

  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  OrderQuantity,

  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  @UI.hidden: true
  ShippedQuantityInOrderQtyUnit,

  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  InvoicedQuantityInOrderQtyUnit,

  @EndUserText.label: 'Diff Qty.'
  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  @Aggregation.default: #FORMULA
  OrderQuantity - InvoicedQuantityInOrderQtyUnit                                    as DiffQty,

  @EndUserText.label: '_Unit'
  @UI.hidden: true
  OrderQuantityUnit,


  @EndUserText.label: 'Order Amount'
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  @UI.hidden: true
  IncomingSalesOrdersNetAmount,

  @EndUserText.label: 'Invoice Amount'
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  @UI.hidden: true
  InvoicedNetAmountInTranCurr,

  @EndUserText.label: 'Diff Amt.'
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  @Aggregation.default: #FORMULA
  @UI.hidden: true
  curr_to_decfloat_amount(IncomingSalesOrdersNetAmount)-$projection.invoicednetamountintrancurr as DiffAmt,

  @EndUserText.label: '_Currency'
  @UI.hidden: true
  TransactionCurrency,

  ShippingStatus,

  @UI.textArrangement: #TEXT_ONLY
  InvoicingStatus,
  @UI.textArrangement: #TEXT_ONLY
  OverallDelivConfStatus,
  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}
  @UI.textArrangement: #TEXT_ONLY
  OverallTotalDeliveryStatus,
  @UI.textArrangement: #TEXT_ONLY
  OverallDeliveryStatus,
  @UI.textArrangement: #TEXT_ONLY
  OverallSDDocumentRejectionSts,
  @UI.textArrangement: #TEXT_ONLY
  SDDocumentRejectionStatus

}
