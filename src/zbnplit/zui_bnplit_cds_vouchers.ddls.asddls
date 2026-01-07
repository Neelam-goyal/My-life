@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UI Layer of VUMST'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@UI.headerInfo: {
  typeName: 'Journal Entry',
  typeNamePlural: 'Journal Entries',
  title: {
    value: 'VoucherNo',
    label: 'Journal Entry'
  },
  description: { type: #STANDARD, value: 'VoucherType' }
}

@UI.presentationVariant: [{
    text: 'Journal Entries',
    //qualifier: 'VAR_DOCHEADER',
    sortOrder: [{
      by: 'DocumentDate',
      direction: #DESC
    },
    {
      by: 'VoucherNo',
      direction: #DESC
    }]
}]
@Search.searchable: true

define view entity ZUI_BNPLIT_CDS_VOUCHERS

  as select from Z_BNPLIT_VUMST

{

      @UI.lineItem: [{ position: 10, label: 'Company Code'  }]
      @UI.selectionField: [{ position: 1 }]
      @Consumption.valueHelpDefault.display: true
      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT
      @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCode', entity.element: 'CompanyCode'  }]
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: true }
      @UI.identification: [{ label: 'Company Code', position:10}]
  key CompanyCode,

      @UI.selectionField: [{ position: 2 }]
//      @Consumption.filter: { selectionType : #SINGLE, mandatory: true }
      @Semantics.fiscal.year: true
  key FiscalYear,

      @UI.lineItem: [{ position: 30, label: 'Voucher No.' }]
//      @UI.identification: [{ label: 'Voucher No.', position:30}]
      @UI.selectionField: [{ position: 3 }]
      @ObjectModel.filter.enabled: true
      @ObjectModel.sort.enabled: false
      @Search.defaultSearchElement: true
      //      @DefaultAggregation: #COUNT
  key VoucherNo,

      @UI.identification: [{ label: 'Voucher Date', position:20 }]
      @UI.lineItem: [{ position: 20, label: 'Voucher Date' }]
      @UI.selectionField: [{ position: 4 }]
      @Consumption.filter:{selectionType: #INTERVAL, multipleSelections: false}
      //      @Consumption.defaultValue: 'Today'
      //      @Consumption.valueHelpDefinition: [{entity.name: 'I_CalendarDate', entity.element: 'CalendarDate'  }]
      DocumentDate,
      
      

      @UI.lineItem: [{ position: 40, label: 'Voucher Type' }]
      @UI.selectionField: [{ position: 4 }]
      @Consumption.valueHelpDefault.display: true
      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT
      @Consumption.valueHelpDefinition: [{entity.name: 'ZI_AccountingDocumentType', entity.element: 'VoucherType'  }]
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true }
      @ObjectModel.filter.enabled: true
      VoucherType,
      
      @UI.lineItem: [{ position: 50, label: 'Transaction Type' }]
      @ObjectModel.filter.enabled: true
      TransactionType,
      @UI.lineItem: [{ position: 60, label: 'Posting Date' }]
      @ObjectModel.filter.enabled: true
      PostingDate,
      TransactionCurrency,
      @UI.lineItem: [{ position: 70, label: 'Voucher Amount' }]
      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      @DefaultAggregation: #SUM
      Amount,

      @UI.lineItem: [{ position: 80, label: 'Created By' }]
      CreatedBy,
      @UI.lineItem: [{ position: 90, label: 'Created On' }]
      CreatedOn,
      @UI.lineItem: [{ position: 100, label: 'Modified On' }]
      LastChangedOn,
      @UI.lineItem: [{  label: 'Ref. Doc. Type' }]
      ReferenceDocumentType,
      @UI.lineItem: [{  label: 'Ref. Doc. ID' }]
      DocumentReferenceID,
      @UI.lineItem: [{  label: 'Ref. Document' }]
      OriginalReferenceDocument,
      @UI.lineItem: [{ label: 'Misc Text' }]
      MiscText
}
