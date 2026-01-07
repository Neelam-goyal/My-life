CLASS zcl_production_update DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    CLASS-DATA it_master TYPE TABLE OF zprod_details.

    TYPES: BEGIN OF ty_json,
             to_master LIKE it_master,
           END OF ty_json.

    DATA: lv_json TYPE ty_json.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PRODUCTION_UPDATE IMPLEMENTATION.


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
                    data = lv_json.
              CATCH cx_root INTO DATA(lx_json).
                response->set_status( i_code   = 400
                                      i_reason = 'Invalid JSON format' ).
                response->set_text( |Deserialization failed: { lx_json->get_text( ) }| ).
                RETURN.
            ENDTRY.

            DATA(it_final_master) = lv_json-to_master.

            IF it_final_master IS NOT INITIAL.
              LOOP AT it_final_master INTO DATA(wa_final_master).
                MODIFY zprod_details FROM @wa_final_master.
                clear : wa_final_master.
              ENDLOOP.

              response->set_status( i_code = 200 i_reason = 'Success' ).
              response->set_text( 'Data updated successfully' ).

            ELSE.
              response->set_status( i_code = 204 i_reason = 'No Content' ).
              response->set_text( 'No data provided' ).
            ENDIF.

          WHEN OTHERS.
            response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
            response->set_text( 'Only POST method is supported' ).

        ENDCASE.

      CATCH cx_root INTO DATA(lx_error).
        response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
        response->set_text( |Unexpected error: { lx_error->get_text( ) }| ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
