@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition For Delivery Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_deliverydocument as select from I_DeliveryDocument as DelDocument
 inner join I_DeliveryDocumentItem as DeliveryItem on DeliveryItem.DeliveryDocument = DelDocument.DeliveryDocument
 inner join ztable_plant as PlantTable on DeliveryItem.Plant = PlantTable.plant_code
 inner join I_Customer as ShipToCustomer on DelDocument.ShipToParty = ShipToCustomer.Customer
 inner join zdt_user_item as UserItem on UserItem.plant = DeliveryItem.Plant
{
    key DelDocument.DeliveryDocument,
    max(DelDocument.CreationDate) as CreationDate,
    max(DeliveryItem.Plant) as Plant,
    max(PlantTable.comp_code) as CompanyCode,
    max(ShipToCustomer.CustomerName) as CustomerName
}
where UserItem.userid = $session.user
group by DelDocument.DeliveryDocument
