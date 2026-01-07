@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZSchemeLines'
define view entity ZI_ZSchemeLines01TP
  as projection on ZR_ZSchemeLines01TP as ZSchemeLines
{
  key Bukrs,
  key Schemecode,
  key Productcode,
  Productdesc,
  Schemegroupcode,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _ZScheme : redirected to parent ZI_ZScheme02TP
  
}
