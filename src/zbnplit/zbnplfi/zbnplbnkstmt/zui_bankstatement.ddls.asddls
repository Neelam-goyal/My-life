@EndUserText.label: 'UI of Statement of Bank'
@AbapCatalog.sqlViewName: 'ZUI_BANKSTMT'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
//@Search.searchable: true
@Metadata.allowExtensions: true

define view ZUI_BankStatement
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode           : bukrs,

    @Consumption.semanticObject: 'ZDIM_BANKMASTER'
    @EndUserText.label: 'Bank (Bank Account Internal Id)'
    @Consumption.valueHelpDefinition: [{entity.name: 'ZDIM_BANKMASTER', entity.element: 'BankAccountInternalID',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    pBankAccountInternalId : zbnkacintid,


    @EndUserText.label: 'From (Posting Date)'
        @Consumption.derivation: { lookupEntity: 'I_FiscalCalendarDate',
        resultElement: 'FiscalYearStartDate',
        binding: [
        { targetElement : 'FiscalYearVariant' , type : #CONSTANT, value : 'V3' },
        { targetElement : 'CalendarDate' , type : #SYSTEM_FIELD, value : '#SYSTEM_DATE' }
    
         ]
        }
        
//    @Consumption.defaultValue: '20250401'
    pFromDate              : budat,
    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
       
    pToDate                : budat,
    @Consumption.defaultValue: 'N'
    @EndUserText.label: 'Include Reverse Entries(Y/N)'
    pIsRevDoc              : z_isrevdoc

  as select from ZTBLF_BANK_STATEMENT(
                           pCompanyCode: $parameters.pCompanyCode,
                           pBankAccountInternalId: $parameters.pBankAccountInternalId,
                           pFromDate: $parameters.pFromDate,
                           pToDate: $parameters.pToDate,
                           pIsRevDoc:$parameters.pIsRevDoc ) _STATEMENT

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
  association [0..1] to I_GLAccountText              as _GLAccount                  on  _GLAccount.ChartOfAccounts = 'YCOA'
                                                                                    and $projection.GLACCOUNT      = _GLAccount.GLAccount
                                                                                    and _GLAccount.Language        = $session.system_language

  association        to ZDIM_BANKMASTER              as _BANK                       on  $projection.BankCode = _BANK.BankAccountInternalID
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

      @ObjectModel.text.element: ['BankName']
      BankCode,

      @Semantics.text: true
      @UI.hidden: true
      concat_with_space(_BANK.BankName,_BANK.BankAccount,1)                        as BankName,

      @ObjectModel.text.element: ['GLACCOUNTNAME']
      GLACCOUNT,

      @Semantics.text: true
      _GLAccount.GLAccountName,

      DOCUMENTDATE,


      cast(REFERENCEDOCUMENTTYPE as awtyp preserving type)                         as REFERENCEDOCUMENTTYPE,
      cast(ORIGINALREFERENCEDOCUMENT as awkey preserving type )                    as ORIGINALREFERENCEDOCUMENT,


      CostCenter,

      @ObjectModel.foreignKey.association: '_CurrentProfitCenter'
      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      ProfitCenter,
      _CurrentProfitCenter._Text.ProfitCenterName,
      _CurrentProfitCenter,

      Plant,
      BusinessPlace,

      @ObjectModel.text.association: '_ControllingAreaText'
      ControllingArea,
      _ControllingAreaText,
      _STATEMENT.ReversalReason,
      _STATEMENT.IsReversal,
      _STATEMENT.IsReversed,
      _STATEMENT.ReversedReferenceDocument,
      _STATEMENT.ReversalReferenceDocument,
      _STATEMENT.ReversedDocument,
      _STATEMENT.ReverseDocument,
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
      cast(case when RUNNINGBALANCE < 0 then 'Cr.' else 'Dr.' end as abap.char(3)) as Sign,
      _JournalEntry,
      _CompanyCode,
      _FiscalYear
}
