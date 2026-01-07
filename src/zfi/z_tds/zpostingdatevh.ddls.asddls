@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Posting Date'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPostingdateVH 
  as select distinct from I_AccountingDocumentJournal( P_Language : 'E' )
{
key AccountingDocument,
key PostingDate,
key CompanyCode

}
where TransactionTypeDetermination = 'WIT'
