@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employees Cube Selected GL'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_PROVIDER ],
  modelingPattern: #ANALYTICAL_CUBE
}
define view entity ZC_EMPSelGLLineItems
  with parameters

    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '20250401'
    pFromDate    : budat,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pToDate      : budat

  as select from ZR_EMPSelGLLineItems(
                 pCompanyCode : $parameters.pCompanyCode,
                 pFromDate:$parameters.pFromDate,
                 pToDate:$parameters.pToDate
                 ) as item

  association [0..1] to ZDIM_GLAccount    as _GLAccount on $projection.GLAccount = _GLAccount.GLAccount

  association [0..1] to I_BusinessPartner as _Employee  on $projection.EmpCode = _Employee.BusinessPartner


{

  @EndUserText.label: 'G/L Account'
  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_GLAccountStdVH',
               element: 'GLAccount' }
  }]
  @ObjectModel.foreignKey.association: '_GLAccount'
  item.GLAccount,

  @EndUserText.label: 'EmpCode'
  @ObjectModel.foreignKey.association: '_Employee'
  item.EmpCode,

  @EndUserText.label: '_Currency'
  item.CompanyCodeCurrency,

  @EndUserText.label: 'Opening'
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  @DefaultAggregation: #SUM
  item.OpeningAmt,

  @EndUserText.label: 'Credit'
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  @DefaultAggregation: #SUM
  item.CreditAmt,

  @EndUserText.label: 'Debit'
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  @DefaultAggregation: #SUM
  item.DebitAmt,

  @EndUserText.label: 'Closing'
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  @DefaultAggregation: #SUM
  item.ClosingAmt,

  _GLAccount,
  _Employee
}
