@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Crates Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CRATES_UNPOSTED as select from ZR_CRATESDATA000
{
    key CompCode,
    key Plant,
    key Cmfyear,
    key Cmtype,
    key Cmno,
    Type,
    Cmaid,
    Cmnoseries,
    Cmdate,
    Cmsalesmancode,
    Cmsalesmancodeorg,
    Cmcrates1,
    Cmcrates2,
    Cmremarks,
    Cmdeltag,
    Cmusercode,
    Cmfeddt,
    Cmupddt,
    Cmcrates11,
    Cmcrates21,
    Cmrefno,
    Cmroutecd,
    Cmcrates3,
    Cmcrates4,
    Cmddealercode,
    Cmgpno,
    Cmgpdate,
    Cmseries,
    Cmcrates1d,
    Cmcrates2d,
    Cmcrates3d,
    Cmcrates4d,
    Cmupuser,
    Cmcratesrate1,
    Cmcratesrate2,
    Cmcratesrate3,
    Cmcratesrate4,
    Cmsecuritytype,
    Cmcmptype,
    ErrorLog,
    Remarks,
    Processed,
    ReferenceDoc
}
where Movementposted = 0;
