@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Final Grn Cds'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FinalGateEntryReport as select distinct from zdd_gate_reg as Gate
    left outer join zpo_helper as PO on PO.DocumentNo = Gate.DocumentNo
                                        and PO.DocumentItemNo = Gate.DocumentItemNo
    left outer join ZI_PlantMasterData as Plant on Plant.Plant = Gate.Plant
                                         and (Plant.CompanyCode = PO.CompanyCode or Plant.CompanyCode is null)
    left outer join ZGRN_Helper as GRN on GRN.GateNo = Gate.GateNo
                                      and GRN.DocumentNo = Gate.DocumentNo
                                      and  GRN.DocumentItemNo = Gate.DocumentItemNo
      {
    // Gate Entry Fields
    key Gate.GateNo as gate_entry_num,
    key Gate.GateItemNo as gate_entryline,
    Gate.EntryType as gateentrytype,
    Gate.GateInDate as gateindate,
    Gate.InvoiceNo as gebillno,
    Gate.InvoiceDate as gebilldate,
    Gate.ProductDesc as productname,
    Gate.VehicleNo as vehicleno,
    Gate.Cancelled as gatecancelled,
    Gate.InvoicingParty as invoiceparty,
    Gate.InvoicePartyName as invoicepartyname,
    Gate.InvoicePartyGST as invoicepartygst,
    Gate.GateQty as gateqty,
    Gate.DocumentNo as ponum,
    Gate.DocumentItemNo as poitem,
    Gate.PartyCode as supplier,
    Gate.PartyName as suppliername,
    Gate.TaxNumber3 as supp_gst,
    Gate.Plant as plant,
    Gate.ProductCode as product,
    
    // PO Fields
    PO.PODate as podate,
    PO.POType as potype,
    PO.PurchasingGroup as pur_group,
    PO.PurchasingOrganization as pur_org,
    PO.POUOM as pouom,
     @Semantics.amount.currencyCode: 'curr'
    PO.PORate as porate,
    @UI.hidden: true
    PO.curr,
    PO.HSNCode as hsncode,
    PO.CompanyCode as companycode,
    PO.ProfitCenter as profitcenter,
    
    // Plant Fields
    Plant.PlantName as plantname,
    Plant.PlantGST as plantgst,
    
    // GRN Fields
    GRN.GRNNum as grnnum,
    GRN.GRNDate as grndate,
    @Semantics.quantity.unitOfMeasure: 'unit'
    GRN.GRNQty as grnqty,
    @UI.hidden: true
    GRN.unit,
    GRN.GRNItem as grnitem,
    GRN.GRNYear as grnyear,
    GRN.isreversed,
    GRN.refinvno,
//     case when GRN.ReverseDocument is not null then 'X' else '' end as isreversed,
//   case when GRN.ReverseDocument is not null then GRN.ReverseDocument else ' ' end as refinvno,
//    GRN.ReverseDocument as isreversed,
//    GRN.ReverseDocument as refinvno,
    // Invoice Fields
    GRN.TaxCodeName as taxcodename,
    GRN.SupplierInvoice as supplierinvoice,
    GRN.SupplierInvoiceItem as supplierinvoiceitem,
    GRN.FiscalYear as fiscalyear,
    concat(GRN.SupplierInvoice, GRN.FiscalYear) as originalreferencedocument,
    GRN.InvPostingDate as invpostingdate,
    
    case 
      when GRN.TransactionType = 'JII' 
      then cast( GRN.NetAmount as abap.dec(15,2) ) * GRN.TaxRate / 100 
      else cast( 0 as abap.dec(15,2) ) 
    end as igst,
    
    case 
      when GRN.TransactionType = 'JII' 
      then GRN.TaxRate 
      else 0 
    end as rateigst,
    
    case 
      when GRN.TransactionType = 'JIC' or GRN.TransactionType = 'JIS' 
      then cast( GRN.NetAmount as abap.dec(15,2) ) * GRN.TaxRate / 200 
      else cast( 0 as abap.dec(15,2) ) 
    end as sgst,
    
    case 
      when GRN.TransactionType = 'JIC' or GRN.TransactionType = 'JIS' 
      then cast( GRN.NetAmount as abap.dec(15,2) ) * GRN.TaxRate / 200 
      else cast( 0 as abap.dec(15,2) ) 
    end as cgst,
    
    case 
      when GRN.TransactionType = 'JIC' or GRN.TransactionType = 'JIS' 
      then GRN.TaxRate / 2 
      else 0 
    end as ratecgst,
    
    case 
      when GRN.TransactionType = 'JIC' or GRN.TransactionType = 'JIS' 
      then GRN.TaxRate / 2 
      else 0 
    end as ratesgst,
    
        @Semantics.amount.currencyCode: 'curr1'
    GRN.NetAmount as netamount,
//     @UI.hidden: true
     GRN.curr as curr1,
    cast( GRN.NetAmount as abap.dec(15,2) ) * GRN.TaxRate / 100 as taxamount,
    case 
  when GRN.TaxRate is null or GRN.TaxRate = 0 
    then cast( GRN.NetAmount as abap.dec(15,2) ) 
  else 
    cast( GRN.NetAmount as abap.dec(15,2) ) + ( cast( GRN.NetAmount as abap.dec(15,2) ) * GRN.TaxRate / 100 ) 
end as totalamount

};
