class ZCL_HTTP_TEST_NEW definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_TEST_NEW IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(customer)     = VALUE #( req[ name = 'customers' ]-value OPTIONAL ).
    DATA(fromdate)        = VALUE #( req[ name = 'fromdate' ]-value OPTIONAL ).
    DATA(todate)     = VALUE #( req[ name = 'todate' ]-value OPTIONAL ).

      TRY.

              DATA(pdf) = zcl_test_new=>read_posts(
                            customer = customer
                            fromdate = fromdate
                            todate = todate
                             ).

              IF pdf = 'ERROR'.
                response->set_text( 'Error generating PDF. Please check the document data.' ).
              ELSE.
                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.


      CATCH cx_static_check INTO DATA(lx_static).
        response->set_status( i_code = 500 ).
        response->set_text( lx_static->get_text( ) ).

      CATCH cx_root INTO DATA(lx_root).
        response->set_status( i_code = 500 ).
        response->set_text( lx_root->get_text( ) ).

    ENDTRY.

  endmethod.
ENDCLASS.
