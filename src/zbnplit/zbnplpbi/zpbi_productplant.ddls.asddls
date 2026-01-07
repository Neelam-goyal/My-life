@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Plant Mapping'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPBI_ProductPlant
  as select from I_Product              as Product
    join         I_ProductDescription   as _Description         on _Description.Product = Product.Product

    join         I_ProductPlantIntlTrd  as _PlantProduct        on _PlantProduct.Product = Product.Product
    join         I_Plant                as _Plant               on _PlantProduct.Plant = _Plant.Plant
    join         I_ProductSalesDelivery as _SalesDelivery       on  Product.Product                = _SalesDelivery.Product
                                                                and _SalesDelivery.ProductSalesOrg = _Plant.SalesOrganization
    join         I_DistributionChannel  as _DistributionChannel on _SalesDelivery.ProductDistributionChnl = _DistributionChannel.DistributionChannel

    join         I_SalesOrganization    as _SalesOrganization   on _SalesDelivery.ProductSalesOrg = _SalesOrganization.SalesOrganization

{
  key Product.Product,
  key _PlantProduct.Plant,
      Product.ProductOldID,
      _Description.ProductDescription,
      _SalesDelivery.ProductSalesOrg,
      _SalesOrganization.CompanyCode,
      _DistributionChannel.DistributionChannel,
      _PlantProduct.ConsumptionTaxCtrlCode as HSN_SAC
}
