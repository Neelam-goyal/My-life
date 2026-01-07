@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@Search.searchable: true
define root view entity ZC_INVOICE
  as select from I_AccountingDocumentJournal( P_Language:'E' )
{
  key AccountingDocument
}
where I_AccountingDocumentJournal.AccountingDocumentType = 'DR'
group by AccountingDocument
