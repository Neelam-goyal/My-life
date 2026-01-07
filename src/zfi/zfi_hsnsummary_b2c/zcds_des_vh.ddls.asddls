@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VALUE HELP CDS FOR UQC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_DES_VH
  as select distinct from I_AE_CnsmpnTaxCtrlCodeTxt as c
{
      //   key a.fiscalyearvalue,
      //   key a.supplierinvoice,
      //   key a.supplierinvoiceitem,
      //   key a.companycode,
      @EndUserText.label    : 'Description'
  key c.ConsumptionTaxCtrlCodeText1
}
