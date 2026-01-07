@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for DEALER'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_DEALER_NEW 
    as projection on ZI_DEALER_NEW
{
  key Dealerbctag,
  key BusinessPartner,
  key CompanyCode,
  DealerDeviceId,
  Dlradvpymttag,
  Dealerift,
  Dealerstation,
  Creditdays,
  Dealersmdtag,
  Sshqcode,
  MinBalance,
  MinBalanceDate,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
