@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document Items Data for Sales'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SALESMATDOCITEMS as select from I_MaterialDocumentItem_2 as a
inner join I_Product as c on a.Material = c.Product
inner join ztable_plant as d on a.Plant = d.plant_code and a.CompanyCode = d.comp_code 
inner join I_ProductText as b on a.Material = b.Product and b.Language = 'E'
{
// Key Fields
   key  a.MaterialDocument,
   key  a.MaterialDocumentItem,
   key  a.MaterialDocumentYear,
   
// Product Fields
    a.Material as ProductCode,
    b.ProductName,
    c.ProductType,
    
// Location Fields
    a.CompanyCode,
    a.Plant,
    d.plant_name1 as PlantName,
    a.StorageLocation,
    a.Batch,
    
// Quantity Fields
    @Semantics.quantity.unitOfMeasure: 'Unit'
    a.QuantityInBaseUnit as Quantity,
    a.MaterialBaseUnit as Unit,
    a.GoodsMovementType,
    
// Relational Fields
    a.SalesOrder,
    a.SalesOrderItem,
    a.DeliveryDocument,
    a.DeliveryDocumentItem,
    
// Additional Fields
    a.DebitCreditCode,
    a._MaterialDocumentHeader.CreationDate,
    a._MaterialDocumentHeader.CreationTime,
    
    tstmpl_to_utcl(
            cast(tstmp_add_seconds(
                  cast( concat( a._MaterialDocumentHeader.CreationDate, a._MaterialDocumentHeader.CreationTime ) as abap.dec(15) ), 
                  cast( 19800 as abap.dec(15) ),
                  'NULL'     
            ) as abap.dec(21,7) ),
        'NULL',
        'NULL'     
    )
     as CreatedAt
}
where a.PurchaseOrder is initial and a.OrderID is initial and d.integrationenabled = 'X'
      and ( a.GoodsMovementType = '601' or a.GoodsMovementType = '602' or a.GoodsMovementType = '641' or a.GoodsMovementType = '642'
            or a.GoodsMovementType = '647' or a.GoodsMovementType = '648' or a.GoodsMovementType = '653' or a.GoodsMovementType = '654' )
      and  ( c.ProductType = 'ZFRT' or c.ProductType = 'ZNVM' or c.ProductType = 'ZWST' )
