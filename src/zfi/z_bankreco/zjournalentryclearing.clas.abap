CLASS zjournalentryclearing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA lo_client TYPE REF TO if_web_http_client.

    TYPES: BEGIN OF ty_clearing_data,
             assignmentref    TYPE zr_booktrans_001-assignmentref,
             voucherno        TYPE zr_booktrans_001-voucherno,
             clearedvoucherno TYPE zr_booktrans_001-clearedvoucherno,
             cleareddate      TYPE zr_booktrans_001-cleareddate,
             cleardoc1        TYPE zr_booktrans_001-cleardoc1,
             bankrecoid       TYPE zr_booktrans_001-bankrecoid,
             company          TYPE zr_bankreco-company,
             fiscalyear       TYPE zr_bankreco-fiscalyear,
           END OF ty_clearing_data.

    DATA it_item TYPE STANDARD TABLE OF ty_clearing_data WITH DEFAULT KEY.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    METHODS
      api_call
        IMPORTING final_xml TYPE string
        RAISING
                  cx_http_dest_provider_error
                  cx_web_http_client_error
                  cx_web_message_error.
    METHODS
      runJob
        IMPORTING bank_reco TYPE C
         RAISING
                  cx_http_dest_provider_error
                  cx_web_http_client_error
                  cx_web_message_error.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZJOURNALENTRYCLEARING IMPLEMENTATION.


METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
  et_parameter_def = VALUE #(
    ( selname = 'P_RECO' kind = if_apj_dt_exec_object=>parameter
      datatype = 'N' length = 2
      param_text = 'BankRecoId'
      lowercase_ind = abap_true
      changeable_ind = abap_true )
  ).

  et_parameter_val = VALUE #(
    ( selname = 'P_RECO' kind = if_apj_dt_exec_object=>parameter
      sign = 'I' option = 'EQ' low = 'BankRecoId' )
  ).

   ENDMETHOD.


     METHOD if_apj_rt_exec_object~execute.
    DATA p_reco TYPE c LENGTH 10.


    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_RECO'. p_reco = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    TRY.

     runJob( bank_reco = p_reco ).

    CATCH cx_http_dest_provider_error
        cx_web_http_client_error
        cx_web_message_error INTO DATA(lx_http_error).

    DATA(lv_msg) = lx_http_error->get_text( ).

    ENDTRY.

     ENDMETHOD.


  METHOD runJob.

  DATA bankRecoId TYPE zr_booktrans_001-Bankrecoid.

  bankRecoId = bank_reco.

    SELECT FROM zr_booktrans_001 AS a
      INNER JOIN zr_bankreco AS b
        ON a~bankrecoid = b~bankrecoid
      FIELDS a~assignmentref, a~voucherno, a~clearedvoucherno, a~cleareddate, a~ClearDoc1 , a~Bankrecoid ,
             b~company, b~fiscalyear
      WHERE a~ClearDoc1 IS NOT INITIAL AND b~Status = 'Posted'
      AND ( a~Bankrecoid = @bankRecoId OR @bankRecoId = '' )
      INTO TABLE @it_item.

    DATA: msgId         TYPE string,
          current_date  TYPE string,
          lv_now        TYPE string,
          creation_date TYPE string,
          final_xml     TYPE string,
          loop_xml      TYPE string.

    lv_now = utclong_current( ).

    msgId = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }_{ lv_now+11(2) }:{ lv_now+14(2) }:{ lv_now+17(2) }|.
    current_date = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }|.

    creation_date = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }T{ lv_now+11(2) }:{ lv_now+14(2) }:{ lv_now+17(2) }.{ lv_now+20(3) }{ lv_now+24(3) }Z|.

    DATA(lv_head) =
      |<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sfin="http://sap.com/xi/SAPSCORE/SFIN">| &&
      |<soapenv:Header/>| &&
      |<soapenv:Body>| &&
      |<sfin:JournalEntryBulkClearingRequest>| &&
      |<MessageHeader>| &&
      |<ID>{ msgId }</ID>| &&
      |<CreationDateTime>{ creation_date }</CreationDateTime>| &&
      |<TestDataIndicator>{ |false| }</TestDataIndicator>| &&
      |</MessageHeader>|.

    LOOP AT it_item INTO DATA(wa_item).

      DATA(lv_payload) =
        |<JournalEntryClearingRequest>| &&
        |<MessageHeader>| &&
        |<ID>{ |SUB_| && msgId }</ID>| &&
        |<CreationDateTime>{ creation_date }</CreationDateTime>| &&
        |</MessageHeader>| &&
        |<JournalEntry>| &&
        |<CompanyCode>{ wa_item-company }</CompanyCode>| &&
        |<AccountingDocumentType>AB</AccountingDocumentType>| &&
        |<DocumentDate>{ current_date }</DocumentDate>| &&
        |<PostingDate>{ current_date }</PostingDate>| &&
        |<CurrencyCode>INR</CurrencyCode>| &&
        |<DocumentHeaderText>Clearing Entry</DocumentHeaderText>|.


      SELECT SINGLE FROM i_journalentryitem AS e
        FIELDS e~CompanyCode , e~FiscalYear , e~AccountingDocument , e~AccountingDocumentitem , e~GLAccount
        WHERE e~accountingdocument = @wa_item-voucherno
          AND e~CompanyCode        = @wa_item-Company
          AND e~fiscalyear         = @wa_item-fiscalyear
          AND e~accountingdocumentitem <> 0
          AND e~sourceledger = '0L'
          AND e~Customer IS INITIAL
          AND e~Supplier IS INITIAL
        INTO @DATA(wa_item1).

      SELECT SINGLE FROM i_journalentryitem AS e
        FIELDS e~CompanyCode , e~FiscalYear , e~AccountingDocument , e~AccountingDocumentitem , e~GLAccount
        WHERE e~accountingdocument = @wa_item-cleardoc1
          AND e~CompanyCode        = @wa_item-Company
          AND e~fiscalyear         = @wa_item-fiscalyear
          AND e~accountingdocumentitem <> 0
          AND e~sourceledger = '0L'
          AND e~GLAccount     = @wa_item1-GLAccount
          AND e~Customer IS INITIAL
          AND e~Supplier IS INITIAL
        INTO @DATA(wa_item2).

      "--- GL Items
      DATA(item1_xml) =
        |<GLItems>| &&
        |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
        |<CompanyCode>{ wa_item1-companycode }</CompanyCode>| &&
        |<GLAccount>{ wa_item1-glaccount }</GLAccount>| &&
        |<FiscalYear>{ wa_item1-fiscalyear }</FiscalYear>| &&
        |<AccountingDocument>{ wa_item-cleardoc1 }</AccountingDocument>| &&
        |<AccountingDocumentItem>{ wa_item2-AccountingDocumentItem }</AccountingDocumentItem>| &&
        |</GLItems>|.

      DATA(item2_xml) =
        |<GLItems>| &&
        |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
        |<CompanyCode>{ wa_item2-companycode }</CompanyCode>| &&
        |<GLAccount>{ wa_item2-glaccount }</GLAccount>| &&
        |<FiscalYear>{ wa_item2-fiscalyear }</FiscalYear>| &&
        |<AccountingDocument>{ wa_item-voucherno }</AccountingDocument>| &&
        |<AccountingDocumentItem>{ wa_item1-AccountingDocumentItem }</AccountingDocumentItem>| &&
        |</GLItems>|.


      loop_xml = loop_xml &&
        lv_payload &&
        item1_xml &&
        item2_xml &&
        |</JournalEntry>| &&
        |</JournalEntryClearingRequest>|.

    ENDLOOP.

    DATA(lv_footer) =
      |</sfin:JournalEntryBulkClearingRequest>| &&
      |</soapenv:Body>| &&
      |</soapenv:Envelope>|.

    final_xml = lv_head && loop_xml && lv_footer.

    api_call( final_xml = final_xml ).

      LOOP AT it_item INTO wa_item.

        SELECT SINGLE FROM I_JournalEntryItem
        FIELDS ClearingJournalEntry
        WHERE AccountingDocument = @wa_item-cleardoc1
        AND ClearingJournalEntry IS NOT INITIAL
        INTO @DATA(clearedEntry).

        MODIFY ENTITIES OF zr_booktrans_001
              ENTITY zrbooktrans001
              UPDATE FIELDS ( ClearDoc2 )
              WITH VALUE #(
                  ( %tky = VALUE #( bankrecoid = wa_item-Bankrecoid
                                    VoucherNo = wa_item-voucherno )
                    cleardoc2 = clearedentry )
              )
              REPORTED DATA(ls_reported)
              FAILED   DATA(ls_failed)
              MAPPED   DATA(ls_mapped).

        COMMIT ENTITIES BEGIN
          RESPONSE OF zr_booktrans_001
          FAILED DATA(ls_save_failed)
          REPORTED DATA(ls_save_reported).
        ...
        COMMIT ENTITIES END.

        DATA(lv_all_cleared) = abap_false.

        SELECT COUNT( * ) AS total,
               SUM( CASE WHEN cleardoc2 IS INITIAL THEN 1 ELSE 0 END ) AS not_cleared
          FROM zr_booktrans_001
          WHERE bankrecoid = @wa_item-bankrecoid
          INTO @DATA(ls_count).

        IF ls_count-not_cleared = 0 AND ls_count-total > 0.
          lv_all_cleared = abap_true.
        ENDIF.
.

        IF lv_all_cleared = abap_true.

          MODIFY ENTITIES OF zr_bankreco
              ENTITY ZrBankreco
              UPDATE FIELDS ( status )
              WITH VALUE #(
                  ( %tky = VALUE #( bankrecoid = wa_item-Bankrecoid )
                    status = 'Cleared' )
              )
              REPORTED DATA(ls_reported1)
              FAILED   DATA(ls_failed1)
              MAPPED   DATA(ls_mapped1).

          COMMIT ENTITIES BEGIN
            RESPONSE OF zr_bankreco
            FAILED DATA(ls_save_failed1)
            REPORTED DATA(ls_save_reported1).
          ...
          COMMIT ENTITIES END.

        ENDIF.

      ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.


    DELETE FROM zbankstmt WHERE statement_id IN ( '1000000001','1000000002','1000000004','1000000009' ).
    DELETE FROM zbankstmtlines WHERE statement_id IN  ( '1000000001','1000000002','1000000004','1000000009' ).
    RETURN.

    SELECT FROM zr_booktrans_001 AS a
      INNER JOIN zr_bankreco AS b
        ON a~bankrecoid = b~bankrecoid
      FIELDS a~assignmentref, a~voucherno, a~clearedvoucherno, a~cleareddate, a~ClearDoc1 , a~Bankrecoid ,
             b~company, b~fiscalyear
      WHERE a~ClearDoc1 IS NOT INITIAL AND b~Status = 'Posted'
      AND a~Bankrecoid = '1000000035'
      INTO TABLE @it_item.

    DATA: msgId         TYPE string,
          current_date  TYPE string,
          lv_now        TYPE string,
          creation_date TYPE string,
          final_xml     TYPE string,
          loop_xml      TYPE string.

    lv_now = utclong_current( ).

    msgId = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }_{ lv_now+11(2) }:{ lv_now+14(2) }:{ lv_now+17(2) }|.
    current_date = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }|.

    creation_date = |{ lv_now(4) }-{ lv_now+5(2) }-{ lv_now+8(2) }T{ lv_now+11(2) }:{ lv_now+14(2) }:{ lv_now+17(2) }.{ lv_now+20(3) }{ lv_now+24(3) }Z|.

    DATA(lv_head) =
      |<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sfin="http://sap.com/xi/SAPSCORE/SFIN">| &&
      |<soapenv:Header/>| &&
      |<soapenv:Body>| &&
      |<sfin:JournalEntryBulkClearingRequest>| &&
      |<MessageHeader>| &&
      |<ID>{ msgId }</ID>| &&
      |<CreationDateTime>{ creation_date }</CreationDateTime>| &&
      |<TestDataIndicator>{ |false| }</TestDataIndicator>| &&
      |</MessageHeader>|.

    LOOP AT it_item INTO DATA(wa_item).

      DATA(lv_payload) =
        |<JournalEntryClearingRequest>| &&
        |<MessageHeader>| &&
        |<ID>{ |SUB_| && msgId }</ID>| &&
        |<CreationDateTime>{ creation_date }</CreationDateTime>| &&
        |</MessageHeader>| &&
        |<JournalEntry>| &&
        |<CompanyCode>{ wa_item-company }</CompanyCode>| &&
        |<AccountingDocumentType>AB</AccountingDocumentType>| &&
        |<DocumentDate>{ current_date }</DocumentDate>| &&
        |<PostingDate>{ current_date }</PostingDate>| &&
        |<CurrencyCode>INR</CurrencyCode>| &&
        |<DocumentHeaderText>Clearing Entry</DocumentHeaderText>|.


      SELECT SINGLE FROM i_journalentryitem AS e
        FIELDS e~CompanyCode , e~FiscalYear , e~AccountingDocument , e~AccountingDocumentitem , e~GLAccount
        WHERE e~accountingdocument = @wa_item-voucherno
          AND e~CompanyCode        = @wa_item-Company
          AND e~fiscalyear         = @wa_item-fiscalyear
          AND e~accountingdocumentitem <> 0
          AND e~sourceledger = '0L'
          AND e~Customer IS INITIAL
          AND e~Supplier IS INITIAL
        INTO @DATA(wa_item1).

      SELECT SINGLE FROM i_journalentryitem AS e
        FIELDS e~CompanyCode , e~FiscalYear , e~AccountingDocument , e~AccountingDocumentitem , e~GLAccount
        WHERE e~accountingdocument = @wa_item-cleardoc1
          AND e~CompanyCode        = @wa_item-Company
          AND e~fiscalyear         = @wa_item-fiscalyear
          AND e~accountingdocumentitem <> 0
          AND e~sourceledger = '0L'
          AND e~GLAccount     = @wa_item1-GLAccount
          AND e~Customer IS INITIAL
          AND e~Supplier IS INITIAL
        INTO @DATA(wa_item2).

      "--- GL Items
      DATA(item1_xml) =
        |<GLItems>| &&
        |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
        |<CompanyCode>{ wa_item1-companycode }</CompanyCode>| &&
        |<GLAccount>{ wa_item1-glaccount }</GLAccount>| &&
        |<FiscalYear>{ wa_item1-fiscalyear }</FiscalYear>| &&
        |<AccountingDocument>{ wa_item-cleardoc1 }</AccountingDocument>| &&
        |<AccountingDocumentItem>{ wa_item2-AccountingDocumentItem }</AccountingDocumentItem>| &&
        |</GLItems>|.

      DATA(item2_xml) =
        |<GLItems>| &&
        |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
        |<CompanyCode>{ wa_item2-companycode }</CompanyCode>| &&
        |<GLAccount>{ wa_item2-glaccount }</GLAccount>| &&
        |<FiscalYear>{ wa_item2-fiscalyear }</FiscalYear>| &&
        |<AccountingDocument>{ wa_item-voucherno }</AccountingDocument>| &&
        |<AccountingDocumentItem>{ wa_item1-AccountingDocumentItem }</AccountingDocumentItem>| &&
        |</GLItems>|.


      loop_xml = loop_xml &&
        lv_payload &&
        item1_xml &&
        item2_xml &&
        |</JournalEntry>| &&
        |</JournalEntryClearingRequest>|.

    ENDLOOP.

    DATA(lv_footer) =
      |</sfin:JournalEntryBulkClearingRequest>| &&
      |</soapenv:Body>| &&
      |</soapenv:Envelope>|.

    final_xml = lv_head && loop_xml && lv_footer.

    out->write( final_xml ).

    MODIFY ENTITIES OF zr_booktrans_001
      ENTITY zrbooktrans001
      UPDATE FIELDS ( ClearingRequest )
      WITH VALUE #(
          ( %tky = VALUE #( bankrecoid = wa_item-Bankrecoid
                            VoucherNo = wa_item-voucherno )
            ClearingRequest = abap_true )
      )
      REPORTED DATA(ls_reported3)
      FAILED   DATA(ls_failed3)
      MAPPED   DATA(ls_mapped3).

    COMMIT ENTITIES BEGIN
      RESPONSE OF zr_booktrans_001
      FAILED DATA(ls_save_failed3)
      REPORTED DATA(ls_save_reported3).
    ...
    COMMIT ENTITIES END.

    TRY.
        api_call( final_xml = final_xml ).
      CATCH cx_http_dest_provider_error
          cx_web_http_client_error
          cx_web_message_error INTO DATA(lx_http_error).
        DATA(lv_msg) = lx_http_error->get_text( ).
    ENDTRY.

    LOOP AT it_item INTO wa_item.

      SELECT SINGLE FROM I_JournalEntryItem
      FIELDS ClearingJournalEntry
      WHERE AccountingDocument = @wa_item-cleardoc1
      AND ClearingJournalEntry IS NOT INITIAL
      INTO @DATA(clearedEntry).

      MODIFY ENTITIES OF zr_booktrans_001
            ENTITY zrbooktrans001
            UPDATE FIELDS ( ClearDoc2 )
            WITH VALUE #(
                ( %tky = VALUE #( bankrecoid = wa_item-Bankrecoid
                                  VoucherNo = wa_item-voucherno )
                  cleardoc2 = clearedentry )
            )
            REPORTED DATA(ls_reported)
            FAILED   DATA(ls_failed)
            MAPPED   DATA(ls_mapped).

      COMMIT ENTITIES BEGIN
        RESPONSE OF zr_booktrans_001
        FAILED DATA(ls_save_failed)
        REPORTED DATA(ls_save_reported).
      ...
      COMMIT ENTITIES END.

      DATA(lv_all_cleared) = abap_false.

      SELECT COUNT( * ) AS total,
             SUM( CASE WHEN cleardoc2 IS INITIAL THEN 1 ELSE 0 END ) AS not_cleared
        FROM zr_booktrans_001
        WHERE bankrecoid = @wa_item-bankrecoid
        INTO @DATA(ls_count).

      IF ls_count-not_cleared = 0 AND ls_count-total > 0.
        lv_all_cleared = abap_true.
      ENDIF.


      IF lv_all_cleared = abap_true.

        MODIFY ENTITIES OF zr_bankreco
            ENTITY ZrBankreco
            UPDATE FIELDS ( status )
            WITH VALUE #(
                ( %tky = VALUE #( bankrecoid = wa_item-Bankrecoid )
                  status = 'Cleared' )
            )
            REPORTED DATA(ls_reported1)
            FAILED   DATA(ls_failed1)
            MAPPED   DATA(ls_mapped1).

        COMMIT ENTITIES BEGIN
          RESPONSE OF zr_bankreco
          FAILED DATA(ls_save_failed1)
          REPORTED DATA(ls_save_reported1).
        ...
        COMMIT ENTITIES END.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD api_call.

    DATA rv_message_id TYPE string.

    TRY.
        rv_message_id = cl_system_uuid=>create_uuid_c36_static( ).

      CATCH cx_uuid_error INTO DATA(lx_uuid).
        rv_message_id = '00000000-0000-0000-0000-000000000000'.
    ENDTRY.

    rv_message_id = to_upper( rv_message_id ).

    SELECT SINGLE FROM zr_integration_tab
        FIELDS intgpath
          WHERE intgmodule = 'My-DOMAIN'
          INTO @DATA(bankable_url).

    DATA(suffix_url) = |https://my418719-api.s4hana.cloud.sap/sap/bc/srt/scs_ext/sap/journalentrybulkclearingreques/200/journalentrybulkclearingrequest/journalentrybulkclearingrequest_in?MessageId={ rv_message_id }|.

    DATA(lv_url) = |{ bankable_url }{ suffix_url } |.

    DATA lv_client2 TYPE REF TO if_web_http_client.
    TRY.
        DATA(dest2) = cl_http_destination_provider=>create_by_url( |{ suffix_url }| ).
        lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).


      CATCH cx_web_http_client_error INTO DATA(lx_dest_err).
        RETURN.
    ENDTRY.

    DATA(lo_request) = lv_client2->get_http_request( ).

    lo_request->set_header_field(
      i_name  = 'Content-Type'
      i_value = 'application/soap+xml; charset=utf-8'
    ).

    SELECT SINGLE FROM zr_integration_tab
    FIELDS Intgpath
    WHERE Intgmodule = 'My-DOMAIN-USER'
    INTO @DATA(user_pass).

    SPLIT user_pass AT ':' INTO DATA(i_username) DATA(i_password).

    lo_request->set_authorization_basic(
        i_username = i_username
        i_password = i_password
    ).

    lo_request->set_content_type( 'application/soap+xml; charset=utf-8' ).
    lo_request->append_text( final_xml ).

    DATA(lo_response) = lv_client2->execute( if_web_http_client=>post ).

    DATA(lv_result) = lo_response->get_text( ).
    DATA(ls_status) = lo_response->get_status( ).

    IF ls_status-code = 202.


    ELSE.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
