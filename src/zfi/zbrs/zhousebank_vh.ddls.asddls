@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help CDS For BRS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZHOUSEBANK_VH as select from I_HouseBankBasic as _Basic
inner join I_HouseBankAccountLinkage as  _Linkage on _Basic.CompanyCode = _Linkage.CompanyCode and _Basic.HouseBank = _Linkage.HouseBank
                                             and _Basic.BankInternalID = _Linkage.BankInternalID
{
    key _Basic.CompanyCode,
    key _Basic.HouseBank,
    _Basic.BankCountry,
    _Basic.BankName,
    _Linkage.HouseBankAccount
  
}
