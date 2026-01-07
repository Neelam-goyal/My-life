@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Loan Types'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_LOANTYPE as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZLOANTYPE' )
{
    @EndUserText.label: 'Value'
    key value_low as Value,
    @Semantics.text: true
    text as Description
}
