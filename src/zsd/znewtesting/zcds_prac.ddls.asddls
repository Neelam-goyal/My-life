@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR DEMO BAS SCREEN'
@Search.searchable: false
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZCDS_PRAC
  as select from I_BillingDocument as a
{
      @UI.facet: [{ id: 'BAS_HT' ,
                     purpose: #STANDARD ,
                     type: #IDENTIFICATION_REFERENCE ,
                     position: 10 ,
                     label: 'BAS HT'  } ]

      @UI.identification: [{ position: 10 , label: 'Billing Document' }]
      @UI.selectionField: [{ position: 10  }]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Billing Document'
      @UI.lineItem: [{ position: 10 , label: 'Billing Document'  }]
      @Consumption.valueHelpDefinition: [{ entity.name: 'I_BillingDocument' , entity.element: 'BillingDocument' }]
  key a.BillingDocument,


      @Search.defaultSearchElement: true
      @UI.identification: [{ position: 20 , label: 'Billing Document Date' }]
      @UI.lineItem: [{ position: 20 , label: 'Billing Document Date'  }]
      a.BillingDocumentDate,


      @Search.defaultSearchElement: true
      @UI.identification: [{ position: 30 , label: 'Billing Document Type' }]
      @UI.lineItem: [{ position: 30 , label: 'Billing Document Type'  }]
      a.BillingDocumentType

}
