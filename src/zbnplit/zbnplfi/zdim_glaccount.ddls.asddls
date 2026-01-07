@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for GL Ledgers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'GLAccount'

define view entity ZDIM_GLAccount
  as select from I_GLAccountText
{
      @ObjectModel.text.element: ['GLAccountName']
  key GLAccount,
      @Semantics.text:true
      GLAccountName

}
where
      ChartOfAccounts = 'YCOA'
  and Language        = 'E'
