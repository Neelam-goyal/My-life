CLASS zcl_http_generateirn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_GENERATEIRN IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    DATA(body)  = request->get_text(  )  .
*    xco_cp_json=>data->from_string( body )->write_to( REF #( lv_respo ) ).
*    /ui2/cl_json=>deserialize(
*    EXPORTING
*        json = body
*    CHANGING
*        data = lv_respo
*    ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .
    DATA : grwt TYPE p DECIMALS 3.
    DATA : ntwt TYPE p DECIMALS 3.

*12.03    req_host = request->get_header_field( i_name = 'Host' ).
*12.03    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

*        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

*        DATA(plant) = lv_respo-plant.
*        DATA(docdate) = lv_respo-docdate.
        DATA: plant   TYPE ztable_irn-plant.
        DATA: docdate TYPE d.
        plant = to_upper( request->get_form_field( `plant` ) ).
        docdate = request->get_form_field( `docdate` ).

        SELECT FROM i_billingdocumentitem AS a
         INNER JOIN I_billingdocument AS c ON a~BillingDocument = c~BillingDocument
        FIELDS
        a~CompanyCode,
        a~BillingDocument,
        a~CreationDate,
       a~Plant,
        a~DistributionChannel,
        a~BillingDocumentType, c~DocumentReferenceID
        WHERE a~Plant = @plant
        AND a~CreationDate = @docdate AND c~BillingDocumentIsCancelled = '' AND
        a~BillingDocument NOT IN ( SELECT billingdocno FROM ztable_irn WHERE billingdocno IS NOT INITIAL )
        INTO TABLE @DATA(lt).

        SORT lt BY BillingDocument.
        DELETE ADJACENT DUPLICATES FROM lt COMPARING BillingDocument CompanyCode.

        DATA: wa_zirn TYPE ztable_irn.
        GET TIME STAMP FIELD DATA(lv_timestamp).
        LOOP AT lt INTO DATA(wa).
          grwt = 0.
          ntwt = 0.
          SELECT ItemGrossWeight,ItemNetWeight FROM
          i_billingdocumentitem AS a
           WHERE a~CompanyCode = @wa-CompanyCode
           AND a~BillingDocument = @wa-BillingDocument
           AND a~Plant = @wa-Plant
         INTO TABLE @DATA(waline).
          LOOP AT waline INTO DATA(waline_data).
            grwt = grwt + waline_data-ItemGrossWeight .
            ntwt = ntwt + waline_data-ItemNetWeight.
          ENDLOOP.

          SELECT SINGLE FROM I_BillingDocumentPartner AS a
          INNER JOIN I_customer AS b ON a~Customer = b~Customer
        FIELDS a~Customer,b~CustomerName
           WHERE a~BillingDocument = @wa-BillingDocument
           AND a~PartnerFunction = 'RE' INTO @DATA(buyer) PRIVILEGED ACCESS.


          wa_zirn-Bukrs = wa-CompanyCode.
          wa_zirn-billingdocno = wa-BillingDocument.
          wa_zirn-billingdate = wa-CreationDate.
          wa_zirn-documentreferenceid = wa-DocumentReferenceID.
          wa_zirn-plant = wa-Plant.
          wa_zirn-distributionchannel = wa-DistributionChannel.
          wa_zirn-billingdocumenttype = wa-BillingDocumentType.
          wa_zirn-Partycode = buyer-Customer.
          wa_zirn-Partyname = buyer-CustomerName.
          wa_zirn-Moduletype = 'SALES'.
          wa_zirn-last_changed_at = lv_timestamp.
          wa_zirn-netweight = ntwt.
          wa_zirn-grossweight = grwt.
          MODIFY ztable_irn FROM @wa_zirn.
          CLEAR wa_zirn.
          CLEAR wa.
        ENDLOOP.
        response->set_text( '1' ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
