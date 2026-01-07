@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For House Bank'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_HOUSEBANKVH as select from I_HouseBankAccountText
{
    key CompanyCode,
    key HouseBank,
    @Consumption.filter.hidden: true
    HouseBankAccountDescription
}
