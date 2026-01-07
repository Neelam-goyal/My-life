@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Account Code'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZCDSAccountCodeVH as select distinct from I_Withholdingtaxitem  as a 
 join I_BusinessPartner as b on a.CustomerSupplierAccount = b.BusinessPartner
{
  key cast( b.BusinessPartner as abap.numc(10) ) as CustomerSupplierAccount, 
  b.BusinessPartnerFullName as BusinessPartnerFullName
}
