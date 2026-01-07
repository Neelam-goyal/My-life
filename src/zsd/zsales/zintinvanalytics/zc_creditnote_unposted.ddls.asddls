@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Credit Note Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CREDITNOTE_UNPOSTED as select from ZR_CREDITNOTE
{
    key CompCode,
    key Implant,
    key Imfyear,
    key Imtype,
    key Imno,
    key Imdealercode,
    Type,
    Location,
    Imnoseries,
    Imdate,
    Imdoccatg,
    Imcramt,
    Imbreadcode,
    Imwrappercode,
    Imbreadwt,
    Imwrapperwt,
    Imfeddt,
    Imfebuser,
    Imstatus,
    GlerrorLog,
    Dealercrdoc
}

where Glposted = '0';
