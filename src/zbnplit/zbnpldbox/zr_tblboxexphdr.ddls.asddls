@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View DBox Expense Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_TBLBOXEXPHDR
  as select from ztbldboxexphdr
  composition [0..*] of ZR_TBLBOXEXPDTL as _Details
{
  key applied_expense_id       as AppliedExpenseId,

      reimb_code               as ReimbCode,
      employee_no              as EmployeeNo,
      employee_name            as EmployeeName,
      designation              as Designation,
      department               as Department,
      cost_center              as CostCenter,
      claimed_by               as ClaimedBy,
      company_name             as CompanyName,
      group_company_code       as GroupCompanyCode,
      claim_title              as ClaimTitle,
      applied_date             as AppliedDate,
      responder                as Responder,
      approved_or_rejected_on  as ApprovedOrRejectedOn,
      responder_comment        as ResponderComnt,
      pending_with             as PendingWith,
      advance_id               as AdvanceID,
      advance_name             as AdvanceName,
      advance_amount           as AdvanceAmount,
      advance_amt_def_curr     as AdvanceAmtDefCurr,
      advance_type             as AdvanceType,
      advance_processed_on     as AdvanceProcessedOn,
      project_name_with_code   as ProjectNameWithCode,
      project_name             as ProjectName,
      project_code             as ProjectCode,
      acted_by                 as ActedBy,
      advance_payment_status   as AdvancePaymentStatus,
      trip_unique_id           as TripUniqueID,
      trip_id                  as TripID,
      trip_name                as TripName,
      trip_description         as TripDescription,
      trip_start_date          as TripStartDate,
      trip_end_date            as TripEndDate,
      settlement_amount        as SettlementAmount,
      settlement_amt_base_curr as SettlementAmtBaseCurr,
      settlement_amt_def_curr  as SettlementAmtDefCurr,
      settlement_type          as SettlementType,
      settled_by               as SettledBy,
      settled_on               as SettledOn,
      paid_date                as PaidDate,
      paid_by                  as PaidBy,
      sap_companycode          as SapCompanycode,
      sap_accountingdocument   as SapAccountingdocument,
      sap_fiscalyear           as SapFiscalyear,
      status                   as Status,
      payment_status           as PaymentStatus,
      transaction_id           as TransactionID,
      payment_comments         as PaymentComments,
      overall_comments         as OverallComments,
      item_total               as ItemTotal,
      claimed_item_total       as ClaimedItemTotal,
      processed_item_total     as ProcessedItemTotal,
      total_claimed_amount     as TotalClaimedAmount,
      total_processed_amount   as TotalProcessedAmount,


      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by    as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,

      // Composition to details for RAP
      _Details
}
