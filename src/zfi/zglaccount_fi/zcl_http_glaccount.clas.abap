CLASS ZCL_HTTP_GLACCOUNT DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_GLACCOUNT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields( ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(CompanyCode) = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ).
    DATA(GlAccount) = VALUE #( req[ name = 'glaccount' ]-value OPTIONAL ).
    DATA(LastDate) = VALUE #( req[ name = 'lastdate' ]-value OPTIONAL ).
    DATA(CurrentDate) = VALUE #( req[ name = 'currentdate' ]-value OPTIONAL ).
    DATA(ProfitCenter1) = VALUE #( req[ name = 'profitcenter' ]-value OPTIONAL ).

    DATA ProfitCenter TYPE string.
   profitcenter = |{ profitcenter1 ALPHA = IN }|.

    CompanyCode = to_upper( CompanyCode ).

    IF strlen( CompanyCode ) > 4.
      response->set_text( |Invalid company code: { CompanyCode }. Length must not exceed 4 characters.| ).
      RETURN.
    ENDIF.
    IF strlen( GlAccount ) = 8.
      CONCATENATE '00' GlAccount INTO GlAccount.
    ELSEIF strlen( GlAccount ) = 9.
      CONCATENATE '0' GlAccount INTO GlAccount.
    ENDIF.

    TRY.
        SELECT SINGLE FROM I_GLAccountInCompanyCode AS a
         FIELDS a~GLAccount
          WHERE GlAccount = @GlAccount
           INTO @DATA(valid_GlAccount).

        IF valid_GlAccount IS NOT INITIAL.
          SELECT SINGLE FROM I_OperationalAcctgDocItem
          FIELDS GLAccount , companycode
          WHERE companycode = @CompanyCode
          AND GlAccount = @GlAccount
          INTO @DATA(valid_GlAccount_companycode).
        ENDIF.
*        IF valid_GlAccount IS INITIAL.
*          response->set_text( |GLAccount { GlAccount } not found in master data| ).
*          RETURN.
*        ENDIF.
*        IF valid_GlAccount_companycode IS INITIAL.
*          response->set_text( |GLAccount { GlAccount } not found in master data for company code { CompanyCode }| ).
*          RETURN.
*        ENDIF.
        DATA(pdf) = zcl_glaccount=>read_posts(
          CompanyCode      = CompanyCode
          GlAccount       = GlAccount
          LastDate        = LastDate
          CurrentDate     = CurrentDate
          ProfitCenter    = ProfitCenter
        ).
       response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
       response->set_text( pdf ).
       return.
      CATCH cx_static_check INTO DATA(lx_static).
        DATA(error_message) = lx_static->get_text( ).
        DATA(error_stack) = lx_static->get_longtext( ).
        response->set_text( |Getting error in generating XML for this GlAccountStatement: { error_message }. Details: { error_stack }| ).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
