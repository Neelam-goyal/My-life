@AbapCatalog.viewEnhancementCategory: [#NONE]
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Order Report - Distinct Keys'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity z_dd_customProdRpt
  as select from I_MfgOrderConfirmation      as a
    inner join I_MfgOrderConfMatlDocItem as c on c.MfgOrderConfirmation = a.MfgOrderConfirmation and c.MfgOrderConfirmationGroup = a.MfgOrderConfirmationGroup and c.ManufacturingOrder = a.ManufacturingOrder
    inner join            I_ManufacturingOrder        as b  on a.ManufacturingOrder = b.ManufacturingOrder
    inner join            I_ProductDescription_2      as d  on  c.Material  = d.Product
                                                            and d.Language = 'E'
    inner join            I_WorkCenter                as e  on a.WorkCenterInternalID = e.WorkCenterInternalID
{
  key a.ManufacturingOrder,
  key a.MfgOrderConfirmation,
  key c.MaterialDocumentItem,
  key a.Plant,
  key c.MaterialDocument,
      c.MaterialDocumentYear,
      a.PostingDate,
      a.MfgOrderConfirmationGroup,
      c.Material,
      d.ProductDescription,
      c.Batch,
      c.StorageLocation,
      e.WorkCenter,
      
      c.GoodsMovementType,

      case a.ShiftDefinition
        when '1' then 'Day'
        when '2' then 'Night'
        else ''
      end                          as ShiftDescription,
      
      @UI.hidden: true
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      b.MfgOrderPlannedTotalQty,
      @UI.hidden: true
      b.ProductionUnit,

      
      @UI.hidden: true
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      a.ConfirmationReworkQuantity,

      @UI.hidden: true
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      a.ConfirmationScrapQuantity,
      @UI.hidden: true
      a.OperationUnit,
      
      
      @Semantics.quantity.unitOfMeasure: 'Unit'
      //      a.ConfirmationYieldQuantity,
      a.ConfirmationYieldQuantity +
      a.ConfirmationScrapQuantity +
      a.ConfirmationReworkQuantity as ConfirmationYieldQuantity,
      @UI.hidden: true
      a.OperationUnit as Unit,
      
      
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      c.QuantityInEntryUnit,    
      
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      case when c.GoodsMovementType = '261' then c.QuantityInEntryUnit
           when c.GoodsMovementType = '262' then -c.QuantityInEntryUnit
           when c.GoodsMovementType = '101' then c.QuantityInEntryUnit
           when c.GoodsMovementType = '102' then -c.QuantityInEntryUnit
           when c.GoodsMovementType = '532' then -c.QuantityInEntryUnit
           when c.GoodsMovementType = '531' then c.QuantityInEntryUnit
           else c.QuantityInEntryUnit
      end as AdjustedQtyInEntryUnit,
      @UI.hidden: true
      c.EntryUnit
}
where
      a.IsReversal is initial
  and a.IsReversed is initial
  
