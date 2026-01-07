@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZCONTROLSHEET'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CONTROLSHEET as select from zcontrolsheet
  association to parent ZR_INVGROUPED000 as _Group on $projection.Gpdate = _Group.Orderdate and $projection.Type = _Group.Type
{
    key comp_code as CompCode,
    key plant as Plant,
    key imfyear as Imfyear,
    key gate_entry_no as GateEntryNo,
    'Expenses' as Type,
    vehiclenum as Vehiclenum,
    gpdate as Gpdate,
    controlsheet as Controlsheet,
    toll as Toll,
    routeexp as Routeexp,
    cngexp as Cngexp,
    other as Other,
    glposted as Glposted,
    dieselexp as Dieselexp,
    repair as Repair,
    cost_center as CostCenter,
    sales_person as SalesPerson,
    posted_ind as PostedInd,
    error_log as ErrorLog,
    reference_doc as ReferenceDoc,
    created_by as CreatedBy,
    created_at as CreatedAt,
    
    case when glposted = 1 then 0 else 1 end as Highlight,
    
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    _Group
}
