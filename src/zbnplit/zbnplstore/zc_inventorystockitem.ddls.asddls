@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Stock Line Item From and To Date'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_INVENTORYSTOCKITEM
  with parameters
    @EndUserText.label: 'Company'
    pCompany    : bukrs,

    @EndUserText.label: 'Plant'
    pPrdnPlant  : werks_d,

    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate
  as select from ZR_INVENTORYSTOCKITEM
{
  key $parameters.pCompany             as CompanyCode,
  key $parameters.pPrdnPlant           as Plant,
  key StorageLocation,
  key Material,
  key cast('561' as bwart)             as GoodsMovementType,
      cast('' as kostl)                as CostCenter,
      cast('00000000' as abap.numc(8)) as WBSElementInternalID,
      cast('' as shkzg)                as DebitCreditCode,
      cast('OB' as abap.char(2))       as TransType,

      MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum(QuantityInBaseUnit)          as QuantityInBaseUnit,
      CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum(TotalGoodsMvtAmtInCCCrcy)    as TotalGoodsMvtAmtInCCCrcy
}
where
      CompanyCode = $parameters.pCompany
  and Plant       = $parameters.pPrdnPlant
  and PostingDate < $parameters.p_date_from
group by
  CompanyCode,
  StorageLocation,
  Material,
  MaterialBaseUnit,
  CompanyCodeCurrency
union all select from ZR_INVENTORYSTOCKITEM
{
  key $parameters.pCompany          as CompanyCode,
  key $parameters.pPrdnPlant        as Plant,
  key StorageLocation,
  key Material,
  key GoodsMovementType,
      CostCenter,
      WBSElementInternalID,
      DebitCreditCode,
      cast('TR' as abap.char(2))    as TransType,
      MaterialBaseUnit,
      sum(QuantityInBaseUnit)       as QuantityInBaseUnit,
      CompanyCodeCurrency,
      sum(TotalGoodsMvtAmtInCCCrcy) as TotalGoodsMvtAmtInCCCrcy
}
where
      CompanyCode = $parameters.pCompany
  and Plant       = $parameters.pPrdnPlant
  and PostingDate between $parameters.p_date_from and $parameters.p_date_to
group by
  StorageLocation,
  Material,
  GoodsMovementType,
  CostCenter,
  WBSElementInternalID,
  DebitCreditCode,
  MaterialBaseUnit,
  CompanyCodeCurrency
