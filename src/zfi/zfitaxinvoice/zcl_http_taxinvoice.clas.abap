CLASS zcl_http_taxinvoice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_TAXINVOICE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(co) = request->get_form_field( `co` ).
    DATA(fs) = request->get_form_field( `fs` ).
    DATA(inv) = request->get_form_field( `inv` ).

    TRY.

        SELECT SINGLE FROM I_AccountingDocumentJournal AS a
        FIELDS
        a~AccountingDocument,
        a~CompanyCode,
        a~FiscalYear
         WHERE AccountingDocument = @inv
               AND CompanyCode = @co
               AND FiscalYear  = @fs
          INTO @DATA(valid_number).

        IF valid_number IS NOT INITIAL.
          DATA(pdf) = zcl_tax_invoice=>read_posts(
             ac = inv
             co = co
             fs = fs
             ).
          IF pdf = 'ERROR'.
            response->set_text( |Error generating credit note: { pdf }| ).
            RETURN.
          ELSE.
            response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
            response->set_text( pdf ).
          ENDIF.
        ELSE.
          response->set_text( '0' ).
          RETURN.
        ENDIF.


      CATCH cx_static_check INTO DATA(lx_static).
        response->set_text( |Error generating credit note: { lx_static->get_text( ) }| ).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
