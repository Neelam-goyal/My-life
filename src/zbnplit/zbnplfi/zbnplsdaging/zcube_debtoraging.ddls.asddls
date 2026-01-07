@EndUserText.label: 'Debtor Aging Cube'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
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
define view entity ZCUBE_DebtorAging
  with parameters

    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompany  : bukrs,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pAsOnDate : budat,


    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '15,30,45,60,90'
    pDaysStr  : z_daysrange

  as select from ZTBLF_DebtorAging
                 (pCompany:$parameters.pCompany,
                 pAsOnDate:$parameters.pAsOnDate,
                 pDaysStr:$parameters.pDaysStr) as rec
  association        to ZDIM_CustomerWithSalesArea as _Customer     on  $projection.Customer  = _Customer.Customer
                                                                    and _Customer.CompanyCode = $parameters.pCompany
  association [0..1] to ZDIM_DistributionChannel   as _DistChannel  on  $projection.distchannel = _DistChannel.DistributionChannel
  association [0..1] to ZDIM_Customer              as _Customer1    on  $projection.Customer = _Customer1.Customer
  association [0..1] to ZDIM_SalesOrganization     as _SalesOrg     on  $projection.salesorg = _SalesOrg.SalesOrganization
  association [0..1] to I_Division                 as _Division     on  $projection.division = _Division.Division
  association [1..1] to I_JournalEntry             as _JournalEntry on  $projection.CompanyCode        = _JournalEntry.CompanyCode
                                                                    and $projection.FiscalYear         = _JournalEntry.FiscalYear
                                                                    and $projection.AccountingDocument = _JournalEntry.AccountingDocument

  association [1..1] to I_CompanyCode              as _CompanyCode  on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association        to I_FiscalYearForCompanyCode as _FiscalYear   on  $projection.FiscalYear  = _FiscalYear.FiscalYear
                                                                    and $projection.CompanyCode = _FiscalYear.CompanyCode

{

  @Consumption.semanticObject: 'Customer'
  @ObjectModel.foreignKey.association: '_Customer1'
  @Consumption.valueHelpDefinition: [{entity.name: 'Z_CustomerCompany', entity.element: 'Customer',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompany', element: 'CompanyCode'}]}]
  @Consumption.semanticObjectMapping.additionalBinding: [{ localElement: 'Customer', element: 'Customer' },
                   { localElement: 'CompanyCode', element: 'CompanyCode' }]
  cast(PartyCode as kunnr preserving type)                 as Customer,
  @EndUserText.label: 'City'
  _Customer.City,
  @EndUserText.label: 'State'
  _Customer.State                                          as Region,
  @EndUserText.label: 'Country'
  _Customer.Country,
  @EndUserText.label: 'DistChannel'
  @ObjectModel.foreignKey.association: '_DistChannel'
  _Customer.DistChannel,
  _DistChannel,
  
  @EndUserText.label: 'Business Partner Type'
  _Customer1.BusinessPartnerTypeDesc,

  $parameters.pCompany                                     as Company,

  @EndUserText.label: 'SalesOrg'
  @ObjectModel.foreignKey.association: '_SalesOrg'
  _Customer.SalesOrg,
  _SalesOrg,

  @EndUserText.label: 'Division'
  @ObjectModel.foreignKey.association: '_Division'
  _Customer.Division,
  _Division,

  @EndUserText.label: 'Posting Date'
  PostingDate,

  @EndUserText.label: 'Due Date'
  NetDueDate,

  @ObjectModel.foreignKey.association: '_JournalEntry'
  @Consumption.semanticObject: 'AccountingDocument'
  @Consumption.semanticObjectMapping.additionalBinding: [{ localElement: 'AccountingDocument', element: 'AccountingDocument' },
                        { localElement: 'CompanyCode', element: 'CompanyCode' },
                        { localElement: 'FiscalYear', element: 'FiscalYear' }]
  @EndUserText.label: 'Journal Entry No.'
  cast(AccountingDocument as belnr_d preserving type )     as AccountingDocument,

  @EndUserText.label: 'Entry Type'
  AccountingDocumentType                                   as DocType,

  @EndUserText.label: 'Document Reference ID'
  DocumentReferenceID,

  @EndUserText.label: 'Closing Bal Amt'
  concat_with_space(
          cast(Balance as abap.char(20)),
          case when Balance < 0 then 'Cr' else 'Dr' end,
          1
        )                                                  as ClosingBal,


  @EndUserText.label: 'Doc Amt'
  @DefaultAggregation: #SUM
  DocAmt,

  @EndUserText.label: 'Doc Bal Amt'
  @DefaultAggregation: #SUM
  VutRefRcptAmt,

  @EndUserText.label: 'Due Amt'
  @DefaultAggregation: #SUM
  case when DueAmt < 0 then 0 else DueAmt end              as DueAmt,

  @EndUserText.label: 'NoDue Amt'
  @DefaultAggregation: #SUM
  case when DueAmt < 0 then DueAmt else 0 end +
   NoDueAmt                                                as NoDueAmt,

  @Semantics.text: true
  @EndUserText.label: 'Due Days'
  DueDays,

  @Semantics.text: true
  @EndUserText.label: 'Range'
  Range,


  @UI.hidden: true
  @ObjectModel.foreignKey.association: '_FiscalYear'
  cast(FiscalYear as fis_gjahr_no_conv   preserving type ) as FiscalYear,

  @UI.hidden: true
  @ObjectModel.foreignKey.association: '_CompanyCode'
  cast(CompanyCode as bukrs preserving type )              as CompanyCode,

  _Customer1,
  _JournalEntry,
  _CompanyCode,
  _FiscalYear
}
