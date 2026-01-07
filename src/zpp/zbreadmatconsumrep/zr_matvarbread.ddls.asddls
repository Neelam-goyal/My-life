@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZMATVARBREAD'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_MATVARBREAD
  as select from zmatvarbread
{
  key comp_code as CompCode,
  key plant_code as PlantCode,
  key productionorder as Productionorder,
  key shift as Shift,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  key confirmationyieldquantity as Confirmationyieldquantity,
  key confirmation_count as ConfirmationCount,
  key confirmation_group as ConfirmationGroup,
  key materialdocument as Materialdocument,
  key actualconsumption as Actualconsumption,
  key bomcomponentcode as Bomcomponentcode,
  key bomcomponentname as Bomcomponentname,
  distlineno as Distlineno,
  shiftgroup as Shiftgroup,
  confirmationdate as Confirmationdate,
  confirmationtime as Confirmationtime,
  postingdate as Postingdate,
  creationdate as Creationdate,
  work_center as WorkCenter,
  product as Product,
  productdesc as Productdesc,
  bomcomponentrequiredquantity as Bomcomponentrequiredquantity,
  goodsmovementtype as Goodsmovementtype,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  bomamtcurr as Bomamtcurr,
  um as Um,
  batch as Batch,
  @Semantics.amount.currencyCode: 'Bomamtcurr'
  actualcost as Actualcost,
  qtydiff as Qtydiff,
  @Semantics.amount.currencyCode: 'Bomamtcurr'
  amtdiff as Amtdiff,
  @Semantics.amount.currencyCode: 'Bomamtcurr'
  amtdiffactualrate as Amtdiffactualrate,
  @Semantics.amount.currencyCode: 'Bomamtcurr'
  bomcomponentamt as Bomcomponentamt,
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
