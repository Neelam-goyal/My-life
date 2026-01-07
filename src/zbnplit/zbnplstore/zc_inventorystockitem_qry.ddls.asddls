@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Inventory Stock Report'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_INVENTORYSTOCKITEM_QRY
  provider contract analytical_query
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompany    : bukrs,

    @AnalyticsDetails.query.variableSequence: 2
    @Consumption.semanticObject: 'ZDIM_Plant'
    @EndUserText.label: 'Plant'
    @Consumption.valueHelpDefinition: [{entity.name: 'ZDIM_Plant', entity.element: 'Plant',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompany', element: 'PlantCompany'}]}]
    pPrdnPlant  : werks_d,

    @AnalyticsDetails.query.variableSequence: 4
    @EndUserText.label: 'From Date'
    @Consumption.derivation: { lookupEntity: 'I_CalendarDate',
    resultElement: 'FirstDayofMonthDate',
    binding: [
    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'p_date_to' } ]
    }
    p_date_from : datum,

    @AnalyticsDetails.query.variableSequence: 5
    @EndUserText.label: 'To Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    p_date_to   : datum
  as projection on ZCUBE_INVENTORYSTOCKITEM(
                   pCompany:$parameters.pCompany,
                   pPrdnPlant: $parameters.pPrdnPlant ,
                   p_date_from: $parameters.p_date_from,
                   p_date_to:$parameters.p_date_to  ) as item
{
  @AnalyticsDetails.query: {
        axis: #FREE,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.CompanyCode,

  @AnalyticsDetails.query: {
        axis: #FREE,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.Plant,

  @AnalyticsDetails.query: {
        axis: #FREE,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.StorageLocation,

  @Semantics.text: true
  item.StorageLocationName,

  @AnalyticsDetails.query: {
        axis: #ROWS,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.ProductType,

  @AnalyticsDetails.query: {
        axis: #ROWS,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.ProductGroupName,

  @AnalyticsDetails.query: {
        axis: #FREE,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.ProductSubGroupName,

  @AnalyticsDetails.query: {
        axis: #FREE,
        totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  item.CostCenter,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  item.WBSElementInternalID,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  item.Material,

  @AnalyticsDetails.query: {
        axis: #COLUMNS,
        totals: #SHOW
    }
  @UI.textArrangement: #TEXT_FIRST
  item.TransType,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  item.GoodsMovementType,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE
  }
  item.DebitCreditCode,

  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals: 3
  }
  item.QuantityInBaseUnit,


  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    sortDirection: #ASC,
    decimals: 2,
    variableSequence: 160
    }
  @UI.hidden: true
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  item.TotalGoodsMvtAmtInCCCrcy,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @EndUserText.label: 'UOM'
  item.MaterialBaseUnit,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @EndUserText.label: 'Currency'
  item.CompanyCodeCurrency,
  _CompanyCode,
  _Plant,
  _Product,
  _ProductType,
  _StorageLocationText,
  _GoodsMovementType

}
