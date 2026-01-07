CLASS zclass_wo_screen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLASS_WO_SCREEN IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_works_order,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

*      DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameters)  = io_request->get_parameters( ).
      DATA(lt_fileds)  = io_request->get_requested_elements( ).
      DATA(lt_sort)  = io_request->get_sort_elements( ).

      DATA: lt_error_log TYPE TABLE OF string.

TRY.
    DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
  CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
  APPEND lx_no_sel_option->get_text( ) TO lt_error_log.
ENDTRY.





      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'SALESDOCUMENT'.
          DATA(lt_salesdoc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SDDOCUMENTCATEGORY'.
          DATA(lt_sd_cat) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'CREATIONDATE'.
          DATA(lt_dt) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
      a~salesdocument,
      a~sddocumentcategory,
      a~creationdate
      FROM i_salesdocument WITH PRIVILEGED ACCESS AS a
      WHERE a~SalesDocument IN @lt_salesdoc
      AND a~SDDocumentCategory IN @lt_sd_cat
      AND a~CreationDate IN @lt_dt
      INTO TABLE @DATA(it_item).

      loop at it_item INTO DATA(wa).
      ls_response-SalesDocument = wa-SalesDocument.
      ls_response-SDDocumentCategory = wa-SDDocumentCategory.
      ls_response-CreationDate = wa-CreationDate.
      APPEND ls_response TO lt_response.
      clear wa.
      clear ls_response.

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

    ENDIF.
  ENDMETHOD.
ENDCLASS.
