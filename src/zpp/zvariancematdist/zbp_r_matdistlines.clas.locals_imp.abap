CLASS lhc_zr_matdistlines DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_matdistlines RESULT result.

ENDCLASS.

CLASS lhc_zr_matdistlines IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA(lv) = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.

ENDCLASS.
