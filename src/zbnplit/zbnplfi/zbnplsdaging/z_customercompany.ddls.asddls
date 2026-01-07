
@EndUserText.label: 'Customers with Company'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                dataCategory: #VALUE_HELP,
                representativeKey: 'Customer',
                semanticKey: [ 'Customer' ],
                usageType.sizeCategory: #M,
                usageType.dataClass: #MIXED,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
                modelingPattern: #VALUE_HELP_PROVIDER

                }
define view entity Z_CustomerCompany 
as 
select from I_CustomerCompany
{

      @EndUserText.label: 'Customer'
      @ObjectModel.text.element: ['CustomerName']
  key cast(Customer as kunnr preserving type)     as Customer,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_CompanyCodeStdVH',
                   element: 'CompanyCode' }
      }]
      cast(CompanyCode as bukrs preserving type ) as CompanyCode,
      @EndUserText.label: 'CustomerName Name'
      @Semantics.text: true
//      @Search: { defaultSearchElement: true, ranking: #LOW,fuzzinessThreshold: 0.7 }
      _Customer.CustomerName                      as CustomerName
}
