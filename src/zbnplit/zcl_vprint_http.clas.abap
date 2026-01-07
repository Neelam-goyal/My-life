CLASS ZCL_VPrint_HTTP DEFINITION
   PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_http_service_extension.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_VPRINT_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(req_method) = request->get_method( ).

    CASE req_method.
      WHEN CONV string( if_web_http_client=>post ).

        DATA(lv_accountingdocument) = request->get_form_field( `lv_accountingdocument` ).
        DATA(lv_companycode) = request->get_form_field( `lv_companycode` ).
        DATA(lv_fiscalyear) = request->get_form_field( `lv_fiscalyear` ).

        IF lv_accountingdocument IS INITIAL OR
           lv_companycode IS INITIAL OR
           lv_fiscalyear IS INITIAL.

          response->set_status( i_code = 500 ).
          response->set_text( |Please submit valid request| ).

        ELSE.


          TRY.
              DATA(pdf_content) = zcl_vprint_xml=>read_posts(
                lv_accountingdocument = lv_accountingdocument
                lv_companycode = lv_companycode
                lv_fiscalyear = lv_fiscalyear
                lc_template_name = 'ZFI_vprint_all/zfi_vprint'
              ).

              response->set_text( pdf_content ).
            CATCH cx_static_check INTO DATA(lx_static).
              response->set_status( i_code = 500 ).
              response->set_text( lx_static->get_text( ) ).
            CATCH cx_root INTO DATA(lx_root).
              response->set_status( i_code = 500 ).
              response->set_text( lx_root->get_text( ) ).
          ENDTRY.
        ENDIF.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
