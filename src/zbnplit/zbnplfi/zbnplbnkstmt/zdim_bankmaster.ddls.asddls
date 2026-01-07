@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for BANK MASTER'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'BankAccountInternalID'
define view entity ZDIM_BANKMASTER
  as select from I_HouseBankAccountLinkage

{
      @EndUserText.quickInfo: 'Product'
      @ObjectModel.text.element: [ 'BankAccount' ]
  key BankAccountInternalID,
      CompanyCode,
      HouseBankAccount,
      @Semantics.text: true
      BankAccount,
      BankInternalID as IFSCCode,

      @Consumption.valueHelpDefinition: [
      { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' } } ]
      GLAccount,

      @Consumption.valueHelpDefinition: [
      { entity: { name: 'I_CurrencyStdVH', element: 'Currency' }} ]
      BankAccountCurrency,

      @Semantics.text: true
      BankAccountHolderName,
      @Semantics.text: true
      CompanyCodeName,
      SWIFTCode,
      BankCountry,
      BankName
      //    BankNumber,
      //    BankAccountAlternative,
      //    ReferenceInfo,
      //    BankControlKey,
      //    IBAN,
      //    BankAccountDescription,
      //    BankAccountNumber
}
