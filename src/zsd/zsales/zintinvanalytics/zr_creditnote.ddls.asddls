@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZDT_RPLCREDITNOTE -> CRN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CREDITNOTE as select from zdt_rplcrnote
  association to parent ZR_INVGROUPED000 as _Group on $projection.Imdate = _Group.Orderdate and $projection.Type = _Group.Type

{
    key comp_code as CompCode,
    key implant as Implant,
    key imfyear as Imfyear,
    key imtype as Imtype,
    key imno as Imno,
    key imdealercode as Imdealercode,
    'Credit Notes' as Type,
    location as Location,
    imnoseries as Imnoseries,
    imdate as Imdate,
    imdoccatg as Imdoccatg,
    imcramt as Imcramt,
    imbreadcode as Imbreadcode,
    imwrappercode as Imwrappercode,
    imbreadwt as Imbreadwt,
    imwrapperwt as Imwrapperwt,
    imfeddt as Imfeddt,
    imfebuser as Imfebuser,
    imstatus as Imstatus,
    glerror_log as GlerrorLog,
    glposted as Glposted,
    dealercrdoc as Dealercrdoc,
     case when glposted = '1' then 0 else 1 end as Highlight,
    
    @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
      _Group
    
}
