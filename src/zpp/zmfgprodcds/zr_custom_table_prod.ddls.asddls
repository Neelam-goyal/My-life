@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZR_CUSTOM_TABLE_PROD'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_CUSTOM_TABLE_PROD as select from zcustomtablepro
{
    key production_order as ProductionOrder,
    confirmation_group as ConfirmationGroup,
    order_confirmation as OrderConfirmation,
    product_description as ProductDescription,
    plant as Plant,
    posting_date as PostingDate,
    product as Product,
    work_center as WorkCenter,
    shift_description as ShiftDescription,
    order_quantity as OrderQuantity,
    order_qty_unit as OrderQtyUnit,
    actual_confirmed_qty as ActualConfirmedQty,
    actual_confirmed_unit as ActualConfirmedUnit,
    actual_consumption_qty as ActualConsumptionQty,
    actual_consumption_unit as ActualConsumptionUnit,
    actual_delivered_unit as ActualDeliveredUnit,
    number_of_material_document as NumberOfMaterialDocument,
    material_document_year as MaterialDocumentYear,
    material_document_item as MaterialDocumentItem,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
