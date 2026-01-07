CLASS zcl_brsreport DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BRSREPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
     DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
     DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
     DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

     DATA(lt_parameters)  = io_request->get_parameters( ).
     DATA(lt_fileds)  = io_request->get_requested_elements( ).
     DATA(lt_sort)  = io_request->get_sort_elements( ).

   TRY.
      DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
    CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      CLEAR lt_filter_cond.
  ENDTRY.

  DATA(lv_default_date) = cl_abap_context_info=>get_system_date( ).
  DATA(lv_has_posting_filter) = abap_false.
  DATA(lv_using_default_date) = abap_false.

  " Process existing filters
  LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
    CASE to_upper( ls_filter_cond-name ).
      WHEN 'COMP_CODE'.
        DATA(lt_comp) = ls_filter_cond-range[].
      WHEN 'HOUSE_BANK'.
        DATA(lt_bank) = ls_filter_cond-range[].
      WHEN 'ACC_ID'.
        DATA(lt_acc) = ls_filter_cond-range[].
       WHEN 'ACTUAL_POSTING'.
          data(lt_postingdate) = ls_filter_cond-range[].
      WHEN 'BRS_POSTING'.
        DATA(lt_brsdate) = ls_filter_cond-range[].
    ENDCASE.
  ENDLOOP.



     DATA: lt_response    TYPE TABLE OF zdd_brs_report,
           ls_line        LIKE LINE OF lt_response,
           lt_responseout LIKE lt_response,
           ls_responseout LIKE LINE OF lt_responseout,
           lt_response1 like lt_response.

       TYPES: BEGIN OF ty_data,
             AccountingDocument                   TYPE I_AccountingDocumentJournal-AccountingDocument,
             GLAccount                            TYPE I_AccountingDocumentJournal-GLAccount,
             HouseBank                            TYPE I_AccountingDocumentJournal-HouseBank,
             DocumentItemText                     TYPE I_AccountingDocumentJournal-DocumentItemText,
             AccountingDocumentHeaderText         TYPE I_AccountingDocumentJournal-AccountingDocumentHeaderText,
             ProfitCenter                         TYPE I_AccountingDocumentJournal-ProfitCenter,
             AccountingDocumentType               TYPE I_AccountingDocumentJournal-AccountingDocumentType,
             DocumentDate                         TYPE I_AccountingDocumentJournal-DocumentDate,
             PostingDate                          TYPE I_AccountingDocumentJournal-PostingDate,
             PostingKey                           TYPE I_AccountingDocumentJournal-PostingKey,
             CreditAmountInCoCodeCrcy             TYPE I_AccountingDocumentJournal-CreditAmountInCoCodeCrcy,
             DebitAmountInCoCodeCrcy              TYPE I_AccountingDocumentJournal-DebitAmountInCoCodeCrcy,
             CompanyCodeCurrency                  TYPE I_AccountingDocumentJournal-CompanyCodeCurrency,
             DebitAmountInTransCrcy               Type I_AccountingDocumentJournal-DebitAmountInTransCrcy,
             CreditAmountInTransCrcy               Type I_AccountingDocumentJournal-CreditAmountInTransCrcy,
             TransactionCurrency                  TYPE I_AccountingDocumentJournal-TransactionCurrency,
           END OF ty_data.

    DATA: it TYPE TABLE OF ty_data,
          wa TYPE ty_data.


        SELECT comp_code,
           house_bank,
           acc_id,
           in_gl,
           out_gl
      FROM zbrstable
      WHERE comp_code IN @lt_comp
        AND house_bank IN @lt_bank
        AND acc_id IN @lt_acc
      INTO TABLE @data(lt_zbrs).

    LOOP AT lt_zbrs ASSIGNING FIELD-SYMBOL(<fs_zbrs>).
      <fs_zbrs>-in_gl  = |{ <fs_zbrs>-in_gl  WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
      <fs_zbrs>-out_gl = |{ <fs_zbrs>-out_gl WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
    ENDLOOP.

     DATA : lt_gl_list TYPE RANGE OF I_AccountingDocumentJournal-GLAccount.

        LOOP AT lt_zbrs INTO DATA(ls_zbrs).
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_zbrs-in_gl ) TO lt_gl_list.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_zbrs-out_gl ) TO lt_gl_list.
        ENDLOOP.

    SELECT DISTINCT AccountingDocument
      FROM I_AccountingDocumentJournal( P_Language = 'E' )
      WHERE GLAccount IN @lt_gl_list
        AND Ledger = '0L' and IsReversal is INITIAL and IsReversed is INITIAL AND ReversalReferenceDocument is INITIAL and
        ClearingDate is INITIAL and ClearingAccountingDocument is INITIAL and CompanyCode IN @lt_comp and PostingDate in @lt_postingdate
      INTO TABLE @data(it1).

      sort it1 by AccountingDocument.

    TYPES: acc_range TYPE RANGE OF I_AccountingDocumentJournal-AccountingDocument.

        DATA: it_temp TYPE TABLE OF ty_data,
              lt_accounting_documents TYPE acc_range.

        LOOP AT it1 INTO DATA(wa_check).
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low = wa_check-accountingdocument ) TO lt_accounting_documents.
        ENDLOOP.


        IF lt_accounting_documents IS NOT INITIAL.
          SELECT FROM I_ACCOUNTINGDOCUMENTJOURNAL( P_Language = 'E' ) AS a
            FIELDS a~AccountingDocument,
                   a~GLAccount,
                   a~HouseBank,
                   a~DocumentItemText,
                   a~AccountingDocumentHeaderText,
                   a~ProfitCenter,
                   a~AccountingDocumentType,
                   a~DocumentDate,
                   a~PostingDate,
                   a~PostingKey,
                   a~CreditAmountInCoCodeCrcy,
                   a~DebitAmountInCoCodeCrcy,
                   a~CompanyCodeCurrency,
                   a~DebitAmountInTransCrcy,
                   a~CreditAmountInTransCrcy,
                   a~TransactionCurrency
            WHERE a~IsReversed IS INITIAL
            AND a~IsReversal IS INITIAL
            AND a~ReversalReferenceDocument IS INITIAL
            AND a~AccountingDocument IN @lt_accounting_documents
            AND a~CompanyCode IN @lt_comp
            AND a~Ledger = '0L'
            AND a~GLAccount Not in  @lt_gl_list
            and a~PostingDate in @lt_postingdate
            and a~ClearingDate is INITIAL and a~ClearingAccountingDocument is INITIAL
            ORDER BY AccountingDocument
            INTO CORRESPONDING FIELDS OF TABLE @it_temp.
        ENDIF.

        APPEND LINES OF it_temp TO it.


    READ TABLE lt_brsdate INTO DATA(ls_postingdate) INDEX 1.
     IF sy-subrc = 0.
        DATA(lv_postingdate) = ls_postingdate-low.
     ENDIF.

    LOOP AT it ASSIGNING FIELD-SYMBOL(<fs_temp>).
      SHIFT <fs_temp>-glaccount LEFT DELETING LEADING '0'.
      SHIFT <fs_temp>-accountingdocument LEFT DELETING LEADING '0'.
    ENDLOOP.

     LOOP AT it INTO wa.
         ls_line-actual_posting = lv_postingdate.
         ls_line-gl_acc = wa-glaccount.
         ls_line-house_bank = wa-housebank.
         ls_line-ref = wa-documentitemtext.
         ls_line-header_text = wa-accountingdocumentheadertext.
         ls_line-doc = wa-AccountingDocument.
         ls_line-profit = wa-profitcenter.
         ls_line-acc_type = wa-accountingdocumenttype.
         ls_line-doc_date = wa-documentdate.
         ls_line-posting_date = wa-postingdate.
         ls_line-posting_key = wa-postingkey.
         if wa-debitamountincocodecrcy is not INITIAL.
        ls_line-loc_amt = wa-debitamountincocodecrcy.
        ls_line-loc_curr = wa-companycodecurrency.
      elseif wa-creditamountincocodecrcy is not INITIAL.
        ls_line-loc_amt = wa-creditamountincocodecrcy.
        ls_line-loc_curr = wa-companycodecurrency.
      ENDIF.
       if wa-debitamountincocodecrcy is not INITIAL.
        ls_line-doc_amt = wa-debitamountintranscrcy.
        ls_line-doc_curr = wa-transactioncurrency.
      elseif wa-creditamountincocodecrcy is not INITIAL.
        ls_line-doc_amt = wa-creditamountintranscrcy.
        ls_line-doc_curr = wa-transactioncurrency.
      ENDIF.
         APPEND ls_line TO lt_response.
         clear ls_line.
     ENDLOOP.


     lv_max_rows = lv_skip + lv_top.
     IF lv_skip > 0.
       lv_skip = lv_skip + 1.
     ENDIF.

     CLEAR lt_responseout.
     LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>).
       ls_responseout = <lfs_out_line_item>.
       APPEND ls_responseout TO lt_responseout.
     ENDLOOP.

     sort lt_responseout by doc.

     io_response->set_total_number_of_records( lines( lt_response ) ).
     io_response->set_data( lt_responseout ).

  ENDMETHOD.
ENDCLASS.
