@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Pass Type Value Help CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_GATEPASSTYPEVH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZGATEPASSTYPE' )
{
    @EndUserText.label: 'Type'
    key value_low as Value,
    @EndUserText.label: 'Description'
    @Semantics.text: true
    text as Description
}
