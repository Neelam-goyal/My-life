@EndUserText.label: 'TABLE FOR TAX CODE Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'TableForTaxCodeAll'
  }
}
define root view entity ZI_TableForTaxCode_S
  as select from I_Language
    left outer join zwht_taxcode on 0 = 0
  composition [0..*] of ZI_TableForTaxCode as _TableForTaxCode
{
  @UI.facet: [ {
    id: 'ZI_TableForTaxCode', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'TABLE FOR TAX CODE', 
    position: 1 , 
    targetElement: '_TableForTaxCode'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _TableForTaxCode,
  @UI.hidden: true
  max( zwht_taxcode.last_changed_at ) as LastChangedAtMax
  
}
where I_Language.Language = $session.system_language
