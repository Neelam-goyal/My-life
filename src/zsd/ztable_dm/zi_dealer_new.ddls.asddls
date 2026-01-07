@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'INTERFACE VIEW FOR DEALER'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_DEALER_NEW as select from zdealer_tab_new1
{

  key dealerbctag as Dealerbctag,
  key businesspartner as BusinessPartner,
  key comp_code as CompanyCode,
  dealer_device_id as DealerDeviceId,
  dlradvpymttag as Dlradvpymttag,
  dealerift as Dealerift,
  dealerstation as Dealerstation,
  creditdays as Creditdays,
  dealersmdtag as Dealersmdtag,
  sshqcode as Sshqcode,
  min_bal as MinBalance,
  min_bal_date as MinBalanceDate,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
  
}

     
