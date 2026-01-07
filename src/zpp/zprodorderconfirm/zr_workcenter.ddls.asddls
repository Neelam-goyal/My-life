@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WORKCENTER as select 
distinct 
from I_WorkCenter as workcenter
//left outer join I_WorkCenterText as  wct  on wct.Plant = workcenter.Plant and wct.WorkCenterTypeCode = workcenter.WorkCenterTypeCode
//and wct.Language    = $session.system_language
   {
   key workcenter.WorkCenter,
   workcenter.Plant,
   _Text.WorkCenterText
    
} 
//group by 
//   workcenter.WorkCenter,
//   workcenter.Plant,
//   wct.WorkCenterText
//where wct.Language = $session.system_language
//where workcenter.Plant = 'BN02' or workcenter.Plant = 'CA02'or workcenter.Plant = 'CA03'
//or workcenter.Plant = 'BI02' or workcenter.Plant = 'BB03'

