@EndUserText.label: 'Suppliers with Company'
//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel: {
//                dataCategory: #VALUE_HELP,
//                representativeKey: 'Supplier',
//                semanticKey: [ 'Supplier' ],
//                usageType.sizeCategory: #M,
//                usageType.dataClass: #MIXED,
//                usageType.serviceQuality: #A,
//                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
//                modelingPattern: #VALUE_HELP_PROVIDER
//
//                }
//define view entity Z_SupplierCompany
//  as select from I_SupplierCompany
//{
//
//      @EndUserText.label: 'Supplier'
//      @ObjectModel.text.element: ['SupplierName']
//  key cast(Supplier as lifnr preserving type)     as Supplier,
//      @Consumption.valueHelpDefinition: [
//      { entity:  { name:    'I_CompanyCodeStdVH',
//                   element: 'CompanyCode' }
//      }]
//      cast(CompanyCode as bukrs preserving type ) as CompanyCode,
//      @EndUserText.label: 'SupplierName Name'
//      @Semantics.text: true
//      //      @Search: { defaultSearchElement: true, ranking: #LOW,fuzzinessThreshold: 0.7 }
//      _Supplier.SupplierName                      as SupplierName
//}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                dataCategory: #VALUE_HELP,
                representativeKey: 'Supplier',
                semanticKey: [ 'Supplier' ],
                usageType.sizeCategory: #M,
                usageType.dataClass: #MIXED,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
                modelingPattern: #VALUE_HELP_PROVIDER

                }

@Search.searchable: true
@Consumption.ranked: true


define view entity Z_SupplierCompany

  as select from I_Supplier
    inner join   I_SupplierCompany as sc on I_Supplier.Supplier = sc.Supplier
{
      @EndUserText.label: 'Supplier'
      @ObjectModel.text.element: ['SupplierName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key I_Supplier.Supplier,
      @EndUserText.label: 'Supplier Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      //@Search.ranking: #HIGH
      @Search.ranking: #LOW
      @EndUserText.quickInfo: 'Supplier Name'
      I_Supplier.OrganizationBPName1                 as SupplierName,

      @Consumption.valueHelpDefinition: [
                  { entity:  { name:    'I_CompanyCodeStdVH',
                               element: 'CompanyCode' }
                  }]
      @UI.hidden: true
      cast(sc.CompanyCode as bukrs preserving type ) as CompanyCode

}
