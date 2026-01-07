@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZSchemeLines'
define view entity ZR_ZSchemeLines01TP
  as select from zschemelines as ZSchemeLines
  association to parent ZR_ZScheme02TP as _ZScheme on $projection.Bukrs = _ZScheme.Bukrs and $projection.Schemecode = _ZScheme.Schemecode
{
  key bukrs as Bukrs,
  key schemecode as Schemecode,
  key productcode as Productcode,
  productdesc as Productdesc,
  schemegroupcode as Schemegroupcode,
  created_by as CreatedBy,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  local_last_changed_at as LocalLastChangedAt,
  _ZScheme
  
}
