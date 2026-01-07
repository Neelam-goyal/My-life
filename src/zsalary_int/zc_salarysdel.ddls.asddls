@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Salary definiton for delete'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SALARYSDEL
provider contract transactional_query
  as projection on ZR_SALARY
{
  key EmployeeCode,
  key DueDate,
  key Plant,
  CompanyCode,
  PostingDate,
  EmployeeType,
  GrossSalary,
  TdsAmount,
  LoanInstallmentAmount,
  AdvanceInstallmentAmount,
  NetPayable,
  Errorlog ,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
where Isposted = '' and Isdeleted = 'X' 
