@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Multi GP Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MULTIGPVH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZMULTIGP' )
{
    @EndUserText.label: 'Type'
    key value_low as Value,
    @EndUserText.label: 'Description'
    @Semantics.text: true
    text as Description
}
