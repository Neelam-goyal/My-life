class zcl_http_bank_reco definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  INTERFACES if_oo_adt_classrun.

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS postData
    IMPORTING
      request  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .

protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_BANK_RECO IMPLEMENTATION.


method if_oo_adt_classrun~main.

update zbank_reco
set status = 'Pending'
where bankrecoid = '1000000014' .


ENDMETHOD.


  METHOD GETCID.
      TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
  ENDMETHOD.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

    CASE request->get_method(  ).
          WHEN CONV string( if_web_http_client=>post ).
           response->set_text( postData( request ) ).

        ENDCASE.
  endmethod.


  METHOD postdata.

    TYPES: BEGIN OF ty_json_structure,
             acc_type       TYPE string,
             actual_posting TYPE string,
             doc            TYPE string,
             doc_amt        TYPE string,
             doc_curr       TYPE string,
             doc_date       TYPE string,
             gl_acc         TYPE string,
             header_text    TYPE string,
             house_bank     TYPE string,
             loc_amt        TYPE string,
             loc_curr       TYPE string,
             posting_date   TYPE string,
             posting_key    TYPE string,
             profit         TYPE string,
             ref            TYPE string,
           END OF ty_json_structure.


    DATA it_table TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( it_table ) ).



        LOOP AT it_table INTO DATA(wa).

          SELECT FROM  I_AccountingDocumentJournal( P_Language = 'E' ) AS a
            FIELDS DISTINCT a~GLAccount,a~companycode
            WHERE a~AccountingDocument = @wa-doc
            AND a~PostingDate = @wa-posting_date
            AND a~Ledger = '0L'
            AND a~IsReversed IS INITIAL
            AND a~IsReversal IS INITIAL
            AND a~ReversalReferenceDocument IS INITIAL
            INTO TABLE @DATA(main_tb).

          DATA: match_gl TYPE string.
          DATA : check TYPE abap_bool VALUE abap_false.

          IF main_tb IS NOT INITIAL.
            LOOP AT main_tb INTO DATA(wa_main).
              SHIFT wa_main-GLAccount LEFT DELETING LEADING '0'.
              MODIFY main_tb FROM wa_main.

              DATA glacc TYPE saknr.
              glacc = |{ wa_main-GLAccount ALPHA = IN }|.

              SELECT SINGLE a~house_bank,
                a~main_gl,
                a~in_gl,
                a~out_gl,
                a~comp_code,
                a~acc_id
               FROM zbrstable AS a
               WHERE a~in_gl = @glacc
               OR a~out_gl = @glacc
               INTO @DATA(result).
              IF result IS NOT INITIAL.
                result-main_gl = |{ result-main_gl WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
                result-in_gl   = |{ result-in_gl   WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
                result-out_gl  = |{ result-out_gl  WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
                IF check = abap_false.
                  match_gl = wa_main-GLAccount.
                  match_gl  = |{ match_gl  WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
                  check = abap_true.
                ENDIF.
              ENDIF.
              CLEAR : wa_main.
            ENDLOOP.
          ENDIF.

          DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
                document   TYPE string.
          APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
          <je_deep>-%cid = getCid(  ).
          <je_deep>-%param = VALUE #(
          companycode  = result-comp_code
          businesstransactiontype = 'RFBU'
          accountingdocumenttype = 'ZR'     "wa-acc_type
          CreatedByUser = sy-uname
          AccountingDocument = wa-doc
          documentdate = wa-doc_date
          postingdate =  wa-posting_date

          _glitems = VALUE #( ( glaccountlineitem = |001|
                              glaccount = '0011001103'"result-main_gl
                              HouseBank = result-house_bank
                              HouseBankAccount = result-acc_id
                              ValueDate = wa-posting_date
*                             AssignmentReference = wa_data-Assignmentreference
                              ProfitCenter = wa-profit

                              _currencyamount = VALUE #( (
                                                  currencyrole = '10'
                                                  journalentryitemamount = wa-loc_amt
                                                  currency = wa-loc_curr ) ) )
                               ( glaccountlineitem = |002|
                               glaccount = match_gl
                              HouseBank = result-house_bank
                              HouseBankAccount = result-acc_id
*                             AssignmentReference = wa_data-Assignmentreference
                              ProfitCenter = wa-profit
                              ValueDate = wa-posting_date
                              _currencyamount = VALUE #( (
                                                  currencyrole = '10'
                                                  journalentryitemamount = wa-loc_amt * ( -1 )
                                                  currency = wa-loc_curr ) ) ) ) ).

          MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
        ENTITY journalentry
        EXECUTE post FROM lt_je_deep
        FAILED DATA(ls_failed_deep)
        REPORTED DATA(ls_reported_deep)
        MAPPED DATA(ls_mapped_deep).

          IF ls_failed_deep IS NOT INITIAL.

            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
              message = <ls_reported_deep>-%msg->if_message~get_longtext( ).
            ENDLOOP.
            RETURN.
          ELSE.

            COMMIT ENTITIES BEGIN
            RESPONSE OF i_journalentrytp
            FAILED DATA(lt_commit_failed)
            REPORTED DATA(lt_commit_reported).

            IF lt_commit_reported IS NOT INITIAL.
              LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
                document = <ls_reported>-AccountingDocument.
              ENDLOOP.
            ELSE.
              LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
                message = <ls_failed>-%fail-cause.
              ENDLOOP.
              RETURN.
            ENDIF.

            COMMIT ENTITIES END.
          ENDIF.
          CLEAR : lt_je_deep,wa.
          CLEAR main_tb.
          check = abap_false.
        ENDLOOP.
      CATCH cx_sy_conversion_no_date INTO DATA(lx_date).
        message = |Error in Date Conversion: { lx_date->get_text( ) }|.

      CATCH cx_sy_conversion_no_time INTO DATA(lx_time).
        message = |Error in Time Conversion: { lx_time->get_text( ) }|.

      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        message = |SQL Error: { lx_sql->get_text( ) }|.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
