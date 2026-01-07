CLASS LHC_ZR_OIPAYMENTS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrOipayments
        RESULT result.

    METHODS falsedelete FOR MODIFY
      IMPORTING keys FOR ACTION ZrOipayments~falsedelete.
    METHODS approveData FOR MODIFY
      IMPORTING keys FOR ACTION  ZrOipayments~approveData.
    CLASS-METHODS convertIST
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(ist_str) TYPE string.


  ENDCLASS.

CLASS lhc_zr_oipayments IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD falsedelete.

    MODIFY ENTITIES OF zr_oipayments IN LOCAL MODE
            ENTITY ZrOipayments
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


      MODIFY ENTITIES OF zr_oipayments IN LOCAL MODE
       ENTITY ZrOipayments
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
             ) TO reported-zroipayments.

        APPEND VALUE #( %tky = wa-%tky )
          TO failed-zroipayments.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD convertIST.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

*    CALL METHOD cl_abap_tstmp=>add
*      EXPORTING
*        tstmp   = timestamp
*        secs    = 19800 " 5 hours 30 minutes in seconds
*      RECEIVING
*        r_tstmp = timestamp.

    CALL METHOD cl_abap_tstmp=>tstmp2utclong
      EXPORTING
        timestamp = timestamp
      RECEIVING
        utclong   = ist_str.

  ENDMETHOD.


ENDCLASS.
