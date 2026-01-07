@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Custom GL Accounts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                dataCategory: #VALUE_HELP,
                representativeKey: 'GLAccount',
                semanticKey: [ 'GLAccount' ],
                usageType.sizeCategory: #M,
                usageType.dataClass: #MIXED,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP],
                modelingPattern: #VALUE_HELP_PROVIDER

                }

@Search.searchable: true
@Consumption.ranked: true

define view entity Z_GLAccounts
  as select from I_GLAccount
{
      @EndUserText.label: 'GLAccount'
      @ObjectModel.text.element: ['GLAccountName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key GLAccount,
        @EndUserText.label: 'GL Account Name'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      //@Search.ranking: #HIGH
      @Search.ranking: #LOW
      @EndUserText.quickInfo: 'GL Account Name'
      _Text[1: Language=$session.system_language].GLAccountName,
     
      @Consumption.valueHelpDefinition: [
                  { entity:  { name:    'I_CompanyCodeStdVH',
                               element: 'CompanyCode' }
                  }]
      @UI.hidden: true
      cast(I_GLAccount.CompanyCode  as bukrs preserving type ) as CompanyCode

}
where
      ChartOfAccounts = 'YCOA'
  
