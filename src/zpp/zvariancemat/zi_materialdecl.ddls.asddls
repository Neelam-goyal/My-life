@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for ZR_MaterialDecl'
define root view entity ZI_MATERIALDECL
  provider contract transactional_interface
  as projection on ZR_MATERIALDECL as MATERIALDECLARATION
{
  key      Bukrs,
  key      Plantcode,
  key      Declaredate,
  key      Declareno,
  key      Productcode,
  key      Batchno,
           Productdesc,
           Uom,
           Stockquantity,
           CreatedBy,
           CreatedAt,
           LastChangedBy,
           LastChangedAt,
           LocalLastChangedAt
}
