CLASS zbankpayablebatchjob DEFINITION
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



CLASS ZBANKPAYABLEBATCHJOB IMPLEMENTATION.


METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post Bank Payables'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post Bank Payables' )

    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    run(  ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    run(  ).
  ENDMETHOD.


  METHOD post.

    SELECT * FROM zr_bankpayable
      WHERE Isdeleted = ''
        AND Isposted = ''
        AND PayStatus = 'E'
      INTO TABLE @DATA(tt_json_structure).

    LOOP AT tt_json_structure INTO DATA(wa).

      DATA(psDate) = zcl_http_bankpayablepost=>checkdateformat( date = CONV string( wa-PostingDate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF zr_bankpayable
          ENTITY ZrBankpayable
          UPDATE FIELDS ( log )
          WITH VALUE #( (
                log = psDate
                Vutdate         = wa-Vutdate
                Unit            = wa-Unit
                Vutacode        = wa-Vutacode
                Createdtime     = wa-Createdtime
                InstructionRefNum = wa-InstructionRefNum


          ) )
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bankpayable
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(dcDate) = zcl_http_bankpayablepost=>checkDateFormat( date = CONV string( wa-PostingDate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF zr_bankpayable
          ENTITY ZrBankpayable
          UPDATE FIELDS (  log )
          WITH VALUE #( (
                log = dcDate
                Vutdate         = wa-Vutdate
                Unit            = wa-Unit
                Vutacode        = wa-Vutacode
                Createdtime     = wa-Createdtime
                InstructionRefNum = wa-InstructionRefNum


          ) )
        FAILED lt_failed
        REPORTED lt_reported.

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bankpayable
        FAILED lt_commit_failed22
        REPORTED lt_commit_reported22.
        COMMIT ENTITIES END.


        RETURN.
      ENDIF.

      DATA(message) = zcl_http_bankpayablepost=>postSupplierPayment( wa_data = wa psdate = psDate dcdate = dcDate ).

    ENDLOOP.

  ENDMETHOD.


  METHOD run.
    post(  ).
  ENDMETHOD.
ENDCLASS.
