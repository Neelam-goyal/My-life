@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS works on ZR_CustomerRecords and Filters Date Range'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CustomerRecords
  with parameters
    pCompanyCode : bukrs,
    pFromDate    : budat,
    pToDate      : budat
  as select from ZR_CustomerRecords
{
  $parameters.pCompanyCode         as CompanyCode,
  PostingDate,
  AccountingDocumentType,
  BusinessTransactionType,
  ProfitCenter,
  BusinessPlace,
  PartyCode,
  PartyName,
  GLAccount,
  CompanyCodeCurrency,
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(AmountInCompanyCodeCurrency) as Amount
}
where
      PostingDate between $parameters.pFromDate and $parameters.pToDate
  and CompanyCode = $parameters.pCompanyCode
group by

  PostingDate,
  AccountingDocumentType,
  BusinessTransactionType,
  ProfitCenter,
  BusinessPlace,
  PartyCode,
  PartyName,
  GLAccount,
  CompanyCodeCurrency
union all select from ZR_CustomerRecords
{

  $parameters.pCompanyCode         as CompanyCode,
  $parameters.pFromDate            as PostingDate,
  '00'                             as AccountingDocumentType,
  '00'                             as BusinessTransactionType,
  ProfitCenter,
  BusinessPlace,
  PartyCode,
  PartyName,
  '0000000000'                     as GLAccount,
  CompanyCodeCurrency,
  sum(AmountInCompanyCodeCurrency) as Amount
}
where
      PostingDate < $parameters.pFromDate
  and CompanyCode = $parameters.pCompanyCode
group by
  ProfitCenter,
  BusinessPlace,
  PartyCode,
  PartyName,
  CompanyCodeCurrency
