@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DIM CDS for Tax Code'
@Metadata.ignorePropagatedAnnotations: true


define view entity ZDIM_TAXCode
  as select from I_TaxCode      as _Tax
    inner join   ZR_TaxCodeRate as _TaxRate on  _TaxRate.TaxCalculationProcedure = _Tax.TaxCalculationProcedure
                                            and _TaxRate.TaxCode                 = _Tax.TaxCode
    inner join   I_TaxCodeText  as _Text    on  _Tax.TaxCalculationProcedure = _Text.TaxCalculationProcedure
                                            and _Tax.TaxCode                 = _Text.TaxCode
                                            and _Text.Language               = 'E'

  association [0..1] to I_TaxType as _TaxType on $projection.TaxType = _TaxType.TaxType


{
  key _Tax.TaxCode,
  key _TaxRate.CndnRecordValidityStartDate,
      _Text.TaxCodeName,
      @ObjectModel.foreignKey.association: '_TaxType'
      _Tax.TaxType,
      _TaxRate.TaxRate,
      _TaxRate.SGSTRate,
      _TaxRate.CGSTRate,
      _TaxRate.IGSTRate,

      _Tax.TargetTaxCode,
      _Tax.IsSalesTaxes,
      _Tax.TaxCategory,
      _Tax.TaxReturnCountry,
      _Tax.TaxCodeIsInactive,
      _TaxType
}
where
  _Tax.TaxCalculationProcedure = '0TXIN'
