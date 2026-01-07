@Metadata.allowExtensions: true
@EndUserText.label: 'Gate Pass Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_GATEPASSHEADER
  provider contract transactional_query
  as projection on ZR_GATEPASSHEADER
{
  key GatePass,
  Plant,
  EntryDate,
  Type,
  SalesmanName,
  VehicleNumber,
  DriverName,
  DriverCode,
  RouteName,
  Remarks,
  VehOutRemarks,
  Cmcrate1,
  Cmcrate2,
  Cmcrate3,
  Cmcrate4,
  Cb,
  MultiGPass,
  FirstGpNumber,
  FirstGpAmount,
  BillAmount,
  OutDate,
  OutTime,
  OutMeterReading,
  VehicleOut,
  Cancelled,
  VrnNo,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _GatePassLine : redirected to composition child ZC_GATEPASSLINE
  
}
