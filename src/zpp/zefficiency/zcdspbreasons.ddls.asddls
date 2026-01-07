@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'reason for breakdown'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDSPBReasons as select from zpbreason
{   
 key reasoncode as Reasoncode,
      reasondesc as ReasonDescription,
      created_by,
      created_at,
      last_changed_by,
      last_changed_at
}
