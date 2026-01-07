class ZCL_HTTP_MARKDATA definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .




  TYPES:BEGIN OF ty_response,
          status  TYPE string,
          message TYPE string,
        END OF ty_response.

  CLASS-METHODS getcid RETURNING VALUE(cid) TYPE abp_behv_cid.

  CLASS-METHODS savedata
    IMPORTING
      request        TYPE REF TO if_web_http_request
    RETURNING
      VALUE(ls_response) TYPE ty_response.

protected section.
private section.

ENDCLASS.



CLASS ZCL_HTTP_MARKDATA IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method( ).
      WHEN 'POST'.
        DATA(response_msg) = savedata( request ).


        DATA:json TYPE REF TO if_xco_cp_json_data.
        xco_cp_json=>data->from_abap(
          EXPORTING
            ia_abap      = response_msg
          RECEIVING
            ro_json_data = json   ).
        json->to_string(
          RECEIVING
            rv_string =   DATA(message) ).
        REPLACE ALL OCCURRENCES OF '"STATUS"' IN message WITH '"Status"'.
        REPLACE ALL OCCURRENCES OF '"MESSAGE"' IN message WITH '"Message"'.


        response->set_text( message ).
        response->set_content_type( 'application/json' ).
      WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
    ENDCASE.
  ENDMETHOD.


  METHOD getcid.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD savedata.

    TYPES:BEGIN OF ty_request,
            booktransactions TYPE zr_booktrans,
            statements       TYPE TABLE OF zr_statementtrans WITH EMPTY KEY,
            mark             TYPE  string,
          END OF ty_request.

    DATA: ls_request TYPE ty_request.

    DATA(lv_body) = request->get_text( ).
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = lv_body
      CHANGING
        data = ls_request ).


    IF ls_request-mark EQ 'false'.

      IF ls_request-booktransactions IS INITIAL AND lines( ls_request-statements ) GT 0.

        LOOP AT ls_request-statements INTO DATA(statements).

          MODIFY ENTITIES OF zr_statementtrans_001
               ENTITY zrstatementtrans001
               UPDATE FIELDS ( clearedvoucherno )
               WITH VALUE #( (
                   bankrecoid = statements-bankrecoid
                   statementid = statements-statementid
                   voucherno = statements-voucherno
                   clearedvoucherno = ''
               ) )
               REPORTED DATA(ls_statementtrans_reported2)
               FAILED   DATA(ls_statementtrans_failed2)
               MAPPED   DATA(ls_statementtrans_mapped2).

          COMMIT ENTITIES BEGIN
          RESPONSE OF zr_statementtrans_001
          FAILED DATA(ls_stmttrans_save_failed2)
          REPORTED DATA(ls_stmt_save_reported2).
          ...
          COMMIT ENTITIES END.

        ENDLOOP.

        ls_response-status = 'S'.
        ls_response-message = 'Statement unmarked successfully'.
        RETURN.
      ENDIF.


      DATA: lv_initial_date TYPE d.

      IF ls_request-booktransactions-bankrecoid IS INITIAL OR
         ls_request-booktransactions-voucherno IS INITIAL OR
         ls_request-statements[ 1 ]-bankrecoid IS INITIAL OR
         ls_request-statements[ 1 ]-statementid IS INITIAL OR
         ls_request-statements[ 1 ]-voucherno IS INITIAL.
        ls_response-status = 'E'.
        ls_response-message = 'Mandatory fields are missing. Please check.'.
        RETURN.
      ENDIF.

      IF ls_request-booktransactions-clearedvoucherno NE ls_request-statements[ 1 ]-voucherno
         AND ls_request-statements[ 1 ]-clearedvoucherno NE ls_request-booktransactions-voucherno.
        ls_response-status = 'E'.
        ls_response-message = 'This transaction is marked with another voucher no. Please check.'.
        RETURN.
      ENDIF.

      MODIFY ENTITIES OF zr_booktrans_001
      ENTITY zrbooktrans001
         UPDATE FIELDS ( cleareddate clearedvoucherno )
         WITH VALUE #( (
             bankrecoid = ls_request-booktransactions-bankrecoid
             voucherno = ls_request-booktransactions-voucherno
             cleareddate = lv_initial_date
             clearedvoucherno = ''
         ) )
         REPORTED DATA(ls_booktrans_reported)
        FAILED   DATA(ls_booktrans_failed)
        MAPPED   DATA(ls_booktrans_mapped).
      COMMIT ENTITIES BEGIN
          RESPONSE OF zr_booktrans_001
            FAILED DATA(ls_booktrans_save_failed)
            REPORTED DATA(ls_booktrans_save_reported).
      ...
      COMMIT ENTITIES END.

      MODIFY ENTITIES OF zr_statementtrans_001
       ENTITY zrstatementtrans001
        UPDATE FIELDS ( clearedvoucherno )
        WITH VALUE #( (
             bankrecoid = ls_request-statements[ 1 ]-bankrecoid
             statementid = ls_request-statements[ 1 ]-statementid
             voucherno = ls_request-statements[ 1 ]-voucherno
             clearedvoucherno = ''
        ) )
        REPORTED DATA(ls_statementtrans_reported)
        FAILED   DATA(ls_statementtrans_failed)
        MAPPED   DATA(ls_statementtrans_mapped).

      COMMIT ENTITIES BEGIN
          RESPONSE OF zr_statementtrans_001
          FAILED DATA(ls_stmttrans_save_failed)
          REPORTED DATA(ls_stmt_save_reported).
      ...
      COMMIT ENTITIES END.

      COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bankreco
        FAILED DATA(ls_save_failed2)
        REPORTED DATA(ls_save_reported2).
      ...
      COMMIT ENTITIES END.



    ELSE.

*    Allowing Self marking of Statement Transaction but not book transaction

      IF ls_request-booktransactions IS INITIAL AND lines( ls_request-statements ) GT 0.

        LOOP AT ls_request-statements INTO statements.


          MODIFY ENTITIES OF zr_statementtrans_001
               ENTITY zrstatementtrans001
               UPDATE FIELDS ( clearedvoucherno )
               WITH VALUE #( (
                   bankrecoid = statements-bankrecoid
                   statementid = statements-statementid
                   voucherno = statements-voucherno
                    clearedvoucherno = statements-voucherno
               ) )
                REPORTED ls_statementtrans_reported2
             FAILED   ls_statementtrans_failed2
             MAPPED   ls_statementtrans_mapped2.

          COMMIT ENTITIES BEGIN
          RESPONSE OF zr_statementtrans_001
          FAILED ls_stmttrans_save_failed2
          REPORTED ls_stmt_save_reported2.
          ...
          COMMIT ENTITIES END.
        ENDLOOP.
        ls_response-status = 'S'.
        ls_response-message = 'Statement marked successfully'.

        RETURN.
      ENDIF.

*    Checks for Marking

*    1. Amount should be same
      DATA(lv_amount_book) = ls_request-booktransactions-amount.
      DATA(lv_amount_statement) = ls_request-statements[ 1 ]-amount.
      IF lv_amount_book NE lv_amount_statement.
        ls_response-status = 'E'.
        ls_response-message = |Amount in Book Transaction ({ lv_amount_book }) and Statement Transaction ({ lv_amount_statement }) are not same. Please check.|.
        RETURN.
      ENDIF.


      MODIFY ENTITIES OF zr_booktrans_001
          ENTITY zrbooktrans001
         UPDATE FIELDS ( cleareddate clearedvoucherno )
         WITH VALUE #( (
             bankrecoid = ls_request-booktransactions-bankrecoid
             voucherno = ls_request-booktransactions-voucherno
             cleareddate = ls_request-statements[ 1 ]-dates
             clearedvoucherno = ls_request-statements[ 1 ]-voucherno
         ) )
         REPORTED DATA(ls_booktrans_reported1)
            FAILED   DATA(ls_booktrans_failed1)
            MAPPED   DATA(ls_booktrans_mapped1).

      COMMIT ENTITIES BEGIN
          RESPONSE OF zr_booktrans_001
            FAILED DATA(ls_booktrans_save_failed1)
            REPORTED DATA(ls_booktrans_save_reported1).
      ...
      COMMIT ENTITIES END.

      MODIFY ENTITIES OF zr_statementtrans_001
             ENTITY zrstatementtrans001
             UPDATE FIELDS ( clearedvoucherno )
             WITH VALUE #( (
                 bankrecoid = ls_request-statements[ 1 ]-bankrecoid
                 statementid = ls_request-statements[ 1 ]-statementid
                 voucherno = ls_request-statements[ 1 ]-voucherno
                 clearedvoucherno = ls_request-booktransactions-voucherno
             ) )
             REPORTED DATA(ls_statementtrans_reported1)
             FAILED   DATA(ls_statementtrans_failed1)
             MAPPED   DATA(ls_statementtrans_mapped1).
      COMMIT ENTITIES BEGIN
          RESPONSE OF zr_statementtrans_001
          FAILED DATA(ls_stmttrans_save_failed1)
          REPORTED DATA(ls_stmt_save_reported1).
      ...
      COMMIT ENTITIES END.

    ENDIF.

    ls_response-status = 'S'.
    ls_response-message = 'Data saved successfully'.



  ENDMETHOD.
ENDCLASS.
