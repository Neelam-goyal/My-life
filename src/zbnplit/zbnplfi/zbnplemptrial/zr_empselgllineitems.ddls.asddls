@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employees Line Items Selected GL'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_EMPSelGLLineItems
  with parameters
    pCompanyCode : bukrs,
    pFromDate    : budat,
    pToDate      : budat
  as select from I_GLAccountLineItem as item
    inner join   ZR_USER_CMPY_ACCESS as _cmpAccess on  _cmpAccess.CompCode = item.CompanyCode
                                                   and _cmpAccess.userid   = $session.user
    inner join   I_BusinessPartner   as _Employee  on  (
         item.Supplier                                                                   = _Employee.BusinessPartner
         or item.Customer                                                                = _Employee.BusinessPartner
       )
                                                   and _Employee.BusinessPartnerGrouping = 'Z005' -- Only Emplyoees
{
  key item.GLAccount,
  key _Employee.BusinessPartner                                                                                                                                                                       as EmpCode,
  item.CompanyCodeCurrency,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when  item.PostingDate <= $parameters.pFromDate then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )                                                                       as OpeningAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when item.PostingDate between $parameters.pFromDate and $parameters.pToDate and item.AmountInCompanyCodeCurrency < 0 then -item.AmountInCompanyCodeCurrency else abap.curr'0.00' end ) as CreditAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when item.PostingDate between $parameters.pFromDate and $parameters.pToDate and item.AmountInCompanyCodeCurrency > 0 then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )  as DebitAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when  item.PostingDate <= $parameters.pToDate then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )                                                                         as ClosingAmt
}
where
       item.SourceLedger                =  '0L'
  and  item.IsReversal                  <> 'X'
  and  item.IsReversed                  <> 'X'
  and  item.FiscalPeriod                >  '000'
  and  item.CompanyCode                 = $parameters.pCompanyCode
  and  item.PostingDate                 <= $parameters.pToDate
  and  item.AmountInCompanyCodeCurrency <> 0
  and(
       item.GLAccount                   =  '0012220000' //Loan and Adv: Emp/SM Loan
    or item.GLAccount                   =  '0012221000' //Loan and Adv: Emp/SM Adv
    or item.GLAccount                   =  '0012212000' //SM Rcv Emp Payable

    or item.GLAccount                   =  '0014107000' //Loan and Adv: Emp/Sm Imprest

    or item.GLAccount                   =  '0012221100' //EMP/SMAN : IMPREST
    or item.GLAccount                   =  '0012216100' //Crate Loan
    or item.GLAccount                   =  '0211011930' //CRATE SECURITY PAYable

    or item.GLAccount                   =  '0021517100' //Emp: Salary and Wages Payable
    or item.GLAccount                   =  '0021517110' //Emp: TA-DA Payable
    or item.GLAccount                   =  '0021517120' //Emp: Crate Security Payable
    or item.GLAccount                   =  '0021517130' //Emp: Incentive Payable
    or item.GLAccount                   =  '0021517140' //Emp: Comm. Payable
    or item.GLAccount                   =  '0021517150' //Emp: Director Payable

    or item.GLAccount                   =  '0021101920' //Incentive Payable Customer
  )
group by
  item.GLAccount,
  _Employee.BusinessPartner,
  item.CompanyCodeCurrency
