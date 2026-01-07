@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for ZR_ActivityDecl'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ACTIVITYDECL 
  provider contract transactional_interface
  as projection on ZR_ACTIVITYDECL as ActivityDeclaration
{
    key Bukrs,
    key Plantcode,
    key Declaredate,
    key Shiftnumber,
    key Workcenterid,
    key Declareno,
    key Costctractivitytype,
    Actualconsumption,
    Workcenter,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
