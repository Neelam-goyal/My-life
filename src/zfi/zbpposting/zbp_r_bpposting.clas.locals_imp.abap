CLASS LHC_ZR_BPPOSTING DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrBpposting
        RESULT result.


    METHODS falsedelete FOR MODIFY
      IMPORTING keys FOR ACTION ZrBpposting~falsedelete.
    METHODS approveData FOR MODIFY
      IMPORTING keys FOR ACTION  ZrBpposting~approveData.
    CLASS-METHODS convertIST
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(ist_str) TYPE string.

ENDCLASS.

CLASS LHC_ZR_BPPOSTING IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.


  METHOD falsedelete.

    MODIFY ENTITIES OF zr_bpposting IN LOCAL MODE
            ENTITY ZrBpposting
            UPDATE FIELDS ( Isdeleted )
            WITH VALUE #( FOR key IN keys INDEX INTO i (
                %tky       = key-%tky
                Isdeleted = abap_true
              ) )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).



  ENDMETHOD.

  METHOD approveData.
    LOOP AT keys INTO DATA(wa).

      DATA(curr_time) = cl_abap_context_info=>get_system_time( ).
      DATA(curr_date) = cl_abap_context_info=>get_system_date( ).

      DATA(ist_str) = convertIST( stime = curr_time sdate = curr_date ).


      MODIFY ENTITIES OF zr_bpposting IN LOCAL MODE
       ENTITY ZrBpposting
         UPDATE FIELDS ( approvedby approvedat )
         WITH VALUE #(
           ( %tky = wa-%tky
             approvedby         = sy-uname
             approvedat         = ist_str )
         )
       FAILED DATA(ls_failed)
       REPORTED DATA(ls_reported).

      IF ls_failed IS NOT INITIAL.
        APPEND VALUE #(
              %tky = wa-%tky
              %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Entry not approved.| )
             ) TO reported-ZrBpposting.

        APPEND VALUE #( %tky = wa-%tky )
          TO failed-ZrBpposting.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD convertIST.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>tstmp2utclong
      EXPORTING
        timestamp = timestamp
      RECEIVING
        utclong   = ist_str.

  ENDMETHOD.

ENDCLASS.
