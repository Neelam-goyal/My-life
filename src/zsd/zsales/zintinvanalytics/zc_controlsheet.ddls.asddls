@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Entity for ZCONTROLSHEET'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_CONTROLSHEET as projection on ZR_CONTROLSHEET
{
    key CompCode,
    key Plant,
    key Imfyear,
    key GateEntryNo,
    Type,
    Vehiclenum,
    Gpdate,
    Controlsheet,
    Toll,
    Routeexp,
    Cngexp,
    Other,
    Glposted,
    Dieselexp,
    Repair,
    CostCenter,
    SalesPerson,
    ErrorLog,
    ReferenceDoc,
    Highlight,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    /* Associations */
    _Group:redirected to parent ZC_INVGROUPED
}
