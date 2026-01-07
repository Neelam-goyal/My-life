@Metadata.allowExtensions: true
@EndUserText.label: 'Post Journal'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_POSTJOURNAL000
  provider contract transactional_query
  as projection on ZR_POSTJOURNAL000
{
  key Companycode,
  key Fiscalyear,
  key Supplierinvoice,
  key Supplierinvoiceitem,
  Postingdate,
  Plant,
  Plantname,
  Material,
  Productname,
  Purchaseorder,
  Purchaseorderitem,
  VendorInvoiceNo,
  VendorInvoiceDate,
  VendorType,
  @Semantics.unitOfMeasure: true
  Baseunit,
  Profitcenter,
  Purchaseordertype,
  Purchaseorderdate,
  Purchasingorganization,
  Purchasinggroup,
  Hsncode,
  Taxcodename,
  Percent,
  Igst,
  Sgst,
  Cgst,
  Rateigst,
  Ratecgst,
  Ratesgst,
  Isreversed,
  Isposted,
  Netamount,
  Taxamount,
  Roundoff,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
