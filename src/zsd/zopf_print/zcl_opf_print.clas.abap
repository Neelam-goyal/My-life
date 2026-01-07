class ZCL_OPF_PRINT definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section .

METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                lv_SO TYPE string
      RETURNING VALUE(html)  TYPE string.

    CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZCL_OPF_PRINT IMPLEMENTATION.


METHOD get_html.    "Response HTML for GET request
        html = |<html> \n| &&
      |<body> \n| &&
      |<title>Order Processing Form</title> \n| &&
*      |<form action="{ url }" method="POST">\n| &&
      |<form action="/sap/bc/http/sap/ZOPF_PRINT?sap-client=080" method="POST">\n| &&
      |<H2>OPF Print</H2> \n| &&
      |<label for="fname">Sale Order No</label> \n| &&
      |<input type="text" id="lv_so" name="lv_so" required ><br><br> \n| &&
*      |<label for="fname">Fiscal Year</label> \n| &&
*      |<input type="text" id="lv_fiscalyear" name="lv_fiscalyear" required ><br><br> \n| &&
*       |<label for="fname">Company Code</label> \n| &&
*      |<input type="text" id="lv_Companycode" name="lv_Companycode" required ><br><br> \n| &&
      |<input type="submit" value="Submit"> \n| &&
      |</form> | &&
      |</body> \n| &&
      |</html> | .
  ENDMETHOD.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

  DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZOPF_PRINT?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA soorder type C LENGTH 10.
        DATA(sorder) = request->get_form_field( `SalesOrder` ).
        soorder = |{ sorder ALPHA = IN  }|.
        select SINGLE from I_SalesOrder
        FIELDS SalesOrder
        where SalesOrder = @soorder
        into @data(lv_sale).

        IF lv_sale IS NOT INITIAL.

          TRY.
              DATA(pdf) = zopf_driver=>read_posts( lv_saleorder = soorder  ) .
              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( pdf ).
            CATCH cx_static_check INTO DATA(er).

              response->set_text( |SalesOrder does not exist: { er->get_longtext( ) }| ).

          ENDTRY.

        ELSE.

          response->set_text( |Please Enter Valid SalesOrder| ).


        ENDIF.

    ENDCASE.

  endmethod.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Order Processing Form</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>OPF Print</H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
