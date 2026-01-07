@EndUserText.label: 'Plant Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZI_PlantTable
  as select from ztable_plant
  association to parent ZI_PlantTable_S as _PlantTableAll on $projection.SingletonID = _PlantTableAll.SingletonID
{
  key comp_code as CompCode,
  key plant_code as PlantCode,
  plant_name1 as PlantName1,
  plant_name2 as PlantName2,
  address1 as Address1,
  address2 as Address2,
  address3 as Address3,
  city as City,
  district as District,
  state_code1 as StateCode1,
  state_code2 as StateCode2,
  state_name as StateName,
  pin as Pin,
  country as Country,
  cin_no as CinNo,
  gstin_no as GstinNo,
  fssai_no as FssaiNo,
  pan_no as PanNo,
  tan_no as TanNo,
  remark1 as Remark1,
  remark2 as Remark2,
  remark3 as Remark3,
  gsppassword as GSPPassword,
  gspusername as GSPUserName,
  ewbpassword as EWBPassword,
  ewbusername as EWBUserName, 
  businessplace as BUSINESSPLACE,
  costcenter as COSTCENTER,
  purchasecostcenter as PURCHASECOSTCENTER,
  profitcenter as PROFITCENTER,
  glaccount as GLACCOUNT,
  phone as Phone,
  active as Active,
  integrationenabled as IntegrationEnabled,
  stpocreationenabled as STPOCreationEnabled,
  stporeceiveenabled as STPOReceiveEnabled,
  @Consumption.hidden: true
  1 as SingletonID,
  _PlantTableAll
  
}
