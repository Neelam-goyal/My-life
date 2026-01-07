CLASS LHC_ZR_LOANMASTER DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrLoanmaster
        RESULT result.

  METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZrLoanmaster RESULT result.


     METHODS changeValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrLoanmaster~changeValues.

    METHODS earlynumbering_loanmaster FOR NUMBERING
      IMPORTING entities FOR CREATE ZrLoanmaster.

      METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE  ZrLoanmaster.

      METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION ZrLoanmaster~Approve.

ENDCLASS.

CLASS LHC_ZR_LOANMASTER IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA: update_requested TYPE abap_boolean,
          delete_requested TYPE abap_boolean.

    READ ENTITIES OF zr_loanmaster IN LOCAL MODE
    ENTITY ZrLoanmaster
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(GateEntryHeaders)
    FAILED failed.

    CHECK GateEntryHeaders IS NOT INITIAL.

    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                  THEN abap_true ELSE abap_false ).
    delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                  THEN abap_true ELSE abap_false ).

    LOOP AT GateEntryHeaders ASSIGNING FIELD-SYMBOL(<lfs_gateheader>).
      IF update_requested = abap_true OR delete_requested = abap_true.
        IF <lfs_gateheader>-Approved = abap_true.

          APPEND VALUE #( %tky = <lfs_gateheader>-%tky ) TO failed-zrloanmaster.

          APPEND VALUE #( %tky = <lfs_gateheader>-%tky
                          %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = 'Cannot Change or delete Document.'
                          ) ) TO reported-zrloanmaster.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.



    METHOD changeValues.

      READ ENTITIES OF zr_loanmaster IN LOCAL MODE
        ENTITY ZrLoanmaster
        FIELDS ( LoanAmount InterestAmount LoanType )
        WITH CORRESPONDING #( keys )
        RESULT DATA(advlicenses).

      LOOP AT advlicenses INTO DATA(exportline).

        IF exportline-LoanType = 'ADVANCE'.
          MODIFY ENTITIES OF zr_loanmaster IN LOCAL MODE
         ENTITY ZrLoanmaster
         UPDATE
         FIELDS ( BalanceAmount TotalAmount EMICount ) WITH VALUE #( ( %tky = exportline-%tky
                       EMICount = 1
                       BalanceAmount = exportline-InterestAmount + exportline-LoanAmount
                       TotalAmount = exportline-InterestAmount + exportline-LoanAmount
                       ) ).
        ELSE.
          MODIFY ENTITIES OF zr_loanmaster IN LOCAL MODE
            ENTITY ZrLoanmaster
            UPDATE
            FIELDS ( BalanceAmount TotalAmount ) WITH VALUE #( ( %tky = exportline-%tky
                          BalanceAmount = exportline-InterestAmount + exportline-LoanAmount
                          TotalAmount = exportline-InterestAmount + exportline-LoanAmount
                          ) ).
        ENDIF.

      ENDLOOP.
    ENDMETHOD.

  METHOD earlynumbering_loanmaster.


    DATA: nr_number     TYPE cl_numberrange_runtime=>nr_number.
    DATA nextnumber TYPE zr_loanmaster-loanno.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).

        DATA Lnm TYPE zr_loanmaster-loanno.

        SELECT loanno FROM zr_loanmaster
        ORDER BY loanno DESCENDING
        INTO TABLE @DATA(LastNo)
        UP TO 1 ROWS .

        LOOP AT LastNo INTO DATA(NextNum).
             Lnm = NextNum-LoanNo.
        ENDLOOP.

        IF sy-subrc = 0.
          nextnumber = CONV zr_loanmaster-loanno( |{ Lnm + 1 }| ).
        ELSE.
          nextnumber = '1000000001'.
        ENDIF.


        SHIFT nextnumber LEFT DELETING LEADING '0'.
    ENDLOOP.

    "assign Gate Entry no.
    APPEND CORRESPONDING #( <gate_entry_header> ) TO mapped-zrloanmaster ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_header>).
    IF <gate_entry_header>-LoanNo IS INITIAL.
"      max_item_id += 10.
      <mapped_gate_entry_header>-LoanNo =  nextnumber.
    ENDIF.


  ENDMETHOD.

  METHOD precheck_create.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<loan>).

        SELECT SINGLE FROM zr_loantype
        FIELDS ( Value )
        WHERE Value = @<loan>-LoanType
        INTO @DATA(LoanType).

        IF LOANTYPE IS INITIAL.
          APPEND VALUE #( %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'Loan Type is not valid.' )
                            ) to reported-zrloanmaster.
        ENDIF.

        SELECT SINGLE FROM zr_paymentmode
        FIELDS ( Value )
        WHERE Value = @<loan>-PaymentMode
        INTO @DATA(PaymentMode).

        IF PaymentMode IS INITIAL.
          APPEND VALUE #( %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'Payment Mode is not valid.' )
                            ) to reported-zrloanmaster.
        ENDIF.



*        IF <loan>-EMICount = 0 .
*        APPEND VALUE #( %msg = new_message_with_text(
*                          severity = if_abap_behv_message=>severity-error
*                          text = 'EMI Count cannot be 0.' )
*                          ) to reported-zrloanmaster.
*        ENDIF.

    ENDLOOP.

   ENDMETHOD.

 METHOD Approve.

   READ ENTITIES OF zr_loanmaster IN LOCAL MODE
       ENTITY ZrLoanmaster
       FIELDS ( LoanNo CompCode Approved )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lv_loanschedule).

   LOOP AT lv_loanschedule INTO DATA(wa_loanschedule).

     IF wa_loanschedule-Approved NE abap_true.

       MODIFY ENTITIES OF zr_loanmaster IN LOCAL MODE
           ENTITY ZrLoanmaster
           UPDATE FIELDS ( Approved ApprovedBy )
           WITH VALUE #( (
               %tky       = wa_loanschedule-%tky
               Approved = abap_true
               ApprovedBy = sy-uname
             ) )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).
     ENDIF.
   ENDLOOP.

   APPEND VALUE #( %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text = 'Approved.' )
                     ) TO reported-zrloanmaster.
   RETURN.
 ENDMETHOD.

ENDCLASS.
