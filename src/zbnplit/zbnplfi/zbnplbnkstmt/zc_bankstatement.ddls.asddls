@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stmt. of Bank in a Company'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_BankStatement
  with parameters
    pCompanyCode           : bukrs,
    pBankAccountInternalId : zbnkacintid,
    pFromDate              : budat,
    pToDate                : budat,
    @Consumption.defaultValue: 'N'
    pIsRevDoc              : abap.char(1)
  as select from ZR_BankStatement as item
{
  key item.CompanyCode,
  key cast('0000000000' as abap.char(10))                                                                                      as AccountingDocument,
  key cast('0000'as abap.numc(4))                                                                                              as FiscalYear,
  key cast('000'as abap.numc(3))                                                                                               as AccountingDocumentItem,

      $parameters.pBankAccountInternalId                                                                                       as BankCode,

      cast('0000000000' as abap.char(10))                                                                                      as GLAccount,

      $parameters.pFromDate                                                                                                    as PostingDate,
      $parameters.pFromDate                                                                                                    as DocumentDate,
      cast('OB' as abap.char(2))                                                                                               as AccountingDocumentType,
      cast('OPBAL' as abap.char(5))                                                                                            as ReferenceDocumentType,
      cast('0000000000' as abap.char(20))                                                                                      as OriginalReferenceDocument,
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
      case when sum(item.AmountInCompanyCodeCurrency) < 0 then abap.curr'0.00' else  sum(item.AmountInCompanyCodeCurrency) end as DebitAmountInCmpCdCrcy
}
where
      item.CompanyCode           = $parameters.pCompanyCode
  and item.Bankaccountinternalid = $parameters.pBankAccountInternalId
  and item.PostingDate           < $parameters.pFromDate
  and case when $parameters.pIsRevDoc = 'N'
        then
           item.IsRevDoc
        else
            1 end                = 1
group by
  item.CompanyCode,
  item.CompanyCodeCurrency

union all

select from ZR_BankStatement as item
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
  key AccountingDocumentItem,
      Bankaccountinternalid                                                                                          as BankCode,

      GLAccount,

      PostingDate,
      DocumentDate,
      AccountingDocumentType,
      ReferenceDocumentType,
      OriginalReferenceDocument,

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
      ReversedReferenceDocument,
      ReversalReferenceDocument,
      ReversedDocument,
      ReverseDocument,


      CompanyCodeCurrency,
      DebitCreditCode,
      AmountInCompanyCodeCurrency,

      case when item.AmountInCompanyCodeCurrency < 0 then -item.AmountInCompanyCodeCurrency else abap.curr'0.00' end as CreditAmountInCmpCdCrcy,
      case when item.AmountInCompanyCodeCurrency < 0 then abap.curr'0.00' else  item.AmountInCompanyCodeCurrency end as DebitAmountInCmpCdCrcy

}
where
      item.CompanyCode                 = $parameters.pCompanyCode
  and item.Bankaccountinternalid       = $parameters.pBankAccountInternalId
  and item.PostingDate                 >= $parameters.pFromDate
  and item.PostingDate                 <= $parameters.pToDate
  and item.AmountInCompanyCodeCurrency <> 0
  and case when $parameters.pIsRevDoc = 'N'
        then
           item.IsRevDoc
        else
            1 end                      =  1
