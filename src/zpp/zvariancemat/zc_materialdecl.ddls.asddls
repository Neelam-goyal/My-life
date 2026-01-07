@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZVARIANCEMAT'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_MATERIALDECL
  provider contract transactional_query
  as projection on ZR_MATERIALDECL as MATERIALDECLARATION
{
        @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.90
        @EndUserText.label: 'Company'
  key   Bukrs,
        @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.90
        @EndUserText.label: 'Plant'
  key   Plantcode,
        @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.90
        @EndUserText.label: 'Declaration Date'
  key   Declaredate,
  key   Declareno,
        @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.90
        @EndUserText.label: 'Product'
  key   Productcode,
        @EndUserText.label: 'Batch'
  key   Batchno,
        Productdesc,
        @Semantics.unitOfMeasure: true
        Uom,
        Stockquantity,
        CreatedBy,
        CreatedAt,
        LastChangedBy,
        LastChangedAt,
        LocalLastChangedAt

}
