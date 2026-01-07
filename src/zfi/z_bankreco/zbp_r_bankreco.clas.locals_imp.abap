CLASS LHC_ZR_BANKRECO DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrBankreco
        RESULT result,
     earlynumbering_bankreco FOR NUMBERING
      IMPORTING entities FOR CREATE ZrBankreco.
*    earlynumbering_gpl FOR NUMBERING
*      IMPORTING entities FOR CREATE ZrGatepassheader\_GatePassLine.
      METHODS validateData FOR MODIFY
      IMPORTING keys FOR ACTION ZrBankreco~validateData.
        METHODS utrBasedReco FOR MODIFY
      IMPORTING keys FOR ACTION ZrBankreco~utrBasedReco.
        METHODS deleteRecords FOR MODIFY
      IMPORTING keys FOR ACTION ZrBankreco~deleteRecords.

ENDCLASS.

CLASS LHC_ZR_BANKRECO IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.


  METHOD earlynumbering_bankreco.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<bank_reco_header>).

      TRY.

        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '10'
            object      = 'ZBANKRECOD'
          IMPORTING
            number      = DATA(nextnumber)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        DATA(message) = lx_number_ranges->get_text( ).
      ENDTRY.
      SHIFT nextnumber LEFT DELETING LEADING '0'.
    ENDLOOP.

    "assign Gate Entry no.
    APPEND CORRESPONDING #( <bank_reco_header> ) TO mapped-zrbankreco ASSIGNING FIELD-SYMBOL(<mapped_bank_reco_header>).
    IF <bank_reco_header>-Bankrecoid IS INITIAL.
      <mapped_bank_reco_header>-Bankrecoid = |{ nextnumber }|.
    ENDIF.


  ENDMETHOD.

 METHOD utrbasedreco.

   LOOP AT keys INTO DATA(ls_key).

     SELECT DISTINCT utr FROM zr_statementtrans
        WHERE bankrecoid = @ls_key-bankrecoid
        AND utr IS NOT INITIAL
        INTO TABLE @DATA(lt_booktrans).

     IF lt_booktrans IS INITIAL.
       CONTINUE.
     ENDIF.

     LOOP AT lt_booktrans INTO DATA(lv_utr).

       SELECT FROM zr_statementtrans
        FIELDS amount, voucherno, dates, statementid
        WHERE bankrecoid = @ls_key-bankrecoid
              AND utr = @lv_utr-utr
        INTO TABLE @DATA(ls_statement).

       IF strlen( lv_utr-utr ) > 10.
         DATA(rem_utr10) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 10
                                      len = 10 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 11.
         DATA(rem_utr11) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 11
                                      len = 11 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 12.
         DATA(rem_utr12) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 12
                                      len = 12 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 13.
         DATA(rem_utr13) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 13
                                      len = 13 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 14.
         DATA(rem_utr14) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 14
                                      len = 14 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 15.
         DATA(rem_utr15) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 15
                                      len = 15 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 16.
         DATA(rem_utr16) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 16
                                      len = 16 ).
       ENDIF.

       IF strlen( lv_utr-utr ) > 17.
         DATA(rem_utr17) = substring( val = lv_utr-utr
                                      off = strlen( lv_utr-utr ) - 17
                                      len = 17 ).
       ENDIF.

       SELECT FROM zr_booktrans
       FIELDS amount, voucherno, dates
       WHERE bankrecoid = @ls_key-bankrecoid
            AND ( AssignmentRef = @rem_utr10
               OR AssignmentRef = @rem_utr11
               OR AssignmentRef = @rem_utr12
               OR AssignmentRef = @rem_utr13
               OR AssignmentRef = @rem_utr14
               OR AssignmentRef = @rem_utr15
               OR AssignmentRef = @rem_utr16
               OR AssignmentRef = @rem_utr17
               OR AssignmentRef = @lv_utr-utr )
       INTO TABLE @DATA(ls_book).

       IF lines( ls_book ) IS INITIAL.
         "OR ( lines( ls_statement ) NE lines( ls_book ) ) .
         CONTINUE.
       ENDIF.

       LOOP AT ls_statement INTO DATA(ls_stmt).

         READ TABLE ls_book INTO DATA(ls_bk) WITH KEY amount = ls_stmt-amount.
         IF sy-subrc = 0.

           MODIFY ENTITIES OF zr_statementtrans_001
             ENTITY zrstatementtrans001
             UPDATE FIELDS ( clearedvoucherno  )
             WITH VALUE #(
               ( bankrecoid = ls_key-bankrecoid
                 voucherno = ls_stmt-voucherno
                 statementid = ls_stmt-statementid
                 clearedvoucherno = ls_bk-voucherno
               )
             )
            FAILED   DATA(ls_failed)
            REPORTED DATA(ls_reported).

           MODIFY ENTITIES OF zr_booktrans_001
             ENTITY zrbooktrans001
             UPDATE FIELDS ( clearedvoucherno cleareddate  )
             WITH VALUE #(
               ( bankrecoid = ls_key-bankrecoid
                 voucherno = ls_bk-voucherno
                 clearedvoucherno = ls_stmt-voucherno
                 cleareddate = ls_stmt-dates
               )
             )
            FAILED   DATA(ls_failed1)
            REPORTED DATA(ls_reported1).
         ENDIF.
       ENDLOOP.
     ENDLOOP.
   ENDLOOP.

   APPEND VALUE #(
        %tky = ls_key-%tky
        %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-success
                  text     = |UTR based marking done successfully.| )
     ) TO reported-zrbankreco.



 ENDMETHOD.

METHOD validatedata.

  DATA : sum_trans     TYPE p DECIMALS 4,
         sum_statement TYPE p DECIMALS 4.

  LOOP AT keys INTO DATA(ls_key).
    CLEAR : sum_trans , sum_statement.


    SELECT FROM zr_booktrans
    FIELDS SUM( amount ) AS sum1
    WHERE bankrecoid = @ls_key-bankrecoid
    AND clearedvoucherno <> ''
    INTO @sum_trans.

    SELECT FROM zr_statementtrans
    FIELDS SUM( amount ) AS sum2
    WHERE bankrecoid = @ls_key-bankrecoid
    AND clearedvoucherno <> ''
    INTO @sum_statement.


    IF sum_trans <> sum_statement.

      APPEND VALUE #(
         %tky = ls_key-%tky
         %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Statement not validated.| )
      ) TO reported-zrbankreco.

      APPEND VALUE #( %tky = ls_key-%tky )
        TO failed-zrbankreco.

    ELSE.

      SELECT FROM zr_booktrans
      FIELDS clearedvoucherno, amount , voucherno
      WHERE bankrecoid = @ls_key-bankrecoid
      INTO TABLE @DATA(cleared_trans).

      SELECT FROM zr_statementtrans
        FIELDS clearedvoucherno, amount , voucherno , statementid
        WHERE bankrecoid = @ls_key-bankrecoid
        INTO TABLE @DATA(cleared_statement).


      DATA lt_delete TYPE TABLE FOR DELETE zr_booktrans_001.

      LOOP AT cleared_trans INTO DATA(transaction) WHERE clearedvoucherno = ''.

        APPEND VALUE #(
          bankrecoid = ls_key-bankrecoid
          voucherno  = transaction-voucherno
        ) TO lt_delete.

      ENDLOOP.

      IF lt_delete IS NOT INITIAL.
        MODIFY ENTITIES OF zr_booktrans_001
          ENTITY zrbooktrans001
          DELETE FROM lt_delete
          FAILED   DATA(ls_failed)
          REPORTED DATA(ls_reported).
      ENDIF.

      DATA lt_delete_statement TYPE TABLE FOR DELETE zr_statementtrans_001.
      DATA lt_statementids TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

      LOOP AT cleared_statement INTO DATA(ostatement).

        IF ostatement-clearedvoucherno = ''.
          APPEND VALUE #(
            bankrecoid = ls_key-bankrecoid
            statementid = ostatement-statementid
            voucherno = ostatement-voucherno
          ) TO lt_delete_statement.

        ELSE.

          APPEND ostatement-statementid TO lt_statementids.

          MODIFY ENTITIES OF zr_bankstmt
          ENTITY zrbankstmtlines
          UPDATE FIELDS ( cleared )
          WITH VALUE #(
                  ( statementid = ostatement-statementid
                    voucherno = ostatement-voucherno
                    cleared = 'X'
                  )
          )
          FAILED   DATA(ls_failed1)
          REPORTED DATA(ls_reported1).

        ENDIF.
      ENDLOOP.

      IF lt_delete_statement IS NOT INITIAL.
        MODIFY ENTITIES OF zr_statementtrans_001
          ENTITY zrstatementtrans001
          DELETE FROM lt_delete_statement
          FAILED   DATA(ls_failed_statement)
          REPORTED DATA(ls_reported_statement).
      ENDIF.

      MODIFY ENTITIES OF zr_bankreco IN LOCAL MODE
      ENTITY zrbankreco
      UPDATE FIELDS ( status )
      WITH VALUE #(
        ( bankrecoid = ls_key-bankrecoid
          status     = 'Released'
        )
      ).

      SORT lt_statementids.
      DELETE ADJACENT DUPLICATES FROM lt_statementids.
      LOOP AT lt_statementids INTO DATA(ls_statementid).
        SELECT SINGLE FROM zr_bankstmtlines
          FIELDS voucherno
          WHERE statementid = @ls_statementid
                AND cleared = ''
          INTO @DATA(lv_status).

        IF lv_status IS INITIAL.
          MODIFY ENTITIES OF zr_bankstmt
          ENTITY zrbankstmt
          UPDATE FIELDS ( status )
          WITH VALUE #( FOR ls_statementids IN lt_statementids
                          (
                            status = 'Close'
                            statementid = ls_statementids
                          )
                      )
         .
        ENDIF.

      ENDLOOP.


    ENDIF.

     APPEND VALUE #(
         %tky = ls_key-%tky
         %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Statement validated successfully.| )
      ) TO reported-zrbankreco.

  ENDLOOP.


ENDMETHOD.

   METHOD deleterecords.

     DATA lt_delete TYPE TABLE FOR DELETE zr_bankreco.

     LOOP AT keys INTO DATA(ls_key).

       SELECT SINGLE FROM zr_booktrans
       FIELDS bankrecoid
       WHERE clearedvoucherno IS NOT INITIAL
       AND bankrecoid = @ls_key-bankrecoid
       INTO @DATA(booked_trans).

       SELECT SINGLE  FROM zr_statementtrans
       FIELDS bankrecoid
       WHERE clearedvoucherno IS NOT INITIAL
       AND bankrecoid = @ls_key-bankrecoid
       INTO @DATA(statement_trans).

       IF booked_trans IS NOT INITIAL OR statement_trans IS NOT INITIAL.

         APPEND VALUE #(
              %tky = ls_key-%tky
              %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = | Marked data selected.| )
           ) TO reported-zrbankreco.

         APPEND VALUE #( %tky = ls_key-%tky )
           TO failed-zrbankreco.

       ELSE.

         APPEND VALUE #(
                 bankrecoid = ls_key-bankrecoid
               ) TO lt_delete.


         SELECT FROM zr_statementtrans
         FIELDS voucherno, statementid
         WHERE bankrecoid = @ls_key-bankrecoid
         INTO TABLE @DATA(bstatement_trans).

         DATA lt_statementids TYPE TABLE OF string.
         LOOP AT bstatement_trans INTO DATA(ls_bstatement).

           MODIFY ENTITIES OF zr_bankstmt
                ENTITY zrbankstmtlines
                UPDATE FIELDS ( cleared )
                WITH VALUE #(
                        ( statementid = ls_bstatement-statementid
                          voucherno = ls_bstatement-voucherno
                          cleared = ''
                        )
                )
            FAILED   DATA(ls_failed)
            REPORTED DATA(ls_reported).
           APPEND ls_bstatement-statementid TO lt_statementids.
         ENDLOOP.

         LOOP AT lt_statementids INTO DATA(ls_statementid).
           SELECT SINGLE FROM zr_bankstmtlines
             FIELDS voucherno
             WHERE statementid = @ls_statementid
                   AND cleared = 'X'
             INTO @DATA(lv_status).

           IF lv_status IS INITIAL.
             MODIFY ENTITIES OF zr_bankstmt
             ENTITY zrbankstmt
             UPDATE FIELDS ( status )
             WITH VALUE #(
                             (
                               status = 'Open'
                               statementid = ls_statementid
                             )
                         )
             FAILED   DATA(ls_failed1)
             REPORTED DATA(ls_reported1).
           ENDIF.
         ENDLOOP.
       ENDIF.

     ENDLOOP.

     MODIFY ENTITIES OF zr_bankreco IN LOCAL MODE
     ENTITY  zrbankreco
     DELETE FROM lt_delete
     FAILED  DATA(ls_failed_statement)
     REPORTED DATA(ls_reported_statement).

     APPEND VALUE #(
           %tky = ls_key-%tky
           %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = | Data deleted.| )
        ) TO reported-zrbankreco.

   ENDMETHOD.


ENDCLASS.
