CLASS zcl_purgstrcmfb60 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_data FOR TABLE FUNCTION ZTBLF_PurGSTRCMFB60.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PURGSTRCMFB60 IMPLEMENTATION.


  METHOD get_data
           BY DATABASE FUNCTION FOR HDB
             LANGUAGE SQLSCRIPT
             OPTIONS READ-ONLY
             USING zr_rcmpurchasedocsdtls.

    fb60 = select *
            From zr_rcmpurchasedocsdtls
            where CompanyCode = :pCompanyCode
            and PostingDate BETWEEN :pFromDate and :pToDate;

    fb60_supp = SELECT
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.supplier,
                    x.suppliername,
                    x.gstnumber,
                    x.region,
                    x.DocumentItemText
                from :fb60 as x
                where x.supplier is not null
                and x.supplier <> ''
                group by x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.supplier,
                    x.suppliername,
                    x.gstnumber,
                    x.region,
                    x.DocumentItemText
                ;

    fb60_JIC = select
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JIC';

    fb60_JIS = SELECT
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JIS';

    fb60_JII = SELECT
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JII';

    fb60_JRC = select
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JRC';

    fb60_JRS = SELECT
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JRS';

    fb60_JRI = SELECT
                    x.companycode,
                    x.fiscalyear,
                    x.accountingdocument,
                    x.TaxBaseAmountInTransCrcy,
                    x.taxrate,
                    x.amountintransactioncurrency

               from :fb60 as x
               where x.TransactionTypeDetermination = 'JRI';

    fb60_inv = SELECT

                x.fiscalyear,
                x.AccountingDocumentType as doc_type,
                x.AccountingDocument as mrn_no,
                ROW_NUMBER ( )
                OVER ( PARTITION BY X.companycode, x.fiscalyear, x.AccountingDocument
                        ORDER BY x.AccountingDocumentItem) as item_sr,
                x.IN_HSNOrSACCode as hsn_code,
                x.DocumentReferenceID as bill_no,
                s.supplier as supplier_code,
                x.postingdate as mrn_date,
                x.documentdate as bill_date,
                x.companycode as company_code,
                x.businessplace as plant_code,
                'PASS' as pass_tag,
                x.businessplacename as location,
                case when x.documentitemtext is null or
                            x.documentitemtext = '' or
                            length( x.documentitemtext ) < 5
                then s.documentitemtext
                else x.documentitemtext end as productname,
                s.suppliername as suppliername,
                s.gstnumber as suppliergstno,
                x.local_centre as localcentre,
                s.region as supplierstate,
                x.glaccount as purpostingcode,
                x.glaccountname as purpostinghead,
                x.taxcodename  as taxcode,
                x.taxrate as gstrate,
                1 as qty,
                'UNIT' as uom,
                x.amountintransactioncurrency as rate,
                x.amountintransactioncurrency as amount

               From :fb60 as x
               inner join :fb60_supp as s on x.accountingdocument = s.accountingdocument
                                            and x.companycode = s.companycode
                                            and x.fiscalyear = s.fiscalyear
               where x.TransactionTypeDetermination = ''
               or x.TransactionTypeDetermination is null;

    return
        select DISTINCT
        100 as client,
        x.*,
        i.amountintransactioncurrency as igstamount,
        c.amountintransactioncurrency as cgstamount,
        s.amountintransactioncurrency as sgstamount,

        -ri.amountintransactioncurrency as rigstamount,
        -rc.amountintransactioncurrency as rcgstamount,
        -rs.amountintransactioncurrency as rsgstamount,
        0 as gstcess
        from :fb60_inv as x
        left outer join :fb60_JII as i on x.mrn_no = i.accountingdocument
                                            and x.company_code = i.companycode
                                            and x.fiscalyear = i.fiscalyear
                                            and x.amount = i.TaxBaseAmountInTransCrcy
                                            and x.gstrate = i.taxrate
        left outer join :fb60_JIC as c on x.mrn_no = c.accountingdocument
                                            and x.company_code = c.companycode
                                            and x.fiscalyear = c.fiscalyear
                                            and x.amount = c.TaxBaseAmountInTransCrcy
                                            and x.gstrate = c.taxrate
        left outer join :fb60_JIS as s on x.mrn_no = s.accountingdocument
                                            and x.company_code = s.companycode
                                            and x.fiscalyear = s.fiscalyear
                                            and x.amount = s.TaxBaseAmountInTransCrcy
                                            and x.gstrate = s.taxrate
        left outer join :fb60_JRI as ri on x.mrn_no = ri.accountingdocument
                                            and x.company_code = ri.companycode
                                            and x.fiscalyear = ri.fiscalyear
                                            and abs(i.amountintransactioncurrency) = abs(ri.TaxBaseAmountInTransCrcy)
                                            and x.gstrate = ri.taxrate
        left outer join :fb60_JRC as rc on x.mrn_no = rc.accountingdocument
                                            and x.company_code = rc.companycode
                                            and x.fiscalyear = rc.fiscalyear
                                            and abs(c.amountintransactioncurrency) = abs(rc.TaxBaseAmountInTransCrcy)
                                            and x.gstrate = rc.taxrate
        left outer join :fb60_JRS as rs on x.mrn_no = rs.accountingdocument
                                            and x.company_code = rs.companycode
                                            and x.fiscalyear = rs.fiscalyear
                                            and abs(s.amountintransactioncurrency) = abs(rs.TaxBaseAmountInTransCrcy)
                                            and x.gstrate = rs.taxrate
        ;
  endmethod.
ENDCLASS.
