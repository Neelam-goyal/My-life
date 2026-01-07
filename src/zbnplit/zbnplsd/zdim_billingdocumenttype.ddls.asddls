@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Billing Document Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'BillingDocumentType'

define view entity ZDIM_BillingDocumentType
  as select from I_BillingDocumentTypeText
{
      @ObjectModel.text.element: ['BillingDocumentTypeName']
  key BillingDocumentType,
      @Semantics.text:true
      BillingDocumentTypeName
}
where
  Language = 'E'
