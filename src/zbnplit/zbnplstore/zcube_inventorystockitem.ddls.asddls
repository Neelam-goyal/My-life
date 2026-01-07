@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube Inventory Stock Line Item'
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

define view entity ZCUBE_INVENTORYSTOCKITEM
  with parameters
    @EndUserText.label: 'Company'
    pCompany    : bukrs,

    @EndUserText.label: 'Plant'
    pPrdnPlant  : werks_d,

    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate
  as select from ZC_INVENTORYSTOCKITEM(
                 pCompany:$parameters.pCompany,
                 p_date_from:$parameters.p_date_from,
                 p_date_to:$parameters.p_date_to,
                 pPrdnPlant:$parameters.pPrdnPlant
                 ) as item
  association [1..1] to ZDIM_Company           as _CompanyCode         on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [1..1] to ZDIM_Plant             as _Plant               on  $projection.Plant = _Plant.Plant
  association [1..1] to ZDIM_Product           as _Product             on  $projection.Material = _Product.Product
  association [1..1] to ZDIM_ProductType       as _ProductType         on  $projection.producttype = _ProductType.ProductType
  association        to ZDIM_CostCenter        as _CostCenter          on  $projection.CostCenter = _CostCenter.CostCenter
  association [1..1] to I_StorageLocation      as _StoreLoc            on  $projection.Plant           = _StoreLoc.Plant
                                                                       and $projection.StorageLocation = _StoreLoc.StorageLocation
  association [1..1] to ZDIM_StorageLocation   as _StorageLocationText on  $projection.Plant           = _StorageLocationText.Plant
                                                                       and $projection.StorageLocation = _StorageLocationText.StorageLocation
  association [1..1] to ZDIM_GoodsMovementType as _GoodsMovementType   on  $projection.GoodsMovementType = _GoodsMovementType.GoodsMovementType
{
  @ObjectModel.foreignKey.association: '_CompanyCode'
  @EndUserText.label: 'Company'
  item.CompanyCode,

  @ObjectModel.foreignKey.association: '_Plant'
  @EndUserText.label: 'Production Plant'
  item.Plant,

  @EndUserText.label: 'Storage Location'
  @ObjectModel.text.element: [ 'StorageLocationName' ]
  @ObjectModel.foreignKey.association: '_StoreLoc'
  item.StorageLocation,

  @Semantics.text: true
  _StorageLocationText.StorageLocationName,

  @ObjectModel.foreignKey.association: '_CostCenter'
  @EndUserText.label: 'Cost Center'
  item.CostCenter,

  item.WBSElementInternalID,

  @EndUserText.label: 'Product Group'
  _Product.ProductGroupName,

  @EndUserText.label: 'Product Sub Group'
  _Product.ProductSubGroupName,

  @ObjectModel.foreignKey.association: '_ProductType'
  @EndUserText.label: 'Product Type'
  _Product.ProductType,

  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_ProductStdVH',
               element: 'Product' }
  }]
  @ObjectModel.foreignKey.association: '_Product'
  @EndUserText.label: 'Product'
  @Consumption.semanticObject: 'Material'
  item.Material,

  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'ZDIM_GoodsMovementType',
               element: 'GoodsMovementType' }
  }]
  @ObjectModel.foreignKey.association: '_GoodsMovementType'
  @EndUserText.label: 'Movement Type'
  item.GoodsMovementType,

  @EndUserText.label: 'Debit/Credit'
  item.DebitCreditCode,

  @EndUserText.label: 'Trans Type'
  item.TransType,

  @EndUserText.label: 'UOM'
  item.MaterialBaseUnit,

  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  @EndUserText.label: 'Quantity'
  @Aggregation.default: #SUM
  item.QuantityInBaseUnit,

  @EndUserText.label: 'Currency'
  item.CompanyCodeCurrency,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  @Aggregation.default: #SUM
  @EndUserText.label: 'Amount'
  item.TotalGoodsMvtAmtInCCCrcy,

  _CompanyCode,
  _Plant,
  _Product,
  _ProductType,
  _StorageLocationText,
  _GoodsMovementType,
  _StoreLoc,
  _CostCenter
}
