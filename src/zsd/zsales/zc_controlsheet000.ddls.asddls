@Metadata.allowExtensions: true
@EndUserText.label: 'Control Sheet'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_CONTROLSHEET000
provider contract transactional_query
  as projection on ZR_CONTROLSHEET000
{

    key CompCode,
    key Plant,
    key Imfyear,
    key GateEntryNo,
    Vehiclenum,
    Gpdate,
    Controlsheet,
    Toll,
    Routeexp,
    Cngexp,
    Other,
    GLPosted,
    Dieselexp,
    Repair,
    CostCenter,
    SalesPerson,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt

  
}
