@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for Billing Documents with Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@Metadata.allowExtensions: true
@ObjectModel.modelingPattern: #ANALYTICAL_CUBE
@ObjectModel.supportedCapabilities:  [ #ANALYTICAL_PROVIDER ,#CDS_MODELING_DATA_SOURCE]
@Aggregation.allowPrecisionLoss:true

define view entity ZCUBE_BillingDocumentItem
  with parameters
    P_ExchangeRateType : kurst,
    P_DisplayCurrency  : vdm_v_display_currency
  as select from ZR_BillingDocumentItem as item

  association to ZDIM_BillingDocumentType   as _BillingDocumentType on  item.BillingDocumentType = _BillingDocumentType.BillingDocumentType
  association to ZDIM_Customer              as _SoldToParty         on  item.SoldToParty = _SoldToParty.Customer
  association to ZDIM_CustomerWithSalesArea as _BillToParty         on  item.BillToParty       = _BillToParty.Customer
                                                                    and item.SalesOrganization = _BillToParty.SalesOrg
  association to ZDIM_Customer              as _ShipToParty         on  item.ShipToParty = _ShipToParty.Customer
  association to I_FiscalCalendarDate       as _TimeDim             on  _TimeDim.CalendarDate      = item.BillingDocumentDate
                                                                    and _TimeDim.FiscalYearVariant = 'V3'
  association to ZDIM_DistributionChannel   as _DistributionChannel on  item.DistributionChannel = _DistributionChannel.DistributionChannel
  association to ZDIM_Division              as _Division            on  item.Division = _Division.Division
  association to ZDIM_Country               as _Country             on  item.Country = _Country.Country
  association to ZDIM_Company               as _CompanyCode         on  item.CompanyCode = _CompanyCode.CompanyCode
  association to ZDIM_Plant                 as _Plant               on  item.Plant = _Plant.Plant
  association to ZDIM_Product               as _Product             on  item.Product = _Product.Product

  association to ZDIM_ProductType           as _ProductType         on  $projection.producttype = _ProductType.ProductType
  association to ZDIM_Brand                 as _ProductBrand        on  $projection.brand = _ProductBrand.Brandcode





{
  key item.BillingDocument,
  key item.BillingDocumentItem,
      @EndUserText.label: 'Bill No.'
      item._BillingDocument.DocumentReferenceID,

      item.BillingDocumentDate,
      @Semantics.fiscal.yearVariant: true
      _TimeDim.FiscalYearVariant,

      @EndUserText.label: 'Year'
      _TimeDim.FiscalYear                                       as BillingYear,

      @EndUserText.label: 'Quarter'
      _TimeDim.FiscalQuarter                                    as BillingQuarter,

      @Semantics.calendar.yearMonth
      @EndUserText.label: 'YearMonth'
      _TimeDim._CalendarDate.YearMonth                          as BillingYearMonth,

      // Organization
      @ObjectModel.foreignKey.association: '_CompanyCode'
      item.CompanyCode,


      item.SalesOrganization,

      @ObjectModel.foreignKey.association: '_DistributionChannel'
      item.DistributionChannel,

      @EndUserText.label: 'BillToPartyMstDistChannel'
      _BillToParty._DistributionChannel.DistributionChannelName as BillToPartyMstDistChannel,

      @ObjectModel.foreignKey.association: '_Division'
      item.Division,

      @ObjectModel.foreignKey.association: '_Plant'
      item.Plant,

      //Added Analytics fields
      @ObjectModel.foreignKey.association: '_SDDocumentCategory'
      SDDocumentCategory,
      @ObjectModel.foreignKey.association: '_BillingDocumentType'
      BillingDocumentType,

      @ObjectModel.foreignKey.association: '_Country'
      Country,

      @EndUserText.label: 'State'
      _Region._RegionText[1:Language='E'].RegionName,

      @EndUserText.label: 'Region'
      item.Region,
      
      @EndUserText.label: 'Order No.'
      item.SalesDocument,

      @EndUserText.label: 'BillToPartyMstState'
      _BillToParty.State                                        as BillToPartyMstState,

      @EndUserText.label: 'BillToPartyMstSSCode'
      _BillToParty.SSCode,

      @EndUserText.label: 'GSTIN'
      _SoldToParty.GSTIN                                        as SoldToPartyGSTIN,

      @EndUserText.label: 'City'
      _SoldToParty.City,

      @ObjectModel.foreignKey.association: '_SalesDistrict'
      SalesDistrict,

      //sales
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_Customer_VH',
                     element: 'Customer' }
        }]
      @ObjectModel.foreignKey.association: '_SoldToParty'
      SoldToParty,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_Customer_VH',
                     element: 'Customer' }
        }]
      @ObjectModel.foreignKey.association: '_BillToParty'
      BillToParty,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_Customer_VH',
                     element: 'Customer' }
        }]
      @ObjectModel.foreignKey.association: '_ShipToParty'
      ShipToParty,


      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_ProductStdVH',
                     element: 'Product' }
        }]
      @ObjectModel.foreignKey.association: '_Product'
      item.Product,

      @ObjectModel.foreignKey.association: '_ProductType'
      _Product.ProductType,

      //      @ObjectModel.foreignKey.association: '_ProductGroup'
      //      @EndUserText.label: 'ProductGroupCode'
      //      item.ProductGroup,

      @EndUserText.label: 'ProductGroup'
      _Product.ProductGroupName,

      @EndUserText.label: 'ProductSubGroup'
      _Product.ProductSubGroupName,

      _Product.ProductCategory,
      @ObjectModel.foreignKey.association: '_ProductBrand'
      _Product.Brand,

      item.BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      @Aggregation.default: #SUM
      @EndUserText.label: 'BillingQuantity'
      item.BillingQuantity,

      @EndUserText.label: 'Item Weight(KG)'
      cast( 'KG' as abap.unit(3) )                              as ItemWeightUnit,

      @Aggregation.default: #SUM
      @Semantics.quantity.unitOfMeasure: 'ItemWeightUnit'
      @EndUserText.label: 'Item Gross Weight'
      unit_conversion( quantity => item.ItemGrossWeight,
      source_unit => item.ItemWeightUnit,
      target_unit =>  cast( 'KG' as abap.unit(3) ),
      error_handling => 'SET_TO_NULL' )                         as ItemGrossWeight,

      @Semantics.quantity.unitOfMeasure: 'ItemWeightUnit'
      @Aggregation.default: #SUM
      @EndUserText.label: 'Item Net Weight'
      unit_conversion( quantity => item.ItemNetWeight,
      source_unit => item.ItemWeightUnit,
      target_unit =>  cast( 'KG' as abap.unit(3) ),
      error_handling => 'SET_TO_NULL' )                         as ItemNetWeight,


      $parameters.P_DisplayCurrency                             as Currency,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Tax Amount'
      cast ( currency_conversion(
        amount => item.TaxAmount,
        source_currency => TransactionCurrency,
        target_currency => $parameters.P_DisplayCurrency,
        exchange_rate_date => BillingDocumentDate,
        exchange_rate_type => $parameters.P_ExchangeRateType,
        error_handling => 'FAIL_ON_ERROR',
        round => 'true',
        decimal_shift => 'true',
        decimal_shift_back => 'true'
      ) as abap.curr(19,2) )                                    as TaxAmountInINR,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Freight Amount'
      cast ( currency_conversion(
        amount => item.FreightAmount,
        source_currency => TransactionCurrency,
        target_currency => $parameters.P_DisplayCurrency,
        exchange_rate_date => BillingDocumentDate,
        exchange_rate_type => $parameters.P_ExchangeRateType,
        error_handling => 'FAIL_ON_ERROR',
        round => 'true',
        decimal_shift => 'true',
        decimal_shift_back => 'true'
      ) as abap.curr(19,2) )                                    as FreightAmountInINR,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Net Amount'
      cast ( currency_conversion(
        amount => item.NetAmount,
        source_currency => TransactionCurrency,
        target_currency => $parameters.P_DisplayCurrency,
        exchange_rate_date => BillingDocumentDate,
        exchange_rate_type => $parameters.P_ExchangeRateType,
        error_handling => 'FAIL_ON_ERROR',
        round => 'true',
        decimal_shift => 'true',
        decimal_shift_back => 'true'
      ) as abap.curr(19,2) )                                    as NetAmountInINR,


      _SDDocumentCategory,
      _BillingDocumentType,
      _SoldToParty,
      _ShipToParty,
      _BillToParty,
      _CompanyCode,
      //      _SalesOrganization,
      _DistributionChannel,
      _TimeDim,
      _Division,
      _Plant,
      _Region,
      //      _SalesOffice,
      //      _CustomerPriceGroup,
      //      _CustomerGroup,

      _Country,
      //      _CityCode,

      _ProductBrand,
      _ProductType,
      _SalesDistrict,
      _Product
}
