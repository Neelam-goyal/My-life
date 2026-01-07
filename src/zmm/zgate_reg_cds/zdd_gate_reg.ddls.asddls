@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition For Gate Register'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_gate_reg as select from zgateentryheader as Header
    left outer join zgateentrylines as Lines on Header.gateentryno = Lines.gateentryno
    left outer join I_Supplier as Supplier on Supplier.Supplier = Lines.partycode {
    key Header.gateentryno as GateNo,
    key Lines.gateitemno as GateItemNo,
    Header.gateindate as GateInDate,
    Header.entrytype as EntryType,
    Header.invoiceno as InvoiceNo,
    Header.invoicedate as InvoiceDate,
    Header.invoicepartygst as InvoicePartyGST,
    Header.cancelled as Cancelled,
    Header.vehicleno as VehicleNo,
    Header.invoiceparty as InvoicingParty,
    Header.invoicepartyname as InvoicePartyName,
    Lines.gateqty as GateQty,
    Lines.documentno as DocumentNo,
    Lines.documentitemno as DocumentItemNo,
    Lines.partycode as PartyCode,
    Lines.partyname as PartyName,
    Lines.productdesc as ProductDesc,
    Lines.plant as Plant,
    Lines.productcode as ProductCode,
    Supplier.TaxNumber3 as TaxNumber3
}
where Lines.documentno is not null 
  and Lines.documentitemno is not null;
