CLASS zcl_http_cash_ledger DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CASH_LEDGER IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(companycode)     = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(glaccount)       = VALUE #( req[ name = 'glaccount' ]-value OPTIONAL ).
    DATA(lastdate)        = VALUE #( req[ name = 'last_date' ]-value OPTIONAL ).
    DATA(currentdate)     = VALUE #( req[ name = 'current_date' ]-value OPTIONAL ).
*    DATA(profitcenter1)   = VALUE #( req[ name = 'profitcenter' ]-value OPTIONAL ).

*    DATA profitcenter TYPE c LENGTH 10.
*    profitcenter = |{ profitcenter1 ALPHA = IN }|.

    companycode = to_upper( companycode ).

    IF strlen( companycode ) > 4.
      response->set_text( |Invalid company code: { companycode }. Length must not exceed 4 characters.| ).
      RETURN.
    ENDIF.

    IF strlen( glaccount ) = 8.
      CONCATENATE '00' glaccount INTO glaccount.
    ELSEIF strlen( glaccount ) = 9.
      CONCATENATE '0' glaccount INTO glaccount.
    ENDIF.


      TRY.

*        CASE request->get_method( ).
*
*          WHEN CONV string( if_web_http_client=>post ).
*           IF request->get_method( ) = if_web_http_client=>post.


            SELECT SINGLE GLAccount, CompanyCode, PostingDate, ProfitCenter, AccountingDocument
              FROM I_AccountingDocumentJournal
              WHERE GLAccount = @glaccount
              INTO @DATA(gl_check).

            IF gl_check IS NOT INITIAL.

              DATA(pdf) = zcl_cashledger=>read_posts(
                            companycode   = companycode
                            glaccount     = glaccount
                            lastdate      = lastdate
                            currentdate   = currentdate
*                            profitcenter  = profitcenter
                             ).

              IF pdf = 'ERROR'.
                response->set_text( 'Error generating PDF. Please check the document data.' ).
              ELSE.
                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.

            ELSE.
              response->set_text( |GL Account { glaccount } not found| ).
              RETURN.
            ENDIF.

*        ENDCASE.

      CATCH cx_static_check INTO DATA(lx_static).
        response->set_status( i_code = 500 ).
        response->set_text( lx_static->get_text( ) ).

      CATCH cx_root INTO DATA(lx_root).
        response->set_status( i_code = 500 ).
        response->set_text( lx_root->get_text( ) ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
