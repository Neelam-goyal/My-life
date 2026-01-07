CLASS zcl_http_dealer_master_api DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_DEALER_MASTER_API IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
*    DATA: lt_dealers TYPE TABLE OF zdealer_tab_new1,
*          lv_json    TYPE string,
*          lv_method  TYPE string.
*
*    " Retrieve the HTTP method as a string
*    lv_method = request->get_method( ).
*
*    " Check if the request method is GET
*    IF lv_method = 'GET'.
*      " Retrieve data from the table
*      SELECT * FROM zdealer_tab_new1 INTO TABLE @lt_dealers.
*
*      " Serialize the internal table to JSON using /ui2/cl_json returning parameter
*      lv_json = /ui2/cl_json=>serialize(
*                   data        = lt_dealers
*                   pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
*
*      " Set the response header to application/json
*      response->set_header_field(
*        name  = 'Content-Type'
*        value = 'application/json'
*      ).
*
*      " Send JSON as response body
*      response->set_cdata( lv_json ).
*    ELSE.
*      " If the method is not GET, return a 405 (Method Not Allowed)
*      response->set_status( code = 405 reason = 'Method Not Allowed' ).
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
