@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Expense Details'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZC_DBoxExpDtls
  as projection on ZR_TBLBOXEXPDTL
{
  key AppliedExpenseId,
  key ItemSeq,
      Description,
      ItemCode,
      Type,
      Ledger,
      ExpenseCategory,
      ProjectCode,
      InvoiceNumber,
      DateOfExpense,
      ConversionFactor,
      Currency,
      ClaimedAmount,
      ApprovedAmount,
      ProcessedAmount,
      UnitQty,
      IsExceeded,
      IsExceededText,
      TravelId,
      TripUniqueId,
      TripId,
      TravelDetails,
      TravelProjectCode,
      TravelTypeTagged,
      ClaimedAmtBaseCurrTxt,
      ClaimedAmtDefCurrTxt,
      ClaimedAmtConvFactorTxt,
      ApprovedAmtBaseCurrTxt,
      ApprovedAmtDefCurrTxt,
      ApprovedAmtConvFactorTxt,
      ProcessedAmtBaseCurrTxt,
      ProcessedAmtDefCurrTxt,
      ProcessedAmtConvFactorTxt,
      IsBillable,
      StartDate,
      EndDate,
      Location,
      VehicleType,
      FromLocation,
      ToLocation,
      DistanceTxt,
      AdminComments,
      NoOfParticipants,
      ParticipantWiseSplitStr,
      CoPaymentPercent,
      CoPaymentAmount,
      DependentName,
      BudgetApplied,
      TaxGroup,
      CustomFieldsStr,
      ItemCostCentersStr,
      AttachmentsStr,
      Status,
      Merchant,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Association to projected parent */
      _Header : redirected to parent ZC_DBOXEXPHDR
}
