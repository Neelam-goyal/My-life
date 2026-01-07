@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Master'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                dataCategory: #VALUE_HELP,
                representativeKey: 'EmpCode',
                semanticKey: [ 'EmpCode' ],
                usageType.sizeCategory: #M,
                usageType.dataClass: #MIXED,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
                modelingPattern: #VALUE_HELP_PROVIDER

                }

@Search.searchable: true
@Consumption.ranked: true


define view entity Z_Employee

  as select from I_Supplier
    inner join   I_SupplierCompany as sc on I_Supplier.Supplier = sc.Supplier
{
      @EndUserText.label: 'Employee'
      @ObjectModel.text.element: ['EmpName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key I_Supplier.Supplier                            as EmpCode,
      @EndUserText.label: 'Employee Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      //@Search.ranking: #HIGH
      @Search.ranking: #LOW
      @EndUserText.quickInfo: 'Supplier Name'
      I_Supplier.OrganizationBPName1                 as EmpName,



      @Consumption.valueHelpDefinition: [
                  { entity:  { name:    'I_CompanyCodeStdVH',
                               element: 'CompanyCode' }
                  }]
      @UI.hidden: true
      cast(sc.CompanyCode as bukrs preserving type ) as CompanyCode

}
where
  I_Supplier.SupplierAccountGroup = 'Z005' -- Only Employee
