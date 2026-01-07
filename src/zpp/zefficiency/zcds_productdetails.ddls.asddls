@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for storing product details data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_productDetails as select from zproductdata
{
@EndUserText.label: 'Posting Date'
    key posting_date as PostingDate,
    @EndUserText.label: 'Work Center'
    key work_center as WorkCenter,
    @EndUserText.label: 'Shift'
    key shift as Shift,
    @EndUserText.label: 'Order Type'
    key order_type as OrderType,
    @EndUserText.label: 'Production Order'
    productionorder as Productionorder,
    @EndUserText.label: 'Product'
    product as Product,
    @EndUserText.label: 'Product Description'
    product_description as ProductDescription,
    @EndUserText.label: 'Total Quantity'
    total_quantity as TotalQuantity,
    @EndUserText.label: 'Total Wastage'
    total_wastage as TotalWastage,
    @EndUserText.label: 'Actual Runtime'
    actual_runtime as ActualRuntime,
    @EndUserText.label: 'Plant Runtime'
    plant_runtime as PlantRuntime,
    @EndUserText.label: 'Difference Runtime'
    diffrence_runtime as DiffrenceRuntime,
    @EndUserText.label: 'Start Time'
    start_time as StartTime,
    @EndUserText.label: 'End Time'
    end_time as EndTime
}
