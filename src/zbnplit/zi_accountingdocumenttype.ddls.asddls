@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Accounting Document Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_AccountingDocumentType as 
select from I_AccountingDocumentTypeText
{
    key AccountingDocumentType,

    AccountingDocumentTypeName,
    concat(concat(concat(AccountingDocumentType, ' ('),AccountingDocumentTypeName), ')' ) as VoucherType
}
where Language = $session.system_language
