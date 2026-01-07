@Metadata.allowExtensions: true
@EndUserText.label: 'Loan Master'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_LOANMASTER
  provider contract transactional_query
  as projection on ZR_LOANMASTER
{
  key CompCode,
  key LoanNo,
  LoanDate,
  EmployeeId,
  EmployeeName,
  Department,
  LoanType,
  LoanAmount,
  @UI.hidden: true
  EMICount,
  EMIAmount,
  Approved,
  ApprovedBy,
  DeductedFrom,
  InterestAmount,
  TotalAmount,
  BalanceAmount,
  PaymentMode,
  BankCode,
  BankName,
  Narration,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
