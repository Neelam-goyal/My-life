@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_ACTIVITYDECL
  as select from zactivitydecl as ActivityDeclaration
{
  @EndUserText.label: 'Company'
  key bukrs as Bukrs,
  @EndUserText.label: 'Plant'
  key plantcode as Plantcode,
  @EndUserText.label: 'Declare Date'
  key declaredate as Declaredate,
  @EndUserText.label: 'Shift'
  key shiftnumber as Shiftnumber,
  @EndUserText.label: 'Work Center Id'
  key workcenterid as Workcenterid,
  @EndUserText.label: 'Declare No'  
  key declareno as Declareno,
  @EndUserText.label: 'Activity'  
  key costctractivitytype as Costctractivitytype,
  @EndUserText.label: 'Actual Consumption'  
  actualconsumption as Actualconsumption,
  @EndUserText.label: 'Work Center'  
  workcenter as Workcenter,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
