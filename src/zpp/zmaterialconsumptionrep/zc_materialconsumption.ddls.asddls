@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC MATERIAL CONSUMPTION'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_MATERIALCONSUMPTION as select from ZR_materialconsuptionREP

{
    key Material,
    key From_Date,
    To_Date,
    Shift,
    Quantity,
    Um,
    Actual_Qty,
    Difference,
    Batch,
    Storagelocation
   
}
