@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZPOC_ERRORLOG000'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_POC_ERRORLOG000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_POC_ERRORLOG000
  association [1..1] to ZR_POC_ERRORLOG000 as _BaseEntity on $projection.PLANT = _BaseEntity.PLANT and $projection.MANUFACTURINGORDER = _BaseEntity.MANUFACTURINGORDER and $projection.ERRORTIMESTAMP = _BaseEntity.ERRORTIMESTAMP
{
  key Plant,
  key Manufacturingorder,
  key Errortimestamp,
  Yieldquantity,
  Errormessage,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
