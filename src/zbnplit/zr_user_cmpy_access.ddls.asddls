@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Company Access'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_USER_CMPY_ACCESS
  as select from ZI_PlantTable as A
    inner join   zdt_user_item as B on A.PlantCode = B.plant
{
  B.userid,
  A.CompCode
}
group by
  B.userid,
  A.CompCode
