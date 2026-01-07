@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Document Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BILLDOCUMENTVH as select from I_BillingDocument as Header
join I_BillingDocumentItem as _BillingDocument
    on Header.BillingDocument = _BillingDocument.BillingDocument
left outer join ZR_GATEPASSLINE as GatePassLine
    on GatePassLine.DocumentNo = Header.BillingDocument
left outer join ZR_GATEPASSHEADER as GatePass
    on GatePassLine.GatePass = GatePass.GatePass
{
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  key Header.BillingDocument,
  Header.DocumentReferenceID,
  Header.CreationDate as DocumentDate,
  Header.BillingDocumentType,
  Header.SalesOrganization,
  concat(concat( Header._SoldToParty.CustomerName,'   -   '),Header._SoldToParty.CityName) as SoldToPartyName,
  
  case when 
        Header.BillingDocumentType = 'F2' or Header.BillingDocumentType = 'JSP'
        then 'INV'
       when 
           Header.BillingDocumentType = 'JDC' or Header.BillingDocumentType = 'JSN' 
        then 'DC'
       when 
           Header.BillingDocumentType = 'JSTO' 
        then 'STO'
       when 
           Header.BillingDocumentType = 'JVR' 
        then 'PURR' 
       else 'NA'
  end as DocumentType, 
  _BillingDocument.Plant as Plant,
  @Semantics.amount.currencyCode: 'Currency'
  ( Header.TotalNetAmount + Header.TotalTaxAmount ) as Amount,
  @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
  sum(_BillingDocument.BillingQuantity) as BillingQuantity,
  Header.TransactionCurrency as Currency,
  _BillingDocument.BillingQuantityUnit as BillingQuantityUnit
}
where
  (GatePassLine.DocumentNo is null or GatePass.Cancelled = 'X')
group by
  Header.BillingDocument,
  Header.DocumentReferenceID,
  Header.CreationDate,
  Header.BillingDocumentType,
  Header.SalesOrganization,
  Header.TotalNetAmount,
  Header.TotalTaxAmount,
  Header.TransactionCurrency,
  _BillingDocument.BillingQuantityUnit,
  _BillingDocument.Plant,
  Header._SoldToParty.CustomerName,
  Header._SoldToParty.CityName
