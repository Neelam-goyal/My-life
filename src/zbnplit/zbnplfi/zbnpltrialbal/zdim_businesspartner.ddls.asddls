@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Partner'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.representativeKey: 'BusinessPartner'
define view entity ZDIM_BusinessPartner
  as select from I_BusinessPartner
  association [0..*] to I_BusinessPartnerGroupingText as _PartnerGroup on  $projection.BusinessPartnerGrouping = _PartnerGroup.BusinessPartnerGrouping
                                                                       and _PartnerGroup.Language              = $session.system_language
  association [0..*] to I_BusinessPartnerTypeText     as _PartnerType  on  $projection.BusinessPartnerType = _PartnerType.BusinessPartnerType
                                                                       and _PartnerType.Language           = $session.system_language
{
      @ObjectModel.text.element: [ 'BusinessPartnerName' ]
  key BusinessPartner,

      PersonNumber,
      ETag,
      @Semantics.text: true
      BusinessPartnerName,
      BusinessPartnerFullName,
      @ObjectModel.foreignKey.association: '_PartnerGroup'
      BusinessPartnerGrouping,
      @ObjectModel.foreignKey.association: '_PartnerType'
      BusinessPartnerType,
      BusinessPartnerIsBlocked,
      FirstName,
      MiddleName,
      LastName,
      PersonFullName,
      _PartnerGroup,
      _PartnerType
}
