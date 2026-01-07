
CLASS ZCL_HTTP_GATE_ENTRY_PRINT DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_GATE_ENTRY_PRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(gatePass) = request->get_form_field( `GatePass` ).


        SELECT SINGLE FROM zgatepassheader
        FIELDS gate_pass WHERE gate_pass = @gatePass "6000000002
        INTO @DATA(lv_belnr2).

        IF gatePass IS NOT INITIAL.
          TRY.
              DATA(pdf) = zcl_gate_entry_print=>read_posts( cleardoc = gatePass ).

               DATA(html) = |{ pdf }|.

              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( html ).
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Gate Pass does not exist.' ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
