CLASS zcl_cashledger DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*  INTERFACES if_oo_adt_classrun.
   CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  companycode TYPE string
                  glaccount TYPE string
                  lastdate TYPE string
                  currentdate TYPE string
*                  profitcenter TYPE prctr

        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
   CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zcashledger/zcashledger'.
ENDCLASS.



CLASS ZCL_CASHLEDGER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .

  METHOD read_posts.


       TYPES: BEGIN OF ty_data,
             AccountingDocument       TYPE I_AccountingDocumentJournal-AccountingDocument,
             AccountingDocumentType   TYPE I_AccountingDocumentJournal-AccountingDocumentType,
             CreditAmountInCoCodeCrcy Type I_AccountingDocumentJournal-CreditAmountInCoCodeCrcy,
             DebitAmountInCoCodeCrcy Type I_AccountingDocumentJournal-DebitAmountInCoCodeCrcy,
             Supplier                 TYPE I_AccountingDocumentJournal-Supplier,
             Customer                 TYPE I_AccountingDocumentJournal-Customer,
             GLAccount                TYPE I_AccountingDocumentJournal-GLAccount,
             FullName                 TYPE string,
             Hardcode                 TYPE string,
             ClearingAccountingDocument type I_AccountingDocumentJournal-ClearingAccountingDocument,
             ClearingDate type I_AccountingDocumentJournal-ClearingDate,
             DocumentReferenceID type I_AccountingDocumentJournal-DocumentReferenceID,
             Documentitemtext  type I_AccountingDocumentJournal-Documentitemtext,
           END OF ty_data.

    DATA: it TYPE TABLE OF ty_data,
          wa TYPE ty_data.

    select single from I_ACCOUNTINGDOCUMENTJOURNAL as a
    inner join I_PROFITCENTERTEXT as b on a~ProfitCenter = b~ProfitCenter
    fields a~CompanyCode,b~ProfitCenter,b~ProfitCenterName
    where a~GLAccount = @glaccount
        AND a~CompanyCode = @companycode
        AND a~PostingDate BETWEEN @lastdate AND @currentdate
    into @data(header).

    data : min_date type string.
    data : max_date type string.
    data : year type string.

    year = lastdate(4) - COND i( WHEN lastdate+4(2) < '04' THEN 1 ELSE 0 ).



    CONCATENATE lastdate+6(2) '-' lastdate+4(2) '-' lastdate+0(4) into min_date.
    CONCATENATE currentdate+6(2) '-' currentdate+4(2) '-' currentdate+0(4) into max_date.

    SELECT FROM I_ACCOUNTINGDOCUMENTJOURNAL( P_Language = 'E' ) AS a
      FIELDS DISTINCT a~AccountingDocument,
             a~AccountingDocumentType
      WHERE a~IsReversed IS INITIAL
        AND a~IsReversal IS INITIAL
        AND a~ReversalReferenceDocument IS INITIAL
        AND a~GLAccount = @glaccount
        AND a~CompanyCode = @companycode
        AND a~PostingDate BETWEEN @lastdate AND @currentdate
        AND a~Ledger = '0L'
      ORDER BY AccountingDocumentType, AccountingDocument
      INTO TABLE @data(it1).

      LOOP AT it1 ASSIGNING FIELD-SYMBOL(<wa_add>).
         <wa_add>-AccountingDocument = |{ <wa_add>-AccountingDocument  ALPHA = IN  }|.
      ENDLOOP.

       TYPES: acc_range TYPE RANGE OF I_AccountingDocumentJournal-AccountingDocument.

        DATA: it_temp TYPE TABLE OF ty_data,
              lt_accounting_documents TYPE acc_range.

        LOOP AT it1 INTO DATA(wa_check).
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low = wa_check-accountingdocument ) TO lt_accounting_documents.
        ENDLOOP.

        IF lt_accounting_documents IS NOT INITIAL.
          SELECT FROM I_ACCOUNTINGDOCUMENTJOURNAL( P_Language = 'E' ) AS a
            FIELDS a~AccountingDocument,
                   a~AccountingDocumentType,
                   a~Supplier,
                   a~Customer,
                   a~GLAccount,
                   a~CreditAmountInCoCodeCrcy,
                   a~DebitAmountInCoCodeCrcy,
                   a~DocumentReferenceID,
                   a~DocumentItemText
            WHERE a~IsReversed IS INITIAL
            AND a~IsReversal IS INITIAL
            AND a~ReversalReferenceDocument IS INITIAL
            AND a~AccountingDocument IN @lt_accounting_documents
            AND a~CompanyCode =  @companycode
            AND a~Ledger = '0L'
            AND a~GLAccount NE @glaccount
            and a~TransactionTypeDetermination is INITIAL
            and a~GLAccount ne '0029500100'
*            and a~FiscalYear = @year
            AND a~PostingDate BETWEEN @lastdate AND @currentdate
            ORDER BY AccountingDocumentType, AccountingDocument
            INTO CORRESPONDING FIELDS OF TABLE @it_temp.
        ENDIF.

        APPEND LINES OF it_temp TO it.



*      DATA: it_temp TYPE TABLE OF ty_data.
*
*      Loop at it1 into data(wa_check).
*        SELECT FROM I_ACCOUNTINGDOCUMENTJOURNAL( P_Language = 'E' ) AS a
*            FIELDS a~AccountingDocument,
*             a~AccountingDocumentType,
*             a~Supplier,
*             a~Customer,
*             a~GLAccount,
*             a~CreditAmountInCoCodeCrcy,
*             a~DebitAmountInCoCodeCrcy
*        WHERE a~IsReversed IS INITIAL
*        AND a~IsReversal IS INITIAL
*        AND a~ReversalReferenceDocument IS INITIAL
*        AND a~AccountingDocument = @wa_check-accountingdocument
*        AND a~CompanyCode = 'BNPL'
*        AND a~Ledger = '0L'
*        AND a~GLAccount ne '0010010010'
*        ORDER BY AccountingDocumentType, AccountingDocument
*        INTO CORRESPONDING FIELDS OF TABLE @it_temp.
*        APPEND LINES OF it_temp TO it.
*      ENDLOOP.

sort it by accountingdocument.
    LOOP AT it INTO wa.
      IF wa-Supplier IS NOT INITIAL.
        SELECT SINGLE BusinessPartnerFullName
          FROM I_BusinessPartner
          WHERE BusinessPartner = @wa-Supplier
          INTO @wa-FullName.

      ELSEIF wa-Customer IS NOT INITIAL.
        SELECT SINGLE BusinessPartnerFullName
          FROM I_BusinessPartner
          WHERE BusinessPartner = @wa-Customer
          INTO @wa-FullName.

      ELSE.
        SELECT SINGLE GLAccountLongName
          FROM I_GLAccountText
          WHERE GLAccount = @wa-GLAccount AND Language = 'E'
          INTO @wa-FullName.
      ENDIF.

      if wa-creditamountincocodecrcy is INITIAL.
       wa-hardcode = |To { wa-Documentitemtext }|.
      else.
        wa-hardcode = |By { wa-Documentitemtext }|.
        wa-creditamountincocodecrcy = wa-creditamountincocodecrcy.
      ENDIF.

      if wa-debitamountincocodecrcy is not initial and wa-clearingaccountingdocument is initial and wa-clearingdate is initial.
      wa-debitamountincocodecrcy = wa-debitamountincocodecrcy.
      ENDIF.

      MODIFY it FROM wa.
    ENDLOOP.


*    SORT it BY  AccountingDocument.

*    LOOP AT it INTO DATA(wa_group) GROUP BY (
*        AccountingDocumentType = wa_group-AccountingDocumentType
*        AccountingDocument     = wa_group-AccountingDocument
*    ) INTO DATA(group).
*
*      DATA(first) = abap_true.
*
*      LOOP AT GROUP group ASSIGNING FIELD-SYMBOL(<wa_line>).
*
*        IF first = abap_true.
*          first = abap_false.
*          CONTINUE.
*        ENDIF.
*
*        <wa_line>-AccountingDocumentType = ''.
*        <wa_line>-AccountingDocument     = ''.
*
*      ENDLOOP.
*    ENDLOOP.

        SORT it BY  AccountingDocument.

        DATA: prev_type TYPE I_AccountingDocumentJournal-AccountingDocumentType,
              prev_doc  TYPE I_AccountingDocumentJournal-AccountingDocument.

        LOOP AT it INTO DATA(wa_group).
          IF wa_group-AccountingDocumentType <> prev_type OR wa_group-AccountingDocument <> prev_doc.
            prev_type = wa_group-AccountingDocumentType.
            prev_doc  = wa_group-AccountingDocument.
          ELSE.
            wa_group-AccountingDocumentType = ''.
            wa_group-AccountingDocument     = ''.
            MODIFY it FROM wa_group.
          ENDIF.
        ENDLOOP.

     Select from  I_ACCOUNTINGDOCUMENTJOURNAL( P_Language = 'E' )
       fields  sum( DebitAmountInCoCodeCrcy ) as debit ,sum( CreditAmountInCoCodeCrcy ) as credit
       where AccountingDocumentType  <> 'WL' AND AccountingDocumentType  <> 'WA' AND AccountingDocumentType  <> 'WE'
       AND SpecialGLCode NE 'F'  AND PostingDate lt @lastdate and Ledger = '0L' and IsReversed IS INITIAL
        AND IsReversal IS INITIAL
        AND ReversalReferenceDocument IS INITIAL
        AND GLAccount = @glaccount
        AND CompanyCode =  @companycode
       into @data(opening).

       data : opening_bal  type I_ACCOUNTINGDOCUMENTJOURNAL-DebitAmountInCoCodeCrcy.

       opening_bal = opening-debit + opening-credit.


    DATA:  lastdate1 type d.
*           lv_previous_date TYPE d,
*          lv_year TYPE n LENGTH 4,
*          lv_month TYPE n LENGTH 2,
*          lv_day TYPE n LENGTH 2,
*          lv_day_number type i,
*          lv_day_name type string.


        lastdate1 = lastdate.
*
*        lv_year  = lastdate1(4).
*        lv_month = lastdate1+4(2).
*        lv_day   = lastdate1+6(2).
*
*        IF
**           ( lv_month = '01' AND lv_day = '01' ) OR  "Jan
*           ( lv_month = '02' AND lv_day = '01' ) OR  "Feb
*           ( lv_month = '03' AND lv_day = '01' ) OR  "Mar
*           ( lv_month = '04' AND lv_day = '01' ) OR  "Apr
*           ( lv_month = '05' AND lv_day = '01' ) OR  "May
*           ( lv_month = '06' AND lv_day = '01' ) OR  "Jun
*           ( lv_month = '07' AND lv_day = '01' ) OR  "Jul
*           ( lv_month = '08' AND lv_day = '01' ) OR  "Aug
*           ( lv_month = '09' AND lv_day = '01' ) OR  "Sep
*           ( lv_month = '10' AND lv_day = '01' ) OR  "Oct
*           ( lv_month = '11' AND lv_day = '01' ) OR  "Nov
*           ( lv_month = '12' AND lv_day = '01' ).    "Dec
*
*            CASE lv_month.
*              WHEN '01' OR '02' OR '04' OR '06' OR '08' OR '09' OR '11'.
*                lv_day = '31'.
*              WHEN '05' OR '07' OR '10' OR '12'.
*                lv_day = '30'.
*              WHEN '03'.
*                " February - check leap year
*                IF ( lv_year MOD 400 = 0 ) OR ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ).
*                  lv_day = '29'. " Leap year
*                ELSE.
*                  lv_day = '28'. " Non-leap year
*                ENDIF.
*            ENDCASE.
*         lv_month = lv_month - 1.
*        lv_previous_date = lv_year && lv_month && lv_day.
*        ELSE.
*          lv_previous_date = lastdate1 - 1.
*        ENDIF.

    data(lv_xml) = |<Form>| &&
                   |<Header>| &&
                   |<companycode>{ header-CompanyCode }</companycode>| &&
                   |<profitcentername>{ header-ProfitCenterName }</profitcentername>| &&
                   |<FromDate>{ min_date }</FromDate>| &&
                   |<ToDate>{ max_date }</ToDate>| &&
                   |<opening_balance>{ opening_bal }</opening_balance>| &&
                   |<opening_date>{ lastdate1 }</opening_date>| &&
                   |<opening_day></opening_day>| &&
                   |</Header>| &&
                   |<Table>|.
    data(lv_item) = ``.

        LOOP at it into data(wa_item).
         lv_item = |<Item>| &&
                   |<accountingdoc>{ wa_item-accountingdocument }</accountingdoc>| &&
                   |<accountingdoctype>{ wa_item-accountingdocumenttype }</accountingdoctype>| &&
                   |<desc>{ wa_item-fullname }</desc>| &&
                   |<Hardcode>{ wa_item-hardcode }</Hardcode>| &&
                   |<Receipts>{ wa_item-creditamountincocodecrcy }</Receipts>| &&
                   |<Payments>{ wa_item-debitamountincocodecrcy }</Payments>| &&
                   |</Item>|.
               CONCATENATE lv_xml lv_item into lv_xml.
        ENDLOOP.
         CONCATENATE lv_xml '</Table>' '</Form>' into lv_xml.

         REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
         clear : opening_bal.
*         ,lv_previous_date.

         CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).
  ENDMETHOD.
ENDCLASS.
