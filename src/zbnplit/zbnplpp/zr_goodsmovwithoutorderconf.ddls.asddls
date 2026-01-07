@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Goods Mov. Entries Without Order Conf.'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GoodsMovWithoutOrderConf
  as select from I_MfgOrderDocdGoodsMovement
{
  ManufacturingOrder,
  GoodsMovement     as MaterialDocument,
  GoodsMovementYear as MaterialDocumentYear
}
except select from I_MfgOrderConfirmation
{
  ManufacturingOrder,
  MaterialDocument,
  MaterialDocumentYear
}
