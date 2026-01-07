@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document Items Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MATDOCITEMS as select from I_MaterialDocumentItem_2 as a
inner join I_Product as c on a.Material = c.Product
inner join ztable_plant as d on a.Plant = d.plant_code and a.CompanyCode = d.comp_code 
inner join I_ProductText as b on a.Material = b.Product and b.Language = 'E'
left outer join I_ProductValuationBasic as e on a.Material = e.Product and a.Plant = e.ValuationArea
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
    a.PurchaseOrder,
    a.PurchaseOrderItem,
    a.OrderID,
    a.OrderItem,
    
// Additional Fields
    a.DebitCreditCode,
    a.PostingDate,
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
where a.SalesOrder is initial and d.integrationenabled = 'X'
      and a.GoodsMovementType != '601' and a.GoodsMovementType != '602' and a.GoodsMovementType != '641' and a.GoodsMovementType != '642'
      and a.GoodsMovementType != '647' and a.GoodsMovementType != '648' and a.GoodsMovementType != '653' and a.GoodsMovementType != '654'
      and (
            ( c.ProductType = 'ZFRT' and e.ValuationClass = '7920' )
            or c.ProductType = 'ZNVM' 
            or c.ProductType = 'ZWST' 
          )
