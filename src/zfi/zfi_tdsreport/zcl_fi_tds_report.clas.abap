CLASS zcl_fi_tds_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
    TYPES: BEGIN OF ty_header2,
             Supplier                    TYPE i_operationalacctgdocitem-Supplier,
             AccountingDocument          TYPE i_withholdingtaxitem-AccountingDocument,
             AccountingDocumentType      TYPE i_operationalacctgdocitem-AccountingDocumentType,
             FiscalYear                  TYPE i_withholdingtaxitem-FiscalYear,
             GLAccount                   TYPE i_withholdingtaxitem-GLAccount,
             CompanyCode                 TYPE i_operationalacctgdocitem-CompanyCode,
             WhldgTaxBaseAmtInCoCodeCrcy TYPE i_withholdingtaxitem-WhldgTaxBaseAmtInCoCodeCrcy,
             WithholdingTaxCode          TYPE i_withholdingtaxitem-WithholdingTaxCode,
             BusinessPartnerFullName     TYPE i_businesspartner-BusinessPartnerFullName,
             BusinessPartnerPanNumber    TYPE i_supplier-BusinessPartnerPanNumber,
           END OF ty_header2.

    TYPES tt_header2 TYPE STANDARD TABLE OF ty_header2 WITH DEFAULT KEY.

    DATA: it_header2   TYPE tt_header2,
          it_headerSum TYPE tt_header2,
          ls_header2   TYPE ty_header2.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_TDS_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lt_response    TYPE TABLE OF zfi_cds_tdsreport,
          ls_response    LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.

    DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).

    TRY.
        DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
        DATA(lv_msg) = lo_error->get_text( ).
    ENDTRY.

    DATA(lt_parameter)     = io_request->get_parameters( ).
    DATA(lt_fields)        = io_request->get_requested_elements( ).
    DATA(lt_sort)          = io_request->get_sort_elements( ).

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        lv_msg = lo_error->get_text( ).
    ENDTRY.

    TYPES: BEGIN OF ty_doc_key,
             AccountingDocument TYPE I_OperationalAcctgDocItem-AccountingDocument,
             FiscalYear         TYPE gjahr,
             CompanyCode        TYPE bukrs,
             glaccount          TYPE I_OperationalAcctgDocItem-GLAccount,
           END OF ty_doc_key.

    DATA: lt_doc_key TYPE STANDARD TABLE OF ty_doc_key,
          ls_doc_key TYPE ty_doc_key.

    LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
      CASE <fs_p>-parameter_name.
        WHEN 'P_FROMDATE'.   DATA(p_fromdate) = <fs_p>-value.
        WHEN 'P_TODATE'.   DATA(p_todate) = <fs_p>-value.
      ENDCASE.
    ENDLOOP.

    DATA lv_enddayofmonth TYPE c LENGTH 2.

    DATA: lv_date     TYPE datn,
          lv_year     TYPE i,
          lv_leapyear TYPE c LENGTH 1.

    lv_year =  p_todate+0(4).
    lv_date = |{ lv_year }0301|.
    lv_date = lv_date - 1.

    DATA(lv_month) = p_todate+4(2).

    IF lv_month = '01' OR lv_month = '03' OR lv_month = '05'
    OR lv_month = '07' OR lv_month = '08' OR lv_month = '10'
    OR lv_month = '12'.
      lv_enddayofmonth = '31'.
    ELSEIF lv_month = '02'.
      IF lv_date+6(2) = '29'.
        lv_enddayofmonth = '29'.
      ELSE.
        lv_enddayofmonth = '28'.
      ENDIF.
    ELSE.
      lv_enddayofmonth = '30'.
    ENDIF.

****************** ADDED BY VKS **********************
******   IF p_fromdate+6(2) = '01' AND p_fromdate+4(2) = p_todate+4(2) AND p_fromdate+0(4) = p_todate+0(4) AND p_todate+6(2) = lv_enddayofmonth.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      IF ls_filter_cond-name = 'VOUCHER_NO'.
        DATA(lt_voucher_number) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'VOUCHER_TYPE'.
        DATA(lt_documentType) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'GLACCOUNT'.
        DATA(lt_GLaccount) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'ACCOUNT_CODE'.
        DATA(lt_CustomerSupplierAccount) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'COMPANY_CODE'.
        DATA(lt_company_code) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'LOCATION'.
        DATA(lt_plant_name1) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'PLANTCODE'.
        DATA(lt_planTCODE) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'SUPPLIER_ACCOUNT_NAME'.
        DATA(lt_SupplierName) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'PAN_NO'.
        DATA(lt_BPTaxNumber) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'TDS_DEDUCTION_RATE'.
        DATA(lt_WithholdingTaxPercent) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'TDS_BASE_AMOUNT'.
        DATA(lt_WhldgTaxBaseAmtInCoCodeCrcY) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'TDS_CODE'.
        DATA(lt_TDS_Code) = ls_filter_cond-range[].

      ENDIF.
    ENDLOOP.

    IF lt_CustomerSupplierAccount IS NOT INITIAL.
      LOOP AT lt_CustomerSupplierAccount ASSIGNING FIELD-SYMBOL(<fs_account_code>).
        IF strlen( <fs_account_code>-low ) < 10.
          <fs_account_code>-low = |{ <fs_account_code>-low ALPHA = IN WIDTH = 10 }|.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_voucher_number IS NOT INITIAL.
      READ TABLE lt_voucher_number ASSIGNING FIELD-SYMBOL(<wa_voucherNumber>) WITH KEY option = 'EQ'.
      <wa_voucherNumber>-low = |{ <wa_voucherNumber>-low ALPHA = IN WIDTH = 10 }|.
    ENDIF.

    SELECT FROM I_OperationalAcctgDocItem AS a
    LEFT JOIN i_journalentry AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~CompanyCode AND a~FiscalYear = b~FiscalYear
    LEFT JOIN ztable_plant AS c ON a~BusinessPlace = c~plant_code
    LEFT JOIN I_GLAccountTextRawData AS d ON a~GLAccount = d~GLAccount AND d~Language = @sy-langu
    FIELDS
    a~AccountingDocument,
    a~AccountingDocumentType,
    a~GLAccount,
    a~CompanyCode,
    a~FiscalYear,
    a~PostingDate,
    a~BusinessPlace,
    SUM( a~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency ,
    a~DebitCreditCode,
    c~plant_name1,
    d~GLAccountLongName
      WHERE
        b~IsReversed IS INITIAL
        AND b~IsReversal IS INITIAL
        AND
*          a~GLAccount BETWEEN '0021603000' AND '0021603021'
          a~GLAccount BETWEEN '0021603000' AND '0021603023'
        AND a~AmountInFunctionalCurrency  <>  0
        AND b~PostingDate BETWEEN @p_fromdate AND @p_todate
        AND  a~accountingdocument IN @lt_voucher_number
        AND b~CompanyCode IN @lt_company_code
        AND a~BusinessPlace   IN @lt_planTCODE
        AND a~AccountingDocumentType IN @lt_documentType
        GROUP BY
         a~AccountingDocument,
    a~AccountingDocumentType,
    a~GLAccount,
    a~CompanyCode,
    a~FiscalYear,
    a~PostingDate,
    a~BusinessPlace,
     a~DebitCreditCode,
    c~plant_name1,
    d~GLAccountLongName
    INTO TABLE @DATA(it_header).

    LOOP AT it_header INTO DATA(wa_header).
      CLEAR ls_doc_key.
      ls_doc_key-AccountingDocument = wa_header-AccountingDocument.
      ls_doc_key-FiscalYear         = wa_header-FiscalYear.
      ls_doc_key-CompanyCode        = wa_header-CompanyCode.
      ls_doc_key-glaccount          = wa_header-GLAccount.
      APPEND ls_doc_key TO lt_doc_key.
    ENDLOOP.

    SORT lt_doc_key BY AccountingDocument FiscalYear CompanyCode.
    DELETE ADJACENT DUPLICATES FROM lt_doc_key COMPARING ALL FIELDS.

    IF lt_doc_key IS NOT INITIAL.

      SELECT FROM i_operationalacctgdocitem AS a
      LEFT JOIN I_BusinessPartner AS b ON a~Supplier = b~BusinessPartner
      LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
        FIELDS a~Supplier,
               a~AccountingDocument,
               b~BusinessPartnerFullName,
               a~FiscalYear,
               a~CompanyCode,
               c~BusinessPartnerPanNumber
        FOR ALL ENTRIES IN @lt_doc_key
        WHERE a~AccountingDocument = @lt_doc_key-AccountingDocument
          AND a~FiscalYear         = @lt_doc_key-FiscalYear
          AND a~CompanyCode        = @lt_doc_key-CompanyCode
         AND a~supplier IS NOT INITIAL
         AND a~Supplier IN @lt_CustomerSupplierAccount
         AND a~accountingdocument IN @lt_voucher_number
         AND a~CompanyCode IN @lt_company_code
         AND b~BusinessPartnerFullName IN @lt_SupplierName
         AND c~BusinessPartnerPanNumber IN @lt_BPTaxNumber
         AND a~AccountingDocumentType IN @lt_documentType
        INTO TABLE @DATA(it_headerSupplier).

      SELECT FROM i_operationalacctgdocitem AS a
      LEFT JOIN I_Withholdingtaxitem AS f ON a~AccountingDocument = f~AccountingDocument AND a~CompanyCode = f~CompanyCode AND a~FiscalYear = f~FiscalYear "AND a~GLAccount = f~GLAccount
      LEFT JOIN I_BusinessPartner AS b ON a~Supplier = b~BusinessPartner
      LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
        FIELDS a~Supplier,
               f~AccountingDocument,
               a~AccountingDocumentType,
               f~FiscalYear,
               f~GLAccount,
               a~CompanyCode,
               f~WhldgTaxBaseAmtInCoCodeCrcy,
               f~WithholdingTaxCode,
               b~BusinessPartnerFullName,
               c~BusinessPartnerPanNumber
        FOR ALL ENTRIES IN @lt_doc_key
        WHERE f~AccountingDocument = @lt_doc_key-AccountingDocument
          AND f~FiscalYear         = @lt_doc_key-FiscalYear
          AND f~CompanyCode        = @lt_doc_key-CompanyCode
          AND f~GLAccount          = @lt_doc_key-glaccount
         AND a~supplier IS NOT INITIAL
         AND a~Supplier IN @lt_CustomerSupplierAccount
         AND a~accountingdocument IN @lt_voucher_number
         AND a~CompanyCode IN @lt_company_code
         AND b~BusinessPartnerFullName IN @lt_SupplierName
         AND c~BusinessPartnerPanNumber IN @lt_BPTaxNumber
         AND a~AccountingDocumentType IN @lt_documentType
        INTO TABLE @DATA(it_header2).

      LOOP AT it_header2 INTO ls_header2.
        COLLECT ls_header2 INTO it_headersum.
      ENDLOOP.

      it_header2 = it_headersum.

      SELECT FROM i_operationalacctgdocitem AS a
        LEFT JOIN zwht_taxcode AS e ON a~GLAccount = e~glaccount AND a~WithholdingTaxCode = e~withholdingtaxcode
        FIELDS
        a~AccountingDocument,
        a~CompanyCode,
        a~FiscalYear,
        a~GLAccount,
        e~officialwhldgtaxcode,
        e~withholdingtaxcode,
        e~withholdingtaxpercent
       FOR ALL ENTRIES IN @lt_doc_key
      WHERE a~AccountingDocument = @lt_doc_key-AccountingDocument
        AND a~FiscalYear         = @lt_doc_key-FiscalYear
        AND a~CompanyCode        = @lt_doc_key-CompanyCode
        AND a~GLAccount          = @lt_doc_key-glaccount
        AND e~officialwhldgtaxcode IN @lt_TDS_Code
        INTO TABLE @DATA(it_header3).
    ENDIF.

    DELETE it_header2 WHERE AccountingDocumentType = 'KZ' AND WithholdingTaxCode IS INITIAL .

    LOOP AT it_header INTO DATA(lv_header).
      ls_response-Voucher_date       = lv_header-PostingDate.
      ls_response-voucher_no         = lv_header-AccountingDocument.
      ls_response-voucher_type       = lv_header-AccountingDocumentType.
      ls_response-glaccount          = lv_header-GLAccount.
      ls_response-GLACCOUNTName      = lv_header-GLAccountLongName.
      ls_response-company_code       = lv_header-CompanyCode.
      ls_response-plantcode          = lv_header-BusinessPlace.
      ls_response-DebitCreditCode    = lv_header-DebitCreditCode.
      ls_response-location           = lv_header-plant_name1.
      ls_response-TDS_Amount         = lv_header-AmountInCompanyCodeCurrency * -1.

      READ TABLE it_headersupplier INTO DATA(wa_headersupplier) WITH KEY AccountingDocument = lv_header-AccountingDocument CompanyCode = lv_header-CompanyCode FiscalYear = lv_header-FiscalYear.
      ls_response-account_code          = wa_headersupplier-Supplier.

      ls_response-Supplier_Account_Name = wa_headersupplier-BusinessPartnerFullName.

      ls_response-Pan_No                = wa_headersupplier-BusinessPartnerPanNumber.

      READ TABLE it_header3 INTO DATA(wa_header3) WITH KEY AccountingDocument = lv_header-AccountingDocument CompanyCode = lv_header-CompanyCode FiscalYear = lv_header-FiscalYear GLAccount = lv_header-GLAccount.


      READ TABLE it_header2 INTO DATA(wa_header2) WITH KEY AccountingDocument = lv_header-AccountingDocument CompanyCode = lv_header-CompanyCode FiscalYear = lv_header-FiscalYear GLAccount = lv_header-GLAccount.

      ls_response-TAXCode            = wa_header2-WithholdingTaxCode .

      ls_response-TDS_Code =  COND string(
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'IM' THEN '194H'
      WHEN wa_header2-GLAccount = '0021603001' AND wa_header2-WithholdingTaxCode = 'IN' THEN '194H'
      WHEN wa_header2-GLAccount = '0021603001' AND wa_header2-WithholdingTaxCode = 'H1' THEN '194H'
      WHEN wa_header2-GLAccount = '0021603009' AND wa_header2-WithholdingTaxCode = 'I8' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603009' AND wa_header2-WithholdingTaxCode = 'I9' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603009' AND wa_header2-WithholdingTaxCode = 'I3' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'A5' THEN '194'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'AI' THEN '194A'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'A3' THEN '194A'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C0' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C1' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IE' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IF' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'Z1' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C5' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C6' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IG' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IH' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'Z2' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C4' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C7' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C2' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'C3' THEN '194C'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'D0' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'II' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'D1' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'D5' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IJ' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'D2' THEN '194D'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'I0' THEN '194I'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'I2' THEN '194I'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IO' THEN '194I'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IP' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'I1' THEN '194A'
      WHEN wa_header2-GLAccount = '0022090022' AND wa_header2-WithholdingTaxCode = 'I5' THEN '194I'
      WHEN wa_header2-GLAccount = '0022090022' AND wa_header2-WithholdingTaxCode = 'I7' THEN '194I'
      WHEN wa_header2-GLAccount = '0022090022' AND wa_header2-WithholdingTaxCode = 'IQ' THEN '194I'
      WHEN wa_header2-GLAccount = '0022090022' AND wa_header2-WithholdingTaxCode = 'IR' THEN '194I'
      WHEN wa_header2-GLAccount = '0022090024' AND wa_header2-WithholdingTaxCode = 'I6' THEN '19IA'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IS' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IT' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J0' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J2' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J3' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603006' AND wa_header2-WithholdingTaxCode = 'J4' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IU' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'IV' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J2' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J5' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J6' THEN '194J'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'J7' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603006' AND wa_header2-WithholdingTaxCode = 'J8' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603007' AND wa_header2-WithholdingTaxCode = 'J9' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'K3' THEN '194K'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'K4' THEN '194K'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'L0' THEN '194L'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'L1' THEN '194L'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'L5' THEN '194L'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header3-WithholdingTaxCode = 'L6' THEN '194L'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'M0' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MQ' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MR' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MS' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MT' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MU' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MV' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MW' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'MX' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '01' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '02' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '03' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '04' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '05' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = '06' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'M1' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MY' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MZ' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'M2' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'M5' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MA' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MB' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MC' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MD' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'ME' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MF' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MG' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MH' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'M6' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MI' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MJ' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MK' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'ML' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MM' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MN' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MO' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'MP' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'M7' THEN '195'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'N1' THEN '196B'
      WHEN wa_header2-GLAccount = '0021613000' AND wa_header2-WithholdingTaxCode = 'N2' THEN '196B'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'N3' THEN '196C'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'N4' THEN '196C'
      WHEN wa_header2-GLAccount = '0021537000' AND wa_header2-WithholdingTaxCode = 'SB' THEN '195'
      WHEN wa_header2-GLAccount = '0021537000' AND wa_header2-WithholdingTaxCode = 'ST' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'SC' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'SO' THEN '195'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'I2' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'I4' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603000' AND wa_header2-WithholdingTaxCode = 'C0' THEN '194C'
      WHEN wa_header2-GLAccount = '0021603002' AND wa_header2-WithholdingTaxCode = 'C2' THEN '194C'
      WHEN wa_header2-GLAccount = '0021603009' AND wa_header2-WithholdingTaxCode = 'I4' THEN '194I'
      WHEN wa_header2-GLAccount = '0021603019' AND wa_header2-WithholdingTaxCode = 'J2' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603011' AND wa_header2-WithholdingTaxCode = ' '  THEN '192B'
      WHEN wa_header2-GLAccount = '0021603006' AND wa_header2-WithholdingTaxCode = 'J0' THEN '194J'
      WHEN wa_header2-GLAccount = '0021603023' AND wa_header2-WithholdingTaxCode = 'R1' THEN '194R'
      WHEN wa_header2-GLAccount = '0021603023' AND wa_header2-WithholdingTaxCode = ' '  THEN '194R'
      WHEN wa_header2-GLAccount = '0021603006' AND wa_header2-WithholdingTaxCode = 'J2' THEN '194J'

      ELSE wa_header3-officialwhldgtaxcode ).

      IF ls_response-voucher_type = 'KZ'.
        ls_response-TDS_Base_Amount = wa_header2-WhldgTaxBaseAmtInCoCodeCrcy.
      ELSE.
        ls_response-TDS_Base_Amount = wa_header2-WhldgTaxBaseAmtInCoCodeCrcy * -1 .
      ENDIF.

      IF ls_response-TDS_Base_Amount = 0.
        ls_response-TDS_Deduction_Rate = 0.
      ELSE.
        ls_response-TDS_Deduction_Rate = ( ls_response-TDS_Amount / ls_response-TDS_Base_Amount ) * 100 .
      ENDIF.

      APPEND ls_response TO lt_response.
      CLEAR : ls_response , lV_header, wa_header2 , wa_header3, wa_headersupplier.
    ENDLOOP.

    SORT lt_response BY Voucher_date voucher_no voucher_type glaccount GLACCOUNTName company_code plantcode DebitCreditCode location TDS_Amount TAXCode  account_code Supplier_Account_Name Pan_No TDS_Base_Amount TDS_Deduction_Rate.
    DELETE ADJACENT DUPLICATES FROM lt_response COMPARING ALL FIELDS.
    DATA tds_amount_total TYPE p LENGTH 15 DECIMALS 2.
    DATA tds_baseamount_total TYPE p LENGTH 15 DECIMALS 2.

    LOOP AT lt_response INTO ls_response.
      tds_amount_total += ls_response-TDS_Amount.
      tds_baseamount_total += ls_response-TDS_Base_Amount.
    ENDLOOP.

    SORT lt_response BY Voucher_date voucher_no.
    LOOP AT lt_sort INTO DATA(ls_sort).
      CASE ls_sort-element_name.
        WHEN 'VOUCHER_DATE'.
          SORT lt_response BY Voucher_date ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Voucher_date DESCENDING.
          ENDIF.

        WHEN 'VOUCHER_NO'.
          SORT lt_response BY voucher_no ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY voucher_no DESCENDING.
          ENDIF.

        WHEN 'GLACCOUNT'.
          SORT lt_response BY glaccount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY glaccount DESCENDING.
          ENDIF.


        WHEN 'COMPANY_CODE'.
          SORT lt_response BY Company_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Company_code DESCENDING.
          ENDIF.

        WHEN 'ACCOUNT_CODE'.
          SORT lt_response BY account_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY account_code DESCENDING.
          ENDIF.

        WHEN 'TDS_CODE'.
          SORT lt_response BY TDS_Code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY TDS_Code DESCENDING.
          ENDIF.

        WHEN 'TDS_AMOUNT'.
          SORT lt_response BY TDS_Amount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY TDS_Amount DESCENDING.
          ENDIF.

        WHEN 'PLANTCODE'.
          SORT lt_response BY plantcode ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY plantcode DESCENDING.
          ENDIF.

        WHEN 'LOCATION'.
          SORT lt_response BY location ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY location DESCENDING.
          ENDIF.

        WHEN 'TDS_DEDUCTION_RATE'.
          SORT lt_response BY TDS_Deduction_Rate ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY TDS_Deduction_Rate DESCENDING.
          ENDIF.


        WHEN 'SUPPLIER_ACCOUNT_NAME'.
          SORT lt_response BY Supplier_Account_Name ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Supplier_Account_Name DESCENDING.
          ENDIF.

        WHEN 'PAN_NO'.
          SORT lt_response BY Pan_No ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Pan_No DESCENDING.
          ENDIF.


        WHEN 'TDS_BASE_AMOUNT'.
          SORT lt_response BY TDS_Base_Amount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY TDS_Base_Amount DESCENDING.
          ENDIF.


        WHEN 'LOWER_DEDUCTION_NO'.
          SORT lt_response BY Lower_Deduction_No ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Lower_Deduction_No DESCENDING.
          ENDIF.

        WHEN 'ACCOUNTINGDOCUMENTTYPE'.
          SORT lt_response BY Accountingdocumenttype ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Accountingdocumenttype DESCENDING.
          ENDIF.


        WHEN 'DEBITCREDITCODE'.
          SORT lt_response BY DebitCreditCode ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY DebitCreditCode DESCENDING.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    CLEAR ls_response.
    ls_response-voucher_no = 'TOTAL'.
    ls_response-tds_amount = tds_amount_total.
    ls_response-TDS_Deduction_Rate = ' '.
    ls_response-tds_base_amount = tds_baseamount_total.
    ls_response-Voucher_date = '00000000'.
    APPEND ls_response TO lt_response.

    lv_max_rows = lv_skip + lv_top.
    IF lv_skip > 0.
      lv_skip = lv_skip + 1.
    ENDIF.


    CLEAR lt_responseout.
    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
      ls_responseout = <lfs_out_line_item>.
      APPEND ls_responseout TO lt_responseout.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_response ) ).
    io_response->set_data( lt_responseout ).

****   ENDIF.
  ENDMETHOD.
ENDCLASS.
