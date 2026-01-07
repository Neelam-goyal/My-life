class ZCL_HTTP_OIPAYMPOSTING definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
     CLASS-METHODS approveData
    IMPORTING
      request  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .

     CLASS-METHODS convertIST
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(ist_str) TYPE string.
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_OIPAYMPOSTING IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

       CASE request->get_method(  ).
          WHEN CONV string( if_web_http_client=>post ).
           response->set_text( approveData( request ) ).

        ENDCASE.

  endmethod.


  METHOD approveData.
          TYPES: BEGIN OF ty_json_structure,
                 Companycode  TYPE zr_oipayments-Companycode,
                 Documentdate TYPE zr_oipayments-Documentdate,
                 Bpartner     TYPE zr_oipayments-Bpartner,
                 SpecialGlCode TYPE zr_oipayments-SpecialGlCode,
                 Createdtime  TYPE zr_oipayments-Createdtime,
                 LineNum      TYPE zr_oipayments-LineNum,
               END OF ty_json_structure.

        DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

        TRY.

            xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

            LOOP AT tt_json_structure INTO DATA(wa).

             DATA(curr_time) = cl_abap_context_info=>get_system_time( ).
             DATA(curr_date) = cl_abap_context_info=>get_system_date( ).

             DATA(ist_str) = convertIST( stime = curr_time sdate = curr_date ).


             MODIFY ENTITIES OF zr_oipayments
              ENTITY ZrOipayments
                UPDATE FIELDS ( approvedby approvedat )
                WITH VALUE #(
                  ( %key-companycode   = wa-companycode
                    %key-documentdate  = wa-documentdate
                    %key-bpartner      = wa-bpartner
                    %key-linenum       = wa-linenum
                    %key-specialglcode = wa-specialglcode
                    %key-createdtime   = wa-createdtime
                    approvedby         = sy-uname
                    approvedat         = ist_str )
                )
              FAILED DATA(failed)
              REPORTED DATA(reported).


            ENDLOOP.
        CATCH cx_sy_conversion_no_date INTO DATA(lx_date).
            message = |Error in Date Conversion: { lx_date->get_text( ) }|.

        CATCH cx_sy_conversion_no_time INTO DATA(lx_time).
            message = |Error in Time Conversion: { lx_time->get_text( ) }|.

        CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
            message = |SQL Error: { lx_sql->get_text( ) }|.

        CATCH cx_root INTO DATA(lx_root).
            message = |General Error: { lx_root->get_text( ) }|.
        ENDTRY.
  ENDMETHOD.


  METHOD convertIST.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>add
      EXPORTING
        tstmp   = timestamp
        secs    = 19800 " 5 hours 30 minutes in seconds
      RECEIVING
        r_tstmp = timestamp.

    CALL METHOD cl_abap_tstmp=>tstmp2utclong
      EXPORTING
        timestamp = timestamp
      RECEIVING
        utclong   = ist_str.

  ENDMETHOD.
ENDCLASS.
