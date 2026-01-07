
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Entity for ZR_SCRAP'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SCRAP as projection on ZR_SCRAP
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
    ErrorLog,
    Processed,
    Scrapindoc,
    Highlight,
    CreatedBy,
    LastChangedBy,
    /* Associations */
    _Group : redirected to parent ZC_INVGROUPED
    
}
