//@AbapCatalog.sqlViewName: ''
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View of BRANDCATEGORY TMG'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS_BRANDCATEGORY as select from zdt_tmg
{
    key brand_code as BrandCode,
    brand_desc as BrandDesc
}
