CLASS ZCL_HTTP_EMPLOYEESTATEMENT DEFINITION
  PUBLIC
  CREATE PUBLIC .

PUBLIC SECTION.
  INTERFACES IF_HTTP_SERVICE_EXTENSION .
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_EMPLOYEESTATEMENT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(lastdate)       = VALUE #( req[ name = 'lastdate' ]-value OPTIONAL ).
    DATA(currentdate)    = VALUE #( req[ name = 'currentdate' ]-value OPTIONAL ).
    DATA(companycode)    = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(employee)       = VALUE #( req[ name = 'employee' ]-value OPTIONAL ).
    DATA(profitcenter1)   = VALUE #( req[ name = 'profitcenter' ]-value OPTIONAL ).

    DATA profitcenter TYPE c LENGTH 10 .
    profitcenter = |{ profitcenter1 ALPHA = IN }|.

    TRY.


        " Validate employee existence
        SELECT single BusinessPartner FROM i_businesspartner AS a
          LEFT JOIN I_supplier AS b
            ON a~BusinessPartner = b~supplier
          WHERE a~BusinessPartner = @employee
          INTO @DATA(valid_employee).

          IF valid_employee IS INITIAL.
            response->set_text( |Employee { employee } not found in master data| ).
            RETURN.
          ENDIF.

          " Validate company code and employee relationship
          SELECT SINGLE FROM I_OperationalAcctgDocItem
            FIELDS supplier , companycode
            WHERE companycode = @companycode
              AND Supplier = @employee
            INTO @DATA(valid_companycode).

          IF valid_companycode IS INITIAL.
            response->set_text( |Employee { employee } not found in master data for company code { companycode }| ).
            RETURN.
          ENDIF.

          " Call method to read posts
          DATA(pdf2) = zcl_employee_statement=>read_posts(
            companycode      = companycode
            employee         = employee
            lastdate         = lastdate
            currentdate      = currentdate
            profitcenter     = profitcenter
          ).
          response->set_text( pdf2 ).
          return.
        CATCH cx_root INTO DATA(lx_root).
          " Handle any exception that occurs
         response->set_status( i_code = 500 ). " Internal Server Error
        response->set_text( |System error: { lx_root->get_text( ) }| ).
      ENDTRY.


    ENDMETHOD.
ENDCLASS.
