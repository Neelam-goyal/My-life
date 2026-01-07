@Metadata.allowExtensions: true
@EndUserText.label: 'Invoice Grouped View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_INVGROUPED
  provider contract transactional_query
  as projection on ZR_INVGROUPED000
{
  key Orderdate,
  key Type,
  Nooforder,
  Orderamount,
  Processed,
  Socreated,
  Soamount,
  Outboundcreated,
  Orderbilled,
  Billedamount,
  Pocreated,
  Migocreated,
  Datavalidated,
  Potobecreated,
  Highlight, 
  @UI.hidden: true 
  IsSales,
  @UI.hidden: true 
  IsUnsold,
  @UI.hidden: true 
  IsExpense,
  @UI.hidden: true 
  IsCrates,
  @UI.hidden: true 
  IsScrap,
  @UI.hidden: true 
  IsCrn,
  @UI.hidden: true 
  IsReceipt,
  _InvoiceHeaders : redirected to composition child ZC_INV_MST002,
  _UnsoldHeaders   : redirected to composition child ZC_USDATAMST001,
  _CtrlHeaders   : redirected to composition child ZC_CONTROLSHEET,
  _CratesHeaders   : redirected to composition child ZC_CRATESDATA000,
  _CRNHeaders   : redirected to composition child ZC_CREDITNOTE000,
  _ScrapHeaders   : redirected to composition child ZC_SCRAP,
  _ReceiptHeaders   : redirected to composition child ZC_CASHROOMCR
  
}
