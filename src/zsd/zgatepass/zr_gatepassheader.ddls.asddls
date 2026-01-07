@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Gate Pass Header'
define root view entity ZR_GATEPASSHEADER
  as select from zgatepassheader
  composition [0..*] of ZR_GATEPASSLINE as _GatePassLine
{
  key gate_pass as GatePass,
  plant as Plant,
  entry_date as EntryDate,
  type as Type,
  salesman_name as SalesmanName,
  vehicle_number as VehicleNumber,
  driver_name as DriverName,
  driver_code as DriverCode,
  route_name as RouteName,
  remarks as Remarks,
  veh_out_remarks as VehOutRemarks,
  cmcrate_1 as Cmcrate1,
  cmcrate_2 as Cmcrate2,
  cmcrate_3 as Cmcrate3,
  cmcrate_4 as Cmcrate4,
  cb2 as Cb,
  multi_g_pass as MultiGPass,
  first_gp_number as FirstGpNumber,
  first_gp_amount as FirstGpAmount,
  bill_amount as BillAmount,
  out_date as OutDate,
  out_time as OutTime,
  out_meter_reading as OutMeterReading,
  vehicle_out as VehicleOut,
  cancelled as Cancelled,
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
  _GatePassLine
  
}
