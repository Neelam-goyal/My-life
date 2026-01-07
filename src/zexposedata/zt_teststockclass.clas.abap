CLASS zt_teststockclass DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZT_TESTSTOCKCLASS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA(del_date) = '20250303'.

  DATA(del_daye) = ''.
  IF del_daye = 'X'.

    DELETE FROM zcurrentstock WHERE inserted_date = @del_date.

  ENDIF.

  ENDMETHOD.
ENDCLASS.
