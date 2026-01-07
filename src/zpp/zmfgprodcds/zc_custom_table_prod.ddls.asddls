@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_CUSTOM_TABLE_PROD
  provider contract transactional_query
  as projection on ZR_CUSTOM_TABLE_PROD
{
    key ProductionOrder,
    ConfirmationGroup,
    OrderConfirmation,
    ProductDescription,
    Plant,
    PostingDate,
    Product,
    WorkCenter,
    ShiftDescription,
    OrderQuantity,
    OrderQtyUnit,
    ActualConfirmedQty,
    ActualConfirmedUnit,
    ActualConsumptionQty,
    ActualConsumptionUnit,
    ActualDeliveredUnit,
    NumberOfMaterialDocument,
    MaterialDocumentYear,
    MaterialDocumentItem,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt
}
