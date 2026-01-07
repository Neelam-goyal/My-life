@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Req. as per BOM for unit Produced Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_MaterialRequirement
  provider contract transactional_query
  as projection on I_ProductionOrderOpComponentTP
{
  key Reservation,
  key ReservationItem,
  key ReservationRecordType,
      MaterialGroup,
      Material,
      Plant,
      ProductionOrder,
      MaterialComponentText,

      BillOfMaterialCategory,
      BillOfMaterialInternalID,
      BillOfMaterialVariant,
      BillOfMaterialItemNodeNumber,
      BillOfMaterialVersion,
      BOMItemInternalChangeCount,
      InheritedBOMItemNode,
      BillOfMaterialItemCategory,
      BillOfMaterialItemNumber,
      BOMExplosionDateID,

      @Semantics.amount.currencyCode: 'Currency'
      ExternalProcessingPrice,

      StorageLocation,
      DebitCreditCode,
      GoodsMovementType,
      GLAccount,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      RequiredQuantity,
      BaseUnit,
      Currency,
      _ProductionOrder.CreationDate as OrderCreationDate

}
