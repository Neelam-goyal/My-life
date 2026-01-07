CLASS zcl_inv_series_rep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INV_SERIES_REP IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zce_inv_series_rep,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA: current TYPE c LENGTH 6 VALUE ' '.
      DATA: previous TYPE c LENGTH 6 VALUE ' '.
      DATA: start_no TYPE c LENGTH 12 VALUE ' '.
      DATA: end_no TYPE c LENGTH 12 VALUE ' '.
      DATA: ls_final LIKE LINE OF lt_response.
      DATA: it_final1 LIKE lt_response.
      DATA: last_index TYPE sy-tabix.
      DATA: curr_index TYPE sy-tabix.
      DATA: count TYPE c LENGTH 10 VALUE 0.
      DATA: cancelled TYPE c LENGTH 10 VALUE 0.



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
        IF ls_filter_cond-name = 'COMP_CODE'.
          DATA(lt_comp) = ls_filter_cond-range[].

*        ELSEIF ls_filter_cond-name = 'BILL_DATE'.
*          DATA(lt_Date) = ls_filter_cond-range[].
*
*        ELSEIF ls_filter_cond-name = 'GSTIN'.
*          DATA(lt_GSTIN) = ls_filter_cond-range[].
*
*        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
*          DATA(lt_comp) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'PLANT_CODE'.
          DATA(lt_plant) = ls_filter_cond-range[].

        ELSEIF ls_filter_cond-name = 'BILLTYPE'.
          DATA(lt_billtype) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

    ENDIF.


*    SELECT FROM I_BillingDocument AS a
*    LEFT JOIN I_BillingDocumentItem AS b ON a~CompanyCode = b~CompanyCode AND a~BillingDocument = b~BillingDocument
*    LEFT JOIN i_billingdocumenttypetext AS c ON a~BillingDocumentType = c~BillingDocumentType AND c~Language = 'E'
*    FIELDS a~CompanyCode AS comp_code, b~Plant AS plant_code,  a~BillingDocumentType AS billtype, a~DocumentReferenceID AS bill_no,
*    a~BillingDocumentIsCancelled AS cancelled_count, c~BillingDocumentTypeName AS sdoc

    select from zbillinglines as a
    left join i_billingdocumenttypetext as c on a~BillingType = c~BillingDocumentType AND c~Language = 'E'
    FIELDS a~CompanyCode AS comp_code, a~deliveryplant AS plant_code,  a~BillingType AS billtype, a~billno AS bill_no,
    a~cancelledinvoice AS cancelled_count, c~BillingDocumentTypeName AS sdoc


    WHERE a~CompanyCode IN @lt_comp AND a~deliveryplant IN @lt_plant AND a~billingtype IN @lt_billtype AND a~billingType NE 'F8'

    INTO CORRESPONDING FIELDS OF TABLE @lt_response.


*    LOOP AT lt_response INTO DATA(wa_final).
*      wa_final-bill4 = wa_final-bill_no+0(2).
*      wa_final-unit_series = wa_final-bill_no+0(2).
*
**      IF wa_final-billtype = 'CBRE' OR ls_response-billtype = 'G2'.
**        wa_final-sdoc = 'Credit Note'.
**      ELSEIF wa_final-billtype = 'JDC'.
**        wa_final-sdoc = 'Delivery Challan'.
**      ELSEIF wa_final-billtype = 'F2' OR ls_response-billtype = 'JSTO'.
**        wa_final-sdoc = 'Invoice'.
**      ENDIF.
*
*      MODIFY lT_response FROM wa_final.
*    ENDLOOP.
*    CLEAR: wa_final.

    SORT lt_response BY comp_code plant_code billtype bill_no .
    DELETE ADJACENT DUPLICATES FROM lt_response.

    CLEAR: it_final1.
    LOOP AT lt_response INTO ls_response.

    concatenate ls_response-billtype ls_response-Bill_no+0(2) into ls_response-bill4.
      ls_response-unit_series = ls_response-Bill_no+0(2).
*      ls_response-bill4 = ls_response-Bill_no+0(2).
      curr_index = sy-tabix.
*      ls_final = ls_response.
      IF current IS INITIAL AND previous IS INITIAL.
        start_no = ls_response-Bill_no.
        previous = ls_response-bill4.
        APPEND ls_response TO it_final1.
        last_index = lines( it_final1 ).
      ENDIF.

      current = ls_response-bill4.

      IF current = previous.
        previous = ls_response-bill4.
        end_no = ls_response-Bill_no.
        count = count + 1.
        IF ls_response-cancelled_count IS NOT INITIAL.
          cancelled = cancelled + 1.
        ENDIF.
*        CONTINUE.
      ELSE.

        READ TABLE it_final1 INDEX last_index INTO DATA(ls_mod).
        IF sy-subrc = 0.
          ls_mod-start_no = start_no.
          ls_mod-end_no = end_no.
          ls_mod-total_count = count.
          ls_mod-cancelled_count = cancelled.
          MODIFY it_final1 INDEX last_index FROM ls_mod TRANSPORTING start_no end_no total_count cancelled_count.
          CLEAR: ls_mod.
          CLEAR: start_no, end_no, current, previous.
        ENDIF.

        start_no = ls_response-Bill_no.
        end_no = ls_response-Bill_no.
        current = ls_response-bill4.
        previous = ls_response-bill4.
        count = 1.
        IF ls_response-cancelled_count IS NOT INITIAL.
          cancelled = 1.
        ELSE.
          cancelled = 0.
        ENDIF.
        APPEND ls_response TO it_final1.
        last_index = lines( it_final1 ).

      ENDIF.

      IF curr_index = lines( lt_response ).
        READ TABLE it_final1 INDEX last_index INTO ls_mod.
        IF sy-subrc = 0.
          ls_mod-start_no = start_no.
          ls_mod-end_no = end_no.
          ls_mod-total_count = count.
          ls_mod-cancelled_count = cancelled.
          MODIFY it_final1 INDEX last_index FROM ls_mod TRANSPORTING start_no end_no total_count cancelled_count.
          CLEAR: start_no, end_no, current, previous, LS_mod.
        ENDIF.
      ENDIF.

      MODIFY lt_response FROM ls_response.
      CLEAR: ls_response, ls_mod.
    ENDLOOP.
    CLEAR: lt_response.
    lt_response = it_final1.


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
