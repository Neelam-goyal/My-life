CLASS ycl_account_statement_handler DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS YCL_ACCOUNT_STATEMENT_HANDLER IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields( ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).


    DATA(accounttype) = VALUE #( req[ name = 'accounttype' ]-value OPTIONAL ).
    DATA(lastdate) = VALUE #( req[ name = 'lastdate' ]-value OPTIONAL ).
    DATA(currentdate) = VALUE #( req[ name = 'currentdate' ]-value OPTIONAL ).
    DATA(correspondence) = VALUE #( req[ name = 'correspondence' ]-value OPTIONAL ).
    DATA(companycode) = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(customer) = VALUE #( req[ name = 'customer' ]-value OPTIONAL ).
    DATA(profitcenter1) = VALUE #( req[ name = 'profitcenter' ]-value OPTIONAL ).
    DATA(confirmletterbox) = VALUE #( req[ name = 'confirmletterbox' ]-value OPTIONAL ).
    DAta(Both) = VALUE #( req[ name = 'both' ]-value OPTIONAL ).

    DATA profitcenter TYPE c LENGTH 10 .
    profitcenter = |{ profitcenter1 ALPHA = IN }|.

    " Convert the input to uppercase
    companycode = to_upper( companycode ).

    IF strlen( companycode ) > 4.
      response->set_text( |Invalid company code: { companycode }. Length must not exceed 4 characters.| ).
      RETURN.
    ENDIF.

    IF strlen( customer ) = 8.
      CONCATENATE '00' customer INTO customer.
    ELSEIF strlen( customer ) = 9.
      CONCATENATE '0' customer INTO customer.
    ENDIF.

    TRY.

        CASE accounttype.
          WHEN 'D'. " Customer
            SELECT SINGLE FROM i_customer AS a
            FIELDS a~customer
             WHERE customer = @customer
              INTO @DATA(valid_customer).

            IF valid_customer IS NOT INITIAL.
              SELECT SINGLE FROM I_OperationalAcctgDocItem
              FIELDS customer , companycode
              WHERE companycode = @companycode
              AND customer = @customer
              INTO @DATA(valid_customer_companycode).
            ENDIF.

            IF valid_customer IS INITIAL.
              response->set_text( |Customer { customer } not found in master data| ).
              RETURN.
            ENDIF.
            IF valid_customer_companycode IS INITIAL.
              response->set_text( |Customer { customer } not found in master data for company code { companycode }| ).
              RETURN.
            ENDIF.
            DATA(pdf2) = yaccount_statement_customer_cl=>read_posts(
              companycode      = companycode
              correspondence   = correspondence
              accounttype      = accounttype
              customer         = customer
              lastdate         = lastdate
              currentdate      = currentdate
              profitcenter     = profitcenter
              confirmletterbox = confirmletterbox
              both            = both
            ).

          WHEN 'K'. " Supplier
            SELECT SINGLE supplier FROM i_supplier
              WHERE supplier = @customer
              INTO @DATA(valid_supplier).

            IF valid_supplier IS NOT INITIAL.
              SELECT SINGLE FROM I_OperationalAcctgDocItem
              FIELDS customer , companycode
              WHERE companycode = @companycode
              AND Supplier = @customer
              INTO @DATA(valid_supplier_companycode).
            ENDIF.


            IF valid_supplier IS INITIAL.
              response->set_text( |Supplier { customer } not found in master data| ).
              RETURN.
            ENDIF.
            IF valid_supplier_companycode IS INITIAL.
              response->set_text( |Supplier { customer } not found in master data for company code { companycode }| ).
              RETURN.
            ENDIF.

            pdf2 = yaccount_statement_vendor_cl=>read_posts(
              companycode      = companycode
              correspondence   = correspondence
              accounttype      = accounttype
              customer         = customer
              lastdate         = lastdate
              currentdate      = currentdate
              profitcenter     = profitcenter
              confirmletterbox = confirmletterbox
              both            = both
            ).

          WHEN OTHERS.
            response->set_text( |Invalid account type: { accounttype }. Must be 'D' or 'K'| ).
            RETURN.
        ENDCASE.

        " Set successful response
        response->set_text( pdf2 ).

      CATCH cx_static_check INTO DATA(lx_static).
        DATA(error_message) = lx_static->get_text( ).
        DATA(error_stack) = lx_static->get_longtext( ).
        response->set_text( |Getting error in generating XML for this business partner: { error_message }. Details: { error_stack }| ).
        RETURN.

      CATCH cx_root INTO DATA(lx_root).
        response->set_status( i_code = 500 ). " Internal Server Error
        response->set_text( |System error: { lx_root->get_text( ) }| ).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
