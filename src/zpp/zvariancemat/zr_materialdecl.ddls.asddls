@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_MATERIALDECL
  as select from zmaterialdecl as MaterialDeclaration
{
  key      bukrs                 as Bukrs,
  key      plantcode             as Plantcode,
  key      declaredate           as Declaredate,
  key      declareno             as Declareno,
  key      productcode           as Productcode,
  key      batchno               as Batchno,
           productdesc           as Productdesc,
           @Consumption.valueHelpDefinition: [ {
             entity.name: 'I_UnitOfMeasureStdVH',
             entity.element: 'UnitOfMeasure',
             useForValidation: true
           } ]
           uom                   as Uom,
           @EndUserText.label: 'Consumed Qty'
           stockquantity         as Stockquantity,
           @Semantics.user.createdBy: true
           created_by            as CreatedBy,
           @Semantics.systemDateTime.createdAt: true
           created_at            as CreatedAt,
           @Semantics.user.localInstanceLastChangedBy: true
           last_changed_by       as LastChangedBy,
           @Semantics.systemDateTime.localInstanceLastChangedAt: true
           last_changed_at       as LastChangedAt,
           @Semantics.systemDateTime.lastChangedAt: true
           local_last_changed_at as LocalLastChangedAt

}
