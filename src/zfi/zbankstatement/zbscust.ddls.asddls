@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity zBSCUST as select from zbrstable 

{
    key acc_id as AccId,
  key main_gl as MainGl,
  key out_gl as OutGl,
  key in_gl as InGl,
  comp_code as CompCode,
  house_bank as HouseBank
}
