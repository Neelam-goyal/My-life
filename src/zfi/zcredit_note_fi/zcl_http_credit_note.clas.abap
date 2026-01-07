CLASS zcl_http_credit_note DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CREDIT_NOTE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(supplierinvoice) = VALUE #( req[ name = 'documentnumber' ]-value OPTIONAL ).
    DATA(companycode) = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(fiscalyear) = VALUE #( req[ name = 'fiscalyear' ]-value OPTIONAL ).
    DATA(PrintType) = VALUE #( req[ name = 'printform' ]-value OPTIONAL ).

    TRY.

        SELECT SINGLE FROM I_SupplierInvoiceAPI01 AS a
        FIELDS a~SupplierInvoice, a~CompanyCode, a~FiscalYear
         WHERE SupplierInvoice = @supplierinvoice
               AND CompanyCode = @companycode
               AND FiscalYear  = @fiscalyear
          INTO @DATA(valid_number).

        IF valid_number IS NOT INITIAL.
            SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'zdebitnote' INTO @data(template_name) .

            IF PrintType = 'Debitnote'.
              DATA(pdf) = zcl_credit_note=>read_posts(
                 supplierinvoice = supplierinvoice
                 companycode    = companycode
                 fiscalyear     =  fiscalyear
                 lc_template_name = CONV string( template_name )
                 ).
              IF pdf = 'ERROR'.
                response->set_text( |Error generating Debitnote note: { pdf }| ).
                RETURN.
              ELSE.
                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
                RETURN.
              ENDIF.

            ELSEIF PrintType = 'TaxFree'.
              pdf = zcl_taxfree=>read_posts(
              supplierinvoice = supplierinvoice
              companycode    = companycode
              fiscalyear     =  fiscalyear
          ).
              IF pdf = 'ERROR'.
                response->set_text( |Error generating Debite Note Taxfree: { pdf }| ).
                RETURN.
              ELSE.
                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
                RETURN.
              ENDIF.

            ELSEIF PrintType = 'Taxable'.
              pdf = zcl_debite_taxable=>read_posts(
              supplierinvoice = supplierinvoice
              companycode    = companycode
              fiscalyear     =  fiscalyear
           ).
              IF pdf = 'ERROR'.
                response->set_text( |Error generating Debite Note Taxable: { pdf }| ).
                RETURN.
              ELSE.
                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
                RETURN.
              ENDIF.
            ENDIF.
          ELSE.
            response->set_text( |Supplier Invoice: { supplierinvoice } does not exist for company code { companycode } and fiscal year { fiscalyear }| ).
            RETURN.
          ENDIF.


        CATCH cx_static_check INTO DATA(lx_static).
          response->set_text( |Error generating credit note: { lx_static->get_text( ) }| ).
          RETURN.
      ENDTRY.
    ENDMETHOD.
ENDCLASS.
