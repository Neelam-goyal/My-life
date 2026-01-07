@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Product'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Product'
define view entity ZDIM_Product
  as select from I_Product as A
    left outer join ZDIM_ProductGroup          as _ProductGroup        on  A.ProductGroup = _ProductGroup.ProductGroup
{
      @EndUserText.quickInfo: 'Product'

      @ObjectModel.text.element: [ 'ProductName' ]
  key A.Product,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #MEDIUM
      A._Text[1: Language=$session.system_language].ProductName,

      @UI.hidden: true
      A.ProductType,
      
      @UI.hidden: true
      A.ProductGroup,
      
      @EndUserText.label: 'ProductGroup'
      _ProductGroup.ProductGroupName,

      @EndUserText.label: 'ProductSubGroup'
      _ProductGroup.ProductSubGroupName,
      
      @UI.hidden: true
      A.ProductCategory,
      @UI.hidden: true
      A.YY1_brandcode_PRD                    as Brand,
      @EndUserText.label: 'GrossWeight'
      cast( A.GrossWeight as abap.dec(13,3)) as GrossWeight,
      @EndUserText.label: 'NetWeight'
      cast( A.NetWeight as abap.dec(13,3))   as NetWeight,
      A.BaseUnit
}
