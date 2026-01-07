@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for CUSTCONTROLSHT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CUSTCONTROLSHT as select from zcustcontrolsht
//  association to parent ZR_CASHROOMCR as _CashHeader on $projection.CompCode = _CashHeader.Ccmpcode and $projection.Plant = _CashHeader.Plant 
//        and $projection.Imfyear = _CashHeader.Cfyear and $projection.GateEntryNo = _CashHeader.Cgpno
{
    key gate_entry_no as GateEntryNo,
    key comp_code as CompCode,
    key plant as Plant,
    key imfyear as Imfyear,
    key dealer as Dealer,
    vehiclenum as Vehiclenum,
    gpdate as Gpdate,
    controlsheet as Controlsheet,
    cost_center as CostCenter,
    dealer_wise_cash as DealerWiseCash,
    sales_person as SalesPerson,
    amt_deposited as AmtDeposited,
    posted_ind as PostedInd,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.localInstanceLastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt
//    _CashHeader
    
}
