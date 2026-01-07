 CLASS zhttp_printform DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZHTTP_PRINTFORM IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.


    TRY.

        DATA(req) = request->get_form_fields(  ).
        response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
        response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
        DATA(cookies)  = request->get_cookies(  ) .

        DATA req_host TYPE string.
        DATA req_proto TYPE string.
        DATA json TYPE string .

        req_host = request->get_header_field( i_name = 'Host' ).
        req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
        IF req_proto IS INITIAL.
          req_proto = 'https'.

        ENDIF.
        DATA(symandt) = sy-mandt.
        DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
        DATA(cc) = request->get_form_field( `companycode` ).
        DATA(doc) = request->get_form_field( `document` ).
        DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
        DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).
        DATA(SalesQuotation) = VALUE #( req[ name = 'salesquotation' ]-value OPTIONAL ).
        DATA(SalesQuotationType) = VALUE #( req[ name = 'salesquotationtype' ]-value OPTIONAL ).

        " Process sales quotation formatting
        IF strlen( salesquotation ) = 8.
          CONCATENATE '00' salesquotation INTO salesquotation.
        ELSEIF strlen( salesquotation ) = 9.
          CONCATENATE '0' salesquotation INTO salesquotation.
        ENDIF.

        IF salesquotationtype = 'QT'.
          salesquotationtype = 'AG'.
        ENDIF.
        IF printname = 'stoOriginal' OR printname = 'stoDuplicate' OR printname = 'stoOffice'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'TAXINVOICE' INTO @DATA(wa_int).
        ELSEIF printname = 'expoOriginal' OR printname = 'expoTransporter' OR printname = 'expoOffice'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'EXPORTINVOICE' INTO @wa_int .
        ELSEIF printname = 'DCOriginal' OR printname = 'DCDuplicate' OR  printname = 'DCOffice' .
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'DELIVERYCHALLAN' INTO @wa_int .
        ELSEIF printname = 'PL'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'PACKINGLIST' INTO @wa_int .
        ELSEIF printname = 'COMINV'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'CommercialInvoice' INTO @wa_int .
        ELSEIF printname = 'CUSINV'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'CustomInvoice' INTO @wa_int .
        ELSEIF printname = 'CusPL'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'CustomPackinglist' INTO @wa_int .
          ELSEIF printname = 'CreditNote'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'CREDITNOTE' INTO @wa_int .
          ELSEIF printname = 'DebitNote'.
          SELECT SINGLE FROM zintegration_tab AS a FIELDS a~intgpath WHERE a~intgmodule = 'DebitNote' INTO @wa_int .
        ENDIF.


        CASE request->get_method( ).
          WHEN CONV string( if_web_http_client=>get ).
            " GET method processing
            DATA: getresult TYPE string.

            IF printname = 'stoOriginal' OR printname = 'stoDuplicate' OR printname = 'stoOffice' OR printname = 'expoOriginal' OR printname = 'expoTransporter' OR printname = 'expoOffice' OR printname = 'PL' OR
               printname = 'COMINV' OR printname = 'CUSINV' OR printname = 'CusPL'.
              SELECT SINGLE DistributionChannel, BillingDocumentType
              FROM I_BillingDocument
              WHERE BillingDocument = @getdocument AND CompanyCode = @getcompanycode
              INTO @DATA(wa_check).
              getresult = ( wa_check-DistributionChannel ).

            ELSEIF printname = 'DCOriginal' OR printname = 'DCDuplicate' OR printname = 'DCOffice'.
              SELECT SINGLE BillingDocumentType , BillingDocument
              FROM I_BillingDocument
              WHERE BillingDocument = @getdocument AND CompanyCode = @getcompanycode
              INTO @DATA(wa_type).
              getresult = ( wa_type-BillingDocumentType ).

            ELSEIF printname = 'PerForma'.
              SELECT SINGLE SalesQuotationType
              FROM I_SalesQuotation
              WHERE SalesQuotation = @salesquotation
              INTO @DATA(wa).
              getresult = ( wa ).

            ELSEIF printname = 'CreditNote'.
              SELECT SINGLE BillingDocumentType
              FROM I_BillingDocument
              WHERE BillingDocument = @getdocument AND CompanyCode = @getcompanycode
              INTO @DATA(wa_credit).
              getresult = ( wa_credit ).

              ELSEIF printname = 'DebitNote'.
              SELECT SINGLE BillingDocumentType
              FROM I_BillingDocument
              WHERE BillingDocument = @getdocument AND CompanyCode = @getcompanycode
              INTO @DATA(wa_debit).
              getresult = ( wa_debit ).
            ENDIF.
            response->set_text( getresult ).

          WHEN CONV string( if_web_http_client=>post ).
            " POST method processing
            SELECT SINGLE *
            FROM I_BillingDocument
            WHERE BillingDocument = @doc AND CompanyCode = @cc
            INTO @DATA(lv_invoice).

*                 salesquotaion
            SELECT SINGLE * FROM i_salesquotation AS a
           WHERE a~SalesQuotation = @salesquotation  AND a~SalesQuotationType = @salesquotationtype
           INTO @DATA(lv_performa).

            SELECT SINGLE BillingDocumentIsCancelled, AccountingPostingStatus
            FROM I_BillingDocument
            WHERE BillingDocument = @doc AND CompanyCode = @cc
            INTO @DATA(wa_validprint).

            IF printname = 'stoOriginal' OR
               printname = 'stoDuplicate' OR
               printname = 'stoOffice' OR
               printname = 'expoOriginal' OR
               printname = 'expoTransporter' OR
               printname = 'expoOffice' OR
               printname = 'CreditNote' or
                 printname = 'DebitNote'  .
              IF wa_validprint-BillingDocumentIsCancelled = 'X'.
                response->set_text( 'This invoice has already been cancelled.' ).
                RETURN.
              ELSEIF wa_validprint-AccountingPostingStatus <> 'C'.
                response->set_text( 'The document is not yet released for this invoice.' ).
                RETURN.
              ELSE.
                IF lv_invoice IS NOT INITIAL.
                  DATA(pdf) = zcl_sto_tax_inv_dr=>read_posts(
                      bill_doc = doc
                      printForm = printname
                      lc_template_name = SWITCH #( printname
*                          WHEN 'stoOriginal' THEN wa_int
*                          WHEN 'stoDuplicate' THEN 'ZBonnTaxInvoice/ZBonnTaxInvoice'
*                          WHEN 'stoOffice'  THEN 'ZBonnTaxInvoice/ZBonnTaxInvoice'
                          WHEN 'stoOriginal' THEN 'TaxinvoiceV1Test/TaxinvoiceV1Test'
                          WHEN 'stoDuplicate' THEN 'TaxinvoiceV1Test/TaxinvoiceV1Test'
                          WHEN 'stoOffice'  THEN 'TaxinvoiceV1Test/TaxinvoiceV1Test'
                          WHEN 'expoOriginal' THEN 'ZBonnExportInvoice/ZBonnExportInvoice'
                          WHEN 'expoTransporter' THEN 'ZBonnExportInvoice/ZBonnExportInvoice'
                          WHEN 'expoOffice' THEN 'ZBonnExportInvoice/ZBonnExportInvoice'
                          WHEN 'CreditNote' THEN 'ZBonnCreditNote/ZBonnCreditNote'
                          WHEN 'DebitNote' THEN 'ZBonnDebitNote/ZBonnDebitNote' )
                          ).

                  IF pdf = 'ERROR'.
                    response->set_text( 'Error generating PDF. Please check the document data.' ).
                  ELSE.
                    response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                    response->set_text( pdf ).
                    RETURN.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF printname = 'DCOriginal' OR printname = 'DCDuplicate' OR printname = 'DCOffice' OR  printname = 'PL' OR  printname = 'CusPL' OR  printname = 'CUSINV' OR  printname = 'COMINV' .
              IF wa_validprint-BillingDocumentIsCancelled = 'X'.
                response->set_text( 'This invoice has already been cancelled.' ).
                RETURN.
              ELSE.
                IF lv_invoice IS NOT INITIAL.
                  pdf = zcl_sto_tax_inv_dr=>read_posts(
                     bill_doc = doc
                      printForm = printname
                     lc_template_name = SWITCH #( printname
                         WHEN 'DCOriginal' THEN 'ZBonnDeliveryChallan/ZBonnDeliveryChallan'
                         WHEN 'DCDuplicate' THEN 'ZBonnDeliveryChallan/ZBonnDeliveryChallan'
                         WHEN 'DCOffice'  THEN 'ZBonnDeliveryChallan/ZBonnDeliveryChallan'
                         WHEN 'PL' THEN 'ZBonnPackingList/ZBonnPackingList'
*                          When 'PL' THEN 'zpacking_list_test/zpacking_list_test'
                         WHEN 'COMINV' THEN 'ZCommercialInvoice/ZCommercialInvoice'
                         WHEN 'CusPL' THEN 'ZCUSTOMPKG/ZCUSTOMPKG'
*                         WHEN 'CusPL' THEN 'ZCustomPKGTest1/ZCustomPKGTest1'
                         WHEN 'CUSINV' THEN 'ZCUSTOM_INVOICE/ZCUSTOM_INVOICE' ) ).

                  IF pdf = 'ERROR'.
                    response->set_text( 'Error generating PDF. Please check the document data.' ).
                  ELSE.
                    response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                    response->set_text( pdf ).
                    RETURN.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF printname = 'PerForma'.
              IF wa_validprint-BillingDocumentIsCancelled = 'X'.
                response->set_text( 'This invoice has already been cancelled.' ).
                RETURN.
              ELSE.
                IF lv_performa IS NOT INITIAL.
                  pdf = zcl_performainvoice=>read_posts( salesQT = salesquotation  lc_template_name = 'ZBONNPERFORMA/ZBONNPERFORMA' ).
                  IF pdf = 'ERROR'.
                    response->set_text( 'Error generating PDF. Please check the document data.' ).
                  ELSE.
                    response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                    response->set_text( pdf ).
                    RETURN.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
        ENDCASE.

      CATCH cx_static_check INTO DATA(lx_static).
        response->set_status( i_code = 500 ).
        response->set_text( lx_static->get_text( ) ).
      CATCH cx_root INTO DATA(lx_root).
        response->set_status( i_code = 500 ).
        response->set_text( lx_root->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
