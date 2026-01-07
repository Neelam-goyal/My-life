
@EndUserText.label: 'cds of ZGOODS_TFR_NOTE'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZCDS_GOODS_TFR_NOTE 
  as select from I_MaterialDocumentItem_2 as a
  join I_MaterialDocumentHeader_2 as b on a.MaterialDocument = b.MaterialDocument
{
  @EndUserText.label: 'Material Document'
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem:       [{ position: 10, label: 'Material Document' }]
  @Search.defaultSearchElement: true
  key a.MaterialDocument,

  @EndUserText.label: 'Company Code'
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 20, label: 'Company Code' }]
  @Search.defaultSearchElement: true
  key a.CompanyCode,

//  @EndUserText.label: 'Material Document Item'
//  @UI.lineItem:       [{ position: 30, label: 'Material Document Item' }]
//  key a.MaterialDocumentItem,

  @EndUserText.label: 'Plant'
  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem:       [{ position: 40, label: 'Plant' }]
  @Search.defaultSearchElement: true
  key a.Plant,
  
  @EndUserText.label: 'Movement from Location '
  @UI.selectionField: [{ position: 90 }]
  @UI.lineItem:       [{ position: 90, label: 'Movement from Location ' }]
  @Search.defaultSearchElement: true
 key a.StorageLocation,
  
  
  
  @EndUserText.label: 'Movement To location '
  @UI.selectionField: [{ position: 100 }]
  @UI.lineItem:       [{ position: 100, label: 'Movement To location ' }]
  @Search.defaultSearchElement: true
  a.IssuingOrReceivingStorageLoc,
  
  
  @EndUserText.label: 'Created By User '
  @UI.selectionField: [{ position: 110 }]
  @UI.lineItem:       [{ position: 110, label: 'Created By User' }]
  @Search.defaultSearchElement: true
  b.CreatedByUser,
  
  
  @EndUserText.label: 'Creation Time'
  @UI.selectionField: [{ position: 120 }]
  @UI.lineItem:       [{ position: 120, label: 'Creation Time' }]
  @Search.defaultSearchElement: true
  b.CreationTime,
  

  @EndUserText.label: 'Movement Type'
  @UI.lineItem:       [{ position: 50, label: 'Movement Type' }]
  @Search.defaultSearchElement: true
  a.GoodsMovementType,

  @EndUserText.label: 'Posting Date'
  @UI.lineItem:       [{ position: 60, label: 'Posting Date' }]
  @Search.defaultSearchElement: true
  a.PostingDate,
  
  @UI.selectionField : [{ position:70  }]
  @Consumption.filter: { selectionType: #SINGLE, mandatory: false   }
  @UI.hidden: true
  a.PostingDate as PostingDateFrom,
      
      
  @Consumption.filter: { selectionType: #SINGLE, mandatory: false   }
  @UI.hidden: true
  @UI.selectionField : [{ position:80  }]
  a.PostingDate as PostingDateTo

}
where a.GoodsMovementType = '311' and a.IsAutomaticallyCreated = ''
group by 
  a.MaterialDocument,
  a.CompanyCode,
  a.Plant,
  a.StorageLocation,
  a.IssuingOrReceivingStorageLoc,
  a.GoodsMovementType,
  b.CreatedByUser,
  b.CreationTime,
  a.PostingDate;


 
