CLASS zcl_gst_purchase_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_gst_purchase_report IMPLEMENTATION.


  METHOD if_rap_query_provider~select.


    DATA: lt_response    TYPE TABLE OF zcds_gst_purchase,
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


    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      IF ls_filter_cond-name = 'DOC_TYPE'.
        DATA(lt_documenttype) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'MRN_NO'.
        DATA(lt_mrn_number) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'HSN_CODE'.
        DATA(lt_hsn_sac_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'BILL_NO'.
        DATA(lt_bill_number) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'SUPPLIER_CODE'.
        DATA(lt_supplier_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'BILL_DATE'.
        DATA(lt_bill_date) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'LOCALCENTRE'.
        DATA(lt_local_centre) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'LOCATION'.
        DATA(lt_location) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'MRN_DATE'.
        DATA(lt_mrn_date) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PRODUCTNAME'.
        DATA(lt_product_name) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PURPOSTINGCODE'.
        DATA(lt_purposting_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PURPOSTINGHEAD'.
        DATA(lt_purposting_head) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'SUPPLIERGSTNO'.
        DATA(lt_supplier_gst_no) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'SUPPLIERNAME'.
        DATA(lt_supplier_name) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'SUPPLIERSTATE'.
        DATA(lt_supplier_state) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'TAXCODE'.
        DATA(lt_tax_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'UOM'.
        DATA(lt_uom) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'COMPANY_CODE'.
        DATA(lt_company_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PLANT_CODE'.
        DATA(lt_plant_code) = ls_filter_cond-range[].
      ENDIF.
    ENDLOOP.


    DATA lv_hsn_code TYPE c LENGTH 8.

    LOOP AT lt_hsn_sac_code INTO DATA(ls_hsn_sac_code).
      lv_hsn_code = |{ ls_hsn_sac_code-low ALPHA = OUT }|.
      ls_hsn_sac_code-low = lv_hsn_code.
      CLEAR lv_hsn_code.
      lv_hsn_code = |{ ls_hsn_sac_code-high ALPHA = OUT }|.
      ls_hsn_sac_code-high = lv_hsn_code.
      MODIFY lt_hsn_sac_code FROM ls_hsn_sac_code.
      CLEAR : ls_hsn_sac_code, lv_hsn_code.
    ENDLOOP.

    DATA lv_pur_posting TYPE c LENGTH 10.

    LOOP AT lt_purposting_code INTO DATA(ls_pur_posting).
      lv_pur_posting = |{ ls_pur_posting-low ALPHA = IN }|.
      ls_pur_posting-low = lv_pur_posting.
      CLEAR lv_pur_posting.
      lv_pur_posting = |{ ls_pur_posting-high ALPHA = IN }|.
      ls_pur_posting-high = lv_pur_posting.
      MODIFY lt_purposting_code FROM ls_pur_posting.
      CLEAR : ls_pur_posting , lv_pur_posting.
    ENDLOOP.



    SELECT FROM zpurchinvlines AS a
    LEFT JOIN I_SupplierInvoiceAPI01 AS b ON b~SupplierInvoice = a~supplierinvoice AND b~FiscalYear = a~fiscalyearvalue
    LEFT JOIN I_Supplier AS c ON c~Supplier = b~InvoicingParty
    LEFT JOIN I_RegionText AS d ON d~Country = c~Country AND d~Region = c~Region AND d~Language = 'E'
    LEFT JOIN c_supplierinvoiceitemdex AS e ON e~SupplierInvoice = a~supplierinvoice AND e~SupplierInvoiceItem = a~supplierinvoiceitem AND e~FiscalYear = a~fiscalyearvalue
    LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 AS h ON h~SupplierInvoice = a~supplierinvoice AND h~SupplierInvoiceItem = a~supplierinvoiceitem AND h~FiscalYear = a~fiscalyearvalue
    FIELDS a~supplierinvoice , a~supplierinvoiceitem , a~postingdate , a~hsncode , a~supp_gst , a~suppliercode ,
           a~suppliercodename , a~productname , a~SupplierBillNo , a~Purchaseordertype , a~taxcodename , a~Plantname ,a~purchaseorder,a~purchaseorderitem ,
           a~rateigst + a~ratendigst AS rateigst , a~ratecgst + a~ratendcgst AS ratecgst , a~ratesgst + a~ratendsgst AS ratesgst,
            a~igst , a~sgst , a~cgst , a~mrnquantityinbaseunit , a~baseunit , a~taxableamount,
           a~grnno , a~totalamount , a~plantcode , a~companycode , a~fiscalyearvalue, a~ndcgst, a~ndigst, a~ndsgst, a~isreversed AS isreversed,
           d~RegionName, a~transactiontype, a~referencedocumentno,
         h~TaxCode , h~SupplierInvoiceItemAmount
    WHERE a~suppliercode IN  @lt_supplier_code
      AND a~hsncode  IN @lt_hsn_sac_code
      AND a~purchaseordertype IN @lt_documenttype
      AND a~grnno IN @lt_mrn_number
      AND a~supplierbillno IN @lt_bill_number
      AND a~postingdate IN @lt_bill_date
      AND a~plantname IN @lt_location
      AND a~postingdate IN @lt_mrn_date
      AND a~productname IN @lt_product_name
      AND a~supp_gst IN @lt_supplier_gst_no
      AND a~suppliercodename IN @lt_supplier_name
      AND d~RegionName IN @lt_supplier_state
      AND a~taxcodename IN @lt_tax_code
      AND a~baseunit IN @lt_uom
      AND a~companycode IN @lt_company_code
      AND a~plantcode IN @lt_plant_code
      AND a~transactiontype NE 'WIT'
    INTO TABLE @DATA(it_main)
    PRIVILEGED ACCESS.

    DATA: it_main2 LIKE it_main.
    MOVE-CORRESPONDING it_main TO it_main2.

    DELETE it_main2 WHERE referencedocumentno IS INITIAL.
*    SELECT FROM I_TaxCodeRate AS a
*    FIELDS a~TaxCode , a~VATConditionType , a~ConditionRateRatio
*    WHERE a~Country = 'IN'
*    INTO TABLE @DATA(it_tax)
*    PRIVILEGED ACCESS.


    LOOP AT it_main ASSIGNING FIELD-SYMBOL(<wa_main>).

      ls_response-supplier_inv = <wa_main>-supplierinvoice.
      ls_response-supplier_item = <wa_main>-supplierinvoiceitem.
      ls_response-mrn_date = <wa_main>-PostingDate.
      ls_response-bill_date = <wa_main>-PostingDate.
      ls_response-hsn_code = <wa_main>-hsncode.
      ls_response-suppliergstno = <wa_main>-supp_gst.
      ls_response-supplier_code = <wa_main>-suppliercode.
      ls_response-suppliername = <wa_main>-suppliercodename.
      ls_response-productname = <wa_main>-productname.
      ls_response-bill_no = <wa_main>-supplierbillno.
      ls_response-doc_type = <wa_main>-purchaseordertype.
      ls_response-taxcode = <wa_main>-taxcodename.
      ls_response-qty = <wa_main>-mrnquantityinbaseunit.
      ls_response-uom = <wa_main>-baseunit.
      ls_response-location = <wa_main>-plantname.
      ls_response-mrn_no = <wa_main>-grnno.
      ls_response-amount = <wa_main>-totalamount.
      ls_response-Taxableamount = <wa_main>-taxableamount.
      ls_response-supplierstate = <wa_main>-RegionName.
      ls_response-company_code = <wa_main>-companycode.
      ls_response-plant_code = <wa_main>-plantcode.
      ls_response-ndcgstamount = <wa_main>-ndcgst.
      ls_response-ndsgstamount = <wa_main>-ndsgst.
      ls_response-ndigstamount = <wa_main>-ndigst.
      ls_response-cgstamount = <wa_main>-cgst.
      ls_response-sgstamount = <wa_main>-sgst.
      ls_response-igstamount = <wa_main>-igst.
      ls_response-isreversed = <wa_main>-isreversed.
      ls_response-gstrate = <wa_main>-ratecgst + <wa_main>-rateigst + <wa_main>-ratesgst.
      READ TABLE it_main2 INTO DATA(wa_main2) WITH KEY referencedocumentno = <wa_main>-supplierinvoice supplierinvoiceitem = <wa_main>-supplierinvoiceitem.
      IF sy-subrc = 0.
        ls_response-isreversed = 'X'.
      ENDIF.


      DATA : suppinv TYPE string .
      DATA : fisyea TYPE string .
      suppinv = <wa_main>-supplierinvoice.
      fisyea = <wa_main>-fiscalyearvalue.
      CONCATENATE suppinv fisyea INTO suppinv.

      SELECT SINGLE FROM I_OperationalAcctgDocItem AS b
         LEFT JOIN I_GLAccountTextRawData AS c ON c~GLAccount = b~GLAccount
         FIELDS c~GLAccountLongName , c~GLAccount
         WHERE c~GLAccountLongName IS NOT INITIAL
           AND c~Language = 'E'
           AND b~AccountingDocumentType <> 'K'
           AND b~AccountingDocumentItemType <> 'T'
           AND b~OriginalReferenceDocument = @suppinv
           AND c~GLAccount IN @lt_purposting_code
           AND b~TransactionTypeDetermination EQ 'WRX'
         INTO  @DATA(wa_gl)
         PRIVILEGED ACCESS.
      ls_response-purpostingcode = wa_gl-GLAccount.
      ls_response-purpostinghead = wa_gl-GLAccountLongName.



      CLEAR : wa_gl ,  suppinv , fisyea.



*      READ TABLE it_tax INTO DATA(wa_tax) WITH KEY TaxCode = <wa_main>-TaxCode .
*      IF wa_tax-VATConditionType = 'JIIG'.
*        ls_response-gstrate = wa_tax-ConditionRateRatio.
*        ls_response-igstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*      ELSEIF wa_tax-VATConditionType = 'JISG'.
*        ls_response-gstrate = wa_tax-ConditionRateRatio.
*        ls_response-cgstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*        ls_response-sgstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*      ELSEIF wa_tax-VATConditionType = 'JIIN'.
*        ls_response-gstrate = wa_tax-ConditionRateRatio.
*        ls_response-igstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*      ELSEIF wa_tax-VATConditionType = 'JISN'.
*        ls_response-gstrate = wa_tax-ConditionRateRatio.
*        ls_response-cgstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*        ls_response-sgstamount = ( <wa_main>-SupplierInvoiceItemAmount * wa_tax-ConditionRateRatio ) / 100 .
*      ENDIF.


      IF <wa_main>-igst IS NOT INITIAL.
        ls_response-localcentre = 'CENTRE'.
      ELSE.
        ls_response-localcentre = 'LOCAL'.
      ENDIF.

      IF <wa_main>-supplierinvoice IS NOT INITIAL.
        ls_response-pass_tag = 'PASS'.
      ELSE.
        ls_response-pass_tag = 'FAIL'.
      ENDIF.

      IF ls_response-qty NE 0.
        ls_response-rate = ls_response-amount / ls_response-qty.
      ELSE.
        ls_response-rate = 0.
      ENDIF.


      APPEND ls_response TO lt_response.
      CLEAR: <wa_main>, ls_response, wa_main2 .
    ENDLOOP.

    CLEAR it_main.

    LOOP AT lt_sort INTO DATA(ls_sort).
      CASE ls_sort-element_name.

        WHEN 'DOC_TYPE'.
          SORT lt_response BY doc_type ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY doc_type DESCENDING.
          ENDIF.

        WHEN 'MRN_NO'.
          SORT lt_response BY mrn_no ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY mrn_no DESCENDING.
          ENDIF.

        WHEN 'HSN_CODE'.
          SORT lt_response BY hsn_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY hsn_code DESCENDING.
          ENDIF.

        WHEN 'BILL_NO'.
          SORT lt_response BY bill_no ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY bill_no DESCENDING.
          ENDIF.

        WHEN 'SUPPLIER_CODE'.
          SORT lt_response BY supplier_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY supplier_code DESCENDING.
          ENDIF.


        WHEN 'BILL_DATE'.
          SORT lt_response BY bill_date ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY bill_date DESCENDING.
          ENDIF.

        WHEN 'LOCALCENTRE'.
          SORT lt_response BY localcentre ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY localcentre DESCENDING.
          ENDIF.

        WHEN 'LOCATION'.
          SORT lt_response BY location ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY location DESCENDING.
          ENDIF.

        WHEN 'MRN_DATE'.
          SORT lt_response BY mrn_date ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY mrn_date DESCENDING.
          ENDIF.

        WHEN 'PRODUCTNAME'.
          SORT lt_response BY productname ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY productname DESCENDING.
          ENDIF.

        WHEN 'PURPOSTINGCODE'.
          SORT lt_response BY purpostingcode ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY purpostingcode DESCENDING.
          ENDIF.

        WHEN 'PURPOSTINGHEAD'.
          SORT lt_response BY purpostinghead ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY purpostinghead DESCENDING.
          ENDIF.

        WHEN 'SUPPLIERGSTNO'.
          SORT lt_response BY suppliergstno ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY suppliergstno DESCENDING.
          ENDIF.

        WHEN 'SUPPLIERNAME'.
          SORT lt_response BY suppliername ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY suppliername DESCENDING.
          ENDIF.

        WHEN 'SUPPLIERSTATE'.
          SORT lt_response BY supplierstate ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY supplierstate DESCENDING.
          ENDIF.

        WHEN 'TAXCODE'.
          SORT lt_response BY taxcode ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY taxcode DESCENDING.
          ENDIF.

        WHEN 'UOM'.
          SORT lt_response BY uom ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY uom DESCENDING.
          ENDIF.

        WHEN 'COMPANY_CODE'.
          SORT lt_response BY company_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY company_code DESCENDING.
          ENDIF.

        WHEN 'PLANT_CODE'.
          SORT lt_response BY plant_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY plant_code DESCENDING.
          ENDIF.

      ENDCASE.
    ENDLOOP.


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



  ENDMETHOD.
ENDCLASS.
