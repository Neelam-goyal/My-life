@Metadata.allowExtensions: true
@EndUserText.label: 'Plant Table App'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZRAPC_TABLE_PLANT
  provider contract transactional_query
  as projection on ZRAPR_TABLE_PLANT
{
  key CompCode,
  key PlantCode,
  PlantName1,
  PlantName2,
  Address1,
  Address2,
  Address3,
  City,
  District,
  StateCode1,
  StateCode2,
  StateName,
  Pin,
  Country,
  CinNo,
  GstinNo,
  FssaiNo,
  PanNo,
  TanNo,
  Remark1,
  Remark2,
  Remark3,
  Gspusername,
  Gsppassword,
  Phone,
  Ewbusername,
  Ewbpassword,
  Businessplace,
  Costcenter,
  Purchasecostcenter,
  Profitcenter,
  Glaccount,
  Active,
  IntegrationEnabled,
  StpocreationEnabled,
  StporeceiveEnabled,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
