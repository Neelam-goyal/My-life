CLASS zcl_http_eway_gen DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .

      CLASS-METHODS getDate
      IMPORTING datestr TYPE string
      RETURNING VALUE(result) TYPE d.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_EWAY_GEN IMPLEMENTATION.


  METHOD getDate.
    DATA: lv_date_str   TYPE string,
      lv_date       TYPE d,
      lv_internal   TYPE c length 8.


        " Extract the date part (DD/MM/YYYY)
        DATA(lv_date_part) = datestr(10).  " '27/03/2025'

        " Convert DD/MM/YYYY to YYYYMMDD
        DATA: lv_day   TYPE c length 2,
              lv_month TYPE c length 2,
              lv_year  TYPE c length 4.

        lv_day   = lv_date_part(2).
        lv_month = lv_date_part+3(2).
        lv_year  = lv_date_part+6(4).

        CONCATENATE lv_year lv_month lv_day INTO result.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
       DATA irn_url TYPE STRING.
        DATA(lv_token) = ZCL_HTTP_IRN=>get_or_generate_token( ).

         select SINGLE from zr_integration_tab
         fields Intgpath
         where Intgmodule = 'EWAY-CREATE-URL'
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


*
         DATA(get_payload) = ZCL_EWAY_GENERATION=>generated_eway_bill( companycode = lv_bukrs invoice = lv_invoice ).

         SELECT SINGLE FROM I_BillingDocumentItem AS b
            FIELDS     b~Plant
            WHERE b~BillingDocument = @lv_invoice
            INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

        select single from ztable_plant
            Fields EWBPassword, EWBUserName, Gstin_No
            where Comp_Code = @lv_bukrs and Plant_Code = @lv_document_details
            into @DATA(userPass).


         DATA guid TYPE STRING.

         TRY.
           DATA(hex) = cl_system_uuid=>create_uuid_x16_static( ).
           guid = |{ hex(4) }-{ hex+4(2) }-{ hex+6(2) }-{ hex+8(2) }-{ hex+10(6) }|.
          CATCH cx_uuid_error INTO DATA(lo_error).
           response->set_text( 'GUID geration has some error' ).
         ENDTRY.


        DATA(req4) = lv_client2->get_http_request( ).

        req4->set_header_field(
           EXPORTING
           i_name  = 'username'
             i_value = CONV string( userPass-EWBUserName )
         ).

         req4->set_header_field(
           EXPORTING
           i_name  = 'password'
             i_value = CONV string( userPass-EWBPassword )
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

             xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message2 ) ).

            DATA: wa_zirn TYPE ztable_irn.
              SELECT SINGLE * FROM ztable_irn AS a
              WHERE a~billingdocno = @lv_invoice AND
              a~bukrs = @lv_bukrs
              INTO @DATA(lv_table_data).

              wa_zirn = lv_table_data.

              wa_zirn-ewaybillno = lv_message2-result-ewaybillno.
              wa_zirn-ewaydate = lv_message2-result-ewaybilldate.
              wa_zirn-ewaystatus = 'GEN'.
              wa_zirn-ewayvaliddate = getDate( lv_message2-result-validupto ).
              wa_zirn-ewaycreatedby = sy-mandt.

              MODIFY ztable_irn FROM @wa_zirn.

              response->set_text( |Eway Bill No - { lv_message2-result-ewaybillno } has been generated for Document - { lv_invoice }| ).

          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
