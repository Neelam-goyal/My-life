@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZScheme'
define root view entity ZR_ZScheme02TP
  as select from zscheme as ZScheme
  composition [0..*] of ZR_ZSchemeLines01TP as _ZSchemeLines
{
  @EndUserText.label: 'Company'
  key bukrs as Bukrs,
  @EndUserText.label: 'Scheme Code'
  key schemecode as Schemecode,
  @EndUserText.label: 'Valid From'
  validfrom as Validfrom,
  @EndUserText.label: 'Valid To'
  validto as Validto,
  customergroup as Customergroup,
  @EndUserText.label: 'Scheme Qty'
  schemeqty as Schemeqty,
  @EndUserText.label: 'Free Qty'
  freeqty as Freeqty,
  @EndUserText.label: 'Minimum Qty'
  minimumqty as Minimumqty,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  _ZSchemeLines
  
}
