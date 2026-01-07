@AccessControl.authorizationCheck:#NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Post Journal'
define root view entity ZR_POSTJOURNAL000
  as select from zpostjournal
{
  key companycode as Companycode,
  key fiscalyear as Fiscalyear,
  key supplierinvoice as Supplierinvoice,
  key supplierinvoiceitem as Supplierinvoiceitem,
  postingdate as Postingdate,
  plant as Plant,
  plantname as Plantname,
  material as Material,
  productname as Productname,
  purchaseorder as Purchaseorder,
  purchaseorderitem as Purchaseorderitem,
  vendor_invoice_no as VendorInvoiceNo,
  vendor_invoice_date as VendorInvoiceDate,
  vendor_type as VendorType,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  baseunit as Baseunit,
  profitcenter as Profitcenter,
  purchaseordertype as Purchaseordertype,
  purchaseorderdate as Purchaseorderdate,
  purchasingorganization as Purchasingorganization,
  purchasinggroup as Purchasinggroup,
  hsncode as Hsncode,
  taxcodename as Taxcodename,
  percent as Percent,
  igst as Igst,
  sgst as Sgst,
  cgst as Cgst,
  rateigst as Rateigst,
  ratecgst as Ratecgst,
  ratesgst as Ratesgst,
  isreversed as Isreversed,
  isposted  as Isposted,
  netamount as Netamount,
  taxamount as Taxamount,
  roundoff as Roundoff,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
