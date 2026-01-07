CLASS zcl_salesapitax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS callAPI IMPORTING VALUE(SalesOrder) TYPE i_salesordertp-SalesOrder
      RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALESAPITAX IMPLEMENTATION.


  METHOD callAPI.

       DATA irn_url TYPE string.
       DATA user_pass TYPE string.

        select SINGLE from zr_integration_tab
         fields Intgpath
         where Intgmodule = 'My-DOMAIN'
         INTO @irn_url.

        TRY.
            DATA(lv_client2) = zcl_http_irn=>create_client( |{ irn_url }/sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('{ salesorder }')| ).
          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            result = 'Error in creating client'.
            RETURN.
        ENDTRY.


        DATA(req4) = lv_client2->get_http_request( ).

         select SINGLE from zr_integration_tab
         fields Intgpath
         where Intgmodule = 'My-DOMAIN-USER'
         INTO @user_pass.

         SPLIT user_pass AT ':' INTO DATA(i_username) DATA(i_password).

        req4->set_authorization_basic(
            i_username = i_username
            i_password = i_password
        ).

        req4->set_header_field( i_name =  'x-csrf-token' i_value = 'fetch' ).

        req4->set_content_type( 'application/json' ).
        DATA url_response2 TYPE string.


        TRY.
            DATA(xcsrfToken) = lv_client2->execute( if_web_http_client=>get )->get_header_field( i_name = 'x-csrf-token' ).

            req4->delete_header_field( name = 'x-csrf-token' ).
            req4->set_header_field( i_name =  'x-csrf-token' i_value = xcsrfToken ).
            req4->set_header_field( i_name =  'If-Match' i_value = '*' ).
            req4->set_text(
                '{"d":{"CustomerTaxClassification1":"1","CustomerTaxClassification2":"1","CustomerTaxClassification3":"1","CustomerTaxClassification4":"1","CustomerTaxClassification5":"1","CustomerTaxClassification6":"1"}}'
             ).

            DATA(lv_response2) = lv_client2->execute( if_web_http_client=>patch ).
            DATA(text_response2) = lv_response2->get_text( ).

            IF lv_response2->get_status( )-code EQ 204.
                result = 'Success'.
            ELSE.
                result = 'Error in executing request'.
            ENDIF.


          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
              result = 'Error in executing request'.
                RETURN.
        ENDTRY.

  ENDMETHOD.
ENDCLASS.
