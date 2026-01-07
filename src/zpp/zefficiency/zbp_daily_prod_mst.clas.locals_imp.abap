CLASS lhc_zdaily_prod_mst DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zdaily_prod_mst RESULT result.
*    METHODS markasdeleted FOR MODIFY
*      IMPORTING keys FOR ACTION zdaily_prod_mst~markasdeleted RESULT result.

ENDCLASS.

CLASS lhc_zdaily_prod_mst IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

*METHOD markasdeleted.
*
*  DATA ls_zproduction_mst TYPE zproduction_mst.
*
*  LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*    CLEAR ls_zproduction_mst.
*    ls_zproduction_mst-client        = sy-mandt.
*    ls_zproduction_mst-posting_date  = <key>-postingdate.
*    ls_zproduction_mst-work_center   = <key>-workcenter.
*    ls_zproduction_mst-shift         = <key>-shiftdefinition.
*    ls_zproduction_mst-plant         = <key>-plant.
*    ls_zproduction_mst-deleted       = 'X'.
*
*    MODIFY zproduction_mst FROM @ls_zproduction_mst.
*  ENDLOOP.
*ENDMETHOD.


ENDCLASS.
