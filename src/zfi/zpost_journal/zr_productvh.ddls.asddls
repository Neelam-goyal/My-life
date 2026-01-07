@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Value Help WIth HSN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PRODUCTVH as  select from I_Product              as Product
    join         I_ProductDescription   as _Description         on _Description.Product = Product.Product
    join         I_ProductPlantIntlTrd  as _PlantProduct        on _PlantProduct.Product = Product.Product
    join         ZI_PlantTable                as _Plant               on _PlantProduct.Plant = _Plant.PlantCode

{
  key Product.Product,
      _Description.ProductDescription,
      _PlantProduct.Plant,
      _PlantProduct.ConsumptionTaxCtrlCode,
      _Plant.CompCode
}
