@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR SALARY EXPENSES'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZCDS_SALESEXPENSES as select from zsalaryexpenses
{
   @EndUserText.label: 'Eemploye Type'
    key employetype as Employetype,
    @EndUserText.label: 'Document Date'
    key salarydate as Salarydate,
//    @EndUserText.label: 'Posting Date'
//    key postingdate as postingdate,
//    @EndUserText.label: 'Company Code'
//    companycode as Companycode,
    @EndUserText.label: 'Plant Code'
    key plantcode as Plantcode,
    @EndUserText.label: 'Salary Expenses'
    salaryexpenses as Salaryexpenses,
    @EndUserText.label: 'Salary Payable'
    salarypayable as Salarypayable,
    @EndUserText.label: 'PLWF Payable'
    plwfpayable as Plwfpayable,
    @EndUserText.label: 'GHIDeduction'
    ghideduction as Ghideduction,
    @EndUserText.label: 'PF Payable'
    pfpayable as Pfpayable,
    @EndUserText.label: 'ESI Payable'
    esipayable as Esipayable,
    @EndUserText.label: 'PT Deduction'
    ptdeduction as Ptdeduction,
    @EndUserText.label: 'VPF Payable'
    vpfpayable as Vpfpayable,
    @EndUserText.label: 'Is Posted'
    isposted as Isposted,
    @EndUserText.label: 'Accounting Document'
    accountingdocument as Accountingdocument,
    @EndUserText.label: 'Error Message'
    errorlog as Errormessage,
    @EndUserText.label: 'IsDeleted'
    isdeleted as Isdeleted,
    @EndUserText.label: 'Created By'
    created_by         as abp_creation_user,
    @EndUserText.label: 'Created At'
    created_at         as abp_creation_tstmpl,
    @EndUserText.label: 'Last Changed By'
    last_changed_by    as abp_locinst_lastchange_user,
    @EndUserText.label: 'Last Changed At'
    last_changed_at    as abp_locinst_lastchange_tstmpl
}
where isdeleted != 'X'
