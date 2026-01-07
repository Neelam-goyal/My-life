@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Control Sheet Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CTRLSHEET_UNPOSTED as select from ZR_CONTROLSHEET
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
    Dieselexp,
    Repair,
    CostCenter,
    SalesPerson,
    PostedInd,
    ErrorLog,
    ReferenceDoc
}
where  Glposted = 0;
