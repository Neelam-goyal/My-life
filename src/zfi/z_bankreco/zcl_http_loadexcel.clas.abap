class ZCL_HTTP_LOADEXCEL definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.

TYPES: BEGIN OF ty_transaction_data,
             manual_transaction TYPE string,
             external_transaction TYPE string,
             value_date TYPE zr_statementtrans-Dates,
             amount TYPE zr_statementtrans-Amount,
             account_currency TYPE string,
             memo_line TYPE zr_booktrans-VoucherNo,
             check_number TYPE string,
             payment_medium_reference TYPE string,
             customer_reference_number TYPE string,
             item_reference TYPE zr_statementtrans-Utr,
             payment_amount TYPE string,
             payment_currency TYPE string,
             partner_name TYPE string,
             partner_national_bank_code TYPE string,
             partner_bank_country_region TYPE string,
             partner_bank_acct_iban TYPE string,
             partner_swift_code TYPE string,
             partner_bank_account TYPE string,
             customer TYPE string,
             supplier TYPE string,
             gl_account TYPE string,
             description TYPE string,
             assignment TYPE string,
             reference TYPE string,
             cost_center TYPE string,
             payment_reference TYPE string,
             profitcenter     TYPE i_journalentryitem-profitcenter,
           END OF ty_transaction_data.

ENDCLASS.



CLASS ZCL_HTTP_LOADEXCEL IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

  DATA(req) = request->get_form_fields(  ).
  DATA(bankrecoid) = VALUE #( req[ name = 'bankrecoid' ]-value OPTIONAL ).

  CASE request->get_method( ).
      WHEN 'GET'.

        DATA responseData TYPE ty_transaction_data.
        DATA responseTable TYPE TABLE OF ty_transaction_data.

        SELECT FROM zr_booktrans as a
        INNER JOIN zr_bankreco as b ON a~Bankrecoid = b~Bankrecoid
        INNER JOIN zr_brstable AS c ON b~bank = c~accid AND  b~Company = c~CompCode
        INNER JOIN i_journalentryitem AS d ON a~glaccount = d~glaccount AND d~companycode = c~CompCode
        AND d~accountingdocument = a~voucherno AND d~FiscalYear = a~Fiscalyear AND d~SourceLedger = '0L'
        FIELDS  a~VoucherNo , d~ProfitCenter , a~Bankrecoid , a~ClearedVoucherno , a~ClearedDate
        WHERE a~bankrecoid = @bankrecoid

        INTO TABLE @DATA(lt_data).

        LOOP AT lt_data INTO DATA(ls_data).

              CLEAR responseData.

              SELECT SINGLE FROM zr_statementtrans as a
              FIELDS a~Dates , a~Amount , a~Utr
                WHERE voucherno = @ls_data-clearedvoucherno
                    AND dates = @ls_data-cleareddate
                    AND bankrecoid = @bankrecoid
              INTO @DATA(wa).

              responseData-manual_transaction = ''.
              responseData-external_transaction = COND #( WHEN wa-Amount < 0
                                               THEN |{ 'ANP' }|
                                               ELSE 'ANR' ).
              responseData-value_date = COND #( WHEN wa-Dates IS NOT INITIAL
                                               THEN |{ wa-Dates }|
                                               ELSE 00000101 ).
              responseData-amount = COND #( WHEN wa-Amount IS NOT INITIAL
                                           THEN |{ wa-Amount }|
                                           ELSE '' ).
              responseData-account_currency = ''.
              responseData-memo_line = COND #( WHEN ls_data-VoucherNo IS NOT INITIAL
                                                   THEN |{ ls_data-VoucherNo }|
                                                   ELSE '' ).
              responseData-check_number = ''.
              responseData-payment_medium_reference = ''.
              responseData-customer_reference_number = ''.
              responseData-item_reference = COND #( WHEN wa-Utr IS NOT INITIAL
                                              THEN |{ wa-Utr }|
                                              ELSE '' ).
              responseData-payment_amount = ''.
              responseData-payment_currency = ''.
              responseData-partner_name = ''.
              responseData-partner_national_bank_code = ''.
              responseData-partner_bank_country_region = ''.
              responseData-partner_bank_acct_iban = ''.
              responseData-partner_swift_code = ''.
              responseData-partner_bank_account = ''.
              responseData-customer = ''.
              responseData-supplier = ''.
              responseData-gl_account = ''.
              responseData-description = ''.
              responseData-assignment = ''.
              responseData-reference = ''.
              responseData-cost_center = ''.
              responseData-payment_reference = ''.
              responseData-profitcenter = COND #( WHEN ls_data-ProfitCenter IS NOT INITIAL
                                                      THEN |{ ls_data-ProfitCenter }|
                                                      ELSE '' ).

              APPEND responseData TO responseTable.
        ENDLOOP.

            DATA:json TYPE REF TO if_xco_cp_json_data.
            DATA:lt_json TYPE string.

            xco_cp_json=>data->from_abap(
              EXPORTING
                ia_abap      = responseTable
              RECEIVING
                ro_json_data = json   ).
              json->to_string(
              RECEIVING
                rv_string =   lt_json ).


                response->set_text( lt_json ).
                response->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
                response->set_status( i_code = 200 i_reason = 'OK' ).

   WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
    ENDCASE.

  endmethod.
ENDCLASS.
