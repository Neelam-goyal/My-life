CLASS zcl_http_bankstatement DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_BANKSTATEMENT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(CompanyCode) = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(BankID) = VALUE #( req[ name = 'bankstatement' ]-value OPTIONAL ).
    DATA(LastDate) = VALUE #( req[ name = 'lastdate' ]-value OPTIONAL ).
    DATA(CurrentDate) = VALUE #( req[ name = 'currentdate' ]-value OPTIONAL ).
    DATA(ProfitCenter1) = VALUE #( req[ name = 'profitcenter' ]-value OPTIONAL )
    .
    DATA ingoGL TYPE string."I_GLAccount-GLAccount.
    DATA outgoGL TYPE string.

    DATA ProfitCenter TYPE string.
    profitcenter = |{ profitcenter1 ALPHA = IN }|.

    CompanyCode = to_upper( CompanyCode ).

    IF strlen( CompanyCode ) > 4.
      response->set_text( |Invalid company code: { CompanyCode }. Length must not exceed 4 characters.| ).
      RETURN.
    ENDIF.

    TRY.
        SELECT SINGLE FROM zr_brstable AS a
         FIELDS a~OutGl
          WHERE AccId = @BankID
           INTO @outgoGL.

        SELECT SINGLE FROM zr_brstable AS b
        FIELDS b~InGl
        WHERE AccId =  @BankID
        INTO @ingoGL.

        IF strlen( outgoGL ) = 8.
          CONCATENATE '00' outgoGL INTO outgoGL.
        ELSEIF strlen( outgoGL ) = 9.
          CONCATENATE '0' outgoGL INTO outgoGL.
        ENDIF.
        IF strlen( ingoGL ) = 8.
          CONCATENATE '00' ingoGL INTO ingoGL.
        ELSEIF strlen( ingoGL ) = 9.
          CONCATENATE '0' ingoGL INTO ingoGL.
        ENDIF.

        IF outgoGL IS NOT INITIAL.
          SELECT SINGLE FROM I_OperationalAcctgDocItem
          FIELDS GLAccount , companycode
          WHERE companycode = @CompanyCode
          AND ( GLAccount = @ingoGL AND GLAccount = @outgoGL )
          INTO @DATA(valid_BankID_companycode).
        ENDIF.

        IF profitcenter = 'undefined' OR profitcenter = 'null'.
          profitcenter = ''.
        ENDIF.

        DATA(pdf) = zcl_bankstatement=>read_posts(
          CompanyCode     = CompanyCode
          IngoinGL        = ingoGL
          OutgoinGL       = outgoGL
          LastDate        = LastDate
          CurrentDate     = CurrentDate
          ProfitCenter    = ProfitCenter
        ).
        response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
        response->set_text( pdf ).
        RETURN.
      CATCH cx_static_check INTO DATA(lx_static).
        DATA(error_message) = lx_static->get_text( ).
        DATA(error_stack) = lx_static->get_longtext( ).
        response->set_text( |Getting error in generating XML for this GlAccountStatement: { error_message }. Details: { error_stack }| ).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
