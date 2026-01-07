        CLASS zcl_tds DEFINITION
          PUBLIC
          FINAL
          CREATE PUBLIC .

          PUBLIC SECTION.
            INTERFACES if_rap_query_provider.
          PROTECTED SECTION.
          PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TDS IMPLEMENTATION.


          METHOD if_rap_query_provider~select.
            DATA: lt_response    TYPE TABLE OF zcds_tds,
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

            TYPES: BEGIN OF ty_zce_tds,
                     Voucher_date           TYPE i_accountingdocumentjournal-postingdate,
                     voucher_no             TYPE i_accountingdocumentjournal-accountingdocument,
                     Company_code           TYPE i_accountingdocumentjournal-companycode,
                     account_code           TYPE I_BusinessPartner-BusinessPartner,
                     TDS_Code               TYPE string,
                     TDS_Amount             TYPE string,
                     plantcode              TYPE werks_d,
                     location               TYPE ztable_plant-plant_name1,
                     TDS_Deduction_Rate     TYPE string,
                     Supplier_Account_Name  TYPE I_BusinessPartner-BusinessPartnerFullName,
                     Pan_No                 TYPE I_Businesspartnertaxnumber-BPTaxNumber,
                     TDS_Base_Amount        TYPE string,
                     Lower_Deduction_No     TYPE string,
                     Accountingdocumenttype TYPE i_accountingdocumentjournal-accountingdocumenttype,
                     DebitCreditCode        TYPE i_operationalacctgdocitem-debitcreditcode,
                   END OF ty_zce_tds.

            TYPES: BEGIN OF ty_total,
                     Voucher_date          TYPE string,
                     voucher_no            TYPE string,
                     Company_code          TYPE string,
                     account_code          TYPE string,
                     TDS_Code              TYPE string,
                     TDS_Amount            TYPE string,
                     plantcode             TYPE string,
                     location              TYPE string,
                     TDS_Deduction_Rate    TYPE string,
                     Supplier_Account_Name TYPE string,
                     Pan_No                TYPE string,
                     TDS_Base_Amount       TYPE string,
                     Lower_Deduction_No    TYPE string,
                   END OF ty_total.

            DATA: ls_total TYPE ty_total.

            DATA: it_glentrytable  TYPE TABLE OF ty_zce_tds,
                  ls_glentry_final TYPE ty_zce_tds,
                  header           TYPE TABLE OF zcds_tds,
                  ls_header        TYPE zcds_tds.

            LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
              CASE <fs_p>-parameter_name.
                WHEN 'P_FROMDATE'.   DATA(p_fromdate) = <fs_p>-value.
                WHEN 'P_TODATE'.   DATA(p_todate) = <fs_p>-value.
              ENDCASE.
            ENDLOOP.

            LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

              IF ls_filter_cond-name = 'VOUCHER_NO'.
                DATA(lt_voucher_number) = ls_filter_cond-range[].

*              ELSEIF ls_filter_cond-name = 'VOUCHER_DATE_FROM'.
*                READ TABLE ls_filter_cond-range INTO DATA(ls_from_range) INDEX 1.
*                IF ls_from_range-low IS NOT INITIAL.
*                  lv_posting_date_from = ls_from_range-low.
*                ENDIF.
*              ELSEIF ls_filter_cond-name = 'VOUCHER_DATE_TO'.
*                READ TABLE ls_filter_cond-range INTO DATA(ls_to_range) INDEX 1.
*                IF ls_to_range-low IS NOT INITIAL.
*                  lv_posting_date_to = ls_to_range-low.
*                ENDIF.

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


            SELECT FROM  I_Withholdingtaxitem  AS a
            LEFT JOIN zwht_taxcode AS g ON a~WithholdingTaxCode = g~withholdingtaxcode AND a~WithholdingTaxType = g~withholdingtaxtype
            LEFT JOIN I_AccountingDocumentJournal( p_language = 'E' ) AS b ON a~AccountingDocument = b~AccountingDocument
                                                                          AND b~TransactionTypeDetermination = 'WIT'
                                                                           AND g~glaccount = b~GLAccount
                                                                           AND a~FiscalYear = b~FiscalYear
                                                                           AND a~CompanyCode = b~CompanyCode
            LEFT JOIN I_OperationalAcctgDocItem  AS c ON b~AccountingDocument = c~AccountingDocumenT
                                                     AND b~TransactionTypeDetermination = c~TransactionTypeDetermination
                                                      AND b~CompanyCode = c~CompanyCode
                                                      AND b~postingdate = c~PostingDate
                                                      AND c~GLAccount = b~GLAccount
            LEFT JOIN ztable_plant AS d ON c~BusinessPlace = d~plant_code AND d~comp_code = c~CompanyCode
            LEFT JOIN i_supplier AS e ON a~CustomerSupplierAccount = e~supplier
            LEFT JOIN I_Businesspartnertaxnumber AS f ON e~supplier = f~BusinessPartner


            FIELDS
              b~PostingDate                  AS Voucher_date,
              a~AccountingDocument          AS voucher_no,
              b~CompanyCode                 AS Company_code,
              e~supplier                    AS account_code,
              g~officialwhldgtaxcode       AS TDS_Code,
              c~AmountInFunctionalCurrency AS TDS_Amount,
              d~plant_code                  AS plantcode,
              d~plant_name1                 AS location,
              a~WithholdingTaxPercent      AS TDS_Deduction_Rate,
              e~suppliername               AS Supplier_Account_Name,
              e~BusinessPartnerPanNumber   AS Pan_No,
              a~WhldgTaxBaseAmtInCoCodeCrcy AS TDS_Base_Amount,
              a~WithholdingTaxCertificate  AS Lower_Deduction_No,
              b~AccountingDocumentType     AS Accountingdocumenttype,
              c~DebitCreditCode            AS DebitCreditCode
               WHERE
                 b~IsReversed IS INITIAL
               AND b~IsReversal IS INITIAL
               AND b~Ledger = '0L'
           AND  a~accountingdocument IN @lt_voucher_number
           AND c~AmountInFunctionalCurrency NE 0
           AND a~WithholdingTaxPercent NE 0
           AND b~AccountingDocumentType NE 'JV'
           AND b~PostingDate BETWEEN @p_fromdate AND @p_todate
           AND b~CompanyCode IN @lt_company_code
           AND d~plant_code   IN @lt_planTCODE
           AND a~CustomerSupplierAccount IN @lt_CustomerSupplierAccount
           AND g~officialwhldgtaxcode IN @lt_TDS_Code
           INTO CORRESPONDING FIELDS OF TABLE @header.

            SORT header BY Company_code plantcode voucher_no Voucher_date.
            DELETE ADJACENT DUPLICATES FROM header COMPARING ALL FIELDS.


*        ************************************************************************************ Added by vinay on 17/07/2025
            SELECT FROM zwht_taxcode AS a
            INNER JOIN  I_OperationalAcctgDocItem  AS b  ON a~glaccount = b~GLAccount
            INNER  JOIN I_AccountingDocumentJournal( p_language = 'E' ) AS c  ON c~AccountingDocument = b~AccountingDocumenT
                                                                            AND c~CompanyCode = b~CompanyCode
                                                                            AND c~postingdate = b~PostingDate
                                                                            AND b~FiscalYear = c~FiscalYear
                                                                           AND c~GLAccount = b~GLAccount
            LEFT JOIN i_supplier AS d ON d~supplier = c~supplier
            LEFT JOIN ztable_plant AS e ON b~BusinessPlace = e~plant_code AND e~comp_code = b~CompanyCode
            LEFT JOIN I_supplier AS f ON d~Supplier = f~supplier
            LEFT JOIN I_Businesspartnertaxnumber AS g ON f~supplier = g~BusinessPartner
            FIELDS
               b~PostingDate AS Voucher_date,
               b~AccountingDocument AS voucher_no,
               b~CompanyCode AS Company_code,
               f~supplier AS account_code,
               a~officialwhldgtaxcode AS TDS_Code,
               b~AmountInFunctionalCurrency AS TDS_Amount,
               e~plant_code AS plantcode,
               e~plant_name1 AS location,
               ' ' AS TDS_Deduction_Rate,
               f~supplierName AS Supplier_Account_Name,
               f~BusinessPartnerPanNumber AS Pan_No,
               ' '  AS TDS_Base_Amount,
               ' ' AS Lower_Deduction_No,
               c~AccountingDocumentType AS Accountingdocumenttype,
               b~DebitCreditCode AS DebitCreditCode
                WHERE
                 c~IsReversed IS INITIAL
               AND c~IsReversal IS INITIAL
               AND c~Ledger = '0L'
               AND ( b~WithholdingTaxCode IS INITIAL AND b~GLAccount IS NOT INITIAL )
               AND b~AmountInFunctionalCurrency NE 0
               AND c~accountingdocumenttype NE 'JV'
               AND  b~accountingdocument IN @lt_voucher_number
               AND b~PostingDate BETWEEN @p_fromdate AND @p_todate
               AND b~CompanyCode IN @lt_company_code
               AND e~plant_code   IN @lt_planTCODE
               AND f~Supplier IN @lt_CustomerSupplierAccount
               INTO TABLE @DATA(it_header).

            SORT it_header BY voucher_no Voucher_date Company_code TDS_Amount.
            DELETE ADJACENT DUPLICATES FROM it_header COMPARING ALL FIELDS.

            LOOP AT it_header INTO DATA(wa_header).
              CLEAR ls_header.
              MOVE-CORRESPONDING wa_header TO ls_header.
              APPEND ls_header TO header.
            ENDLOOP.
*        ****************************************************************************************************************************

            SELECT FROM i_operationalacctgdocitem AS a
            INNER JOIN zwht_taxcode AS c ON a~WithholdingTaxCode = c~withholdingtaxcode
            LEFT JOIN i_accountingdocumentjournal AS b ON a~accountingdocument = b~accountingdocument
                                                       AND a~postingdate = b~postingdate
                                                       AND a~companycode = b~companycode
                                                       AND a~GLAccount = b~GLAccount
             FIELDS
              a~postingdate AS PostingDate,
              a~accountingdocument AS AccountingDocument,
              a~DebitCreditCode,
              a~CompanyCode AS CompanyCode,
              c~officialwhldgtaxcode AS officialwhldgtaxcode,
              a~AccountingDocumentType
             WHERE ( a~glaccount = '0021603011'
             OR  a~glaccount = '0021603018'
             OR  a~GLAccount = '0021603015'
             OR  a~GLAccount = '0021603005'
             OR  a~GLAccount = '0021603014'
             OR  a~GLAccount = '0021603020'
             OR  a~GLAccount = '0021603021'
             OR  a~GLAccount = '0021603000'
            )
             AND b~Ledger = '0L'
             AND b~IsReversed IS INITIAL
             AND b~IsReversal IS INITIAL
             AND b~AccountAssignmentType NE 'JV'
             AND a~accountingdocument IN @lt_voucher_number
             AND b~PostingDate BETWEEN @p_fromdate AND @p_todate
             AND a~CompanyCode IN @lt_company_code
           INTO TABLE @DATA(it_glentry_final).
*    **************************************************************************************************************
            LOOP AT it_glentry_final INTO DATA(wa_glentry).

              SELECT FROM i_operationalacctgdocitem AS a
                LEFT JOIN i_supplier AS b ON a~supplier = b~supplier
                LEFT JOIN i_businesspartnertaxnumber AS d ON a~supplier = d~businesspartner
                LEFT JOIN ztable_plant AS c ON a~BusinessPlace = c~plant_code
                FIELDS a~supplier,
                       a~GLAccount ,
                       a~AmountInCompanyCodeCurrency ,
                       b~SupplierName,
                       c~plant_code,
                       c~plant_name1,
                       b~BusinessPartnerPanNumber,
                       a~WithholdingTaxCode
                WHERE a~accountingdocument = @wa_glentry-accountingdocument
                AND a~PostingDate = @wa_glentry-postingdate
                AND a~companycode = @wa_glentry-companycode
                    AND (
                    ( ( a~glaccount = '0021603011' OR  a~glaccount = '0021603018' OR  a~glaccount = '0021603015' OR a~glaccount = '0021603005' OR  a~glaccount = '0021603014' OR
                        a~glaccount = '0021603020' OR  a~glaccount = '0021603021' OR a~GLAccount = '0021603000'  )  AND a~supplier IS INITIAL )
                    OR ( ( a~glaccount <> '0021603011' OR  a~glaccount <> '0021603018' OR  a~glaccount <> '0021603015' OR a~glaccount <> '0021603005' OR  a~glaccount <> '0021603014' OR
                        a~glaccount <> '0021603020'  OR  a~glaccount <> '0021603021' OR  a~GLAccount = '0021603000' )  AND a~supplier IS NOT INITIAL )
                    )

                INTO TABLE @DATA(it_glEntry).

              ls_glentry_final-Voucher_date          = wa_glentry-postingdate.
              ls_glentry_final-DebitCreditCode     = wa_glentry-debitcreditcode.
              ls_glentry_final-voucher_no            = wa_glentry-accountingdocument.
              ls_glentry_final-Company_code          = wa_glentry-companycode.
              ls_glentry_final-tds_code              = wa_glentry-officialwhldgtaxcode.
              ls_glentry_final-tds_base_amount = ' '.
              ls_glentry_final-tds_deduction_rate = ' '.

              LOOP AT it_glEntry INTO DATA(wa_vendor) WHERE supplier IS NOT INITIAL.
                IF sy-subrc = 0.
                  LS_glentry_final-plantcode = wa_vendor-plant_code.
                  ls_glentry_final-location = wa_vendor-plant_name1.
                  ls_glentry_final-account_code = wa_vendor-supplier.
                  ls_glentry_final-supplier_account_name = wa_vendor-SupplierName.
                  ls_glentry_final-Pan_No = wa_vendor-BusinessPartnerPanNumber.

                ENDIF.
                CLEAR : wa_vendor.
              ENDLOOP.
              SORT it_glEntry BY glaccount.

              READ TABLE it_glEntry INTO DATA(wa_tds)
                 WITH KEY glaccount = '0021603011' BINARY SEARCH.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603018' BINARY SEARCH.
              ENDIF.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603015' BINARY SEARCH.
              ENDIF.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603005' BINARY SEARCH.
              ENDIF.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603014' BINARY SEARCH.
              ENDIF.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603020' BINARY SEARCH.
              ENDIF.

              IF sy-subrc <> 0.
                READ TABLE it_glEntry INTO wa_tds
                     WITH KEY glaccount = '0021603021' BINARY SEARCH.
              ENDIF.

              IF sy-subrc = 0.
                ls_glentry_final-tds_amount = wa_tds-amountincompanycodecurrency.
                CASE wa_tds-GLAccount.
                  WHEN '0021603018'.
                    ls_glentry_final-tds_code = '192B'.
                  WHEN '0021603015'.
                    ls_glentry_final-tds_code = '194C'.
                  WHEN '0021603005'.
                    ls_glentry_final-tds_code = '194R'.
                  WHEN '0021603011'.
                    ls_glentry_final-tds_code = '192B'.
                  WHEN '0021603014'.
                    ls_glentry_final-tds_code = ' '.
                  WHEN '0021603020'.
                    ls_glentry_final-tds_code = '194A'.
                  WHEN '0021603021'.
                    ls_glentry_final-tds_code = '194I'.
                ENDCASE.
              ENDIF.


              APPEND ls_glentry_final TO it_glentrytable.
              CLEAR: it_glEntry, wa_tds, ls_glentry_final.
              CLEAR : wa_glentry.
            ENDLOOP.


            LOOP AT it_glentrytable INTO DATA(ls_line).
              CLEAR ls_header.
              MOVE-CORRESPONDING ls_line TO ls_header.
              APPEND ls_header TO header.
            ENDLOOP.



            LOOP AT header INTO DATA(lv_header).
              ls_response-voucher_date            = lv_header-Voucher_date.
*              ls_response-Voucher_date_from       = lv_header-Voucher_date.
*              ls_response-Voucher_date_to         = lv_header-Voucher_date.
              ls_response-company_code            = lv_header-Company_code.
*              ls_response-Voucher_date_from       = lv_posting_date_from.
*              ls_response-Voucher_date_to         = lv_posting_date_to.
              ls_response-voucher_no              = lv_header-voucher_no.
              ls_response-plantcode               = lv_header-plantcode.
              ls_response-DebitCreditCode         = lv_header-DebitCreditCode.
              ls_response-location                = lv_header-location.
              ls_response-account_code            = lv_header-account_code.
              ls_response-supplier_account_name   = lv_header-Supplier_Account_Name.
              ls_response-pan_no                  = lv_header-Pan_No.
              ls_response-tds_code                = lv_header-TDS_Code.
              ls_response-tds_deduction_rate      = lv_header-TDS_Deduction_Rate.
              IF lv_header-TDS_Base_Amount < 0.
                ls_response-tds_base_amount       = lv_header-TDS_Base_Amount * -1.
              ELSE.
                ls_response-tds_base_amount       = lv_header-TDS_Base_Amount.
              ENDIF.
              IF lv_header-Accountingdocumenttype = 'RK'.
                ls_response-tds_amount            = lv_header-TDS_Amount * -1.
              ELSEIF lv_header-TDS_Amount < 0 .
                ls_response-tds_amount            = lv_header-TDS_Amount * -1.
              ELSE.
                ls_response-tds_amount            = lv_header-TDS_Amount.
              ENDIF.
              ls_response-lower_deduction_no      = lv_header-Lower_Deduction_No.

              IF lv_header-DebitCreditCode = 'H' AND ls_response-tds_amount < 0.
                ls_response-tds_amount            = ls_response-tds_amount * -1 .
              ELSE.
                ls_response-tds_amount            =  ls_response-tds_amount .
              ENDIF.

              IF lv_header-DebitCreditCode        = 'S' AND ls_response-tds_amount > 0.
                ls_response-tds_amount            = ls_response-tds_amount * -1 .
              ELSE.
                ls_response-tds_amount            =  ls_response-tds_amount .
              ENDIF.

              APPEND ls_response TO lt_response.
              CLEAR : ls_response , lV_header.

            ENDLOOP.

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

*                WHEN 'VOUCHER_DATE_FROM'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY voucher_date_from DESCENDING.
*                  ELSE.
*                    SORT lt_response BY voucher_date_from ASCENDING.
*                  ENDIF.
*
*                WHEN 'VOUCHER_DATE_TO'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY voucher_date_to DESCENDING.
*                  ELSE.
*                    SORT lt_response BY voucher_date_to ASCENDING.
*                  ENDIF.

                WHEN 'VOUCHER_NO'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY voucher_no DESCENDING.
*                  ELSE.
*                    SORT lt_response BY voucher_no ASCENDING.
*                  ENDIF.
                  SORT lt_response BY voucher_no ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY voucher_no DESCENDING.
                  ENDIF.


                WHEN 'COMPANY_CODE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY company_code DESCENDING.
*                  ELSE.
*                    SORT lt_response BY company_code ASCENDING.
*                  ENDIF.
                  SORT lt_response BY Company_code ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY Company_code DESCENDING.
                  ENDIF.


                WHEN 'ACCOUNT_CODE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY account_code DESCENDING.
*                  ELSE.
*                    SORT lt_response BY account_code ASCENDING.
*                  ENDIF.
                  SORT lt_response BY account_code ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY account_code DESCENDING.
                  ENDIF.



                WHEN 'TDS_CODE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY tds_code DESCENDING.
*                  ELSE.
*                    SORT lt_response BY tds_code ASCENDING.
*                  ENDIF.
                  SORT lt_response BY TDS_Code ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY TDS_Code DESCENDING.
                  ENDIF.

                WHEN 'TDS_AMOUNT'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY tds_amount DESCENDING.
*                  ELSE.
*                    SORT lt_response BY tds_amount ASCENDING.
*                  ENDIF.
                  SORT lt_response BY TDS_Amount ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY TDS_Amount DESCENDING.
                  ENDIF.

                WHEN 'PLANTCODE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY plantcode DESCENDING.
*                  ELSE.
*                    SORT lt_response BY plantcode ASCENDING.
*                  ENDIF.
                  SORT lt_response BY plantcode ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY plantcode DESCENDING.
                  ENDIF.

                WHEN 'LOCATION'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY location DESCENDING.
*                  ELSE.
*                    SORT lt_response BY location ASCENDING.
*                  ENDIF.
                  SORT lt_response BY location ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY location DESCENDING.
                  ENDIF.

                WHEN 'TDS_DEDUCTION_RATE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY tds_deduction_rate DESCENDING.
*                  ELSE.
*                    SORT lt_response BY tds_deduction_rate ASCENDING.
*                  ENDIF.
                  SORT lt_response BY TDS_Deduction_Rate ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY TDS_Deduction_Rate DESCENDING.
                  ENDIF.


                WHEN 'SUPPLIER_ACCOUNT_NAME'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY supplier_account_name DESCENDING.
*                  ELSE.
*                    SORT lt_response BY supplier_account_name ASCENDING.
*                  ENDIF.
                  SORT lt_response BY Supplier_Account_Name ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY Supplier_Account_Name DESCENDING.
                  ENDIF.

                WHEN 'PAN_NO'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY pan_no DESCENDING.
*                  ELSE.
*                    SORT lt_response BY pan_no ASCENDING.
*                  ENDIF.
                  SORT lt_response BY Pan_No ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY Pan_No DESCENDING.
                  ENDIF.


                WHEN 'TDS_BASE_AMOUNT'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY tds_base_amount DESCENDING.
*                  ELSE.
*                    SORT lt_response BY tds_base_amount ASCENDING.
*                  ENDIF.
                  SORT lt_response BY TDS_Base_Amount ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY TDS_Base_Amount DESCENDING.
                  ENDIF.


                WHEN 'LOWER_DEDUCTION_NO'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY lower_deduction_no DESCENDING.
*                  ELSE.
*                    SORT lt_response BY lower_deduction_no ASCENDING.
*                  ENDIF.
                  SORT lt_response BY Lower_Deduction_No ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY Lower_Deduction_No DESCENDING.
                  ENDIF.

                WHEN 'ACCOUNTINGDOCUMENTTYPE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY accountingdocumenttype DESCENDING.
*                  ELSE.
*                    SORT lt_response BY accountingdocumenttype ASCENDING.
*                  ENDIF.
                  SORT lt_response BY Accountingdocumenttype ASCENDING.
                  IF ls_sort-descending = abap_true.
                    SORT lt_response BY Accountingdocumenttype DESCENDING.
                  ENDIF.


                WHEN 'DEBITCREDITCODE'.
*                  IF ls_sort-descending = 'X'.
*                    SORT lt_response BY debitcreditcode DESCENDING.
*                  ELSE.
*                    SORT lt_response BY debitcreditcode ASCENDING.
*                  ENDIF.
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
            ls_response-Voucher_date = '20250428'.
*            ls_response-Voucher_date_from = '20250428'.
*            ls_response-Voucher_date_to = '20250427'.
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

*            io_response->set_total_number_of_records( lines( lt_response ) ).
*            io_response->set_data( lt_response ).

          ENDMETHOD.
ENDCLASS.
