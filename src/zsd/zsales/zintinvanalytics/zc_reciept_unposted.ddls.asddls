@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Reciept Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_RECIEPT_UNPOSTED as select from ZR_CASHROOMCR
{
    key Ccmpcode,
    key Plant,
    key Cfyear,
    key Cgpno,
    key Cno,
    Type,
    Cdate,
    Caid,
    Ctype,
    Cnoseries,
    Csalesmancode,
    Croutecd,
    Camt,
    Camtf,
    Cremarks,
    Cdeltag,
    Cusercode,
    Cfeddt,
    Cupddt,
    Cpasstag,
    Cvutno,
    Cvutdate,
    C1000,
    C500,
    C100,
    C50,
    C20,
    C10,
    C5,
    C2,
    C1,
    Ccoins,
    Cdnote,
    Ccounting,
    Cpasstime,
    Cgpdate,
    Cspoilamt,
    Cshortcash,
    C200,
    Cempcode,
    ErrorLog,
    Remarks,
    ReferenceDoc
}
where Glposted = 0;
