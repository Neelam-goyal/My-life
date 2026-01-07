@AbapCatalog.viewEnhancementCategory: [#NONE]
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for CUSTCONTROLSHT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CUSTCONTROLSHT as projection on ZR_CUSTCONTROLSHT
 
{
       key GateEntryNo,
       key CompCode,
       key Plant,
       key Imfyear,
       key Dealer,
       Vehiclenum,
       Gpdate,
       Controlsheet,
       CostCenter,
       DealerWiseCash,
       SalesPerson,
       AmtDeposited,
       PostedInd,
       CreatedBy,
       LastChangedBy
       /* Associations */
//       _CashHeader : redirected to parent ZC_CASHROOMCR
}
