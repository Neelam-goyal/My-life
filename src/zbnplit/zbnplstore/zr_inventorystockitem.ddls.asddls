@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Stock Line Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZR_INVENTORYSTOCKITEM
  as select from I_MaterialDocumentItem_2 as Item
    inner join   zdt_user_item            as _plantAccess on  _plantAccess.plant  = Item.Plant
                                                          and _plantAccess.userid = $session.user

{
  key Item.CompanyCode,
  key Item.Plant,
  key Item.StorageLocation,
  key Item.PostingDate,
  key Item.Material,
  key Item.GoodsMovementType,
      Item.CostCenter,
      Item.WBSElementInternalID,
      Item.DebitCreditCode,
      Item.MaterialBaseUnit,
      
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum((case Item.DebitCreditCode when 'H' then -Item.QuantityInBaseUnit else Item.QuantityInBaseUnit end ))             as QuantityInBaseUnit,
      Item.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum((case Item.DebitCreditCode when 'H' then -Item.TotalGoodsMvtAmtInCCCrcy else Item.TotalGoodsMvtAmtInCCCrcy end) ) as TotalGoodsMvtAmtInCCCrcy
}
group by
  Item.CompanyCode,
  Item.Plant,
  Item.StorageLocation,
  Item.PostingDate,
  Item.Material,
  Item.GoodsMovementType,
  Item.CostCenter,
  Item.WBSElementInternalID,
  Item.DebitCreditCode,
  Item.MaterialBaseUnit,
  Item.CompanyCodeCurrency
