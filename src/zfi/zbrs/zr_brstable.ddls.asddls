@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BRSTABLE
  as select from zbrstable
{
  key acc_id as AccId,
  key main_gl as MainGl,
  key out_gl as OutGl,
  key in_gl as InGl,
  comp_code as CompCode,
  house_bank as HouseBank,
  accountcode as Accountcode,
  profitcenter as ProfitCenter,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
  
}
