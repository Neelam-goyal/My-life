CLASS ZCL_HHTP_SAVECAUSEDETAIL DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    CLASS-DATA it_cause TYPE TABLE OF zcause_cust_tab.

    TYPES: BEGIN OF ty_json,
             to_cause LIKE it_cause,
           END OF ty_json.

    DATA: lv_json TYPE ty_json.

TYPES: BEGIN OF ty_cause_detail,

        plant                 TYPE c LENGTH 4,
         workcenter            TYPE c LENGTH 8,
         shift                 TYPE c LENGTH 5,
         breakdowndate         TYPE d,
         manufacturingorder    TYPE c LENGTH 12,
         causecode             TYPE c LENGTH 10,
         reasoncode            TYPE c LENGTH 10,
         resondescription       TYPE c LENGTH 100,
         causedescription      TYPE c LENGTH 100,
         remarks               TYPE c LENGTH 100,
         companycode           TYPE c LENGTH 4,
         breakdownduration     TYPE i,
         breakdowndurationmin  TYPE i,
         totaltimemins         TYPE i,
         noofoccurence         TYPE i,

       END OF ty_cause_detail.


   TYPES: tt_cause_detail TYPE STANDARD TABLE OF ty_cause_detail WITH DEFAULT KEY.

    DATA: it_final_master TYPE tt_cause_detail,
          wa_final_master TYPE ty_cause_detail.

PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HHTP_SAVECAUSEDETAIL IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    TRY.

        DATA(lv_body) = request->get_text( ).

        CASE request->get_method( ).

          WHEN CONV string( if_web_http_client=>post ).
            TRY.
                CALL METHOD /ui2/cl_json=>deserialize
                  EXPORTING
                    json = lv_body
                  CHANGING
                    data = it_final_master.
              CATCH cx_root INTO DATA(lx_json).
                response->set_status( i_code   = 400
                                      i_reason = 'Invalid JSON format' ).
                response->set_text( |Deserialization failed: { lx_json->get_text( ) }| ).
                RETURN.
            ENDTRY.

*            DATA(it_final_master) = lv_json-to_product.


            IF it_final_master IS NOT INITIAL.

              LOOP AT it_final_master INTO DATA(wa_final_master).

                DATA(ls_db_entry) = VALUE zcause_cust_tab(
                  plant                = wa_final_master-plant
                  workcenter           = wa_final_master-workcenter
                  shift                = wa_final_master-shift
                  breakdowndate        = wa_final_master-breakdowndate
                  manufacturingorder   = wa_final_master-manufacturingorder
                  causecode            = wa_final_master-causecode
                  reasoncode           = wa_final_master-reasoncode
                  resondescription     = wa_final_master-resondescription
                  causedescription     = wa_final_master-causedescription
                  remarks              = wa_final_master-remarks
                  companycode          = wa_final_master-companycode
                  breakdowndurationmin = wa_final_master-breakdowndurationmin
                  totaltimemins        = wa_final_master-totaltimemins
                  noofoccurence        = wa_final_master-noofoccurence
                ).

                MODIFY zcause_cust_tab FROM @ls_db_entry.
              ENDLOOP.
              response->set_status( i_code = 200 i_reason = 'Success' ).
              response->set_text( 'Data updated successfully' ).
              RETURN.

            ELSE.
              response->set_status( i_code = 204 i_reason = 'No Content' ).
              response->set_text( 'No data provided' ).
              RETURN.
            ENDIF.

          WHEN OTHERS.
            response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
            response->set_text( 'Only POST method is supported' ).
            RETURN.

        ENDCASE.

      CATCH cx_root INTO DATA(lx_error).
        response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
        RETURN.
        response->set_text( |Unexpected error: { lx_error->get_text( ) }| ).
        RETURN.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
