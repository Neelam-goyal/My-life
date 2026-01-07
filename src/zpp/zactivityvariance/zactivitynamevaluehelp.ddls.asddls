@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'act help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zactivityNameValueHelp as select from  DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZACTIVITY_NAME_DOMAIN' )
{
  @UI.hidden: true
 key domain_name,
@UI.hidden: true
 key value_position,
 @UI.hidden: true
 key language,
 value_low,
 text
}
