CLASS LHC_ZR_BANKSTMT DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zrbankstmt
        RESULT result,
      earlynumbering_bankstmt FOR NUMBERING
        IMPORTING entities FOR CREATE zrbankstmt,
      earlynumbering_bankstmtline FOR NUMBERING
        IMPORTING entities FOR CREATE zrbankstmt\_statementlines,
      addLineNum FOR DETERMINE ON SAVE
          IMPORTING keys FOR ZrBankstmtlines~addLineNum.
*      Methods saveStatementLine FOR VALIDATE ON SAVE
*          IMPORTING keys FOR ZrBankstmtlines~saveStatementLine.
     METHODS checkUniqueBankPeriod FOR VALIDATE ON SAVE
          IMPORTING keys FOR ZrBankstmt~checkUniqueBankPeriod.
      METHODS deletionOrder FOR MODIFY
          IMPORTING keys FOR ACTION ZrBankstmt~deletionOrder.


  ENDCLASS.

CLASS LHC_ZR_BANKSTMT IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.


  METHOD earlynumbering_bankstmt.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<bank_stmt_header>).

      TRY.

          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '10'
              object      = 'ZBNKSTMTID'
            IMPORTING
              number      = DATA(nextnumber)
          ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          DATA(message) = lx_number_ranges->get_text( ).

      ENDTRY.
      SHIFT nextnumber LEFT DELETING LEADING '0'.
    ENDLOOP.

    "assign Gate Entry no.
    APPEND CORRESPONDING #( <bank_stmt_header> ) TO mapped-zrbankstmt ASSIGNING FIELD-SYMBOL(<mapped_bank_stmt_header>).
    IF <bank_stmt_header>-StatementID IS INITIAL.
      <mapped_bank_stmt_header>-StatementID = nextnumber.
    ENDIF.
  ENDMETHOD.



  METHOD earlynumbering_bankstmtline.
    READ ENTITIES OF zr_bankstmt IN LOCAL MODE
      ENTITY ZrBankstmt BY \_StatementLines
        FIELDS ( LineNum )
          WITH CORRESPONDING #( entities )
          RESULT DATA(bank_stmt_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<bank_stmt_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR bank_stmt_line IN bank_stmt_lines "USING KEY entity WHERE ( StatementID = <bank_stmt_header>-StatementID )
                                    NEXT max = COND posnr( WHEN bank_stmt_line-LineNum > max
                                                           THEN bank_stmt_line-LineNum
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Gate Entry Item id
    LOOP AT <bank_stmt_header>-%target ASSIGNING FIELD-SYMBOL(<bank_stmt_line>).
      APPEND CORRESPONDING #( <bank_stmt_line> ) TO mapped-zrbankstmtlines ASSIGNING FIELD-SYMBOL(<mapped_bank_stmt_line>).
      IF <bank_stmt_line>-LineNum IS INITIAL.
        max_item_id += 1.
        <mapped_bank_stmt_line>-VoucherNo = |{ <bank_stmt_line>-StatementID }-{ max_item_id }|.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

 METHOD addlinenum.

   READ ENTITIES OF zr_bankstmt IN LOCAL MODE
     ENTITY zrbankstmt BY \_statementlines
         FIELDS ( voucherno )
         WITH CORRESPONDING #( keys )
         RESULT DATA(bank_stmt_lines)
         FAILED DATA(failed).

   LOOP AT keys ASSIGNING FIELD-SYMBOL(<bank_stmt_line>).
     SPLIT <bank_stmt_line>-voucherno AT '-' INTO DATA(statement_id) DATA(line_num).

     MODIFY ENTITIES OF zr_bankstmt IN LOCAL MODE
        ENTITY zrbankstmtlines
        UPDATE FIELDS ( linenum )
        WITH VALUE #( (
            linenum = line_num
            statementid = <bank_stmt_line>-statementid
            voucherno = <bank_stmt_line>-voucherno ) ).
   ENDLOOP.

 ENDMETHOD.

METHOD checkUniqueBankPeriod.

  READ ENTITIES OF zr_bankstmt IN LOCAL MODE
    ENTITY zrbankstmt
    FIELDS ( Bankcode Fromdate Todate Bankname )
    WITH CORRESPONDING #( keys )
    RESULT DATA(statements).



  LOOP AT statements ASSIGNING FIELD-SYMBOL(<stmt>).

    SELECT SINGLE statement_id
      FROM zbankstmt
      WHERE bankcode = @<stmt>-bankcode
        AND fromdata <= @<stmt>-todate
        AND todate   >= @<stmt>-fromdate
      INTO @DATA(lv_existing).

    IF lv_existing IS NOT INITIAL .
      APPEND VALUE #(
          %tky = <stmt>-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = |Bank { <stmt>-bankname } { <stmt>-Bankcode } already has overlapping statement period| ) )
        TO reported-zrbankstmt.

      APPEND VALUE #( %tky = <stmt>-%tky ) TO failed-zrbankstmt.
    ENDIF.

  ENDLOOP.

ENDMETHOD.

METHOD deletionOrder.

 READ ENTITIES OF zr_bankstmt IN LOCAL MODE
     ENTITY zrbankstmt
         FIELDS ( Status StatementID Bankcode )
         WITH CORRESPONDING #( keys )
         RESULT DATA(bank_details)
         FAILED DATA(failed2).

  DATA(bankcode) =  bank_details[ 1 ]-Bankcode.
  DATA(status) =  bank_details[ 1 ]-Status.
  IF status = 'OPEN'.

  SELECT MAX( todate )
  FROM zr_bankstmt
  WHERE bankcode = @bankcode AND status = 'OPEN'
  INTO @DATA(lv_max_date).

  SELECT MAX( todate )
  FROM zr_bankstmt
  WHERE bankcode = @bankcode AND status = 'CLOSED' OR status = 'HOLD'
  INTO @DATA(lv_closed_date).

  IF sy-subrc <> 0.
      CLEAR lv_closed_date.
    ENDIF.

  IF bank_details[ 1 ]-Todate = lv_max_date AND lv_max_date > lv_closed_date.

  ELSE.

  APPEND VALUE #( %tky = bank_details[ 1 ]-%tky
                      %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |Delete not allowed. Statement { bank_details[ 1 ]-StatementID } is not the latest OPEN period.| ) )
             TO reported-zrbankstmt.

  APPEND VALUE #( %tky = bank_details[ 1 ]-%tky ) TO failed-zrbankstmt.
  ENDIF.

  ELSE.
 APPEND VALUE #( %tky = bank_details[ 1 ]-%tky
                    %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = |Only OPEN statements can be deleted.| ) )
           TO reported-zrbankstmt.

 APPEND VALUE #( %tky = bank_details[ 1 ]-%tky ) TO failed-zrbankstmt.
  ENDIF.

ENDMETHOD.

*METHOD saveStatementLine.
*
*LOOP AT keys INTO DATA(ls_key).
*   SELECT SINGLE dates
*      FROM zr_bankstmtlines
*      WHERE statementid = @ls_key-StatementID
*      INTO @DATA(lv_date).
*
*    SELECT SINGLE fromdate, todate
*      FROM zr_bankstmt
*      WHERE statementid = @ls_key-StatementID
*      INTO @DATA(date_defn).
*
*    IF lv_date <= date_defn-todate AND lv_date >= date_defn-fromdate.
*
*    ELSE.
*
* APPEND VALUE #( %tky = ls_key-%tky
*                      %msg = new_message_with_text(
*                                severity = if_abap_behv_message=>severity-error
*                                text     = |Date not within header validity period.| ) )
*             TO reported-zrbankstmtlines.
*
*      APPEND VALUE #( %tky = ls_key-%tky )
*             TO failed-zrbankstmtlines.
*
*ENDIF.
*ENDLOOP.
*ENDMETHOD.

ENDCLASS.
