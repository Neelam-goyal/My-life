CLASS zcl_clearjournal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    TYPES: BEGIN OF ty_transtomain,
             amount           TYPE zr_booktrans-amount,
             assignmentref    TYPE zr_booktrans-assignmentref,
             clearedvoucherno TYPE zr_booktrans-clearedvoucherno,
             voucherno        TYPE zr_booktrans-voucherno,
             glaccount        TYPE zr_booktrans-glaccount,
             maingl           TYPE zr_brstable-maingl,
             compcode         TYPE zr_brstable-compcode,
             dates            TYPE zr_booktrans-dates,
             housebank        TYPE zr_brstable-housebank,
             accountid        TYPE i_housebankaccountlinkage-housebankaccount,
             profitcenter     TYPE zr_brstable-profitcenter,
             paymenttype      TYPE zr_booktrans-paymenttype,
           END OF ty_transtomain.

    CLASS-METHODS:
      runjob
        IMPORTING paramcmno TYPE c,
      savelogs
        IMPORTING
          id_severity TYPE cl_bali_free_text_setter=>ty_severity
          message     TYPE STRING,
      getcid
        RETURNING
          VALUE(cid) TYPE abp_behv_cid,
      savedata,
      createassignementref,
      posttransgltomaingl
        IMPORTING
          wa_data TYPE ty_transtomain
        RETURNING
          VALUE(message) TYPE STRING,
      updateutrindocument
        IMPORTING
          accountingdocument TYPE c
          fiscalyear         TYPE gjahr
          companycode        TYPE bukrs
          utr                TYPE c
        RETURNING
          VALUE(message)     TYPE string.


    CLASS-DATA: lo_log     TYPE REF TO if_bali_log,
                bankrecoid TYPE zr_bankreco-bankrecoid.

PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CLEARJOURNAL IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = ''   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA p_descr TYPE c LENGTH 80.

    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
    runjob( p_descr ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runjob( '' ).
  ENDMETHOD.


    METHOD runjob.

      TRY.
          lo_log = cl_bali_log=>create( ).
        CATCH cx_bali_runtime.
          DATA(message) = 'Error in Log Creation'.
      ENDTRY.
      SELECT FROM zr_bankreco
      FIELDS bankrecoid
      WHERE status NE 'Posted'
      INTO TABLE @DATA(lt_bankreco).

      LOOP AT lt_bankreco INTO DATA(ls_bankreco).
        bankrecoid = ls_bankreco-bankrecoid.
        savedata( ).
      ENDLOOP.

      TRY.
          cl_bali_log_db=>get_instance( )->save_log( log                        = lo_log
                                                assign_to_current_appl_job = abap_true ).
        CATCH cx_bali_runtime.
          message = 'Error in Log Save'.
      ENDTRY.

    ENDMETHOD.


  METHOD getcid.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


METHOD savelogs.
  DATA: lo_free TYPE REF TO if_bali_free_text_setter,
        err     TYPE c LENGTH 200.
  err = message.
  lo_free = cl_bali_free_text_setter=>create( severity = id_severity
                                              text     = err ).
  TRY.
      lo_log->add_item( lo_free ).
    CATCH cx_bali_runtime.
      err = 'Error in Log Item Creation'.
  ENDTRY.
ENDMETHOD.


  METHOD savedata.
    createassignementref(  ).

    SELECT FROM zr_booktrans AS a
    INNER JOIN zr_bankreco AS b ON a~bankrecoid = b~bankrecoid
    INNER JOIN zr_brstable AS c ON b~bank = c~Accountcode AND b~Company = c~CompCode
    INNER JOIN i_housebankaccountlinkage AS d ON d~housebank = c~housebank AND d~companycode = c~compcode
    INNER JOIN i_journalentryitem AS e ON e~glaccount = a~glaccount AND e~companycode = c~compcode
                                          AND e~accountingdocument = a~voucherno AND e~FiscalYear = a~Fiscalyear
                                          AND e~SourceLedger = '0L'
    FIELDS a~amount, a~assignmentref, a~clearedvoucherno, a~voucherno, a~glaccount, c~maingl, c~compcode,
           a~dates, c~housebank, d~housebankaccount, c~ProfitCenter, a~Paymenttype
    WHERE b~bankrecoid = @bankrecoid
          AND a~cleardoc1 IS INITIAL
          AND a~cleardoc2 IS INITIAL
          AND b~Status = 'Released'
    INTO TABLE @DATA(lt_booktrans).

    LOOP AT lt_booktrans INTO DATA(ls_booktrans).
      DATA(message)    =    posttransgltomaingl( ls_booktrans ).
      IF message IS NOT INITIAL.
        savelogs( id_severity = if_bali_constants=>c_severity_error message = message ).
        CONTINUE.
      ENDIF.
    ENDLOOP.

*   Post 2nd Document against main GL for Clearing (SU)
*    SELECT FROM zr_booktrans AS a
*    INNER JOIN zr_bankreco AS b ON a~bankrecoid = b~bankrecoid
*    INNER JOIN zr_bankglmapping AS c ON b~bank = c~accid
*    INNER JOIN i_housebankaccountlinkage AS d ON d~housebank = c~housebank AND d~companycode = c~compcode
*    INNER JOIN i_journalentryitem AS e ON e~glaccount = a~glaccount AND e~companycode = c~compcode
*                                          AND e~accountingdocument = a~voucherno
*    FIELDS a~amount, a~assignmentref, a~clearedvoucherno, a~voucherno, a~glaccount, c~maingl, c~compcode,
*           a~dates, c~housebank, d~housebankaccount, e~profitcenter
*    WHERE b~bankrecoid = @bankrecoid
*          AND a~cleardoc2 IS INITIAL
*    INTO TABLE @DATA(lt_booktrans2).
*
*
*    LOOP AT lt_booktrans INTO DATA(ls_booktrans2).
*      message    =    postclearingdoc( ls_booktrans ).
*      IF message IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*    ENDLOOP.


*   Check that all vouchers are cleared and then update status in bankreco
    SELECT SINGLE FROM zr_booktrans
    FIELDS COUNT( bankrecoid ) AS ct1
    WHERE bankrecoid = @bankrecoid
          AND cleardoc1 IS INITIAL
    INTO @DATA(lv_count).

    IF lv_count IS INITIAL.

      MODIFY ENTITIES OF zr_bankreco
         ENTITY zrbankreco
         UPDATE FIELDS ( status )
         WITH VALUE #(  (
                bankrecoid = bankrecoid
                status = 'Posted'
             )  )
         FAILED DATA(lt_failed)
         REPORTED DATA(lt_reported).

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_bankreco
      FAILED DATA(lt_commit_failed2)
      REPORTED DATA(lt_commit_reported2).

      ...
      COMMIT ENTITIES END.

    ENDIF.

    MESSAGE = 'Clearing Process Completed'.

  ENDMETHOD.


  METHOD updateutrindocument.

    DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change,
          document   TYPE string.

    SELECT SINGLE FROM i_journalentryitem
    FIELDS customer, supplier, glaccount, ledgergllineitem
    WHERE accountingdocument = @accountingdocument
          AND companycode = @companycode
          AND fiscalyear = @fiscalyear
          AND sourceledger = '0L'
          AND ( customer IS NOT INITIAL OR supplier IS NOT INITIAL )
    INTO @DATA(lt_je_item).

    IF lt_je_item IS NOT INITIAL.

    SELECT SINGLE FROM i_journalentryitem
     FIELDS ledgergllineitem
     WHERE accountingdocument = @accountingdocument
           AND companycode = @companycode
           AND fiscalyear = @fiscalyear
           AND sourceledger = '0L'
           AND ( customer IS INITIAL AND supplier IS INITIAL )
     INTO @DATA(lt_je_item2).

      APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
      <je_deep>-accountingdocument = accountingdocument.
      <je_deep>-companycode        = companycode.
      <je_deep>-fiscalyear         = fiscalyear.
      <je_deep>-%param = VALUE #(
              _aparitems = VALUE #( (
                                      assignmentreference = utr
                                      glaccountlineitem = lt_je_item-ledgergllineitem
                                      %control-assignmentreference = cl_abap_behv=>flag_changed
                                    )
                                  )
              _glitems = VALUE #(
                              (
                                  assignmentreference = utr
                                  glaccountlineitem = lt_je_item2
                                  %control-assignmentreference = cl_abap_behv=>flag_changed
                                )
                            )
       ).
    ELSE.

      SELECT  FROM i_journalentryitem
     FIELDS customer, supplier, glaccount, ledgergllineitem
     WHERE accountingdocument = @accountingdocument
           AND companycode = @companycode
           AND fiscalyear = @fiscalyear
           AND sourceledger = '0L'
     INTO TABLE @DATA(lt_je_items).


      APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep1>).
      <je_deep1>-accountingdocument = accountingdocument.
      <je_deep1>-companycode        = companycode.
      <je_deep1>-fiscalyear         = fiscalyear.
      <je_deep1>-%param = VALUE #(
              _glitems = VALUE #( FOR ls_je_items IN lt_je_items (
                                      assignmentreference = utr
                                      glaccountlineitem = ls_je_items-ledgergllineitem
                                      %control-assignmentreference = cl_abap_behv=>flag_changed
                                    )
                            )
       ).
    ENDIF.




    MODIFY ENTITIES OF i_journalentrytp
    ENTITY journalentry
    EXECUTE change FROM lt_je_deep
    FAILED DATA(ls_failed_deep)
    REPORTED DATA(ls_reported_deep)
    MAPPED DATA(ls_mapped_deep).

    IF ls_failed_deep IS NOT INITIAL.

      LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
        message = <ls_reported_deep>-%msg->if_message~get_text( ).
      ENDLOOP.
      message =  message &&  |For { accountingdocument }-{ companycode }-{ fiscalyear }-{ utr }|.
      savelogs( id_severity = if_bali_constants=>c_severity_error message = message ).
      RETURN.
    ELSE.

      COMMIT ENTITIES BEGIN
      RESPONSE OF i_journalentrytp
      FAILED DATA(lt_commit_failed)
      REPORTED DATA(lt_commit_reported).

      IF lt_commit_failed IS NOT INITIAL.
        LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
          message = <ls_failed>-%fail-cause.
        ENDLOOP.
        message =  message &&  |For { accountingdocument }-{ companycode }-{ fiscalyear }-{ utr }|.
        savelogs( id_severity = if_bali_constants=>c_severity_error message = message ).
        RETURN.
      ENDIF.

      COMMIT ENTITIES END.

    ENDIF.
  ENDMETHOD.


  METHOD createassignementref.

    SELECT FROM zr_booktrans AS a
    INNER JOIN zr_bankreco AS b ON a~bankrecoid = b~bankrecoid
    FIELDS assignmentref, voucherno, clearedvoucherno, cleareddate, b~company, b~fiscalyear
    WHERE a~bankrecoid = @bankrecoid
          AND assignmentref IS INITIAL
          AND clearedvoucherno IS NOT INITIAL
    INTO TABLE @DATA(lt_booktrans).

    DATA refno TYPE C LENGTH 18.
    LOOP AT lt_booktrans INTO DATA(ls_booktrans).


      SELECT SINGLE FROM zr_statementtrans
      FIELDS utr, voucherno, statementid
      WHERE voucherno = @ls_booktrans-clearedvoucherno
            AND dates = @ls_booktrans-cleareddate
            AND bankrecoid = @bankrecoid
      INTO @DATA(ls_statementtrans).

      IF ls_statementtrans-utr IS NOT INITIAL.
        refno = ls_statementtrans-utr.
      ELSE.
        refno = |CLR{ sy-tabix }-{ ls_statementtrans-statementid }|.
      ENDIF.


      DATA(valid) = updateutrindocument(
                                            accountingdocument = ls_booktrans-voucherno
                                            companycode        = ls_booktrans-company
                                            fiscalyear         = ls_booktrans-fiscalyear
                                            utr                = refno
                                       ).

      IF valid IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_booktrans_001
         ENTITY zrbooktrans001
         UPDATE FIELDS ( assignmentref )
         WITH VALUE #(  (
                bankrecoid = bankrecoid
                voucherno = ls_booktrans-voucherno
                assignmentref = refno
             )  )
         FAILED DATA(lt_failed)
         REPORTED DATA(lt_reported).

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_booktrans_001
      FAILED DATA(lt_commit_failed2)
      REPORTED DATA(lt_commit_reported2).

      ...
      COMMIT ENTITIES END.

      MODIFY ENTITIES OF zr_statementtrans_001
        ENTITY zrstatementtrans001
        UPDATE FIELDS ( utr )
        WITH VALUE #(  (
               bankrecoid = bankrecoid
               voucherno = ls_booktrans-voucherno
               statementid = ls_statementtrans-statementid
               utr = refno
            )  )
        FAILED DATA(lt_failed1)
        REPORTED DATA(lt_reported1).

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_statementtrans_001
      FAILED DATA(lt_commit_failed21)
      REPORTED DATA(lt_commit_reported21).

      ...
      COMMIT ENTITIES END.
      CLEAR refno.
    ENDLOOP.

    SELECT FROM zr_statementtrans AS a
     INNER JOIN zr_bankreco AS b ON a~bankrecoid = b~bankrecoid
   FIELDS utr, voucherno, clearedvoucherno, statementid, b~company, b~fiscalyear
   WHERE a~bankrecoid = @bankrecoid
         AND utr IS INITIAL
         AND clearedvoucherno IS NOT INITIAL
   INTO TABLE @DATA(lt_stmttrans).

    LOOP AT lt_stmttrans INTO DATA(ls_stmttrans).

      SELECT SINGLE FROM zr_booktrans
      FIELDS assignmentref, voucherno, clearedvoucherno
      WHERE voucherno = @ls_stmttrans-clearedvoucherno
            AND bankrecoid = @bankrecoid
      INTO @DATA(lw_booktrans).

      IF lw_booktrans-assignmentref IS NOT INITIAL.
        refno = lw_booktrans-assignmentref.
      ELSE.
        refno = |CLR{ sy-tabix }-{ lw_booktrans-voucherno }|.
      ENDIF..

      valid = updateutrindocument(
                                           accountingdocument = ls_stmttrans-ClearedVoucherno
                                           companycode        = ls_stmttrans-company
                                           fiscalyear         = ls_stmttrans-fiscalyear
                                           utr                = refno
                                      ).

      IF valid IS NOT INITIAL.
        CONTINUE.
      ENDIF.


      MODIFY ENTITIES OF zr_booktrans_001
         ENTITY zrbooktrans001
         UPDATE FIELDS ( assignmentref )
         WITH VALUE #(  (
                bankrecoid = bankrecoid
                voucherno = ls_booktrans-voucherno
                assignmentref = refno
             )  )
         FAILED lt_failed
         REPORTED lt_reported.

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_booktrans_001
      FAILED lt_commit_failed2
      REPORTED lt_commit_reported2.

      ...
      COMMIT ENTITIES END.

      MODIFY ENTITIES OF zr_statementtrans_001
        ENTITY zrstatementtrans001
        UPDATE FIELDS ( utr )
        WITH VALUE #(  (
               bankrecoid = bankrecoid
               voucherno = ls_booktrans-voucherno
               statementid = ls_statementtrans-statementid
               utr = refno
            )  )
        FAILED lt_failed1
        REPORTED lt_reported1.

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_statementtrans_001
      FAILED lt_commit_failed21
      REPORTED lt_commit_reported21.

      ...
      COMMIT ENTITIES END.
      CLEAR refno.
    ENDLOOP.


  ENDMETHOD.


  METHOD posttransgltomaingl.
    DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          document   TYPE string.


    APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
    <je_deep>-%cid = getcid(  ).
    <je_deep>-%param = VALUE #(
        companycode = wa_data-compcode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'SA'
*        accountingdocumentheadertext = wa_data-gltext
        documentdate = wa_data-dates
        CreatedByUser = sy-uname
        postingdate = cl_abap_context_info=>get_system_date( )
        _glitems = VALUE #(
                            (
                                glaccountlineitem = |001|
                                glaccount = wa_data-maingl
                                housebank = wa_data-housebank
                                housebankaccount = wa_data-accountid
                                assignmentreference = wa_data-assignmentref
*                               documentitemtext = wa_data-gltext
                                profitcenter = wa_data-profitcenter
                                _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-amount
                                                    currency = 'INR' ) )
                            )
                            (
                                glaccountlineitem = |002|
                                glaccount = wa_data-glaccount
                                housebank = wa_data-housebank
                                housebankaccount = wa_data-accountid
                                assignmentreference = wa_data-assignmentref
*                               documentitemtext = wa_data-gltext
                                profitcenter = wa_data-profitcenter
                                _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-amount * -1
                                                    currency = 'INR' ) )
                             )
                          )
     ).

    MODIFY ENTITIES OF i_journalentrytp
    ENTITY journalentry
    EXECUTE post FROM lt_je_deep
    FAILED DATA(ls_failed_deep)
    REPORTED DATA(ls_reported_deep)
    MAPPED DATA(ls_mapped_deep).

    IF ls_failed_deep IS NOT INITIAL.

      LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
        message = <ls_reported_deep>-%msg->if_message~get_text( ).
      ENDLOOP.
      message =  message &&  |For { wa_data-dates }-{ wa_data-maingl }-{ wa_data-glaccount }-{ wa_data-assignmentref }|.
      savelogs( id_severity = if_bali_constants=>c_severity_error message = message ).
      RETURN.
    ELSE.

      COMMIT ENTITIES BEGIN
      RESPONSE OF i_journalentrytp
      FAILED DATA(lt_commit_failed)
      REPORTED DATA(lt_commit_reported).

      IF lt_commit_reported IS NOT INITIAL.
        LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
          document = <ls_reported>-accountingdocument.
        ENDLOOP.
      ELSE.
        LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
          message = <ls_failed>-%fail-cause.
        ENDLOOP.
        message =  message &&  |For { wa_data-dates }-{ wa_data-maingl }-{ wa_data-glaccount }-{ wa_data-assignmentref }|.
        savelogs( id_severity = if_bali_constants=>c_severity_error message = message ).
        RETURN.
      ENDIF.

      COMMIT ENTITIES END.


      IF document IS NOT INITIAL.
*        message = |Document Created Successfully: { document }|.
        MODIFY ENTITIES OF zr_booktrans_001
        ENTITY zrbooktrans001
        UPDATE FIELDS ( cleardoc1 )
        WITH VALUE #(  (
               bankrecoid = bankrecoid
               voucherno = wa_data-voucherno
               cleardoc1 = document
            )  )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_booktrans_001
        FAILED DATA(lt_commit_failed2)
        REPORTED DATA(lt_commit_reported2).

        ...
        COMMIT ENTITIES END.
      ELSE.
        message = |Document Creation Failed: { message }|.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
