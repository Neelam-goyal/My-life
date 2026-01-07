@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customized Customer Trial Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_PROVIDER ],
  modelingPattern: #ANALYTICAL_CUBE
}
define view entity ZC_CustomerTrial
  with parameters

    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '20250401'
    pFromDate    : budat,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pToDate      : budat
  as select from ZC_CustomerRecords(
                   pCompanyCode : $parameters.pCompanyCode,
                   pFromDate:$parameters.pFromDate,
                   pToDate:$parameters.pToDate
                   ) as item
  association [0..1] to ZDIM_GLAccount            as _GLAccount               on  $projection.GLAccount = _GLAccount.GLAccount
  association [0..1] to I_BusinessTransactionType as _BusinessTransactionType on  $projection.BusinessTransactionType = _BusinessTransactionType.BusinessTransactionType
  association [0..1] to I_AccountingDocumentType  as _AccountingDocumentType  on  $projection.AccountingDocumentType = _AccountingDocumentType.AccountingDocumentType
  association        to I_FiscalCalendarDate      as _TimeDim                 on  _TimeDim.CalendarDate      = item.PostingDate
                                                                              and _TimeDim.FiscalYearVariant = 'V3'
{
  CompanyCode,
  PostingDate,
  @Semantics.fiscal.yearVariant: true
  _TimeDim.FiscalYearVariant,

  @EndUserText.label: 'Year'
  _TimeDim.FiscalYear              as FinYear,

  @EndUserText.label: 'Quarter'
  _TimeDim.FiscalQuarter           as Quarter,

  @Semantics.calendar.yearMonth
  @EndUserText.label: 'YearMonth'
  _TimeDim._CalendarDate.YearMonth as YearMonth,

  @ObjectModel.foreignKey.association: '_AccountingDocumentType'
  AccountingDocumentType,

  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_BusTransTypeStdVH',
               element: 'BusinessTransactionType' }
  }]
  @ObjectModel.foreignKey.association: '_BusinessTransactionType'
  BusinessTransactionType,
  
  ProfitCenter,
BusinessPlace,

  @ObjectModel.text.element: [ 'PartyName' ]
  PartyCode,
  @Semantics.text: true
  PartyName,

  @EndUserText.label: 'G/L Account'
  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_GLAccountStdVH',
               element: 'GLAccount' }
  }]
  @ObjectModel.foreignKey.association: '_GLAccount'
  GLAccount,

  @Semantics.text: true
  @EndUserText.label: 'Tag'
  case
  when GLAccount ='0012100000' then 'Receivables'
  when GLAccount ='0000000000' then ' Openings'
  else _GLAccount.GLAccountName
  end                              as Tag,

  @EndUserText.label: '_Currency'
  CompanyCodeCurrency,
  
  

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  @EndUserText.label: 'Amount'
  @DefaultAggregation: #SUM
  Amount,

  _GLAccount,
  _BusinessTransactionType,
  _AccountingDocumentType
}
