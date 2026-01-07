@AbapCatalog.sqlViewName: 'ZSUPPLIERVH'
@AbapCatalog.compiler.compareFilter: true

@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'Supplier'

@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,
                                     #CDS_MODELING_DATA_SOURCE,
                                     #CDS_MODELING_ASSOCIATION_TARGET,
                                     #VALUE_HELP_PROVIDER,
                                     #SEARCHABLE_ENTITY]
@ObjectModel.modelingPattern: #NONE
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.dataClass: #MASTER

@AccessControl.authorizationCheck: #CHECK
//<TODO> Please double-check personal data blocking
//@AccessControl.personalData.blocking: #REQUIRED

@ClientHandling.algorithm: #SESSION_VARIABLE

@Search.searchable: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Suppliers Value Help'
@Consumption.ranked: true

define view Z_Supplier_VH
  as select from    I_Supplier
    left outer join I_RegionText as _RegionText on  I_Supplier.Region    = _RegionText.Region
                                                and I_Supplier.Country   = _RegionText.Country
                                                and _RegionText.Language = $session.system_language

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
      @Search.ranking: #MEDIUM
      @EndUserText.quickInfo: 'Supplier Name'
      I_Supplier.OrganizationBPName1 as SupplierName,

      @Semantics.text:true
      @EndUserText.label: 'GSTIN'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      //@Search.ranking: #HIGH
      @Search.ranking: #LOW
      @EndUserText.quickInfo: 'GSTIN'
      I_Supplier.TaxNumber3          as GSTIN,

      @EndUserText.label: 'City'
      I_Supplier.CityName            as City,

      @EndUserText.label: 'State'
      _RegionText.RegionName         as Region,

      @EndUserText.label: 'Country'
      I_Supplier.Country
}
