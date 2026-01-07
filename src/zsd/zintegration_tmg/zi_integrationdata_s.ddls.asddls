@EndUserText.label: 'Integration Data Singleton'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'IntegrationDataAll'
  }
}
define root view entity ZI_IntegrationData_S
  as select from I_Language
    left outer join zintegration_tmg on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_IntegrationData as _IntegrationData
{
  @UI.facet: [ {
    id: 'ZI_IntegrationData', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Integration Data', 
    position: 1 , 
    targetElement: '_IntegrationData'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _IntegrationData,
  @UI.hidden: true
  max( zintegration_tmg.local_last_changed_at ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 2 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as sxco_transport) as TransportRequestID,
  _ABAPTransportRequestText
  
}
where I_Language.Language = $session.system_language
