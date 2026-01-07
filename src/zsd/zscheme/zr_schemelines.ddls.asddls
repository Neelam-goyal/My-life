@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Scheme Line CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_Schemelines as select from zschemelines as schline
join zscheme on schline.bukrs = zscheme.bukrs and schline.schemecode = zscheme.schemecode
{
    key schline.bukrs,
    key schline.schemecode,
    key schline.schemegroupcode,
    key schline.productcode,
    schline.productdesc,
    zscheme.freeqty,
    zscheme.schemeqty,
    zscheme.minimumqty,
    concat(concat(schline.schemecode, '-'), schline.schemegroupcode) as schemecombination
}
