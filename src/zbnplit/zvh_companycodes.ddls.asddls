@AbapCatalog.sqlViewName: 'ZVH_COMPCODES'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Master Help View'
@Metadata.ignorePropagatedAnnotations: true
//@AbapCatalog.compiler.compareFilter: true
//@ObjectModel: { dataCategory: #VALUE_HELP,
//                representativeKey: 'CompanyCode',
//                usageType.sizeCategory: #S,
//                usageType.dataClass: #ORGANIZATIONAL,
//                usageType.serviceQuality: #A,
//                supportedCapabilities: [#VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY],
//                modelingPattern: #VALUE_HELP_PROVIDER }
@Search.searchable: true

define view ZVH_CompanyCodes
  as select from I_CompanyCode
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key CompanyCode,
      @Semantics.text: true
      @Search: { defaultSearchElement: true, ranking: #LOW }
      CompanyCodeName,
      CityName
}
