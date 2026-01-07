@AbapCatalog.sqlViewName: 'ZVH_CUSTMST'
@AbapCatalog.compiler.compareFilter: true

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Master Help View'
@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #BASIC

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'Customer'

@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,
                                     #CDS_MODELING_DATA_SOURCE,
                                     #CDS_MODELING_ASSOCIATION_TARGET,
                                     #VALUE_HELP_PROVIDER,
                                     #ANALYTICAL_DIMENSION,
                                     #SEARCHABLE_ENTITY]
@ObjectModel.modelingPattern: #ANALYTICAL_DIMENSION                                     
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.dataClass: #MASTER
@ClientHandling.algorithm: #SESSION_VARIABLE

@Search.searchable: true
@Consumption.ranked: true

define view ZVH_CustomerMaster
as select from I_Customer
{
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key Customer,
      @EndUserText.label: 'Customer Name'
      CustomerName,
      @EndUserText.label: 'GSTIN'
      TaxNumber3,
      @EndUserText.label: 'City'
      CityName
      //      @EndUserText.label: 'District'
      //      DistrictName,
      //      @EndUserText.label: 'Business Partner Customer Name'
      //      I_Customer.BPCustomerName
}
