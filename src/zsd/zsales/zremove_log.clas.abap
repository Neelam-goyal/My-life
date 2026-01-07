CLASS zremove_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: delete_restart_log.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS ZREMOVE_LOG IMPLEMENTATION.


  METHOD delete_restart_log.

*    DATA(lo_restart) = cl_restart_log=>get_instance( ).
*
*    TRY.
*        " Delete the restart log for table ZVEHICLE_TAB
*        lo_restart->delete_log( iv_table = 'ZVEHICLE_TAB' ).
*
*        WRITE: 'Restart log deleted successfully for table ZVEHICLE_TAB'.
*
*      CATCH cx_root INTO DATA(lo_error).
*        WRITE: 'Error deleting restart log:', lo_error->get_text( ).
*    ENDTRY.

UPDATE zdt_rplcrnote set error_log = '' where error_log NE ''.
UPDATE zdt_rplcrnote set  glerror_log = '' where glerror_log NE ''.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  delete_restart_log( ).
  ENDMETHOD.
ENDCLASS.
