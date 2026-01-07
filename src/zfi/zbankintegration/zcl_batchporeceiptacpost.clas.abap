CLASS zcl_batchporeceiptacpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
    METHODS: run,
            post.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BATCHPORECEIPTACPOST IMPLEMENTATION.


METHOD if_apj_dt_exec_object~get_parameters.
  " Return the supported selection parameters here
  et_parameter_def = VALUE #(
    ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post Bank Receipts'   lowercase_ind = abap_true changeable_ind = abap_true )
  ).

  " Return the default parameters values here
  et_parameter_val = VALUE #(
    ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post Bank Receipts' )

  ).

ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    run(  ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    run(  ).
  ENDMETHOD.


  METHOD post.

    SELECT * FROM zr_bankreceipt
      WHERE Isdeleted = ''
        AND Isposted = ''
      INTO TABLE @DATA(tt_json_structure).

    LOOP AT tt_json_structure INTO DATA(wa).

      wa-Creditdatetime = wa-Creditdatetime+0(10).
      DATA(psDate) = zcl_bankreceiptaccpost=>checkdateformat( date = CONV string( wa-Creditdatetime ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF zr_bankreceipt
          ENTITY ZrBankreceipt
          UPDATE FIELDS ( Errorlog )
          WITH VALUE #( (
              Errorlog = psDate
              Id = wa-Id

          ) )
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bankreceipt
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(dcDate) = zcl_bankreceiptaccpost=>checkDateFormat( date = CONV string( wa-Creditdatetime ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF zr_bankreceipt
          ENTITY ZrBankreceipt
          UPDATE FIELDS (  Errorlog )
          WITH VALUE #( (
              Errorlog = dcDate
               Id = wa-Id

          ) )
        FAILED lt_failed
        REPORTED lt_reported.

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bankreceipt
        FAILED lt_commit_failed22
        REPORTED lt_commit_reported22.
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(message) = zcl_bankreceiptaccpost=>postCustomerPayment( wa_data = wa psdate = psDate dcdate = dcDate ).

    ENDLOOP.

  ENDMETHOD.


  METHOD run.
    post(  ).
  ENDMETHOD.
ENDCLASS.
