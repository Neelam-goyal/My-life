@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label:  'DIM CDS for Storage Location'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//@Analytics.dataCategory: #DIMENSION

@ObjectModel.representativeKey: 'StorageLocation'
define view entity ZDIM_StorageLocation 
as 
select from I_StorageLocation

{
    key Plant, -- Key filter
    @ObjectModel.text.element: [ 'StorageLocationName' ]
    key StorageLocation,
    @Semantics.text: true
    StorageLocationName 
//    SalesOrganization,
//    DistributionChannel,
//    Division,
//    IsStorLocAuthznCheckActive,
//    HandlingUnitIsRequired,
//    ConfigDeprecationCode,
//    /* Associations */
//    _ConfignDeprecationCode,
//    _Plant
}
