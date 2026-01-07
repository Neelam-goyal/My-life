@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Salary posted definition'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SALARYPOSTED
 provider contract transactional_query
  as projection on ZR_SALARY
{
  key EmployeeCode,
  key DueDate,
  key Plant,
  CompanyCode,
  PostingDate,
  EmployeeType,
  Accountingdocument,
  Accountingdocument2,
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
where Isposted = 'X' and Isdeleted = '' 
    
