class ZCL_HTTP_VALIDATEPOSTING definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_VALIDATEPOSTING IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
   DATA: lv_companycode     TYPE string,
         lv_documentdate  type string,
         lv_bpartner type string,
         lv_createdtime type t,
         lv_specialglcode type  string,
         lv_linenumber type string,
        lo_request  TYPE REF TO if_web_http_request,
        lo_response TYPE REF TO if_web_http_response.

       lo_request = request.
       lo_response = response.
       data(lv_spath) = lo_request->get_header_field( '~request_uri' ).

       FIND PCRE 'Companycode=''([^'']*)''' IN lv_spath SUBMATCHES lv_companycode.
       FIND PCRE 'Documentdate=''([^'']*)''' IN lv_spath SUBMATCHES lv_documentdate.
       FIND PCRE 'Bpartner=''([^'']*)''' IN lv_spath SUBMATCHES lv_bpartner.
       FIND PCRE 'Createdtime=''([^'']*)''' IN lv_spath SUBMATCHES lv_createdtime.
       FIND PCRE 'SpecialGlCode=''([^'']*)''' IN lv_spath SUBMATCHES lv_specialglcode.
       FIND PCRE 'LineNum=''([^'']*)''' IN lv_spath SUBMATCHES lv_linenumber.







  endmethod.
ENDCLASS.
