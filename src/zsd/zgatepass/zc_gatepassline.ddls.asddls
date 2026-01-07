@Metadata.allowExtensions: true
@EndUserText.label: 'Gate Pass Line'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_GATEPASSLINE
  as projection on ZR_GATEPASSLINE
{
  key GatePass,
  key PassLineNo,
  DocumentNo,
  DocumentReference,
  DocumentDate,
  Amount,
  Quantity,
  @Semantics.currencyCode: true
  Currency,
  @Semantics.unitOfMeasure: true
  Unit,
  VrnNo,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _GatePassHeader : redirected to parent ZC_GATEPASSHEADER
  
}
