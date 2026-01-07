CLASS zcl_http_ewaybillbyirn DEFINITION
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



CLASS ZCL_HTTP_EWAYBILLBYIRN IMPLEMENTATION.


  METHOD getPayload.

    TYPES: BEGIN OF ty_expshipdtls,
             addr1 TYPE string,
             addr2 TYPE string,
             loc   TYPE string,
             pin   TYPE  c LENGTH 8,
             stcd  TYPE string,
           END OF ty_expshipdtls.

    TYPES: BEGIN OF ty_transport,
             irn         TYPE string,
             transid     TYPE string,
             transname   TYPE string,
             transdocno  TYPE string,
             transmode   TYPE string,
             distance    TYPE i,
             transdocdt  TYPE string,
             vehno       TYPE string,
             vehtype     TYPE string,
             expshipdtls TYPE ty_expshipdtls,
           END OF ty_transport.


    DATA : wa_json TYPE ty_transport.
    DATA supType TYPE string.

    SELECT SINGLE FROM i_billingdocument AS a
        INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
        FIELDS b~DistributionChannel
        WHERE a~BillingDocument = @invoice AND a~CompanyCode = @companycode
        INTO @DATA(lv_trans_details) PRIVILEGED ACCESS.

    IF lv_trans_details NE 'EX'.
      supType = 'B2B'.
    ELSE.
      supType = 'EXPWOP'.
    ENDIF.

    IF supType = 'EXPWOP'.

      SELECT SINGLE FROM I_BillingDocumentItem AS a
          INNER JOIN i_billingdocitempartner AS b ON a~BillingDocument = b~BillingDocument
          INNER JOIN i_customer AS c ON  c~customer = b~customer
          FIELDS c~taxnumber3, c~CustomerFullName,  c~CityName, c~PostalCode, c~Region, c~StreetName
           WHERE a~billingdocument = @invoice AND b~PartnerFunction = 'WE'
          INTO @DATA(lv_shipDetails) PRIVILEGED ACCESS.

      wa_json-expshipdtls-addr1 = lv_shipDetails-StreetName.
      wa_json-expshipdtls-addr2 = |{ lv_shipDetails-CityName }, { lv_shipDetails-PostalCode }|.
      wa_json-expshipdtls-loc   = lv_shipDetails-cityname .
      wa_json-expshipdtls-pin   = lv_shipDetails-postalcode  .
*                IF lv_shipDetails-TaxNumber3 = ''.
*                    wa_json-expshipdtls-stcd  = '3' .
*                else.
      SELECT SINGLE FROM zstatecodemaster
       FIELDS Statecodenum
       WHERE StateCode = @lv_shipDetails-Region
       INTO @DATA(lv_statecode).

      wa_json-expshipdtls-stcd = lv_statecode .
*                ENDIF.

    ENDIF.


    SELECT SINGLE FROM zr_zirntp
    FIELDS Transportername, Vehiclenum, Grdate, Grno, Transportergstin, Irnno
    WHERE Billingdocno = @invoice AND Bukrs = @companycode
    INTO @DATA(Eway).

    IF Eway-Irnno = ''.
      result = '1'.
      RETURN.
    ENDIF.

    wa_json-vehno = Eway-Vehiclenum .
    wa_json-irn = Eway-Irnno .
    wa_json-transname = Eway-Transportername .
    wa_json-transdocdt = Eway-Grdate+6(2) && '/' && Eway-Grdate+4(2) && '/' && Eway-Grdate(4).
    wa_json-transdocno = Eway-Grno .
    wa_json-transid = Eway-Transportergstin .
    wa_json-transmode = '1'.
    wa_json-distance = 0.
    wa_json-vehtype = 'R'.

*            need to write logic for export ship details



    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_json
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

    REPLACE ALL OCCURRENCES OF '"IRN"'            IN lv_string WITH '"Irn"'.
    REPLACE ALL OCCURRENCES OF '"TRANSID"'        IN lv_string WITH '"TransId"'.
    REPLACE ALL OCCURRENCES OF '"TRANSNAME"'      IN lv_string WITH '"TransName"'.
    REPLACE ALL OCCURRENCES OF '"TRANSDOCNO"'     IN lv_string WITH '"TransDocNo"'.
    REPLACE ALL OCCURRENCES OF '"TRANSMODE"'      IN lv_string WITH '"TransMode"'.
    REPLACE ALL OCCURRENCES OF '"DISTANCE"'       IN lv_string WITH '"Distance"'.
    REPLACE ALL OCCURRENCES OF '"TRANSDOCDT"'     IN lv_string WITH '"TransDocDt"'.
    REPLACE ALL OCCURRENCES OF '"VEHNO"'          IN lv_string WITH '"VehNo"'.
    REPLACE ALL OCCURRENCES OF '"VEHTYPE"'        IN lv_string WITH '"VehType"'.
    REPLACE ALL OCCURRENCES OF '"EXPSHIPDTLS"'    IN lv_string WITH '"ExpShipDtls"'.
    REPLACE ALL OCCURRENCES OF '"ADDR1"'          IN lv_string WITH '"Addr1"'.
    REPLACE ALL OCCURRENCES OF '"ADDR2"'          IN lv_string WITH '"Addr2"'.
    REPLACE ALL OCCURRENCES OF '"LOC"'            IN lv_string WITH '"Loc"'.
    REPLACE ALL OCCURRENCES OF '"PIN"'            IN lv_string WITH '"Pin"'.
    REPLACE ALL OCCURRENCES OF '"STCD"'           IN lv_string WITH '"Stcd"'.
    REPLACE ALL OCCURRENCES OF '"ExpShipDtls":{"Addr1":"","Addr2":"","Loc":"","Pin":"","Stcd":""}'           IN lv_string WITH '"ExpShipDtls":null'.
    REPLACE ALL OCCURRENCES OF '"TransId":""' IN lv_string WITH '"TransId":null'.
    REPLACE ALL OCCURRENCES OF '"TransName":""' IN lv_string WITH '"TransName":null'.
    REPLACE ALL OCCURRENCES OF '"TransDocNo":""' IN lv_string WITH '"TransDocNo":null'.
    REPLACE ALL OCCURRENCES OF '"TransDocDt":"00/00/0000"' IN lv_string WITH '"TransDocDt":null'.
    REPLACE ALL OCCURRENCES OF '"VehNo":""' IN lv_string WITH '"VehNo":null'.


    result = lv_string.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
           DATA irn_url TYPE STRING.
            DATA(lv_token) = ZCL_HTTP_IRN=>get_or_generate_token( ).

             select SINGLE from zr_integration_tab
             fields Intgpath
             where Intgmodule = 'EWAY-BY-IRN-URL'
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
         DATA(get_payload) = getPayload( companycode = lv_bukrs invoice = lv_invoice ).

         if get_payload = '1'.
             response->set_text( 'IRN Not Generated.' ).
                 return.
            ENDIF.

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
            response->set_text( 'GUID geration have some error' ).
         ENDTRY.


        DATA(req4) = lv_client2->get_http_request( ).

        req4->set_header_field(
           EXPORTING
           i_name  = 'user_name'
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
                     EwbNo  TYPE string,
                     EwbDt  TYPE string,
                     EwbValidTill    TYPE string,
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

              wa_zirn-ewaybillno = lv_message2-result-ewbno.
              wa_zirn-ewaydate = lv_message2-result-ewbdt .
              wa_zirn-ewaystatus = 'GEN'.
              wa_zirn-ewayvaliddate = ZCL_HTTP_IRN=>getdate( lv_message2-result-ewbvalidtill ).
              wa_zirn-ewaycreatedby = sy-mandt.

              MODIFY ztable_irn FROM @wa_zirn.

              response->set_text( |EWB No - { lv_message2-result-ewbno } has been Generated| ).

          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
