@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Loan Master'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_LOANMASTER
  as select from zloanmaster
{
  key comp_code as CompCode,
  key loan_no as LoanNo,
  loan_date as LoanDate,
  employee_id as EmployeeId,
  employee_name as EmployeeName,
  department as Department,
  loan_type as LoanType,
  loan_amount as LoanAmount,
  emi_count as EMICount,
  emi_amount as EMIAmount,  
  approved as Approved,
  approved_by as ApprovedBy,
  deducted_from as DeductedFrom,
  interest_amount as InterestAmount,
  total_amount as TotalAmount,
  balance_amount as BalanceAmount,
  payment_mode as PaymentMode,
  bank_code as BankCode,
  bank_name as BankName,
  narration as Narration,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
