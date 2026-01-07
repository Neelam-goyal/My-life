@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Documnet CDS Customized'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BillingDocumentItem
  as select from    I_BillingDocumentItem         as item
    inner join      ZR_USER_CMPY_ACCESS           as _cmpAccess on  _cmpAccess.CompCode = item.CompanyCode
                                                                and _cmpAccess.userid   = $session.user
    left outer join ZR_BillingDocumentItemFreight as frt        on  item.BillingDocument     = frt.BillingDocument
                                                                and item.BillingDocumentItem = frt.BillingDocumentItem

{
  key item.BillingDocument,
  key item.BillingDocumentItem,
      item.SalesDocumentItemCategory,
      item.SalesDocumentItemType,
      item.ReturnItemProcessingType,
      item.CreatedByUser,
      item.CreationDate,
      item.CreationTime,
      item.ReferenceLogicalSystem,
      item.OrganizationDivision,
      item.Division,
      item.SalesOffice,

      item.Product,
      item.OriginallyRequestedMaterial,
      item.InternationalArticleNumber,
      item.PricingReferenceMaterial,
      item.Batch,
      item.ProductHierarchyNode,

      item.ProductGroup,

      item.ProductConfiguration,
      item.MaterialCommissionGroup,
      item.Plant,
      item.StorageLocation,
      item.ReplacementPartType,
      item.MaterialGroupHierarchy1,
      item.MaterialGroupHierarchy2,
      item.PlantRegion,
      item.PlantCounty,
      item.PlantCity,
      item.TransitPlant,
      item.ValueChainCategory,
      item.BOMExplosion,
      item.MaterialDeterminationType,
      item.SoldProduct,
      item.BillingDocumentItemText,
      item.ServicesRenderedDate,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.BillingQuantity * -1 else item.BillingQuantity end  )                     as BillingQuantity,
      item.BillingQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.BillingQuantityInBaseUnit * -1 else item.BillingQuantityInBaseUnit end  ) as BillingQuantityInBaseUnit,
      item.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      item.MRPRequiredQuantityInBaseUnit,
      item.BillingToBaseQuantityDnmntr,
      item.BillingToBaseQuantityNmrtr,

      @Semantics.quantity.unitOfMeasure: 'ItemWeightUnit'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.ItemGrossWeight * -1 else item.ItemGrossWeight end  )                     as ItemGrossWeight,

      @Semantics.quantity.unitOfMeasure: 'ItemWeightUnit'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.ItemNetWeight * -1 else item.ItemNetWeight end  )                         as ItemNetWeight,

      item.ItemWeightUnit,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then frt.FreightValue * -1 else frt.FreightValue end  )                             as FreightAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.NetAmount * -1 else item.NetAmount end  )                                 as NetAmount,

      item.TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.GrossAmount * -1 else item.GrossAmount end  )                             as GrossAmount,

      item.PricingDate,
      item.PriceDetnExchangeRate,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      item.PricingScaleQuantityInBaseUnit,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.TaxAmount * -1 else item.TaxAmount end  )                                 as TaxAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( case when item.BillingDocumentType = 'S1' or item.BillingDocumentType = 'CBRE'
      then item.CostAmount * -1 else item.CostAmount end  )                               as CostAmount,




      item.BusinessArea,
      item.ProfitCenter,
      item.OrderID,
      item.WBSElement,
      item.WBSElementInternalID,
      item.ProviderContract,
      item.ProviderContractItem,
      item.BillingPerformancePeriodStrDte,
      item.BillingPeriodOfPerfStartDate,
      item.BillingPerformancePeriodEndDte,
      item.BillingPeriodOfPerfEndDate,
      item.ControllingArea,
      //      ProfitabilitySegment,
      item.ProfitabilitySegment_2,
      item.CostCenter,
      item.OriginSDDocument,
      item.OriginSDDocumentItem,
      item.PriceDetnExchangeRateDate,
      item.MatlAccountAssignmentGroup,
      item.ReferenceSDDocument,
      item.ReferenceSDDocumentItem,
      item.ReferenceSDDocumentCategory,
      item.SalesDocument,
      item.SalesDocumentItem,
      item.SalesSDDocumentCategory,
      item.HigherLevelItem,
      item.HigherLvlItmOfBatSpltItm,
      item.BillingDocumentItemInPartSgmt,
      item.ExternalReferenceDocument,
      item.ExternalReferenceDocumentItem,
      item.BillingDocExtReferenceDocItem,
      item.PrelimBillingDocument,
      item.PrelimBillingDocumentItem,
      item.SalesGroup,

      item.SDDocumentReason,
      item.RetailPromotion,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      item.RebateBasisAmount,
      item.VolumeRebateGroup,
      item.ItemIsRelevantForCredit,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      item.CreditRelatedPrice,
      item.SalesDeal,

      item.SDDocumentCategory,
      item.BillingDocumentType,

      item.SalesOrganization,
      item.DistributionChannel,
      item.CustomerPriceGroup,
      item.CustomerGroup,
      item.Country,
      //      @ObjectModel.text.element: ['RegionName']
      item.Region,


      item.CityCode,
      item.SalesDistrict,

      item.BillingDocumentDate,
      item.CompanyCode,
      item.County,
      item.BillingDocumentCategory,

      item.SoldToParty,
      item.PayerParty,
      item.ShipToParty,
      item.BillToParty,
      item.SalesEmployee,
      item.ResponsibleEmployee,

      item.YY1_scheme_code_bd_BDI,
      item.YY1_SchemeGroupCode_bd_BDI,

      item._BaseUnit,

      item._BillingDocument,
      item._BillingDocumentCategory,
      item._BillingDocumentType,

      item._BillingQuantityUnit,
      item._BillToParty,

      item._BusinessArea,
      item._BusinessAreaText,

      item._CityCode,
      item._CompanyCode,
      item._ControllingArea,
      item._CostCenter,
      item._CostCenter_2,
      item._Country,

      item._County,
      item._CreatedByUser,
      item._CustomerGroup,
      item._CustomerPriceGroup,

      item._DistributionChannel,
      item._Division,
      item._HigherLevelItem,
      item._HigherLvlItmOfBatSpltItm,

      item._ItemWeightUnit,

      item._MaterialCommissionGroup,



      item._MatlAccountAssignmentGroup,
      item._OrganizationDivision,

      item._Partner,
      item._PayerParty,
      item._Plant,

      item._PrelimBillingDocument,
      item._PrelimBillingDocumentItem,
      item._PricingElement,
      item._PricingReferenceMaterial,
      item._PricingReferenceMaterialText,

      item._Product,
      item._ProductGroup,
      item._ProductHierarchyNode,
      item._ProductText,
      item._ProfitCenter,
      item._ProviderContract,
      item._ProviderContractItem,
      item._ReferenceBillingDocItemBasic,
      item._ReferenceDeliveryDocumentItem,
      item._ReferenceLogicalSystem,
      item._ReferenceSalesDocumentItem,
      item._ReferenceSDDocumentCategory,
      item._Region,

      item._ResponsibleEmployee,
      item._RetailPromotion,
      item._SalesDeal,
      item._SalesDistrict,
      item._SalesDocument,
      item._SalesDocumentItem,
      item._SalesDocumentItemCategory,
      item._SalesDocumentItemType,
      item._SalesEmployee,
      item._SalesGroup,
      item._SalesOffice,

      item._SalesOrganization,
      item._SalesSDDocumentCategory,
      item._SDDocumentCategory,
      item._SDDocumentReason,

      item._ShipToParty,
      item._SoldProduct,
      item._SoldProductText,
      item._SoldToParty,

      item._StorageLocation,

      item._TransactionCurrency,
      item._TransitPlant,
      item._ValueChainCategory,
      item._WBSElement,
      item._WBSElementBasicData,
      item._WBSElementText
}
where
  item.BillingDocumentType <> 'F8' // Proforma Invoice Excluded
