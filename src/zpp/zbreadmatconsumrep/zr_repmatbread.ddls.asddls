@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Resource CDS for Bread Material Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZR_REPMATBREAD as select from zrepmatbread
{
    key plant as Plant,
    key material as Material,
    key rangedate as Rangedate,
    key todate as Todate,
    key shift as Shift,
    quantity as Quantity,
    um as Um,
    actual_qty as ActualQty,
    difference as Difference,
    var_posted as VarPosted,
    batch as Batch,
    storagelocation as Storagelocation,
    movementtype as Movementtype,
    matdesc as Matdesc,
    idfier as Idfier,
    loadcomplete as Loadcompleted
}
