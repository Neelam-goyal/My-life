@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TYPEVH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZTYPE' )
{
     @EndUserText.label: 'Name'
    key text as Description
}
