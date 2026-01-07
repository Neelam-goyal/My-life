@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZDS for RPLCRNOTEV2'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS_RPLCRNOTEV2 as select from zrplcrnotev2
//composition of target_data_source_name as _association_name
{
    key comp_code as CompCode,
    key implant as Implant,
    key imfyear as Imfyear,
    key imtype as Imtype,
    key imno as Imno,
    key imdealercode as Imdealercode,
    credit_gl_account as CreditGlAccount,
    debit_gl_account as DebitGlAccount,
    spglcode as Spglcode,
    location as Location,
    imnoseries as Imnoseries,
    imdate as Imdate,
    imdoccatg as Imdoccatg,
    imcramt as Imcramt,
    imfeddt as Imfeddt,
    imfebuser as Imfebuser,
    imstatus as Imstatus,
    glerror_log as GlerrorLog,
    glposted as Glposted,
    dealercrdoc as Dealercrdoc,
    dr_gl_narration as DrGLnarration,
    cr_gl_narration as CrGLnarration,
    doc_type as Doc_type,       
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
//    _association_name // Make association public
}
