@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PBI Product Master'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZPBI_Product
  as select from    I_Product            as A
    inner join      I_ProductDescription as PD   on  A.Product   = PD.Product
                                                 and PD.Language = $session.system_language
    left outer join ZPBI_ProductHSN      as phsn on A.Product = phsn.Product

{

  key A.Product,
      A.ProductOldID,
      A._Text[1: Language=$session.system_language].ProductName,
      PD.ProductDescription,
      A.ProductType,
      A._ProductTypeName[1: Language=$session.system_language].MaterialTypeName            as ProductTypeName,

      A.ProductGroup,
      A._ProductGroupText_2[1: Language=$session.system_language].ProductGroupText         as ProductGroupName,
      A._ProductGroupText_2[1: Language=$session.system_language].ProductGroupName         as ProductSubGroupName,

      A.ProductCategory,
      A._ProductCategoryText[1: Language=$session.system_language].Name                    as ProductCategoryName,
      
      A.Division,
      A._DivisionText[1: Language=$session.system_language].DivisionName,

      A.Brand,
      A._BrandText[1: Language=$session.system_language].BrandName,
      
      A.YY1_brandcode_PRD                                                                  as ZBrand,

      phsn.HSN,

      cast( A.GrossWeight as abap.dec(13,3))                                               as GrossWeight,
      cast( A.NetWeight as abap.dec(13,3))                                                 as NetWeight,

      A.BaseUnit,
      A._BaseUnitOfMeasureText[1: Language=$session.system_language].UnitOfMeasureLongName as BaseUnitName,

      A.ProductUUID,

      A.ItemCategoryGroup,
      A._ItemCategoryGroupText[1: Language=$session.system_language].ItemCategoryGroupName,

      A.CreationDateTime,
      A.LastChangeDateTime
}
