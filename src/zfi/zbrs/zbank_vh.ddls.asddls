@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Bank'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBANK_VH as select from I_Housebank as _Bank
inner join I_HouseBankBasic as _Basic on _Bank.HouseBank = _Basic.HouseBank
                                         and _Bank.CompanyCode = _Basic.CompanyCode
{
    key _Bank.HouseBank,
    key _Bank.CompanyCode,
    _Bank.ChargeAccount,
    _Basic.BankName
}
