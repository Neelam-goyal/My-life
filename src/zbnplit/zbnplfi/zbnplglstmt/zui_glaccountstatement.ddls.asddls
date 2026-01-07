@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UI - GL Account Statement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZUI_GLAccountStatement
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'GL Account'
    @Consumption.valueHelpDefinition: [{entity.name: 'Z_GLAccounts', entity.element: 'GLAccount',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    pGLAccount   : saknr,


    @EndUserText.label: 'From (Posting Date)'
    //    @Consumption.derivation: { lookupEntity: 'I_FiscalCalendarDate',
    //    resultElement: 'FiscalYearStartDate',
    //    binding: [
    //    { targetElement : 'FiscalYearVariant' , type : #CONSTANT, value : 'V3' },
    //    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'pToDate' }
    //
    //     ]
    //    }
    @Consumption.defaultValue: '20250401'
    pFromDate    : calendardate,
    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    pToDate      : calendardate,
    @Consumption.defaultValue: 'N'
    @EndUserText.label: 'Include Reverse Entries(Y/N)'
    pIsRevDoc    : z_isrevdoc

  as select from ZTBLF_GLAccountStatement(
                                         pCompanyCode: $parameters.pCompanyCode,
                                         pGLAccount: $parameters.pGLAccount,
                                         pFromDate: $parameters.pFromDate,
                                         pToDate: $parameters.pToDate,
                                         pIsRevDoc:$parameters.pIsRevDoc

                                         ) as Item
  association [1..1] to I_JournalEntry               as _JournalEntry               on  $projection.CompanyCode        = _JournalEntry.CompanyCode
                                                                                    and $projection.FiscalYear         = _JournalEntry.FiscalYear
                                                                                    and $projection.AccountingDocument = _JournalEntry.AccountingDocument
  association [1..1] to I_CompanyCode                as _CompanyCode                on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association        to I_FiscalYearForCompanyCode   as _FiscalYear                 on  $projection.FiscalYear  = _FiscalYear.FiscalYear
                                                                                    and $projection.CompanyCode = _FiscalYear.CompanyCode
  association        to I_AccountingDocumentTypeText as _AccountingDocumentTypeText on  $projection.AccountingDocumentType   = _AccountingDocumentTypeText.AccountingDocumentType
                                                                                    and _AccountingDocumentTypeText.Language = $session.system_language
  association [1..1] to I_ControllingArea            as _ControllingAreaText        on  $projection.ControllingArea = _ControllingAreaText.ControllingArea
  association [1..1] to I_ProfitCenter               as _CurrentProfitCenter        on  $projection.ControllingArea            = _CurrentProfitCenter.ControllingArea
                                                                                    and $projection.ProfitCenter               = _CurrentProfitCenter.ProfitCenter
                                                                                    and _CurrentProfitCenter.ValidityStartDate <= $session.system_date
                                                                                    and _CurrentProfitCenter.ValidityEndDate   >= $session.system_date
  association [0..1] to I_Customer                   as _Customer                   on  $projection.Customer = _Customer.Customer
  association [0..1] to I_Supplier                   as _Supplier                   on  $projection.Supplier = _Supplier.Supplier
{
      @ObjectModel.sort.enabled: false
  key SRNO,
      @ObjectModel.foreignKey.association: '_FiscalYear'
  key cast(FISCALYEAR as fis_gjahr_no_conv   preserving type )                     as FiscalYear,

      @ObjectModel.foreignKey.association: '_CompanyCode'
  key cast(COMPANYCODE as bukrs preserving type )                                  as CompanyCode,
      @ObjectModel.foreignKey.association: '_JournalEntry'
  key cast(ACCOUNTINGDOCUMENT as belnr_d preserving type )                         as AccountingDocument,



      POSTINGDATE,

      @ObjectModel.foreignKey.association: '_AccountingDocumentTypeText'
      @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ]
      cast(ACCOUNTINGDOCUMENTTYPE as blart preserving type )                       as AccountingDocumentType,
      _AccountingDocumentTypeText.AccountingDocumentTypeName,
      _AccountingDocumentTypeText,

      @Semantics.text: true
      DOCUMENTITEMTEXT,


      @ObjectModel.text.element: ['GLACCOUNTNAME']
      GLACCOUNT,

      @Semantics.text: true
      @UI.hidden: true
      GLACCOUNTNAME,
      DOCUMENTDATE,


      cast(REFERENCEDOCUMENTTYPE as awtyp preserving type)                         as REFERENCEDOCUMENTTYPE,
      cast(ORIGINALREFERENCEDOCUMENT as awkey preserving type )                    as ORIGINALREFERENCEDOCUMENT,

      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      _Customer.CustomerName,
      @ObjectModel.text.element: [ 'SupplierName' ]
      Supplier,
      _Supplier.SupplierName,
      CostCenter,

      @ObjectModel.foreignKey.association: '_CurrentProfitCenter'
      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      ProfitCenter,
      _CurrentProfitCenter._Text.ProfitCenterName,
      _CurrentProfitCenter,
      Item.ReversalReason,
      Item.IsReversal,
      Item.IsReversed,
      Item.ReversedReferenceDocument,
      Item.ReversalReferenceDocument,
      Item.ReversedDocument,
      Item.ReverseDocument,
      Plant,
      BusinessPlace,

      @ObjectModel.text.association: '_ControllingAreaText'
      ControllingArea,
      _ControllingAreaText,


      COMPANYCODECURRENCY,
      DEBITCREDITCODE,

      @Semantics: { amount : {currencyCode: 'COMPANYCODECURRENCY'} }
      AMOUNTINCOMPANYCODECURRENCY,

      @Semantics: { amount : {currencyCode: 'COMPANYCODECURRENCY'} }
      //      @DefaultAggregation: #SUM
      CREDITAMOUNTINCMPCDCRCY,

      @Semantics: { amount : {currencyCode: 'COMPANYCODECURRENCY'} }

      //      @DefaultAggregation: #SUM
      DEBITAMOUNTINCMPCDCRCY,

      @Semantics: { amount : {currencyCode: 'COMPANYCODECURRENCY'} }

      @ObjectModel.text.element: [ 'Sign' ]
      //      @UI.dataPoint: { title: 'Running Balance' }
      abs(RUNNINGBALANCE)                                                          as RUNNINGBALANCE,
      @Semantics.text: true
      cast(case when RUNNINGBALANCE < 0 then 'Cr.' else 'Dr.' end as abap.char(3)) as Sign,
      _JournalEntry,
      _CompanyCode,
      _FiscalYear,
      _Customer,
      _Supplier
}
