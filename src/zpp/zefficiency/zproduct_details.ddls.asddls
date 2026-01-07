@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Details Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zproduct_details as select from zdd_customProdRpt as a

left outer join zprod_details as b on 
    a.WorkCenter = b.work_center and 
    a.PostingDate = b.posting_date and 
    a.ShiftDescription = b.shift and
    a.ManufacturingOrder = b.mfgorder
left outer join I_ManufacturingOrderOperation as c on 
    a.ManufacturingOrder = c.ManufacturingOrder
left outer join ztable_plant as d on a.Plant = d.plant_code
 
{
    @EndUserText.label: 'Work Center'
    key a.WorkCenter,
    @EndUserText.label: 'Posting Date'
    key a.PostingDate,

    @EndUserText.label: 'Shift'
  key cast(
      case
        when a.ShiftDescription = 'Night' then 'NIGHT'
//       when a.ShiftDescription = 'Day' then 'DAY'
        else 'DAY'                   
      end as abap.char(5)
    ) as ShiftDescription,

    @EndUserText.label: 'Plant'
    key a.Plant,
    
    @EndUserText.label: 'Confirmed Yield Quantity'
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    key sum(a.ConfirmationYieldQuantity) as ConfirmationYieldQuantity,
//    key a.TotalQty_ZROH as TotalQty_ZROH,

    @EndUserText.label: 'Total Wastage'
    @Semantics.quantity.unitOfMeasure: 'BaseUnit1'
    key sum(a.TotalQty_ZWST) as TotalQty_ZWST,
//       a.TotalQty_ZWST as TotalQty_ZWST,

    @EndUserText.label: 'Order'
//    key a.ManufacturingOrder,
cast( cast(a.ManufacturingOrder as abap.int8) as abap.char(20) ) as ManufacturingOrder,

    @EndUserText.label: 'Standard Runtime (MIN)'
//        case 
//          when b.actual_runtime is not null 
//          then cast(b.actual_runtime as abap.dec(15,2))
//          else
           sum( cast(((cast(720 as abap.dec(15,3)) / cast(c.OperationReferenceQuantity as abap.dec(15,3))) * cast(a.ConfirmationYieldQuantity as abap.dec(15,3))) as abap.dec(15,2))) as CalculatedActualRuntime,
//        end as CalculatedActualRuntime,

   @EndUserText.label: 'Actual Runtime (MIN)'
     b.manual_actual_runtime as ChangeActualRuntime,
        
@EndUserText.label: 'Difference Runtime (MIN)'
case 
  when b.manual_actual_runtime is null 
       then cast(720 as abap.dec(15,2)) - sum( cast(((cast(720 as abap.dec(15,3)) / cast(c.OperationReferenceQuantity as abap.dec(15,3))) * cast(a.ConfirmationYieldQuantity as abap.dec(15,3))) as abap.dec(15,2)))
  else 
       cast(720 as abap.dec(15,2)) - cast(b.manual_actual_runtime as abap.dec(15,2))
end as difference_runtime,
    
    @EndUserText.label: 'Product Description'
    a.ProductDescription,
    
//    d.IsReversal,
//    d.IsReversed,
  
    @EndUserText.label: 'Product'
    a.Product,

    @EndUserText.label: 'Operation Unit'
    c.OperationUnit,
    @EndUserText.label: 'Base Unit'
    a.BaseUnit,
    
    a.BaseUnit1,

    @EndUserText.label: 'Operation Reference Quantity'
    @Semantics.quantity.unitOfMeasure: 'OperationUnit'
    sum(c.OperationReferenceQuantity) as OperationReferenceQuantity,

    @EndUserText.label: 'Quantity in 1(MIN)'
    @Semantics.quantity.unitOfMeasure: 'OperationUnit'
    cast((cast(720 as abap.dec(15,3)) / cast(c.OperationReferenceQuantity as abap.dec(15,3))) as abap.dec(15,3)) as OperationReferenceQuantityDiv,
    

    

    @EndUserText.label: 'Plant Runtime(MIN)'
    (cast(720 as abap.int4)) as plant_runtime,

    b.start_time as start_time,
    b.end_time as end_time,
    d.comp_code as CompanyCode
}
group by
    a.WorkCenter,
    a.PostingDate,
    a.ShiftDescription,
    a.Plant,
    a.ManufacturingOrder,
    a.ProductDescription,
    a.Product,
    c.OperationUnit,
    a.BaseUnit,
    a.BaseUnit1,
    b.manual_actual_runtime ,
    c.OperationReferenceQuantity,
    b.start_time,
    b.end_time,
    b.actual_runtime,
    b.difference_runtime,
    d.comp_code

