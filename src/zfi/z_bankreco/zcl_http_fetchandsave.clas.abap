class ZCL_HTTP_FETCHANDSAVE definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .
  INTERFACES if_oo_adt_classrun.

  TYPES: BEGIN OF ty_request,
           bank             TYPE dtgbk,
           company          TYPE bukrs,
           statementdate    TYPE d,
           Fiscalyear       TYPE gjahr,
           Bankrecoid       TYPE zr_bankreco-bankrecoid,
           BankName         TYPE zr_bankreco-BankName,
         END OF ty_request.

  CLASS-DATA: ls_request TYPE ty_request.

  TYPES: BEGIN OF ty_response,
           bankrecoid      TYPE zr_bankreco-bankrecoid,
           success TYPE c LENGTH 1,
         END OF ty_response.
  CLASS-DATA: ls_response TYPE ty_response,
              bankrecoid  TYPE zr_bankreco-bankrecoid.
  CLASS-METHODS getcid RETURNING VALUE(cid) TYPE abp_behv_cid.

  CLASS-METHODS savedata
    IMPORTING
      request        TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string.



  CLASS-METHODS savestatements.
  CLASS-METHODS savedocuments.

protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_FETCHANDSAVE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method( ).
      WHEN 'POST'.
        response->set_text( savedata( request ) ).
        response->set_content_type( 'application/json' ).
      WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
    ENDCASE.
  ENDMETHOD.


  METHOD getcid.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD savedata.

    DATA(lv_body) = request->get_text( ).
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = lv_body
      CHANGING
        data = ls_request ).

    DATA(reco_cid) = getcid( ).

    IF ls_request-bankrecoid IS INITIAL.
      MODIFY ENTITIES OF zr_bankreco
       ENTITY zrbankreco
       CREATE FIELDS (
         bank
         company
         statementdate
         status
         FiscalYear
         BankName
       )
       WITH VALUE #( (
              %cid    = reco_cid
              bank    = ls_request-bank
              company = ls_request-company
              statementdate = ls_request-statementdate
              status = 'Pending'
              FiscalYear = ls_request-fiscalyear
              BankName = ls_request-bankname
          ) )
         REPORTED DATA(ls_po_reported)
           FAILED   DATA(ls_po_failed)
           MAPPED   DATA(ls_po_mapped).

      COMMIT ENTITIES BEGIN
         RESPONSE OF zr_bankreco
         FAILED DATA(ls_save_failed)
         REPORTED DATA(ls_save_reported).

      IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
        ls_response-success = 'N'.
      ELSE.
        ls_response-success = 'Y'.
        LOOP AT ls_po_mapped-zrbankreco INTO DATA(ls_reported).
          bankrecoid = ls_reported-bankrecoid.
        ENDLOOP.
      ENDIF.

      COMMIT ENTITIES END.
    ELSE.
      bankrecoid = ls_request-bankrecoid.
      ls_response-success = 'Y'.
    ENDIF.

    ls_response-bankrecoid = bankrecoid.

    IF bankrecoid IS NOT INITIAL.
      savestatements( ).
      savedocuments( ).
    ENDIF.


    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = ls_response
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   message ).


    REPLACE ALL OCCURRENCES OF '"SUCCESS"' IN message WITH '"Success"'.
    REPLACE ALL OCCURRENCES OF '"BANKRECOID"' IN message WITH '"BankRecoId"'.


  ENDMETHOD.


  METHOD savestatements.

    SELECT FROM zr_bankstmtlines AS a
    INNER JOIN zr_bankstmt AS b ON a~statementid = b~statementid
    FIELDS amount, dates, description, a~statementid, voucherno, type, utr
    WHERE b~bankcode = @ls_request-bank
      AND b~company = @ls_request-company
      AND a~dates <= @ls_request-statementdate
      AND b~Status NE 'Closed'
      AND NOT EXISTS ( SELECT * FROM zr_statementtrans AS b
                   WHERE a~statementid = b~statementid AND a~voucherno = b~voucherno )
    INTO TABLE @DATA(lt_stmtlines).

    IF lt_stmtlines IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_statementtrans_001
    ENTITY zrstatementtrans001
    CREATE FIELDS (
        amount
        bankrecoid
        dates
        description
        statementid
        utr
        voucherno
    )
    WITH VALUE #( FOR ls_stmtline IN lt_stmtlines
                    (
                      %cid          = getcid( )
                      amount        = ls_stmtline-amount
                      bankrecoid    = bankrecoid
                      dates         = ls_stmtline-dates
                      description   = ls_stmtline-description
                      statementid   = ls_stmtline-statementid
                      utr           = ls_stmtline-utr
                      voucherno     = ls_stmtline-voucherno
                    )
                )
      REPORTED DATA(ls_po_reported)
        FAILED   DATA(ls_po_failed)
        MAPPED   DATA(ls_po_mapped).

    COMMIT ENTITIES BEGIN
      RESPONSE OF zr_statementtrans_001
      FAILED DATA(ls_save_failed)
      REPORTED DATA(ls_save_reported).
    ...
    COMMIT ENTITIES END.


*    Get distinct statement ids from the saved statement lines and update the status to Hold
    DATA lt_statementids TYPE STANDARD TABLE OF STRING WITH DEFAULT KEY.
    LOOP AT lt_stmtlines INTO DATA(lv_stmtline).
      APPEND lv_stmtline-statementid TO lt_statementids.
    ENDLOOP.
    SORT lt_statementids.
    DELETE ADJACENT DUPLICATES FROM lt_statementids.

    MODIFY ENTITIES OF zr_bankstmt
    ENTITY ZrBankstmt
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR ls_statementids IN lt_statementids
                    (
                      Status = 'Hold'
                      StatementID = ls_statementids
                    )
                )
    REPORTED DATA(ls_po_reported1)
       FAILED   DATA(ls_po_failed1)
       MAPPED   DATA(ls_po_mapped1).

    COMMIT ENTITIES BEGIN
      RESPONSE OF ZR_BANKSTMT
      FAILED DATA(ls_save_failed1)
      REPORTED DATA(ls_save_reported1).
    ...
    COMMIT ENTITIES END.


  ENDMETHOD.


  METHOD savedocuments.

    SELECT SINGLE FROM zr_brstable AS b
    FIELDS b~ingl, b~outgl, b~compcode
    WHERE b~Accountcode = @ls_request-bank
      AND b~compcode = @ls_request-company
    INTO @DATA(ls_glmapping).

    SELECT FROM i_operationalacctgdocitem AS c
    FIELDS c~accountingdocument AS voucherno, c~accountingdocumenttype AS paymenttype, c~fiscalyear, c~postingdate, c~AmountInCompanyCodeCurrency,
           c~assignmentreference, c~glaccount, c~companycode
      WHERE c~postingdate <= @ls_request-statementdate
      AND c~companycode = @ls_glmapping-compcode
      AND c~FiscalYear = @ls_request-Fiscalyear
      AND c~clearingitem IS INITIAL
      AND ( c~glaccount = @ls_glmapping-ingl OR c~glaccount = @ls_glmapping-outgl  )
      AND NOT EXISTS ( SELECT * FROM zr_booktrans AS f
               INNER JOIN zr_bankreco AS g ON f~bankrecoid = g~bankrecoid
               WHERE c~accountingdocument = f~voucherno AND f~fiscalyear = c~fiscalyear and g~Company = c~CompanyCode  )
    INTO TABLE @DATA(lt_documents).

    IF lt_documents IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_documents INTO DATA(ls_doc).

      SELECT SINGLE FROM i_journalentryitem AS a
      LEFT JOIN i_supplier AS d ON a~supplier = d~supplier
      LEFT JOIN i_customer AS e ON a~customer = e~customer
      FIELDS  ( CASE
                   WHEN a~supplier IS NOT INITIAL THEN a~supplier
                   ELSE a~customer
              END ) AS partycode,
            ( CASE
                   WHEN a~supplier IS NOT INITIAL THEN d~suppliername
                   ELSE e~customername
              END ) AS partyname, a~GLAccount
      WHERE a~accountingdocument = @ls_doc-voucherno
            AND a~fiscalyear = @ls_doc-fiscalyear
            AND a~companycode = @ls_doc-companycode
            AND a~offsettingaccount = @ls_doc-glaccount
            AND a~isreversal = '' AND a~isreversed = ''
            AND a~sourceledger = '0L'
      INTO @DATA(party_details).

      IF party_details IS INITIAL.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_booktrans_001
      ENTITY zrbooktrans001
      CREATE FIELDS (
          bankrecoid
          voucherno
          paymenttype
          fiscalyear
          dates
          amount
          partycode
          partyname
          assignmentref
          glaccount
      )
      WITH VALUE #(
                  (
                      %cid          = getcid( )
                      bankrecoid    = bankrecoid
                      voucherno     = ls_doc-voucherno
                      paymenttype   = ls_doc-paymenttype
                      fiscalyear    = ls_doc-fiscalyear
                      dates         = ls_doc-postingdate
                      amount        = ls_doc-AmountInCompanyCodeCurrency
                      partycode     = party_details-partycode
                      partyname     = party_details-partyname
                      assignmentref = ls_doc-assignmentreference
                      glaccount     = ls_doc-glaccount
                  ) )
      REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).


    ENDLOOP.

    COMMIT ENTITIES BEGIN
        RESPONSE OF zr_booktrans_001
        FAILED DATA(ls_save_failed)
        REPORTED DATA(ls_save_reported).
    ...
    COMMIT ENTITIES END.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

  DATA(del_bankreco_id) = '1000000014'.

  DELETE FROM zbank_reco WHERE bankrecoid = @del_bankreco_id.
  DELETE FROM zbook_trans WHERE bankrecoid = @del_bankreco_id.
  DELETE FROM zstatement_trans WHERE bankrecoid = @del_bankreco_id.

  ENDMETHOD.

ENDCLASS.
