CLASS zcl_http_cancelirn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .

     CLASS-METHODS :getPayload IMPORTING
                                                 invoice       TYPE ztable_irn-billingdocno
                                                 companycode   TYPE ztable_irn-bukrs
                                       RETURNING VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CANCELIRN IMPLEMENTATION.


  METHOD getPayload.


          TYPES: BEGIN OF ty_item_list,
               irn type string,
               CnlRsn type string,
               CnlRem type string,
           END OF ty_item_list.

            DATA : wa_json TYPE ty_item_list.

             SELECT SINGLE FROM ztable_irn AS a
             FIELDS a~irnno
              WHERE a~billingdocno = @invoice AND
              a~bukrs = @companycode
              INTO @DATA(lv_table_data).

              wa_json-irn = lv_table_data.
              wa_json-cnlrem = 'Wrong entry'.
              wa_json-cnlrsn = '1'.


             DATA:json TYPE REF TO if_xco_cp_json_data.

            xco_cp_json=>data->from_abap(
              EXPORTING
                ia_abap      = wa_json
              RECEIVING
                ro_json_data = json   ).
            json->to_string(
              RECEIVING
                rv_string =   DATA(lv_string) ).

           REPLACE ALL OCCURRENCES OF '"IRN"' IN lv_string WITH '"Irn"'.
            REPLACE ALL OCCURRENCES OF '"CNLRSN"' IN lv_string WITH '"CnlRsn"'.
            REPLACE ALL OCCURRENCES OF '"CNLREM"' IN lv_string WITH '"CnlRem"'.

        result = lv_string.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
       DATA irn_url TYPE STRING.
        DATA(lv_token) = ZCL_HTTP_IRN=>get_or_generate_token( ).

         select SINGLE from zr_integration_tab
         fields Intgpath
         where Intgmodule = 'IRN-CANCEL-URL'
         INTO @irn_url.

          TRY.
          DATA(lv_client2) = ZCL_HTTP_IRN=>create_client( irn_url ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_text( lv_cx_static_check2->get_longtext( ) ).
        ENDTRY.

          DATA: companycode TYPE string.
        DATA: document    TYPE string.
        DATA: gstno       Type string.


        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        lv_bukrs = request->get_form_field( `companycode` ).
        lv_invoice = request->get_form_field( `document` ).

         SELECT SINGLE FROM ztable_irn AS a
            FIELDS a~irnno
               WHERE a~billingdocno = @lv_invoice AND
               a~bukrs = @lv_bukrs
               INTO @DATA(lv_table_data1).


            IF lv_bukrs IS INITIAL OR lv_invoice IS INITIAL.
              response->set_text( 'Company code and document number are required' ).
              RETURN.
            ELSEIF lv_table_data1 IS  INITIAL.
              response->set_text( 'IRN not generated' ).
              RETURN.
            ENDIF.



*
         DATA(get_payload) = getPayload( companycode = lv_bukrs invoice = lv_invoice ).

         SELECT SINGLE FROM I_BillingDocumentItem AS b
            FIELDS     b~Plant
            WHERE b~BillingDocument = @lv_invoice
            INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

        select single from ztable_plant
            Fields GSPPassword, GSPUserName, Gstin_No
            where Comp_Code = @lv_bukrs and Plant_Code = @lv_document_details
            into @DATA(userPass).


         DATA guid TYPE STRING.

         TRY.
           DATA(hex) = cl_system_uuid=>create_uuid_x16_static( ).
           guid = |{ hex(4) }-{ hex+4(2) }-{ hex+6(2) }-{ hex+8(2) }-{ hex+10(6) }|.
          CATCH cx_uuid_error INTO DATA(lo_error).
            response->set_text( 'GUID generation has some error' ).
         ENDTRY.


        DATA(req4) = lv_client2->get_http_request( ).

        req4->set_header_field(
           EXPORTING
           i_name  = 'user_name'
             i_value = CONV string( userPass-GSPUserName )
         ).

         req4->set_header_field(
           EXPORTING
           i_name  = 'password'
             i_value = CONV string( userPass-GSPPassword )
         ).

         req4->set_header_field(
           EXPORTING
           i_name  = 'gstin'
             i_value = CONV string( userPass-Gstin_No )
         ).

          req4->set_header_field(
           EXPORTING
           i_name  = 'requestid'
             i_value = guid
         ).

         req4->set_authorization_bearer( lv_token ).
         req4->set_text( get_payload ).
         req4->set_content_type( 'application/json' ).
        DATA url_response2 TYPE string.


        TRY.
           url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).

            TYPES: BEGIN OF ty_message,
                     ewayBillNo  TYPE string,
                     ewayBillDate  TYPE string,
                     validUpto    TYPE string,
                     alert TYPE string,
                   END OF ty_message.

            TYPES: BEGIN OF ty_message2,
                     message TYPE string,
                     success  TYPE string,
                   END OF ty_message2.

            TYPES: BEGIN OF ty_message3,
                    result TYPE  ty_message,
                    END OF ty_message3.


            DATA lv_message TYPE ty_message2.
            DATA lv_message2 TYPE ty_message3.

            xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).

            if lv_message-success = 'false'.
                 response->set_text( lv_message-message ).
                 return.
            ENDIF.
                 DATA: wa_zirn TYPE ztable_irn.
                  SELECT SINGLE * FROM ztable_irn AS a
                     WHERE a~billingdocno = @lv_invoice AND
                     a~bukrs = @lv_bukrs
                     INTO @DATA(lv_table_data2).
                     wa_zirn = lv_table_data2.
                     wa_zirn-irnno = ''.
                     wa_zirn-ackno = ''.
                     wa_zirn-ackdate = ''.
                     wa_zirn-irnstatus = 'CNL'.
                     wa_zirn-signedinvoice = ''.
                     wa_zirn-signedqrcode = ''.
                     wa_zirn-irncanceldate = sy-datum.

                     MODIFY ztable_irn FROM @wa_zirn.

              response->set_text( |IRN Cancelled| ).

          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
