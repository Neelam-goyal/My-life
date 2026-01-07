CLASS zcl_http_irn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

    CLASS-METHODS create_client
      IMPORTING url           TYPE string
      RETURNING VALUE(result) TYPE REF TO if_web_http_client
      RAISING   cx_static_check.

    CLASS-METHODS get_or_generate_token
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS getDate
      IMPORTING datestr       TYPE string
      RETURNING VALUE(result) TYPE d.

    CLASS-METHODS checktax
      IMPORTING billingdoc    TYPE ztable_irn-billingdocno
      RETURNING VALUE(result) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_IRN IMPLEMENTATION.


  METHOD checktax.
    """"""""""""""""""" changes by apratim on 23/05/2025 """"""""""""""""""""""""""""""""
    result = 0.

    SELECT SINGLE FROM i_billingdocumentitem AS a
    INNER JOIN i_producttaxclassification AS b ON a~Product = b~Product
    INNER JOIN i_billingdocument AS c ON a~BillingDocument = c~BillingDocument
    FIELDS
    b~TaxClassification1,
    c~DistributionChannel
    WHERE a~BillingDocument = @billingdoc AND b~TaxClassification1 = '0'
    INTO @DATA(lv_checktax).

    IF lv_checktax-TaxClassification1 = '0' AND lv_checktax-DistributionChannel <> 'EX'.
      SELECT SINGLE FROM
      i_billingdocumentitem AS a
      LEFT JOIN ztable_plant AS b ON a~Plant = b~plant_code
      FIELDS
      b~gstin_no
      WHERE a~BillingDocument = @billingdoc
      INTO @DATA(lv_plant_gstin).

      SELECT SINGLE FROM
      i_billingdocument AS a
      LEFT JOIN i_customer AS b ON a~SoldToParty = b~Customer
      FIELDS
      b~TaxNumber3
      WHERE a~BillingDocument = @billingdoc
      INTO @DATA(lv_cust_gstin).

      SELECT FROM
      i_billingdocumentitem AS a INNER JOIN
      i_billingdocumentitemprcgelmnt AS b ON a~billingdocument = b~billingdocument AND a~billingdocumentitem = b~billingdocumentitem
       FIELDS
      b~ConditionType,
      b~BillingDocumentItem,
      b~BillingDocument
      WHERE a~BillingDocument = @billingdoc AND
      a~SalesDocumentItemCategory <> 'CBXN'
      INTO TABLE @DATA(lt_item).

      SELECT FROM
      i_billingdocumentitem AS a
      FIELDS
      a~BillingDocumentItem
      WHERE a~BillingDocument = @billingdoc and
      a~SalesDocumentItemCategory <> 'CBXN'
      INTO TABLE @DATA(lt_item_cnt).

      DELETE lt_item WHERE ConditionType <> 'JOIG'
                 AND ConditionType <> 'JOSG'
                 AND ConditionType <> 'JOCG'.


      SORT lt_item BY BillingDocumentItem ASCENDING.
      DATA(lt_count) =  lines( lt_item_cnt ).
      DATA : lv_count TYPE i VALUE 0.

      IF lv_plant_gstin+0(2) = lv_cust_gstin+0(2).

        DATA : flag TYPE i VALUE 0.
        LOOP AT lt_item INTO DATA(wa_item).

*          SELECT SINGLE FROM
*          I_BillingDocumentItem AS a
*          FIELDS
*          a~SalesDocumentItemCategory
*          WHERE a~BillingDocument = @wa_item-BillingDocument AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
*          AND a~SalesDocumentItemCategory <> 'CBXN'
*          INTO @DATA(lv_cbxn).

*          IF lv_cbxn <> 'CBXN'.

          IF wa_item-ConditionType = 'JOCG' OR wa_item-ConditionType = 'JOSG'.
            lv_count = lv_count + 1.
          ENDIF.
          CLEAR wa_item.

*          ENDIF.
*          CLEAR lv_cbxn.
          CLEAR wa_item.

        ENDLOOP.

        IF lt_count * 2 = lv_count.
          flag = 1.
        ENDIF.

        IF flag = 0.
          result =  1.
        ENDIF.

      ELSE.
        flag = 0.
        lv_count = 0.
        LOOP AT lt_item INTO wa_item.

*          SELECT SINGLE FROM
*            I_BillingDocumentItem AS a
*            FIELDS
*            a~SalesDocumentItemCategory
*            WHERE a~BillingDocument = @wa_item-BillingDocument AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
*            AND a~SalesDocumentItemCategory <> 'CBXN'
*            INTO @lv_cbxn.

*          IF lv_cbxn <> 'CBXN'.
          IF wa_item-ConditionType = 'JOIG'.
            lv_count = lv_count + 1.
          ENDIF.
          CLEAR wa_item.
*          ENDIF.
*          CLEAR lv_cbxn.
          CLEAR wa_item.

        ENDLOOP.

        IF lt_count = lv_count.
          flag = 1.
        ENDIF.

        IF flag = 0.
          result = 1.
        ENDIF.
      ENDIF.

    ENDIF.


    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDMETHOD.


  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.


  METHOD getDate.
    DATA: lv_date_str TYPE string,
          lv_date     TYPE c LENGTH 10,
          lv_internal TYPE c LENGTH 8.



    lv_date = datestr+0(10). " Extract '2025-04-08'
    REPLACE ALL OCCURRENCES OF '-' IN lv_date WITH ''.
    result = lv_date.

  ENDMETHOD.


  METHOD get_or_generate_token.

*      select SINGLE from zr_integration_tab WITH PRIVILEGED ACCESS
*         fields Intgpath,LastChangedAt
*         where Intgmodule = 'GSP-TOKEN-BEARER'
*         INTO @DATA(token).
*
*         DATA:       lv_date      TYPE d,
*          lv_time      TYPE t,
*          lv_diff      TYPE i.
*
**        Extract date and time from timestamp
*         DATA(datestr) = CONV STRING( token-LastChangedAt ).
*         lv_date = datestr+0(8).   " YYYYMMDD -> 20250320
*         lv_time = datestr+8(6).   " HHMMSS   -> 075828
*
*
**       Convert to system time format
*        DATA(lv_ts_seconds) = ( lv_date - sy-datum ) * 86400 + ( lv_time - sy-uzeit ).
*
*        " Convert 24 hours to seconds
*        DATA(lv_3hours) = 24 * 3600.
*
*        " Compare time difference
*        IF abs( lv_ts_seconds ) < lv_3hours and token-Intgpath ne ''.
*            result = token-Intgpath.
*            RETURN.
*        ENDIF.
*

    SELECT SINGLE FROM zr_integration_tab
       FIELDS Intgpath
       WHERE Intgmodule = 'GSP-TOKEN-URL'
       INTO @DATA(token_url).

    SELECT SINGLE FROM zr_integration_tab
       FIELDS Intgpath
       WHERE Intgmodule = 'GSP-TOKEN-HEAD-1'
       INTO @DATA(client_id).

    SELECT SINGLE FROM zr_integration_tab
    FIELDS Intgpath
    WHERE Intgmodule = 'GSP-TOKEN-HEAD-2'
    INTO @DATA(client_password).

    TRY.
        DATA(client) = create_client( CONV string( token_url ) ).
      CATCH cx_static_check INTO DATA(lv_cx_static_check).
        result = lv_cx_static_check->get_longtext( ).
    ENDTRY.

    DATA(req) = client->get_http_request(  ).

    SPLIT client_id  AT ':' INTO DATA(head1name) DATA(head1val).
    SPLIT client_password  AT ':' INTO DATA(head2name) DATA(head2val).

    req->set_header_field(
           EXPORTING
           i_name  = head1name
             i_value = head1val
         ).

    req->set_header_field(
          EXPORTING
          i_name  = head2name
            i_value = head2val
        ).


    TRY.
        DATA(response) = client->execute( if_web_http_client=>post )->get_text(  ).
      CATCH cx_web_http_client_error INTO DATA(lv_cx_web_http_client_error). "cx_web_message_error.
        result = lv_cx_web_http_client_error->get_longtext( ).
        "handle exception
    ENDTRY.

    REPLACE ALL OCCURRENCES OF '{"access_token":"' IN response WITH ''.
    SPLIT response AT '","token_type' INTO DATA(v1) DATA(v2) .
    result = v1 .

    TRY.
        client->close(  ).

*        update zintegration_tab set Intgpath = @result where Intgmodule = 'GSP-TOKEN-BEARER'.

      CATCH cx_web_http_client_error INTO DATA(lv_cx_web_http_client_error2).
        result = lv_cx_web_http_client_error2->get_longtext( ).
        "handle exception
    ENDTRY.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        DATA irn_url TYPE string.
        DATA lv_client TYPE REF TO if_web_http_client.
        DATA req TYPE REF TO if_web_http_client.
        DATA lv_client2 TYPE REF TO if_web_http_client.
        DATA req3 TYPE REF TO if_web_http_client.

        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        lv_bukrs = request->get_form_field( `companycode` ).
        lv_invoice = request->get_form_field( `document` ).


        """""""""""""'changes by apratim on 23/05/2025""""""""""""""""""""""'

        """"""""""""" chnages by apratim on 21/06/2025 ( comment all changes made on 23/05/2025 """"""""""""""""""

        DATA : lv_result TYPE i.

        lv_result = zcl_http_irn=>checktax( billingdoc = lv_invoice ).
        SELECT SINGLE * FROM ztable_irn AS a
               WHERE a~billingdocno = @lv_invoice AND
               a~bukrs = @lv_bukrs
               INTO @DATA(lv_table_temp_data2).
        DATA : wa_temp_zirn TYPE ztable_irn.

        wa_temp_zirn = lv_table_temp_data2.

        IF lv_result = 1.
          wa_temp_zirn-tax_validated = 0.
          MODIFY ztable_irn FROM @wa_temp_zirn.
        ENDIF.
        IF lv_result = 0.
          wa_temp_zirn-tax_validated = 1.
          MODIFY ztable_irn FROM @wa_temp_zirn.
        ENDIF.

        IF  lv_result = 1.
          response->set_text( 'Tax error in  Invoice' ).
          RETURN.
        ENDIF.

        IF zcl_http_irn=>checktax( billingdoc = lv_invoice ) = 1.
          response->set_text( 'Tax error in  Invoice' ).
          RETURN.
        ENDIF.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        SELECT SINGLE FROM ztable_irn AS a
           FIELDS a~irnno
              WHERE a~billingdocno = @lv_invoice AND
              a~bukrs = @lv_bukrs
              INTO @DATA(lv_table_data1).


        IF lv_bukrs IS INITIAL OR lv_invoice IS INITIAL.
          response->set_text( 'Company code and document number are required' ).
          RETURN.
        ELSEIF lv_table_data1 IS NOT INITIAL.
          response->set_text( 'IRN is aready generated' ).
          RETURN.
        ENDIF.


        SELECT SINGLE FROM I_BillingDocumentItem AS b
           FIELDS     b~Plant, b~BillingDocumentType
           WHERE b~BillingDocument = @lv_invoice
           INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

        IF lv_document_details-BillingDocumentType = 'JDC' OR lv_document_details-BillingDocumentType = 'JSN' OR lv_document_details-BillingDocumentType = 'JVR'.
          response->set_text( 'IRN Not Applicatble for this Document Type' ).
          RETURN.
        ENDIF.

        DATA(lv_token) = get_or_generate_token( ).

        SELECT SINGLE FROM zr_integration_tab
        FIELDS Intgpath
        WHERE Intgmodule = 'IRN-CREATE-URL'
        INTO @irn_url.

        TRY.
            lv_client2 = create_client( irn_url ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_text( lv_cx_static_check2->get_longtext( ) ).
        ENDTRY.

        DATA: companycode TYPE string.
        DATA: document    TYPE string.
        DATA: gstno       TYPE string.


        DATA(get_payload) = zcl_irn_generation=>generated_irn( companycode = lv_bukrs document = lv_invoice ).


        SELECT SINGLE FROM ztable_plant
            FIELDS GSPPassword, GSPUserName, gstin_no
            WHERE comp_code = @lv_bukrs AND Plant_Code = @lv_document_details-Plant
            INTO @DATA(userPass).


        DATA guid TYPE string.

        TRY.
            DATA(hex) = cl_system_uuid=>create_uuid_x16_static( ).
            guid = |{ hex(4) }-{ hex+4(2) }-{ hex+6(2) }-{ hex+8(2) }-{ hex+10(6) }|.
          CATCH cx_uuid_error INTO DATA(lo_error).
            response->set_text( 'GUID geration has some error' ).
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
            DATA: wa_zirn TYPE ztable_irn.

            TYPES: BEGIN OF ty_message,
                     ackno         TYPE string,
                     ackdt         TYPE string,
                     irn           TYPE string,
                     status        TYPE string,
                     SignedInvoice TYPE string,
                     SignedQRCode  TYPE string,
                     EwbNo         TYPE string,
                     EwbDt         TYPE string,
                     EwbvalidTill  TYPE string,
                   END OF ty_message.


            IF url_response2+11(5) = 'false'.

              TYPES: BEGIN OF ty_message4,
                       desc  TYPE ty_message,
                       InfCd TYPE string,
                     END OF ty_message4.

              TYPES: BEGIN OF ty_message2,
                       message TYPE string,
                       result  TYPE TABLE OF ty_message4 WITH EMPTY KEY,
                       status  TYPE string,
                     END OF ty_message2.

              DATA lv_message TYPE ty_message2.

              xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).
              IF lv_message-message = '2150 : Duplicate IRN'.
                LOOP AT lv_message-result INTO DATA(irn).
                  SELECT SINGLE * FROM ztable_irn AS a
                     WHERE a~billingdocno = @lv_invoice AND
                     a~bukrs = @lv_bukrs
                     INTO @DATA(lv_table_data).

                  wa_zirn = lv_table_data.
                  wa_zirn-irnno = irn-desc-irn.
                  wa_zirn-ackno = irn-desc-ackno.
                  wa_zirn-ackdate = irn-desc-ackdt.

                  MODIFY ztable_irn FROM @wa_zirn.
                ENDLOOP.
              ENDIF.

              response->set_text( lv_message-message ).
              RETURN.
            ELSE.

              TYPES: BEGIN OF ty_message3,
                       message TYPE string,
                       result  TYPE  ty_message,
                       status  TYPE string,
                     END OF ty_message3.

              DATA lv_message1 TYPE ty_message3.
              DATA ewbres TYPE string.

              xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message1 ) ).

              SELECT SINGLE * FROM ztable_irn AS a
              WHERE a~billingdocno = @lv_invoice AND
              a~bukrs = @lv_bukrs
              INTO @DATA(lv_table_data2).
              wa_zirn = lv_table_data2.
              wa_zirn-irnno = lv_message1-result-irn.
              wa_zirn-ackno = lv_message1-result-ackno.
              wa_zirn-ackdate = lv_message1-result-ackdt.
              wa_zirn-irnstatus = 'GEN'.
              wa_zirn-signedinvoice = lv_message1-result-signedinvoice.
              wa_zirn-signedqrcode = lv_message1-result-signedqrcode.
              wa_zirn-ewaybillno = lv_message1-result-ewbno.
              wa_zirn-ewaydate = lv_message1-result-ewbdt.
              IF wa_zirn-ewaybillno NE ''.
                wa_zirn-ewaystatus = 'GEN'.
                wa_zirn-ewayvaliddate = getDate( lv_message1-result-ewbvalidtill ).
                ewbres = | with Eway Bill No - { wa_zirn-ewaybillno }|.
              ENDIF.



              MODIFY ztable_irn FROM @wa_zirn.


              response->set_text( | Irn no for document no - { lv_invoice } is { lv_message1-result-irn } Generated Successfully{ ewbres }. | ).


            ENDIF.

*


          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
