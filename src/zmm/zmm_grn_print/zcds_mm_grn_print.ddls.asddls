@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_CN_DN_SCREEN_CLASS'
@UI.headerInfo: {typeName: 'cn_dn PRINT'}



@UI.presentationVariant: [
  {
    sortOrder: [
      { by: 'PostingDate', direction: #DESC }
    ]
  }
]
define view entity ZCDS_MM_GRN_PRINT
//  with parameters
//   @EndUserText.label: 'Voucher Date From'
//    p_fromdate : vdm_v_start_date,
//     @EndUserText.label: 'Voucher Date From'
//    p_todate   : vdm_v_end_date
    
  as select from    I_MaterialDocumentItem_2   as a
    left outer join I_MaterialDocumentHeader_2 as b on  a.MaterialDocument     = b.MaterialDocument
                                                    and a.MaterialDocumentYear = b.MaterialDocumentYear
    left outer join zgateentryheader           as c on b.MaterialDocumentHeaderText = c.gateentryno
    left outer join I_PurchaseOrderAPI01       as d on a.PurchaseOrder = d.PurchaseOrder
    left outer join I_Supplier                 as e on d.Supplier = e.Supplier
    
{
      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:10 }]
      @UI.lineItem : [{ position:10, label:'AccountingDocument' }]
      // @EndUserText.label: 'Accounting document'
  key a.MaterialDocument,

      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:20 }]
      @UI.lineItem : [{ position:20, label:'AccountingDocument' }]
      // @EndUserText.label: 'Accounting document'
  key a.CompanyCode,

      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:21 }]
      @UI.lineItem : [{ position: 21, label:'AccountingDocument' }]
      // @EndUserText.label: 'Accounting document'
   key a.Plant,

      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:40 }]
      @UI.lineItem : [{ position:40, label:'AccountingDocument' }]
      // @EndUserText.label: 'Accounting document'
  key a.MaterialDocumentYear,
      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:50 }]
      @UI.lineItem : [{ position:50, label:'AccountingDocument' }]
      // @EndUserText.label: 'Accounting document'
  key a.GoodsMovementType,

      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:60 }]
      @UI.lineItem : [{ position:60, label:'IsCancelled' }]
      // @EndUserText.label: 'Accounting document'
      a.GoodsMovementIsCancelled,
      
      
//      @Search.defaultSearchElement: true
//      @UI.selectionField : [{ position:70 }]
//      @UI.lineItem : [{ position:80, label:'IsCancelled' }]
//      a.PostingDate,

      @Search.defaultSearchElement: true
      @UI.lineItem : [{ position:70, label:'IsCancelled' }]
      a.PostingDate,
      @UI.selectionField : [{ position:70  }]
      @Consumption.filter: { selectionType: #SINGLE, mandatory: false   }
      @UI.hidden: true
      a.PostingDate as PostingDateFrom,
      @Consumption.filter: { selectionType: #SINGLE, mandatory: false   }
      @UI.hidden: true
      @UI.selectionField : [{ position:80  }]
      a.PostingDate as PostingDateTo,
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField : [{ position:70 }]
//      @UI.lineItem : [{ position:80, label:'IsCancelled' }]
//      // @EndUserText.label: 'Accounting document'
//      a.PostingDate as todate,


      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:90 }]
      @UI.lineItem : [{ position:90, label:'IsCancelled' }]
      // @EndUserText.label: 'Accounting document'
      d.PurchaseOrderType,

      c.gateentryno  as GateEntryNo,
      c.vehicleno    as VehicleNo,
      e.Supplier     as Supplier,
      e.SupplierName as SupplierName

}

//where
//      a.PostingDate between $parameters.p_fromdate
//                        and $parameters.p_todate

where
         ( a.GoodsMovementType = '101'
           or a.GoodsMovementType = '102' )
         and a.PurchaseOrder is not initial
       
       or a.GoodsMovementType = '305'
    


    //or a.AccountingDocumentType       = 'KG'
    //    or a.AccountingDocumentType       = 'DG'
    //    or a.AccountingDocumentType       = 'DD'

//and   a.FinancialAccountType = 'K'

group by
  a.MaterialDocument,
  a.MaterialDocumentYear,
  a.CompanyCode,
  a.Plant,
  a.GoodsMovementType,
  a.GoodsMovementIsCancelled,
  a.PostingDate,
  c.gateentryno,
  c.vehicleno,
  e.Supplier,
  e.SupplierName,
  d.PurchaseOrderType
