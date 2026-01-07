CLASS lhc_zr_matdistlines DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR matdistlinebrd RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR matdistlinebrd RESULT result.


  ENDCLASS.

CLASS lhc_zr_matdistlines IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

    METHOD get_global_authorizations.
  ENDMETHOD.


ENDCLASS.
*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
