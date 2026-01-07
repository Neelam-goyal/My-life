@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR DOCUMENT TYPE VALUE HELP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_DOCTYPEVALUEHELP
  as select distinct from zpurchinvlines as a
{
      //   key a.fiscalyearvalue,
      //   key a.supplierinvoice,
      //   key a.supplierinvoiceitem,
      //   key a.companycode,
      @EndUserText.label    : 'Document Type'
  key a.purchaseordertype
}
