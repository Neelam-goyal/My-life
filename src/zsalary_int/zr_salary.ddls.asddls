@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_SALARY
  as select from zsalary
{
  key employee_code as EmployeeCode,
  key due_date as DueDate,
  key plant as Plant,
  company_code as CompanyCode,
  posting_date as PostingDate,
  employee_type as EmployeeType,
  accountingdocument as Accountingdocument,
  accountingdocument2 as Accountingdocument2,
  gross_salary as GrossSalary,
  tds_amount as TdsAmount,
  loan_installment_amount as LoanInstallmentAmount,
  advance_installment_amount as AdvanceInstallmentAmount,
  net_payable as NetPayable,
  errorlog  as Errorlog,
  isposted as Isposted,
  isdeleted as Isdeleted,
  isvalidate as Isvalidate,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy, 
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
  
}
