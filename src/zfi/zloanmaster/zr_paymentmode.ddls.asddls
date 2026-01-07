@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Payment Modes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PAYMENTMODE as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZPAYMENTMODE' )
{
    @EndUserText.label: 'Value'    
    key value_low as Value,
    @Semantics.text: true
    text as Description
}


