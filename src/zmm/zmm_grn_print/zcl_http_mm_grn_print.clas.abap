
CLASS ZCL_HTTP_MM_GRN_PRINT DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                belnr       TYPE string
                lv_company  TYPE string
                lv_fiscal   TYPE string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_MM_GRN_PRINT IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
|<body> \n| &&
|<title>Purchase Payment Voucher  </title> \n| &&
|<form action="{ url }" method="POST">\n| &&
|<H2>Purchase Payment Voucher Print</H2> \n| &&
|<label for="fname">Document Number:  </label> \n| &&
|<input type="text" id="belnr" name="belnr" required ><br><br> \n| &&
|<input type="submit" value="Submit"> \n| &&
|</form> | &&
|</body> \n| &&
|</html> | .



  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_MM_GRN_PRINT?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(lv_belnr) = request->get_form_field( `belnr` ).
        DATA(lv_fiscal) = request->get_form_field( `fiscal` ).
        DATA(lv_company) = request->get_form_field( `company` ).


        SELECT SINGLE FROM I_MaterialDocumentItem_2
        FIELDS MaterialDocument WHERE MaterialDocument = @lv_belnr "6000000002
        INTO @DATA(lv_belnr2).

        IF lv_belnr2 IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_mm_grn_print=>read_posts( cleardoc = lv_belnr lv_fiscal = lv_fiscal lv_company = lv_company ).

*            response->set_text( pdf ).

               DATA(html) = |{ pdf }|.
*              DATA(html) = |{ pdf }|.

              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( html ).
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Document number does not exist.' ).
        ENDIF.

    ENDCASE.

*    TRY.
*        DATA(pdf) = ycl_adobe_print=>read_posts( ebeln = ebeln ).
*
*
*        response->set_text( pdf ).
*      CATCH cx_static_check INTO DATA(er).
*        response->set_text( er->get_longtext(  ) ).
*    ENDTRY.


  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Purchase Payment Voucher Print</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Purchase Payment Voucher Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
