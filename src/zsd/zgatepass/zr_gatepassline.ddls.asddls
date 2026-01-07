@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Gate Pass Line'
define view entity ZR_GATEPASSLINE as select from zgatepassline
association to parent ZR_GATEPASSHEADER as _GatePassHeader on $projection.GatePass = _GatePassHeader.GatePass
{
  key gate_pass as GatePass,
  key pass_line_no as PassLineNo,
  document_no as DocumentNo,
  document_reference as DocumentReference,
  document_date as DocumentDate,
  @Semantics.amount.currencyCode: 'Currency'
  amount as Amount,
  @Semantics.quantity.unitOfMeasure: 'Unit'
  quantity as Quantity,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  unit as Unit,
  vrn_no as VrnNo,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  _GatePassHeader
  
}
