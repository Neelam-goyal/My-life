@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unposted Unsold Transactions'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_UNSOLD_UNPOSTED as select from ZR_USDATAMST
{
    key CompCode,
    key Plant,
    key Imfyear,
    key Imtype,
    key Imno,
    Imnoseries,
    Imdate,
    Imjobno,
    Imsalesmancode,
    Impartycode,
    Imroutecode,
    Imremarks,
    Imtotqty,
    Imvogamt,
    Imtxbamt,
    Imnetamt,
    Imnetamtro,
    Imcrates1,
    Imcrates2,
    Imrcds,
    Imdeltag,
    Imusercode,
    Imdfdt,
    Imdudt,
    Imaid,
    Iminno,
    Imindate,
    Imfgpasstag,
    Imagnstgpno,
    Imagnstgpdate,
    Imcgstamount,
    Imsgstamount,
    Imigstamount,
    ErrorLog,
    Remarks,
    Processed,
    ReferenceDoc,
    Orderamount,
    ReferenceDocDel,
    ReferenceDocInvoice,
    Invoiceamount,
    Status,
    Ztime,
    Datavalidated,
    CustCode,
    /* Associations */
    _UnsoldLines
}
where ReferenceDocInvoice = ''
