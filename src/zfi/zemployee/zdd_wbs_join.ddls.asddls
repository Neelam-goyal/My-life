@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR WBS_JOIN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDD_WBS_JOIN
  with parameters
    emp_code     : abap.char(10),
    pCompany     : abap.char(4),
    pFromDate    : abap.dats,
    pToDate      : abap.dats
  as select from I_BusinessPartner as bp
  inner join I_AccountingDocumentJournal(P_Language: 'E') as a
    on a.WBSElementExternalID = bp.BusinessPartner
{
  key a.FiscalPeriod,
  a.CompanyCode,
  a.GLAccount,
  a.GLAccountName,
  bp.BusinessPartner,
  bp.BusinessPartnerFullName,
  'WBS' as MatchType
}
where
  bp.BusinessPartner = $parameters.emp_code and
  a.Supplier is initial and
  a.CompanyCode = $parameters.pCompany and
  a.PostingDate between $parameters.pFromDate and $parameters.pToDate and
  a.Ledger = '0L'
