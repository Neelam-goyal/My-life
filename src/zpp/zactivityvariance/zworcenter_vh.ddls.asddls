@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value for work center'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zworcenter_vh as select from I_WorkCenter
{
     @UI.hidden: true
    key WorkCenterInternalID,
    
     @UI.adaptationHidden: true
    key WorkCenterTypeCode,
    
    WorkCenter
}
