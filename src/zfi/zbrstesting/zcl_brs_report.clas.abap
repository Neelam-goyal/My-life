CLASS zcl_brs_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BRS_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
     DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
     DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
     DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

     DATA(lt_parameters)  = io_request->get_parameters( ).
     DATA(lt_fileds)  = io_request->get_requested_elements( ).
     DATA(lt_sort)  = io_request->get_sort_elements( ).

     TRY.
         DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
       CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
         CLEAR lt_Filter_cond.
     ENDTRY.

     LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
       IF ls_filter_cond-name = to_upper( 'comp_code' ).
         DATA(lt_comp) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'house_bank' ).
         DATA(lt_bank) = ls_FILTER_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'acc_id' ).
         DATA(lt_acc) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'postingdate' ).
         DATA(lt_postingdate) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'brspostingdate' ).
         DATA(lt_brsdate) = ls_filter_cond-range[].
       ENDIF.
     ENDLOOP.

     DATA: lt_response    TYPE TABLE OF zdd_brs_report,
           ls_line        LIKE LINE OF lt_response,
           lt_responseout LIKE lt_response,
           ls_responseout LIKE LINE OF lt_responseout,
           lt_response1 like lt_response.

    select from zbrstable as a
    left join I_AccountingDocumentJournal as b on a~in_gl = b~GLAccount and a~out_gl = b~GLAccount
    fields b~AccountingDocument
    where a~comp_code in @lt_comp and a~house_bank in @lt_bank and a~acc_id in @lt_acc
    into table @data(it).

    READ TABLE lt_postingdate INTO DATA(ls_postingdate) INDEX 1.
     IF sy-subrc = 0.
        DATA(lv_postingdate) = ls_postingdate-low.
     ENDIF.

     LOOP AT it INTO DATA(wa).
         ls_line-actual_posting = lv_postingdate.
         ls_line-doc = wa-AccountingDocument.
         APPEND ls_line TO lt_response.
         clear ls_line.
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
