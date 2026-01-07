@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Scraps Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_SCRAPS_UNPOSTED as select from ZR_SCRAP
{
    key CompCode,
    key Implant,
    key Imfyear,
    key Imtype,
    key Imno,
    key Imdealercode,
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
    ErrorLog,
    Scrapindoc
}
where Processed = '0'
