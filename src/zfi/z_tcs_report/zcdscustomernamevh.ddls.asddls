@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR CUSTOMER NAME VALUE HELP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDSCUSTOMERNAMEVH as select distinct from I_BillingDocument as A
join I_Customer as B on A.PayerParty = B.Customer
{
    key B.Customer as PayerParty,
    B.CustomerName as PayerPartyName
}
