@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Consumption.ranked:true
@VDM.viewType: #BASIC
@ObjectModel: { representativeKey: 'BusinessPlace',
                dataCategory: #VALUE_HELP,
                usageType.serviceQuality: #A,
                usageType.sizeCategory: #S,
                usageType.dataClass: #ORGANIZATIONAL }

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER ]
@EndUserText.label: 'Business Places Dimension'
define view entity ZDIM_BusinessPlace
  as select from I_BusinessPlaceVH
{
      @Search.defaultSearchElement:true
      @Search.fuzzinessThreshold:0.7
      @Search.ranking:#LOW
  key CompanyCode,
      @Search.defaultSearchElement:true
      @Search.fuzzinessThreshold:0.8
      @Search.ranking:#HIGH
      @ObjectModel.text.element:['BusinessPlaceDescription']
  key BusinessPlace,
      //    @Search.defaultSearchElement:true
      @Semantics.text:true
      BusinessPlaceDescription

}
