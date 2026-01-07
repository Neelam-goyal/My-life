 CLASS zcl_http_pick_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_PICK_LIST IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    TRY.

        DATA(req) = request->get_form_fields(  ).
        response->set_header_field( i_name = 'Addess-Control-Allow-Origin' i_value = '*' ).
        response->set_header_field( i_name = 'Addess-Control-Allow-Credentials' i_value = 'true' ).
        DATA(cookies)  = request->get_cookies(  ) .

        DATA req_host TYPE string.
        DATA req_proto TYPE string.
        DATA json TYPE string .

        req_host = request->get_header_field( i_name = 'Host' ).
        req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
        IF req_proto IS INITIAL.
          req_proto = 'https'.

        ENDIF.
        DATA(symandt) = sy-mandt.

        DATA(dd) = VALUE #( req[ name = 'deliverydocument' ]-value OPTIONAL ).


        CASE request->get_method( ).

          WHEN CONV string( if_web_http_client=>post ).
            " POST method processing
*            data : lv_del type I_DeliveryDocument-DeliveryDocument.
*            CONCATENATE '00' dd into lv_del.
*
*            SELECT SINGLE deliverydocument,deliverydate
*              FROM I_DeliveryDocument
*              WHERE deliverydocument = @lv_del
*              INTO @DATA(wa_check).


            IF dd is not initial.
                 data(pdf) = zcl_picklist=>read_posts( Delivery = dd  ).
                IF pdf = 'ERROR'.
                    response->set_text( 'Error generating PDF. Please check the document data.' ).
                  ELSE.
                    response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                    response->set_text( pdf ).
                ENDIF.
            ENDIF.
        ENDCASE.

      CATCH cx_static_check INTO DATA(lx_static).
        response->set_status( i_code = 500 ).
        response->set_text( lx_static->get_text( ) ).
      CATCH cx_root INTO DATA(lx_root).
        response->set_status( i_code = 500 ).
        response->set_text( lx_root->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
