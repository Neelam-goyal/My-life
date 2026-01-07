@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VALUE HELP CDS FOR UQC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_HSN_VH
  as select distinct from zbillinglines as a
{
      //   key a.fiscalyearvalue,
      //   key a.supplierinvoice,
      //   key a.supplierinvoiceitem,
      //   key a.companycode,
      @EndUserText.label    : 'HSN'
  key a.hsncode
}
