@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bread Account Statment ZC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_BREADACDATA
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @Consumption.semanticObject: 'Z_CustomerAndSupplier'
    @EndUserText.label: 'Party (Supplier/Customer)'
    @Consumption.valueHelpDefinition: [{entity.name: 'Z_CustomerAndSupplier', entity.element: 'PartyCode',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    pCust_Supp   : kunnr,

    @EndUserText.label: 'GL Account'
    @Consumption.valueHelpDefinition: [{entity.name: 'Z_GLAccounts', entity.element: 'GLAccount',useForValidation: true,
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompanyCode', element: 'CompanyCode'}]}]
    @Consumption.defaultValue: '0010011001'
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
    pIsRevDoc    : z_isrevdoc,

    @Consumption.defaultValue: 'N'
    @EndUserText.label: 'Exclude Spl. GL(Y/N)'
    pIsExcSplGL  : z_isrevdoc
  as select from ZR_BREADACData as item
{
  key item.CompanyCode,
  key cast('0000000000' as abap.char(10))                                                                                      as AccountingDocument,
  key cast('0000'as abap.numc(4))                                                                                              as FiscalYear,
  key cast('000'as abap.numc(3))                                                                                               as AccountingDocumentItem,

      $parameters.pCust_Supp                                                                                                   as PartyCode,
      PartyName,
      cast('0000000000' as abap.char(10))                                                                                      as GLAccount,
      cast('' as abap.char(20))                                                                                                as GLAccountName,
      $parameters.pFromDate                                                                                                    as PostingDate,
      $parameters.pFromDate                                                                                                    as DocumentDate,
      cast('OB' as abap.char(2))                                                                                               as AccountingDocumentType,
      cast('OPBAL' as abap.char(5))                                                                                            as ReferenceDocumentType,
      cast('0000000000' as abap.char(20))                                                                                      as OriginalReferenceDocument,
      cast('0000000000' as abap.char(16))                                                                                      as DocumentReferenceID,

      cast('0000000000' as abap.char(30))                                                                                      as PaymentReference,
      cast('0000000000' as abap.char(10))                                                                                      as InvoiceReference,
      cast('0000000000' as abap.char(10))                                                                                      as SalesDocument,
      cast('0000000000' as abap.char(10))                                                                                      as PurchasingDocument,
      cast('' as abap.char(50))                                                                                                as DocumentItemText,

      cast('' as abap.char(4))                                                                                                 as BusinessTransactionType,
      cast('' as kostl)                                                                                                        as CostCenter,
      cast('' as prctr)                                                                                                        as ProfitCenter,
      cast('' as abap.char(16))                                                                                                as FunctionalArea,
      cast('' as abap.char(4))                                                                                                 as BusinessArea,
      cast('' as abap.char(4))                                                                                                 as BusinessPlace,
      cast('' as abap.char(10))                                                                                                as Segment,
      cast('' as abap.char(4))                                                                                                 as Plant,
      cast('' as abap.char(4))                                                                                                 as ControllingArea,

      cast('' as    stgrd)                                                                                                     as ReversalReason,
      cast('' as abap.char(1))                                                                                                 as IsReversal,
      cast('' as abap.char(1))                                                                                                 as IsReversed,
      cast('' as abap.char(1))                                                                                                 as SpecialGLCode,
      cast('' as abap.char(1))                                                                                                 as SpecialGLTransactionType,
      cast('' as abap.char(10))                                                                                                as ReversedReferenceDocument,
      cast('' as abap.char(10))                                                                                                as ReversalReferenceDocument,
      cast('' as abap.char(10))                                                                                                as ReversedDocument,
      cast('' as abap.char(10))                                                                                                as ReverseDocument,

      item.CompanyCodeCurrency                                                                                                 as CompanyCodeCurrency,
      cast(case when sum(item.AmountInCompanyCodeCurrency) < 0 then 'H' else 'S' end as abap.char(1))                          as DebitCreditCode,

      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(item.AmountInCompanyCodeCurrency)                                                                                    as AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case when sum(item.AmountInCompanyCodeCurrency) < 0 then -sum(item.AmountInCompanyCodeCurrency) else abap.curr'0.00' end as CreditAmountInCmpCdCrcy,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case when sum(item.AmountInCompanyCodeCurrency) < 0 then abap.curr'0.00' else  sum(item.AmountInCompanyCodeCurrency) end as DebitAmountInCmpCdCrcy,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      cast('0.00' as abap.curr(23,2))                                                                                          as TDSAmountInCmpCdCrcy
}
where
                                                      item.CompanyCode     = $parameters.pCompanyCode
  and                                                 item.PartyCode       = $parameters.pCust_Supp
  and                                                 item.PostingDate     < $parameters.pFromDate
  and                                                 case when $parameters.pIsRevDoc = 'N'
                                                        then
                                                           item.IsRevDoc
                                                        else
                                                            1 end          = 1

  and                                                 case when $parameters.pIsExcSplGL = 'N'
                                                        then
                                                           1
                                                        else
                                                            IsExcSplGL end = 1
  and                                                 case when $parameters.pGLAccount is initial or  $parameters.pGLAccount = '0010011001'
                                                      then 1
                                                      when  item.GLAccount = $parameters.pGLAccount then 1
                                                      else 0
                                                      end                  = 1
group by
  item.CompanyCode,
  item.PartyName,
  item.CompanyCodeCurrency

union all

select from ZR_BREADACData as item
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
  key AccountingDocumentItem,
      PartyCode,
      PartyName,
      GLAccount,
      GLAccountName,
      PostingDate,
      DocumentDate,
      AccountingDocumentType,
      ReferenceDocumentType,
      OriginalReferenceDocument,
      DocumentReferenceID,
      PaymentReference,
      InvoiceReference,
      SalesDocument,
      PurchasingDocument,
      DocumentItemText,

      BusinessTransactionType,
      CostCenter,
      ProfitCenter,
      FunctionalArea,
      BusinessArea,
      BusinessPlace,
      Segment,
      Plant,
      ControllingArea,
      ReversalReason,
      IsReversal,
      IsReversed,
      SpecialGLCode,
      SpecialGLTransactionType,

      ReversedReferenceDocument,
      ReversalReferenceDocument,
      ReversedDocument,
      ReverseDocument,


      CompanyCodeCurrency,
      DebitCreditCode,
      AmountInCompanyCodeCurrency,

      case when item.AmountInCompanyCodeCurrency < 0 then -item.AmountInCompanyCodeCurrency else abap.curr'0.00' end as CreditAmountInCmpCdCrcy,
      case when item.AmountInCompanyCodeCurrency < 0 then abap.curr'0.00' else  item.AmountInCompanyCodeCurrency end as DebitAmountInCmpCdCrcy,

      TDSAmtinCmpCodeCurr                                                                                            as TDSAmountInCmpCdCrcy
}
where
                                                      item.CompanyCode                 = $parameters.pCompanyCode
  and                                                 item.PartyCode                   = $parameters.pCust_Supp
  and                                                 item.PostingDate                 >= $parameters.pFromDate
  and                                                 item.PostingDate                 <= $parameters.pToDate
  and                                                 item.AmountInCompanyCodeCurrency <> 0
  and                                                 case when $parameters.pIsRevDoc = 'N'
                                                        then
                                                           item.IsRevDoc
                                                        else
                                                            1 end                      =  1
  and                                                 case when $parameters.pIsExcSplGL = 'N'
                                                        then
                                                           1
                                                        else
                                                            IsExcSplGL end             =  1
  and                                                 case when $parameters.pGLAccount is initial or  $parameters.pGLAccount = '0010011001'
                                                      then 1
                                                      when  item.GLAccount = $parameters.pGLAccount then 1
                                                      else 0
                                                      end                              =  1
