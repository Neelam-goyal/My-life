@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Resource CDS for Stock Log Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_CURRENTSTOCKLOG as select from zcurrentstocklog
{
    key plant as Plant,
    key product as Product,
    key storage_location as StorageLocation,
    key batch as Batch,
    key inserted_date as InsertedDate,
    key inserted_time as InsertedTime,
    plant_name as PlantName,
    product_type as ProductType,
    product_name as ProductName,
    material_base_unit as MaterialBaseUnit,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
    matlwrhsstkqtyinmatlbaseunit as Matlwrhsstkqtyinmatlbaseunit,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.localInstanceLastChangedBy: true
    local_last_changed_by as LocalLastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt
}
