CLASS zcl_hsnb2b DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_HSNB2B IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zce_hsn_b2b,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.




      "   DATA : lv_index          TYPE sy-tabix.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited
      THEN 0
                                  ELSE lv_top ).

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).



      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          DATA(lv_msg) = lx_no_sel_option->get_text( ).
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'HSN'.
          DATA(lt_hsn) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'BILL_DATE'.
          DATA(lt_Date) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'GSTIN'.
          DATA(lt_GSTIN) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_compantcodename) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'PLANTCODE'.
          DATA(lt_plantcodename) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'UOM'.
          DATA(lt_uom) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'SALETYPE'.
          DATA(lt_saletype) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

    ENDIF.


    SELECT a~saletype,
    SUM( a~totaltaxamount ) AS totaltaxamount,
    SUM( a~totalamount ) AS totalamount,
         a~hsncode,
         a~uom,
    SUM( a~qty ) AS qty,
    SUM( a~rate ) AS rate,
    SUM( a~taxablevalueafterdiscount ) AS taxablevalueafterdiscount,
    SUM( a~igstamt ) AS igstamt,
    SUM(  a~cgstamt  ) AS cgstamt,
    SUM( a~ugstamt ) AS ugstamt,
    SUM( a~sgstamt ) AS sgstamt,
         a~companycode,
         a~gstrate,
         a~deliveryplant AS plant
    FROM zbillinglines   AS a
    WHERE a~saletype        IN @lt_saletype
    AND a~hsncode           IN @lt_hsn
    AND a~invoicedate       IN @lt_date
    AND a~companycode       IN @lt_compantcodename
    AND a~deliveryplant     IN @lt_plantcodename
    AND a~soldtopartygstin  IN @lt_gstin
    AND a~uom               IN @lt_uom
    AND a~deliveryplant     IS NOT INITIAL
    AND a~companycode       IS NOT INITIAL
    AND a~hsncode           IS NOT INITIAL
    AND a~fiscalyearvalue   IS NOT INITIAL
    AND a~billingtype       NOT IN ( 'JDC', 'JVR', 'JSN' )
    AND a~cancelledinvoice  NE 'X'
    GROUP BY companycode, deliveryplant, hsncode, uom, saletype, gstrate
    INTO  TABLE @DATA(lt_result) PRIVILEGED ACCESS .

    LOOP AT lt_result INTO DATA(wa).
      ls_response-companycode = wa-companycode.
      ls_response-plantcode = wa-Plant.
      ls_response-b2b_b2c = wa-saletype.
      ls_response-hsn = wa-hsncode.
      ls_response-uqm = wa-uom.
      ls_response-TotalQuantity = wa-qty.
      ls_response-TotalValue = wa-totalamount .
      ls_response-GstRate = wa-gstrate.
      ls_response-TaxableValue = wa-taxablevalueafterdiscount.
      ls_response-IntegratedTaxAmount = wa-igstamt.
      ls_response-CentralTaxAmount = wa-cgstamt.
      ls_response-StateTaxAmount = wa-sgstamt.
      ls_response-StateUTTaxAmount = wa-ugstamt.
      APPEND ls_response TO lt_response.
      CLEAR: ls_response.
    ENDLOOP.

    LOOP AT lt_response INTO ls_response.
      SELECT SINGLE Consumptiontaxctrlcodetext1
      FROM I_AE_CnsmpnTaxCtrlCodeTxt
      WHERE ConsumptionTaxCtrlCode = @ls_response-hsn AND Language = 'E'
      INTO @ls_response-Description.
      MODIFY lt_response FROM ls_response.
    ENDLOOP.

    SORT lt_response BY hsn uqm plantcode GstRate Description  companycode ." bill_Date.

    DELETE ADJACENT DUPLICATES FROM lt_response COMPARING ALL FIELDS.

    " SORT LOGIC BASED ON UI
    LOOP AT lt_sort ASSIGNING FIELD-SYMBOL(<fs_sort>).
      CASE <fs_sort>-element_name.
        WHEN 'HSN'.
          IF <fs_sort>-descending = abap_true.
            SORT lt_response BY hsn DESCENDING.
          ELSE.
            SORT lt_response BY hsn ASCENDING.
          ENDIF.


        WHEN 'TAXABLEVALUE'.
          IF <fs_sort>-descending = abap_true.
            SORT lt_response BY TaxableValue DESCENDING.
          ELSE.
            SORT lt_response BY TaxableValue ASCENDING.
          ENDIF.
          " Add more WHEN clauses here if other fields are sortable

      ENDCASE.
    ENDLOOP.



    lv_max_rows = lv_skip + lv_top.
    IF lv_skip > 0.
      lv_skip = lv_skip + 1.
    ENDIF.
    CLEAR lt_responseout.
    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>)
    FROM lv_skip TO lv_max_rows.
      ls_responseout = <lfs_out_line_item>.
      APPEND ls_responseout TO lt_responseout.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_response ) ).
    io_response->set_data( lt_responseout ).


  ENDMETHOD.
ENDCLASS.
