@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_SALARY
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
where Isposted = '' and Isdeleted = '' 
