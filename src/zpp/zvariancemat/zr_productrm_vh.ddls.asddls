@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RM Product List'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ProductRM_VH as 
  select from I_Product as pr
  join I_ProductDescription as pd on pr.Product = pd.Product and pd.LanguageISOCode = 'EN' //and pr.ProductType ='ZFRT' 
  join I_ProductUnitsOfMeasure as puom on pr.Product = puom.Product
{
    key pr.Product,
    pd.ProductDescription,
    ltrim(pr.Product,'0') as ProductAlias,
    pr.ProductOldID,
    puom.BaseUnit
  
}
