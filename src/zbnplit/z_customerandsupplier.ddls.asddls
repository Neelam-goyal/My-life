@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Common View for Customers and Suppliers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                dataCategory: #VALUE_HELP,
                representativeKey: 'PartyCode',
                semanticKey: [ 'PartyCode' ],
                usageType.sizeCategory: #M,
                usageType.dataClass: #MIXED,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
                modelingPattern: #VALUE_HELP_PROVIDER

                }

@Search.searchable: true
@Consumption.ranked: true


define view entity Z_CustomerAndSupplier

  as select from I_Supplier
    inner join   I_SupplierCompany as sc on I_Supplier.Supplier = sc.Supplier
{
      @EndUserText.label: 'Party Code'
      @ObjectModel.text.element: ['PartyName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key I_Supplier.Supplier                            as PartyCode,
      @EndUserText.label: 'Party Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      //@Search.ranking: #HIGH
      @Search.ranking: #LOW
      @EndUserText.quickInfo: 'Party Name'
      I_Supplier.OrganizationBPName1                 as PartyName,



      @Consumption.valueHelpDefinition: [
                  { entity:  { name:    'I_CompanyCodeStdVH',
                               element: 'CompanyCode' }
                  }]
      @UI.hidden: true
      cast(sc.CompanyCode as bukrs preserving type ) as CompanyCode

}
where
  I_Supplier.SupplierAccountGroup <> 'Z005' -- Only Employee

union

select from  I_Customer
  inner join I_CustomerCompany as sc on I_Customer.Customer = sc.Customer
{

  key I_Customer.Customer                            as PartyCode,

      I_Customer.OrganizationBPName1                 as PartyName,

      cast(sc.CompanyCode as bukrs preserving type ) as CompanyCode

}
