@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data defination of Tax Invoice'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity zdd_taxinvoice as select from I_AccountingDocumentJournal( P_Language:'E' )
{
    key CompanyCode,
    key AccountingDocument,
    key Ledger,
    key FiscalYear,
    key LedgerGLLineItem
}
