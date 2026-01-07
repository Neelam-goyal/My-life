@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZCASHROOMCRTABLE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CASHROOMCR as select from zcashroomcrtable
//  composition [0..*] of ZR_CUSTCONTROLSHT as _CashLines
  association to parent ZR_INVGROUPED000 as _Group on $projection.Cdate = _Group.Orderdate and $projection.Type = _Group.Type
{
    key ccmpcode as Ccmpcode,
    key plant as Plant,
    key cfyear as Cfyear,
    key cgpno as Cgpno,
    key cno as Cno,
    'Receipts' as Type,
    cdate as Cdate,
    caid as Caid,
    ctype as Ctype,
    cnoseries as Cnoseries,
    csalesmancode as Csalesmancode,
    croutecd as Croutecd,
    camt as Camt,
    camtf as Camtf,
    cremarks as Cremarks,
    cdeltag as Cdeltag,
    cusercode as Cusercode,
    cfeddt as Cfeddt,
    cupddt as Cupddt,
    cpasstag as Cpasstag,
    cvutno as Cvutno,
    cvutdate as Cvutdate,
    c1000 as C1000,
    c500 as C500,
    c100 as C100,
    glposted as Glposted,
    c50 as C50,
    c20 as C20,
    c10 as C10,
    c5 as C5,
    c2 as C2,
    c1 as C1,
    ccoins as Ccoins,
    cdnote as Cdnote,
    ccounting as Ccounting,
    cpasstime as Cpasstime,
    cgpdate as Cgpdate,
    cspoilamt as Cspoilamt,
    cshortcash as Cshortcash,
    c200 as C200,
    cempcode as Cempcode,
    error_log as ErrorLog,
    remarks as Remarks,
    reference_doc as ReferenceDoc,
    case when glposted = 1 then 0 else 1 end as Highlight,
     @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
    _Group
//    _CashLines
}
