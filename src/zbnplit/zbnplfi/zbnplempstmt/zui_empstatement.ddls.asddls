@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UI of Employee Statement'
@AbapCatalog.sqlViewName: 'ZUI_EMPSTMT'
@AbapCatalog.compiler.compareFilter: true
@Metadata.ignorePropagatedAnnotations: true

//@Search.searchable: true

@Metadata.allowExtensions: true

define view ZUI_EmpStatement
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    
    @EndUserText.label: 'Employee'
    @Consumption.valueHelpDefinition: [{entity.name: 'Z_Employee', entity.element: 'EmpCode',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    pEmpCode     : kunnr,

 @EndUserText.label: 'GL Account'
    @Consumption.valueHelpDefinition: [{entity.name: 'Z_GLAccounts', entity.element: 'GLAccount',useForValidation: true,
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    @Consumption.defaultValue: '0010011001'
    pGLAccount     : saknr,

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
    pFromDate      : calendardate,
    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    pToDate        : calendardate,

    @Consumption.semanticObject: 'ZDIM_BusinessPlace'
    @EndUserText.label: 'B.Place (Corporate for All)'
    @Consumption.valueHelpDefinition: [{entity.name: 'ZDIM_BusinessPlace', entity.element: 'BusinessPlace',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    pBusinessPlace : j_1bbranc_,

    @Consumption.defaultValue: 'N'
    @EndUserText.label: 'Include Reverse Entries(Y/N)'
    pIsRevDoc      : z_isrevdoc,

    @Consumption.defaultValue: 'N'
    @EndUserText.label: 'Exclude Spl. GL(Y/N)'
    pIsExcSplGL    : z_isrevdoc

  as select from ZTBLF_EMP_STATEMENT(
                                         pCompanyCode: $parameters.pCompanyCode,
                                         pEmpCode: $parameters.pEmpCode,
                                         pGLAccount:$parameters.pGLAccount,
                                         pFromDate: $parameters.pFromDate,
                                         pToDate: $parameters.pToDate,
                                         pBusinessPlace:$parameters.pBusinessPlace,
                                         pIsRevDoc:$parameters.pIsRevDoc,
                                         pIsExcSplGL:$parameters.pIsExcSplGL
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
{
      @ObjectModel.foreignKey.association: '_FiscalYear'
  key cast(FISCALYEAR as fis_gjahr_no_conv   preserving type )                     as FiscalYear,

      @ObjectModel.foreignKey.association: '_CompanyCode'
  key cast(COMPANYCODE as bukrs preserving type )                                  as CompanyCode,
      @ObjectModel.foreignKey.association: '_JournalEntry'
  key cast(ACCOUNTINGDOCUMENT as belnr_d preserving type )                         as AccountingDocument,

      @ObjectModel.sort.enabled: false
  key SRNO,

      POSTINGDATE,

      @ObjectModel.foreignKey.association: '_AccountingDocumentTypeText'
      @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ]
      cast(ACCOUNTINGDOCUMENTTYPE as blart preserving type )                       as AccountingDocumentType,
      _AccountingDocumentTypeText.AccountingDocumentTypeName,
      _AccountingDocumentTypeText,

      @Semantics.text: true
      DOCUMENTITEMTEXT,

      @ObjectModel.text.element: ['EmpNAME']
      EMPCODE,

      @Semantics.text: true
      @UI.hidden: true
      EMPNAME,

      @ObjectModel.text.element: ['GLACCOUNTNAME']
      GLACCOUNT,

      @Semantics.text: true
      GLACCOUNTNAME,
      DOCUMENTDATE,


      cast(REFERENCEDOCUMENTTYPE as awtyp preserving type)                         as REFERENCEDOCUMENTTYPE,
      cast(ORIGINALREFERENCEDOCUMENT as awkey preserving type )                    as ORIGINALREFERENCEDOCUMENT,


      CostCenter,

      @ObjectModel.foreignKey.association: '_CurrentProfitCenter'
      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      ProfitCenter,
      _CurrentProfitCenter._Text.ProfitCenterName,
      _CurrentProfitCenter,
      Item.ReversalReason,
      Item.IsReversal,
      Item.IsReversed,
      Item.SpecialGLCode,
      Item.SpecialGLTransactionType,
      Item.ReversedReferenceDocument,
      Item.ReversalReferenceDocument,
      Item.ReversedDocument,
      Item.ReverseDocument,
      Plant,
      BusinessPlace,

      @ObjectModel.text.association: '_ControllingAreaText'
      ControllingArea,
      _ControllingAreaText,

      @Semantics.currencyCode:true
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
      _FiscalYear
}
